//
//  ProgressHUD.m
//
//  Created by chenq on 11-10-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "ProgressHUD.h"
#import "MBProgressHUD.h"

@implementation ProgressHUD

- (void)showProgressHD:(BOOL)tf inView:(UIView *)inView info:(NSString *)info
{
    [self showProgressHD:tf inView:inView info:info avoidTopBar:NO];
}

/**
 *  显示弹出框
 *
 *  @param tf     是否显示
 *  @param inView 显示的view
 *  @param info   蒙层信息
 *  @param avoid  是否避开导航栏,让导航栏失效
 */
- (void)showProgressHD:(BOOL)tf inView:(UIView *)inView info:(NSString *)info avoidTopBar:(BOOL)avoid
{
    if (tf == YES) {
        if (hud == nil && inView) {
            hud = [[MBProgressHUD alloc] initWithView:inView];
            //            hud.isFixedFrame = YES;
            hud.yOffset = offsetY;
            hud.detailsLabelFont = [UIFont fontWithName:@"Arial" size:16];
        }
        
        if (avoid) {
            //解决无法相应导航栏按钮事件问题
            CGRect frame = hud.frame;
            if (!frame.origin.y) {
                frame.origin.y += 64;
                frame.size.height -= 64;
                hud.frame = frame;
                hud.yOffset -= 64;
            }
        }
              //如果页面不存在hdd，则加入
        if (![inView.subviews containsObject:hud]) {
            [inView addSubview:hud];
        }
        [inView bringSubviewToFront:hud];
        
        hud.labelText = info;
        [hud show:YES];
    } else {
        if (hud != nil) {
            [hud hide:YES];
            [hud removeFromSuperview];
            hud = nil;
        }
    }
  
}

- (void)hide
{
    if (hud != nil) {
        
        CGRect frame = hud.frame;
        if (frame.origin.y) {
            frame.origin.y -= 64;
            frame.size.height += 64;
            hud.frame = frame;
            hud.yOffset += 64;
        }
        
        [hud hide:YES];
        [hud removeFromSuperview];
        hud = nil;
    }
}

- (void)showProgressHD:(BOOL)tf inView:(UIView *)inView title:(NSString *)title  detail:(NSString*)detail
{
    if (tf == YES) {
        if (hud != nil) {
            [hud removeFromSuperview];
            hud = nil;
        }
        if (hud == nil) {
            hud = [[MBProgressHUD alloc] initWithSelfView:inView];
//            hud.isFixedFrame = YES;

            hud.yOffset = offsetY;
            hud.detailsLabelFont = [UIFont fontWithName:@"Arial" size:16];
            [inView addSubview:hud];
            [inView bringSubviewToFront:hud];
        }
        hud.labelText = title;
        hud.detailsLabelText = detail;
        [hud show:YES];
    } else {
        if (hud != nil) {
            [hud hide:YES];
            [hud removeFromSuperview];
            hud = nil;
        }
    }
}
+ (id)instance
{
    static ProgressHUD *ph;
    if (ph == nil) {
      ph = [[ProgressHUD alloc] init];
    }
    return ph;
}

- (void)setTextInfo:(NSString *)text
{
    hud.detailsLabelText = text;
    
}

- (void)setHUDTitle:(NSString *)title detail:(NSString *)detail
{
    hud.labelText = title;
    hud.detailsLabelText = detail;
}
- (void)setOffsetY:(CGFloat)y
{
    offsetY = y;
}

- (void)showProgress:(BOOL)tf inView:(UIView *)inView info:(NSString *)info
{
    if (tf == YES) {
        if (hud == nil && inView) {
            hud = [[MBProgressHUD alloc] initWithView:inView];
            hud.yOffset = offsetY;
            hud.detailsLabelFont = [UIFont fontWithName:@"Arial" size:16];
            [inView addSubview:hud];
            [inView bringSubviewToFront:hud];
        }
        hud.labelText = info;
        [hud show:YES];
    } else {
        hud.alpha = 0;
    }
}

- (void)CompletedProgressHD:(NSString*)ltext deta:(NSString *)detaText
{
    [hud show:YES];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@".png"]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = ltext;
    hud.detailsLabelText = detaText.length > 0 ? detaText : nil;
    hud.detailsLabelFont = [UIFont fontWithName:@"Arial" size:12];
    hud.labelFont = [UIFont fontWithName:@"Arial" size:16];
}

- (void)rootProgressHD:(NSString*)ltext deta:(NSString *)detaText
{
    [hud show:YES];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@".png"]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = ltext;
    hud.detailsLabelFont = [UIFont fontWithName:@"Arial" size:16];
    hud.labelFont = [UIFont fontWithName:@"Arial" size:16];
    hud.detailsLabelText = detaText.length > 0 ? detaText : nil;
}

- (void)CompletedProgressHD:(NSString*)ltext
{
    [hud show:YES];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@".png"]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = ltext;
}

// 打钩界面
- (void)changeCompletedProgressHD:(NSString*)ltext
{
    [hud show:YES];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TipViewIcon.png"]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = ltext;

}

- (void)changeCompletedProgressHD:(NSString*)ltext inView:(UIView *)view
{
	[hud show:YES];
	hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TipViewIcon.png"]];
	hud.mode = MBProgressHUDModeCustomView;
	hud.labelText = ltext;
	[self performSelector:@selector(closeToast:) withObject:view afterDelay:1.5];
}

- (void)changeCompletedProgressHDWithoutDetail:(NSString*)ltext inView:(UIView *)view
{
    if (hud.isFixedFrame) {
        [hud show:NO];
        [hud removeFromSuperview];
        hud = nil;

        if (view) {
            hud = [[MBProgressHUD alloc] initWithView:view];
            hud.yOffset = offsetY;
            hud.detailsLabelFont = [UIFont fontWithName:@"Arial" size:16];
            [view addSubview:hud];
            [view bringSubviewToFront:hud];
        }
    }
    [hud show:YES];
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TipViewIcon.png"]];
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = ltext;
    hud.detailsLabelText = nil;
}

- (void)CompletedProgressHD:(BOOL)tf inView:(UIView *)inView msg:(NSString *)msg
{
    if (tf == YES) {
        if (hud == nil && inView) {
            hud = [[MBProgressHUD alloc] initWithView:inView];
            hud.yOffset = offsetY;
            [inView addSubview:hud];
        }
        hud.labelText = msg;
        [hud show:NO];
    } else {
        if (hud != nil) {
            [hud hide:YES];
            [hud removeFromSuperview];
            hud = nil;
        }
    }
}

#pragma mark -
#pragma mark -- toast
- (void)showToast:(UIView *)view title:(NSString *)title duration:(CGFloat)duration
{
    [self showProgressHD:YES inView:view info:nil];
    [self CompletedProgressHD:title];
    [self performSelector:@selector(closeToast:) withObject:view afterDelay:duration];
}

- (void)showToast:(UIView *)view title:(NSString *)title duration:(CGFloat)duration complete:(void (^)())complete
{
    [self showProgressHD:YES inView:view info:nil];
    [self CompletedProgressHD:title];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self closeToast:view];
        if (complete) {
            complete();
        }
    });
}

- (void)closeToast:(UIView *)view
{
    [self showProgressHD:NO inView:view info:nil];
}

- (UIView *)getUIView
{
    return hud;
}

- (MBProgressHUD *)hud
{
    return hud;
}

- (void)showInstanceToast:(UIView *)view title:(NSString *)title duration:(CGFloat)duration complete:(void (^)())complete
{
    [self setHUDTitle:title detail:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self closeToast:view];
        if (complete) {
            complete();
        }
    });
}

@end
