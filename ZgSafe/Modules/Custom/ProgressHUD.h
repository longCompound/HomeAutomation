//
//  ProgressHUD.h
//  aqgj
//
//  Created by chenq on 11-10-25.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MBProgressHUD;

@interface ProgressHUD : NSObject {
    MBProgressHUD *hud;
    CGFloat offsetY;
}

/**
 *  显示弹出框
 *
 *  @param tf     是否显示
 *  @param inView 显示的view
 *  @param info   蒙层信息
 *  @param avoid  是否避开导航栏,让导航栏失效
 */
- (void)showProgressHD:(BOOL)tf inView:(UIView *)inView info:(NSString *)info avoidTopBar:(BOOL)avoid;

- (void)showProgressHD:(BOOL)tf inView:(UIView *)inView info:(NSString *)info;
- (void)showProgressHD:(BOOL)tf inView:(UIView *)inView title:(NSString *)title  detail:(NSString*)detail;
+ (id)instance;
- (void)setOffsetY:(CGFloat)y;
- (void)setTextInfo:(NSString *)text;
- (void)CompletedProgressHD:(NSString*)ltext deta:(NSString *)detaText;
- (void)rootProgressHD:(NSString*)ltext deta:(NSString *)detaText;
- (void)CompletedProgressHD:(NSString*)ltext;
- (void)showProgress:(BOOL)tf inView:(UIView *)inView info:(NSString *)info;
- (void)setHUDTitle:(NSString *)title detail:(NSString *)detail;

// 打钩界面
- (void)changeCompletedProgressHD:(NSString*)ltext;
- (void)changeCompletedProgressHD:(NSString*)ltext inView:(UIView *)view;
- (void)changeCompletedProgressHDWithoutDetail:(NSString*)ltext inView:(UIView *)view;

//显示土司
- (void)showToast:(UIView *)view title:(NSString *)title duration:(CGFloat)duration;
- (void)showToast:(UIView *)view title:(NSString *)title duration:(CGFloat)duration complete:(void (^)())complete;

//显示进度
- (void)CompletedProgressHD:(BOOL)tf inView:(UIView *)inView msg:(NSString *)msg;

- (void)hide;

- (MBProgressHUD *)hud;

- (void)showInstanceToast:(UIView *)view title:(NSString *)title duration:(CGFloat)duration complete:(void (^)())complete;

@end
