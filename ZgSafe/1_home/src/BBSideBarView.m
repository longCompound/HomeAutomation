//
//  BBSideBarView.m
//  ZgSafe
//
//  Created by box on 13-10-29.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

/*!
            用法 
 创建(viewdidload中)：    _siderBar = [BBSideBarView siderBarWithBesideView:self.view];
 移除（delloc中）：    [_siderBar show];
*/

#import "BBSideBarView.h"
#import "BBUnlockView.h"
@interface BBSideBarView()<UIGestureRecognizerDelegate>

//左右滑动的手势
@property (nonatomic,assign) UISwipeGestureRecognizer *leftGesture;
@property (nonatomic,assign) UISwipeGestureRecognizer *rightGesture;

- (IBAction)onClickBtn:(UIButton *)sender;

@end

@implementation BBSideBarView

- (id)initWithFrame:(CGRect)frame
{ 
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    self.besideView = nil;
    return self;
}

- (void)dealloc
{
    [_besideView removeGestureRecognizer:_leftGesture];
    [_besideView removeGestureRecognizer:_rightGesture];
    [super dealloc];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    _besideView = nil;
    
    [self setFrame:CGRectMake(-self.frame.size.width
                              , 20
                              , self.frame.size.width
                              , appDelegate.window.frame.size.height-20)];
    
    
    
    return self;
}

/*!
 *@description      以指定的侧边栏旁边的view初始化侧边栏
 *@function         initWithBesideView:
 *@param            view    --指定的view
 *@return           (id)
 */
+ (id)siderBarWithBesideView:(UIView *)view
{
    BBSideBarView *siderBar = [[[NSBundle mainBundle]loadNibNamed:@"BBSideBarView"
                                               owner:self
                                             options:nil]lastObject];
    [siderBar retain];//此处的retain在remove方法中release
    siderBar.besideView = view;

    BBAppDelegate *delegate = ((BBAppDelegate *)[[UIApplication sharedApplication]delegate]);
    [delegate.window addSubview:siderBar];
    
    //添加弹出侧边栏的手势
    siderBar.leftGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:siderBar action:@selector(hide)];
    siderBar.leftGesture.delegate = siderBar;
    [siderBar.leftGesture setDirection:UISwipeGestureRecognizerDirectionLeft];
    [view addGestureRecognizer:siderBar.leftGesture];
    [siderBar.leftGesture release];
    
    siderBar.rightGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:siderBar action:@selector(show)];
    siderBar.rightGesture.delegate = siderBar;
    [siderBar.rightGesture setDirection:UISwipeGestureRecognizerDirectionRight];
    [view addGestureRecognizer:siderBar.rightGesture];
    [siderBar.rightGesture release];
    
    
    [view.layer setShadowColor:[UIColor grayColor].CGColor];
    [view.layer setShadowOffset:CGSizeMake(0., 0.)];
    [view.layer setShadowOpacity:1.0];

    return siderBar;
}


/*!
 *@description      显示侧边栏
 *@function         show
 *@param            (void)
 *@return           (void)
 */
- (void)show
{
    //已经显示了就返回
    if (self.center.x > 0 || !_besideView) {
        return;
    }
 
    [UIView animateWithDuration:0.25f animations:^{
        
        [_besideView setCenter:CGPointMake(_besideView.center.x+self.frame.size.width
                                    , _besideView.center.y)];
        
        [self setCenter:CGPointMake(self.center.x+self.frame.size.width
                                    , self.center.y)];
    }];
    
}




/*!
 *@description      隐藏侧边栏
 *@function         hide
 *@param            (void)
 *@return           (void)
 */
- (void)hide
{
    if (!_besideView || self.center.x<0) {
        return;
    }
    
    [UIView animateWithDuration:0.25f animations:^{
        
        [_besideView setCenter:CGPointMake(_besideView.center.x-self.frame.size.width
                                    , _besideView.center.y)];
        
        [self setCenter:CGPointMake(self.center.x-self.frame.size.width
                                    , self.center.y)];
    }completion:^(BOOL finished) {
    }];
}


/*!
 *@description      移除侧边栏
 *@function         remove
 *@param            (void)
 *@return           (void)
 */
- (void)remove
{
    if (_besideView && self.center.x>0) {
        [self hide];
    }
    double delayInSeconds = 0.25;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        _besideView = nil;
        [self removeFromSuperview];
        [self release];
    });
}


/*!
 *@description      响应点击侧边栏按钮事件
 *@function         onClickBtn:
 *@param            sender  --按钮
 *@return           (void)
 */
- (IBAction)onClickBtn:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectedButtonAtIndex:)]) {
        [_delegate didSelectedButtonAtIndex:sender.tag%10];
    }
}



#pragma mark -
#pragma mark - UIGestureRecognizerDelegate method
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[BBUnlockView class]]
        || [touch.view isKindOfClass:[UIImageView class]]) {
        return NO;
    }
    return YES;
}



@end
