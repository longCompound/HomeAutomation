//
//  BBshowADcorl.m
//  ZgSafe
//
//  Created by iXcoder on 13-11-11.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBshowADcorl.h"
#import "BBLoginViewController.h"

@implementation BBshowADcorl

-(void)drawRect:(CGRect)rect
{

    [super drawRect:rect];
    
    [self addimages];
    
    UISwipeGestureRecognizer *swip=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(onSwips)];
    [swip setDirection:UISwipeGestureRecognizerDirectionUp];
    [self addGestureRecognizer:swip];
    [swip release];
}
/*!
 *@brief        在scollview添加图片
 *@function    addimages
 *@param        param1
 *@return       (void)
 */
-(void)addimages
{
    NSArray *array=[[NSArray alloc]initWithObjects:@"ads_1.png",@"ads_2.png",nil];
//    NSArray *array=[[NSArray alloc]initWithObjects:@"btn_yellow.png",@"horizon_bg.png",@"ip4_eyes_orange.png",nil];
    [_scollView setContentSize:CGSizeMake(_scollView.frame.size.width * array.count, _scollView.frame.size.height)];
    [_scollView setPagingEnabled:YES];
    [_scollView setShowsHorizontalScrollIndicator:NO];
    _pageCorl.numberOfPages=[array count];
    _scollView.delegate=self;
    for (int i=0;i<array.count ; i++) {
        NSString *indexarray=(NSString *)[array objectAtIndex:i];
        UIImageView *image=[[UIImageView alloc]init];
        [image setContentMode:UIViewContentModeScaleAspectFill];
        [image setFrame:CGRectMake(_scollView.frame.size.width*i, _scollView.frame.origin.y,_scollView.frame.size.width, _scollView.frame.size.height)];
        [image setImage:[UIImage imageNamed:indexarray]];
        
        [_scollView addSubview:image];
        [image release];
    }
    [array release];

}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [_scollView release];
    [_pageCorl release];
    [super dealloc];
}
/*!
 *@brief        点击进入首页
 *@function     pullButton
 *@param        sender
 *@return       （void）
 */
- (IBAction)pullButton:(UIButton *)sender {
    
    [self onSwips];
    
   
}
/*!
 *@brief        上滑进入首页
 *@function     onSwips
 *@return       （void）
 */
-(void)onSwips
{
    
    [UIView animateWithDuration:0.7
                     animations:^{
                         self.frame = CGRectMake(self.frame.origin.x
                                                 , self.frame.origin.y - self.frame.size.height -60.
                                                 , self.frame.size.width
                                                 , self.frame.size.height);
                     }];
  
}

#pragma mark -
#pragma mark UIScrollViewDelegate method
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGPoint offset=scrollView.contentOffset;
    CGRect bounds=scrollView.frame;
    [_pageCorl setCurrentPage:offset.x / bounds.size.width];
    
}
- (void)pageTurn:(UIPageControl*)sender
{
    CGSize viewSize=_scollView.frame.size;
    CGRect rect=CGRectMake(sender.currentPage*viewSize.width, 0, viewSize.width, viewSize.height);
    [_scollView scrollRectToVisible:rect animated:YES];
    
}


@end
