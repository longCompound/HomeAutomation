//
//  BBFullImageView.m
//  VankeClub
//
//  Created by box on 13-10-26.
//  Copyright (c) 2013年 Blue Box. All rights reserved.
//

/*!
使用说明：不需要使用的时候，removeFromSuperView，别release
*/

#import "BBFullImageView.h"

#define FILE_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

@interface BBFullImageView()<UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    UILabel *_countLable;
}

@end

@implementation BBFullImageView

- (void)dealloc
{
    [super dealloc];
}


- (id)initWithFrame:(CGRect)frame
{
    BBAppDelegate *deleagte = (BBAppDelegate *)[[UIApplication sharedApplication]delegate];
    frame = deleagte.window.frame;
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _curIndex = 0;
        _openSaveImage = NO;
        
        _scrollView = [[UIScrollView alloc]initWithFrame:frame];
        [self addSubview:_scrollView];
        [_scrollView release];
        [_scrollView setPagingEnabled:YES];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        _scrollView.delegate = self;
        
        
        
        [self setBackgroundColor:[UIColor blackColor]];
        
        _countLable = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width-60
                                                               , 0
                                                               , 60
                                                               , 40)];
        [self addSubview:_countLable];
        [_countLable setBackgroundColor:[UIColor clearColor]];
        [_countLable setTextColor:[UIColor whiteColor]];
        
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-40, self.frame.size.width, 40)];
        [bgView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
        [bgView addSubview:_countLable];
        [self addSubview:bgView];
        
        [bgView release];
        [_countLable release]; 
        
        
        if (_openSaveImage) {
            UIButton *saveImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [saveImageBtn setFrame:CGRectMake(130, 4, 80, 32)];
            [saveImageBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [saveImageBtn setTitle:@"保存图片" forState:UIControlStateNormal];
            [saveImageBtn addTarget:self action:@selector(onSaveImage:) forControlEvents:UIControlEventTouchUpInside];
            [saveImageBtn setBackgroundColor:[UIColor clearColor]];
            [saveImageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [saveImageBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
            saveImageBtn.layer.borderColor = [UIColor whiteColor].CGColor;
            saveImageBtn.layer.borderWidth = 1.0f;
            saveImageBtn.layer.cornerRadius = 5;
            saveImageBtn.clipsToBounds = YES;
            [bgView addSubview:saveImageBtn];
        }
        
        
    }
    return self;
}

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    for (UIGestureRecognizer *gesture in self.gestureRecognizers) {
        [self removeGestureRecognizer:gesture];
    }
    [super addGestureRecognizer:gestureRecognizer];
}

/*!
 *@description      重新从url导入图片
 *@function         loadImagesFromUrls:
 *@param            urlArr  --需要加载图片的url
 *@return           (void)
 */
- (void)loadImagesFromUrls:(NSArray *)urlArr
{
    [urlArr retain];
    
    _imageCount = urlArr.count;
    
    for (UIView *view in _scrollView.subviews) {
        [view removeFromSuperview];
    }
    for (int i = 0; i<urlArr.count; i++) {
        
        UIScrollView *secondScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(_scrollView.frame.size.width*i
                                                                                   , 0
                                                                                   , _scrollView.frame.size.width
                                                                                   , _scrollView.frame.size.height)];
        secondScroll.tag = 11100+i;
        secondScroll.minimumZoomScale = 1.0f;
        secondScroll.maximumZoomScale = 2.;
        secondScroll.delegate = self;
        
        UIImageView *newImageView = [[UIImageView alloc]
                                     initWithFrame:_scrollView.frame];
        
        [newImageView setImageWithURL:urlArr[i]];
        newImageView.contentMode = UIViewContentModeScaleAspectFit;
        newImageView.userInteractionEnabled = YES;
        newImageView.tag = secondScroll.tag+1;
        [secondScroll addSubview:newImageView];
        [_scrollView addSubview:secondScroll];
        [newImageView release];
        [secondScroll release];
    }
    
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width*urlArr.count
                                         , _scrollView.frame.size.height);
    [urlArr release];
    
    _scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width*_curIndex, 0.);
    NSString *str = [NSString stringWithFormat:@"%d/%d",_curIndex+1,_imageCount];
    _countLable.text = str;
    
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                         action:@selector(removeFullImageView)];
    [tap setDelegate:self];
    [self addGestureRecognizer:tap];
    [tap release];
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    CATransition *anim = [CATransition animation];
    anim.type = kCATransitionMoveIn;
    anim.subtype = kCATransitionFromLeft;
    anim.duration = 0.25f;
    [self.layer addAnimation:anim forKey:nil];
    
    [self superview].userInteractionEnabled = NO;
    [[self superview] performSelector:@selector(setUserInteractionEnabled:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.25];
}

/*!
 *@description      移除视图
 *@function         removeFullImageView
 *@param            (void)
 *@return           (void)
 */
- (void)removeFullImageView
{
    self.hidden = YES;
    
    CATransition *anim = [CATransition animation];
    anim.type = kCATransitionPush;
    anim.subtype = kCATransitionFromRight;
    anim.duration = 0.5f;
    [self.layer addAnimation:anim forKey:nil];
    
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.5f];
    
    
    
//    CGFloat k = 0.5f;
//    CGRect frame = self.scrollView.frame;
//    [UIView animateWithDuration:0.25f animations:^{
//        [self.scrollView setFrame:CGRectMake(self.frame.size.width*(0.5-k/2.),
//                                             self.scrollView.frame.origin.y*(2.0-k),
//                                             self.scrollView.frame.size.width*k,
//                                             self.scrollView.frame.size.height*k)];
////        self.scrollView.alpha = 0.;
////        self.alpha = 0.;
//    } completion:^(BOOL finished) {
////        self.hidden = YES;
////        self.scrollView.frame = frame;
////        self.scrollView.alpha = 1.;
////        self.alpha = 1.;
//        [self removeFromSuperview];
//    }];
}


//#pragma mark -
//#pragma mark 保存图片到相册
///*!
// *@description  保存图片完成回调方法
// *@function     image:didFinishSavingWithError:contextInfo:
// *@param        image           --需要保存的图片
// *@param        error           --错误信息
// *@param        contextInfo     --上下文信息
// *@return       (void)
// */
//- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error
//   contextInfo:(void *)contextInfo
//{
//    if (error) {
//        UtilAlert(@"图片保存失败", [error description]);
//    }else{
//        UtilAlert(@"提示", @"图片已保存到相册");
//    }
//}



/*!
 *@description  响应保存图片
 *@function     onSaveImage
 *@param        sender    --保存图片按钮
 *@return       (void)
 */
- (void)onSaveImage:(UIButton *)sender
{
    
    UIImageWriteToSavedPhotosAlbum(_visibleImageView.image
                                   , self
                                   , @selector(image:didFinishSavingWithError:contextInfo:)
                                   , nil);
}


#pragma mark - 
#pragma mark UIScrollViewDelegate method
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _curIndex = (NSInteger)(_scrollView.contentOffset.x / _scrollView.frame.size.width);
    NSString *newStr = [NSString stringWithFormat:@"%d/%d",_curIndex+1,_imageCount];
    if (![newStr isEqualToString:_countLable.text]) {
        
        [_countLable setText:newStr];
        if (_visibleImageView) {
            //还原上一个图
            UIScrollView *secondScroll = (UIScrollView *)[_visibleImageView superview];
            [UIView animateWithDuration:1.0f animations:^{
                [secondScroll setZoomScale:1.0f];
            }];
            [secondScroll setContentSize:CGSizeMake(_scrollView.frame.size.width
                                                    , _scrollView.frame.size.height)];
        }
        _visibleImageView = (UIImageView *)[_scrollView viewWithTag:11100+_curIndex+1];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (scrollView != _scrollView) {
        UIView *zoomView = [scrollView viewWithTag:scrollView.tag+1];
        return zoomView;
    }
    return nil;
}

#pragma mark -
#pragma mark - UIGestureRecognizerDelegate method
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}



#pragma mark -
#pragma mark 数据源来自scrollView的方法 建议不用这些方法

- (id)initWithTarget:(UIScrollView *)aScrollView
{
    if (self = [super init]) {
        
        _target = aScrollView;
        
        //给原scroll上的imageview加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                             action:@selector(showWithGuesture:)];
        [aScrollView addGestureRecognizer:tap];
        [tap release];
        
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                         action:@selector(removeFullImageView)];
    [tap setDelegate:self];
    [self addGestureRecognizer:tap];
    [tap release];
    
    self.hidden = YES;
    BBAppDelegate *deleagte = (BBAppDelegate *)[[UIApplication sharedApplication]delegate];
    [deleagte.window addSubview:self];
    [self release];
    
    return self;
}



/*!
 *@description      重新导入图片
 *@function         reloadImagesFromTargetScroll
 *@param            (void)
 *@return           (void)
 */
- (void)reloadImagesFromTargetScroll
{
    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        for (UIView *view in _scrollView.subviews) {
            [view removeFromSuperview];
        }
        for (int i = 0; i<_target.subviews.count; i++) {
            
            UIImageView *sourceImageView = (UIImageView *)_target.subviews[i];
            
            if ([sourceImageView isKindOfClass:[UIImageView class]]) {
                
                UIImageView *newImageView = [[UIImageView alloc]
                                             initWithFrame:CGRectMake(_scrollView.frame.size.width*i
                                                                      , 0
                                                                      , _scrollView.frame.size.width
                                                                      , _scrollView.frame.size.height)];
                
                sourceImageView.userInteractionEnabled = YES;
                
                if (sourceImageView.image) {
                    newImageView.image = sourceImageView.image;
                }
                newImageView.contentMode = UIViewContentModeScaleAspectFit;
                newImageView.userInteractionEnabled = YES;
                newImageView.tag = 11100+i;
                [_scrollView addSubview:newImageView];
                [newImageView release];
            }
        }
        
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width*_target.subviews.count
                                             , _scrollView.frame.size.height);
        
    });
}



/*!
 *@description  显示全屏图片
 *@function     showWithGuesture
 *@param        guesture    --手势
 *@return       (void)
 */
- (void)showWithGuesture:(UITapGestureRecognizer *)guesture
{
    
    int location = 0;
    //点击图片的位置
    location = (NSInteger)(_target.contentOffset.x/_target.frame.size.width);
    [_countLable setText:[NSString stringWithFormat:@"%d/%d",location+1,_imageCount]];
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width*location
                                              , 0)];
    self.hidden = NO;
    
    
    UIView *sencondScrollView = [_scrollView viewWithTag:11100+location];
    _visibleImageView = (UIImageView *)[sencondScrollView viewWithTag:sencondScrollView.tag+1];
    
    CGFloat k = 0.5f;
    CGRect frame = _scrollView.frame;
    _scrollView.alpha = 0.;
    self.alpha = 0.;
    [_scrollView setFrame:CGRectMake(self.frame.size.width*(0.5-k/2.),
                                     _scrollView.frame.origin.y*(2.0-k),
                                     _scrollView.frame.size.width*k,
                                     _scrollView.frame.size.height*k)];
    
    [UIView animateWithDuration:0.25f animations:^{
        _scrollView.frame = frame;
        _scrollView.alpha = 1.;
        self.alpha = 1.;
    }];
}



@end
