//
//  BBPopupView.m
//  VankeClub
//
//  Created by iXcoder on 13-7-31.
//  Copyright (c) 2013年 Blue Box. All rights reserved.
//

#import "BBPopupView.h"
#import "BBAppDelegate.h"

static id target = nil;

static UIView *cusView = nil;
@implementation BBPopupView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {

    }
    return self;
}

#pragma mark -
#pragma mark self defined method
/*!
 *@brief        模态展示一个视图
 *@function     showWithView:
 *@param        customView      -- 要展示的视图
 *@return       (void)
 */
+ (void)popupWithView:(UIView *)customView withDelegate:(id<BBPopupDelegate>)delegate animation:(CAAnimation *)animation
{
    if (target != nil) {
        NSLog(@"模态展示一个视图 -- 已有视图");
        return ;
    }
    target = delegate;
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"BBPopupView" owner:nil options:nil];
    BBPopupView *contentView = (BBPopupView *)[nibs objectAtIndex:0];
    cusView = customView;
    
    if (target && [target respondsToSelector:@selector(popupWillShowWithCustomView:)]) {
        [target popupWillShowWithCustomView:cusView];
    }
    BBAppDelegate *app = (BBAppDelegate *)[UIApplication sharedApplication].delegate;
    contentView.frame = CGRectMake(0,0 , app.window.frame.size.width, app.window.frame.size.height+70);
    CGRect rect = CGRectMake(0
                             ,0
                             , cusView.frame.size.width
                             , cusView.frame.size.height);
    cusView.frame = rect;
//    (contentView.frame.size.width - cusView.frame.size.width) / 2
//    (contentView.frame.size.height - cusView.frame.size.height) / 2 - 40
    
    
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"tranform.translate.z"];
    scaleAnimation.duration = 2.0;
    scaleAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:2.0],[NSNumber numberWithFloat:2.0], nil];
    scaleAnimation.keyTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:.5],[NSNumber numberWithFloat:0.3], [NSNumber numberWithFloat:0.5] ,nil];
    [contentView.layer addAnimation:animation forKey:@"scale"];
    [contentView addSubview:cusView];
    
//    if (delegate == nil) {
//    if (animation != nil) {
//        animation.removedOnCompletion = YES;
//        [contentView.layer addAnimation:animation forKey:@"show popup"];
//    }
    [app.window addSubview:contentView];
//    } else {
//        [[(UIViewController *)delegate view] addSubview:contentView];
//    }

    
    if (target && [target respondsToSelector:@selector(popupDidShowWithCustomView:)]) {
        [target popupDidShowWithCustomView:cusView];
    }
    
}

/*!
 *@brief        消失模态视图
 *@function     dismiss
 *@return       (void)
 */
+ (void)dismiss
{
    [UIView beginAnimations:@"dismiss Popup view" context:NULL];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationDidStopSelector:@selector(viewAnimationDidStop:)];
    [cusView.superview setAlpha:0.0];
    [UIView commitAnimations];
    target = nil;
    cusView = nil;
}

/*!
 *@brief        删除黑色半透明位置消失模态视图页面
 *@function     tapHandler:
 *@param        sender
 *@return       (void)
 */
- (IBAction)tapHandler:(id)sender
{
    [BBPopupView dismiss];
}

- (void)viewAnimationDidStop:(id)sender
{
    [cusView.superview removeFromSuperview];
}

@end
