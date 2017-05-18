//
//  BBAppDelegate.h
//  ZgSafe
//
//  Created by iXcoder on 13-10-24.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBHomePageController.h"
#import "BBNavigationController.h"
#import "WeiboSDK.h"
#import "tool/QQhulian/TencentOpenAPI.framework/Headers/TencentOAuth.h"

@class BBLoginViewController;
@class BBSideBarView;

typedef NS_ENUM(NSInteger, AuthorizeType) {
    kAuthorizeTypeSina = 0,
    kAuthorizeTypeQQ,
    KAuthorizeTypeWeixin
}; 

@interface BBAppDelegate : UIResponder <UIApplicationDelegate>{
    NSString *_tel;
}


- (void)dialNumber:(NSString *)tel;

@property (strong, nonatomic) TencentOAuth *tencentOAuth;
@property (assign, nonatomic) AuthorizeType at;// 当前类型
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BBNavigationController *navigationController;
@property (strong, nonatomic) BBHomePageController *homePageVC;
@property (nonatomic,assign) BOOL EyesVCShowwing;//当前显示的是云眼
@property (nonatomic,assign) BOOL EyesVCBtn;//是否是云眼页推的
@property (nonatomic,assign) BOOL EyesIsOpen;//是否是云眼页推的
@property (nonatomic,assign) BOOL UserRegister;//是否注册成功
@property (nonatomic,retain)UIView *statusBg; 
@property (nonatomic,assign) NSString *Zgan_DeviceToken;



/*!
 *@brief        采用sso方式授权访问sina微博
 *@function     ssoAuthrize:
 *@param        sender
 *@return       (void)
 */
- (void)sinaSSOAuthrize:(id)sender;

@end
