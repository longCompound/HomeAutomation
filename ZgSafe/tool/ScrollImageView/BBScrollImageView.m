//
//  BBScrollImageView.m
//  ImageScrollView
//
//  Created by box on 13-12-17.
//  Copyright (c) 2013年 box. All rights reserved.
//
/*!示例代码
 
 
 NSArray *iamgeArr = @[
 @"http://img1.zgantech.com/2013/12/17/3_19_1080-664788385.jpg",
 @"http://e.hiphotos.baidu.com/image/w%3D2048/sign=f23406698694a4c20a23e02b3acc1ad5/aa64034f78f0f7368b7fab670b55b319eac413d6.jpg",
 //                          @"http://a.hiphotos.baidu.com/image/w%3D2048/sign=0ef89c67cf1b9d168ac79d61c7e6b58f/a71ea8d3fd1f4134ef340bc6241f95cad1c85e02.jpg",
 //                          @"http://img1.zgantech.com/2013/12/17/3_19_1080-664004589.jpg",
 //                          @"http://img1.zgantech.com/2013/12/17/3_19_1080-663963686.jpg",
 //                          @"http://img1.zgantech.com/2013/12/17/3_19_1080-663912143.jpg",
 //                          @"http://img1.zgantech.com/2013/12/17/3_19_1080-663768778.jpg",
 //                          @"http://img1.zgantech.com/2013/12/17/3_19_1380-661719112.jpg",
 @"http://img1.zgantech.com/2013/12/17/3_19_1380-661481351.jpg",
 @"http://img1.zgantech.com/2013/12/17/3_19_1380-661462959.jpg"];
 NSMutableArray *urls = [[NSMutableArray alloc]init];
 for (NSString *str in iamgeArr) {
 [urls addObject:[NSURL URLWithString:str]];
 }
 
 
 
 _scrollImageView = [[[[NSBundle mainBundle]loadNibNamed:@"BBScrollImageView" owner:self options:nil]lastObject]retain];
 _scrollImageView.delegate = self;
 _scrollImageView.autoPlay = YES;
 _scrollImageView.showFullImageWhenClick = NO;
 [_scrollImageView loadWithUrls:urls];
 _scrollImageView.pageControlLimit = 100;
 [urls release];
 */
//#import "SDImageCache.h"
#import "BBScrollImageView.h"
#import "UIImageView+WebCache.h"
#import "BBFullImageView.h"

#define nexturlIndex (_urls.count==_urlIndex+1?0:_urlIndex+1)
#define lasturlIndex (0==_urlIndex?_urls.count-1:_urlIndex-1)

#define nextImageViewIndex (_imageViewArr.count==imageViewIndex+1?0:imageViewIndex+1)
#define lastImageViewIndex (0==imageViewIndex?_imageViewArr.count-1:imageViewIndex-1)

#define curCenter CGPointMake(self.center.x, self.center.y-self.frame.origin.y)
#define nextCenter CGPointMake(self.center.x+self.frame.size.width, self.center.y-self.frame.origin.y)
#define lastCenter CGPointMake(self.center.x-self.frame.size.width, self.center.y-self.frame.origin.y)


@interface BBScrollImageView()<UIImageViewWebCacheDelegate>
{
    NSInteger imageViewIndex;//当前显示imageView的索引
    NSTimer *_timer;
    BBFullImageView *_fullImageView;
    NSArray *_imageArr;
}

@property (retain, nonatomic) IBOutlet UILabel *numberLbl;
@property (retain, nonatomic) NSArray *imageViewArr;
@property (retain, nonatomic) IBOutletCollection(UIView) NSArray *indicatorViews;
@property (retain,nonatomic)NSArray *urls;


@end


@implementation BBScrollImageView

- (void)dealloc {
    [_urls release];
    [_imageViewArr release]; 
    [_numberLbl release];
    [_indicatorViews release];
    [_pageControl release];
    [super dealloc];
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _autoPlay = NO;
        _showFullImageWhenClick = NO;
        _showIndicator = YES;
        _autoPlayDuration = 3.0f;
        _animateDuration = 0.6f;
        _pageControlLimit = 5;
        _timer = nil;
        _urls = [[NSArray alloc]init];
        _imageViewArr = [[NSArray alloc]initWithObjects:[self viewWithTag:1000],[self viewWithTag:1001], nil];
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initSettings];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
//    [[SDImageCache sharedImageCache]clearDisk];
//    [[SDImageCache sharedImageCache]cleanDisk];
}

/*!
 *@description  初始化各种设置
 *@function     initSettings
 *@param        (void)
 *@return       (void)
 */
- (void)initSettings
{
    _pageControl = [[BBPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height-20, self.frame.size.width, 10)];
    _pageControl.numberOfPages = 0;
    _pageControl.currentPage = 0;
    _pageControl.selectedColor = [UIColor orangeColor];
    _pageControl.otherColor = [UIColor whiteColor];
    _pageControl.alignment = kBBIndicatorAlignmentRight;
    _pageControl.hidden = YES;
    //    _pageControl.delegate = self;
    _pageControl.backgroundColor = [UIColor clearColor];
    _pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self addSubview:_pageControl];
    
    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(onSkipToNextImage:)];
    left.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:left];
    [left release];
    
    
    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(onSkipToLastImage:)];
    right.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:right];
    [right release];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onSelectImageView:)];
    [self addGestureRecognizer:tap];
    [tap release];
    
    
    
    
    for (UIImageView *imgView in _imageViewArr) {
        imgView.delegateCache = self;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}
/*!
 *@description  载入url
 *@function     loadWithUrls
 *@param        urlArr  --url数组
 *@return       (void)
 */
- (void)loadWithUrls:(NSArray *)urlArr aryImg:(NSArray *)aryImg
{
    [_urls release];
    _urls = [[NSArray alloc]initWithArray:urlArr];
    _imageArr=aryImg;
    _urlIndex = 0;
    imageViewIndex = 0;
    
    for (UIImageView *imgView in _imageViewArr) {
        [[SDWebImageManager sharedManager]cancelForDelegate:imgView];
        if (imgView.tag==1000) {
            imgView.superview.center = curCenter;
            _visibleImageView = imgView;
        }else{
            imgView.superview.center = nextCenter;
        }
    }
    
    
    if (_showIndicator) {
        if (_urls.count > _pageControlLimit) {
            _pageControl.hidden = YES;
            //_numberLbl.hidden = NO;
            _numberLbl.text = [NSString stringWithFormat:@"1/%d",_urls.count];
        }else{
            _pageControl.hidden = NO;
           // _numberLbl.hidden = YES;
            _pageControl.numberOfPages = _urls.count;
            _pageControl.currentPage = 0;
        }
        
        
    }else{
        _pageControl.hidden = YES;
        //_numberLbl.hidden = YES;
        
         _numberLbl.text=@"";
    }
    
    
    UIImageView *imageView = (UIImageView *)_imageViewArr[0];
    UIView *indicatorView = [imageView.superview viewWithTag:imageView.tag+100];
    indicatorView.alpha = 0.8f;
    if (_urls.count) {
        [imageView setImageWithURL:_urls[0]];
    }else{
        imageView.image = nil;
        [self imageView:imageView didSetWithImage:nil];
    }
    
    if (_autoPlay && _urls.count>1) {
        if (_timer) {
            [_timer invalidate];
        }
        _timer = [NSTimer scheduledTimerWithTimeInterval:_autoPlayDuration target:self selector:@selector(onAutoPlay:) userInfo:nil repeats:YES];
    }
    
    [self setTimeText];
   
}


/*!
 *@description  跳到下一张图片
 *@function     onSkipToNextImage:
 *@param        gesture     --手势
 *@return       (void)
 */
- (void)onSkipToNextImage:(UISwipeGestureRecognizer *)gesture
{
    if (_urls.count < 2) {
        return;
    }
    
    UIImageView *imageView = (UIImageView *)_imageViewArr[imageViewIndex];
    
    imageViewIndex = nextImageViewIndex;
    
    _urlIndex = (_urls.count==_urlIndex+1?0:_urlIndex+1);
    UIImageView *nextImageView = (UIImageView *)_imageViewArr[imageViewIndex];
    UIView *indicatorView = [nextImageView.superview viewWithTag:nextImageView.tag+100];
    indicatorView.alpha = 0.8f;
//    self.userInteractionEnabled = NO;
    [nextImageView setImageWithURL:_urls[_urlIndex]];
     
    nextImageView.superview.center = nextCenter;
    
    [self setTimeText];
    //_numberLbl.text = [NSString stringWithFormat:@"%d/%d",_urlIndex+1,_urls.count];
    _pageControl.currentPage = _urlIndex;
    
    if (gesture && _autoPlay) {
        [_timer invalidate];
        _timer = [NSTimer scheduledTimerWithTimeInterval:_autoPlayDuration target:self selector:@selector(onAutoPlay:) userInfo:nil repeats:YES];
    }
    [UIView animateWithDuration:_animateDuration animations:^{
        nextImageView.superview.center = curCenter;
        imageView.superview.center = lastCenter;
    } completion:^(BOOL finished) {
        _visibleImageView = nextImageView;
        [[SDWebImageManager sharedManager]cancelForDelegate:imageView];
    }];
}

/*!
 *@description  给外部调用的跳到下一张图
 *@function     skipToNextImage
 *@param        (void)
 *@return       (BOOL)  --跳转成功与否 不成功代表已经是最后一张了
 */
- (BOOL)skipToNextImage
{
    if (_urlIndex == _urls.count-1) {
        return NO;
    }
    
    [self onSkipToNextImage:nil];
    return YES;
}

-(void)setTimeText{
    
    if(_imageArr!=nil && _imageArr.count>0){
        NSString *strTime=[_imageArr[_urlIndex] valueForKey:@"IMAGES_TIME_KEY"];
        
        _numberLbl.text=strTime;
    }
    

}

/*!
 *@description  跳到上一张图片
 *@function     onSkipToLastImage:
 *@param        gesture     --手势
 *@return       (void)
 */
- (void)onSkipToLastImage:(UISwipeGestureRecognizer *)gesture
{
    if (_urls.count < 2) {
        return;
    }
    
    UIImageView *imageView = (UIImageView *)_imageViewArr[imageViewIndex];
    
    imageViewIndex = lastImageViewIndex;
    _urlIndex = lasturlIndex;
    UIImageView *lastImageView = (UIImageView *)_imageViewArr[imageViewIndex];
    UIView *indicatorView = [lastImageView.superview viewWithTag:lastImageView.tag+100];
    
    indicatorView.alpha = 0.8f;
//    self.userInteractionEnabled = NO;
    [lastImageView setImageWithURL:_urls[_urlIndex]];
    
    lastImageView.superview.center = lastCenter;
    
    [self setTimeText];
    //_numberLbl.text = [NSString stringWithFormat:@"%d/%d",_urlIndex+1,_urls.count];
    _pageControl.currentPage = _urlIndex;
    
    
    if (gesture && _autoPlay) {
        [_timer invalidate];
        _timer = [NSTimer scheduledTimerWithTimeInterval:_autoPlayDuration target:self selector:@selector(onAutoPlay:) userInfo:nil repeats:YES];
    }
    [UIView animateWithDuration:_animateDuration animations:^{
        lastImageView.superview.center = curCenter;
        imageView.superview.center = nextCenter;
    } completion:^(BOOL finished) {
        _visibleImageView = lastImageView;
        [[SDWebImageManager sharedManager]cancelForDelegate:imageView];
    }];
}

/*!
 *@description  给外部调用的跳到上一张图
 *@function     skipToNextImage
 *@param        (void)
 *@return       (BOOL)  --跳转成功与否 不成功代表已经是第一张了
 */
- (BOOL)skipToLastImage
{
    if (_urlIndex == 0) {
        return NO;
    }
    
    [self onSkipToLastImage:nil];
    return YES;
}

/*!
 *@description  响应点击图片
 *@function     onSelectImageView:
 *@param        gesture     --手势
 *@return       (void)
 */
- (void)onSelectImageView:(UITapGestureRecognizer *)gesture
{
    if (_showFullImageWhenClick) {
        _fullImageView = [[BBFullImageView alloc]init];
        _fullImageView.curIndex = _urlIndex;
        [_fullImageView loadImagesFromUrls:_urls];
        UIWindow *window = [[[UIApplication sharedApplication]delegate]window];
        _fullImageView.frame = window.bounds;
        [window addSubview:_fullImageView];
        [_fullImageView release];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(scrollImageView:didSeletedImageView:atIndex:)]) {
        
        [_delegate scrollImageView:self didSeletedImageView:_imageViewArr[imageViewIndex] atIndex:_urlIndex];
    }
}

/*!
 *@description  自动播放
 *@function     onAutoPlay
 *@param        (void)
 *@return       (void)
 */
- (void)onAutoPlay:(NSTimer *)timer
{
    [self onSkipToNextImage:nil];
}


#pragma mark -
#pragma mark UIImageViewWebCacheDelegate method
- (void)imageView:(UIImageView *)imageView didSetWithImage:(UIImage *)image
{
    UIView *indicatorView = [imageView.superview viewWithTag:imageView.tag+100];
    [UIView animateWithDuration:1.0f animations:^{
        indicatorView.alpha = 0.0f;
    }completion:^(BOOL finished) {
//        self.userInteractionEnabled = YES;
//        indicatorView.hidden = YES;
    }];
}

@end
