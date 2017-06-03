//
//  Defines.h
//  JiangbeiEPA
//
//  Created by YANGReal on 13-9-4.
//  Copyright (c) 2013年 bulebox. All rights reserved.
//

#ifndef JiangbeiEPA_Defines_h
#define JiangbeiEPA_Defines_h

#import <Foundation/Foundation.h>

#ifdef DEBUG
#   define BBLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#   define ELog(err) {if(err) NSLog(@"%@", err)}
#else
#   define BBLog(...)
#endif

#define BB_SAFE_RELEASE(obj) {\
    [obj release];\
    obj = nil;\
}

#ifndef NOTICE_TITLE
#define NOTICE_TITLE @"柚保消息提醒"
#endif

#define UtilAlert(title, msg) { \
    UIAlertView *dialAlert = [[UIAlertView alloc] initWithTitle:NOTICE_TITLE \
                                                        message:title \
                                                       delegate:nil \
                                              cancelButtonTitle:@"确定" \
                                            otherButtonTitles:nil]; \
[dialAlert show]; \
}

#define ISIP5 ([UIScreen mainScreen].bounds.size.height == 568 ? YES : NO)

#define NETWORK_TIMEOUT 30      //网络超时时限



#define BBUUID       @"BlueBox_Universal_Unique_Identifier"
#define BBExtFile    @"BlueBox_Extend_Info.plist"

#ifndef BBUserDidLogonNotificaiton
#define BBUserDidLogonNotificaiton      @"BBUserDidLogonNotificaiton"
#endif

//报警通知
#ifndef BBDidReceiveWarningNotificaiton
#define BBDidReceiveWarningNotificaiton      @"BBDidReceiveWarningNotificaiton"
#endif

// 定义用户信息存储key
#ifndef USER_KEY
#define USER_KEY        @"BlueBoxer"
#endif

//#ifndef SERVER_PATH
//#define SERVER_PATH     @"http://cloudlogin1.zgantech.com:8820"
//#endif

#ifndef IOS_VERSION
#define IOS_VERSION     [[[UIDevice currentDevice] systemVersion]floatValue]
#endif

#ifndef appDelegate
#define appDelegate ((BBAppDelegate *)[[UIApplication sharedApplication]delegate])
#endif

#ifndef curUser
#define curUser ([BlueBoxerManager getCurrentUser])
#endif



/**
 *  百度地图Key
 */
#define kBaiduMapKey        @"10CE79CE9C7CD89F487F9D86FD6C88BDBBF803B8"

#ifndef place_mark
#define place_mark          @"__placeMark__"
#endif

#ifndef P_WEATHER_PATH
#define P_WEATHER_PATH(areacode)     [NSString stringWithFormat:@"http://www.weather.com.cn/data/sk/%@.html", areacode]
#endif

#ifndef WEATHER_INFO_PATH
#define WEATHER_INFO_PATH(areacode)   [NSString stringWithFormat:@"http://m.weather.com.cn/data/%@.html", areacode]
#endif

/*!
 *  今天已经获得了积分的key
 */
#define HAVE_GET_SCORE_KEY @"HAVE_GET_SCORE_KEY"

/*!
 *  安全手势、报警提醒等设置开启标识的存取key
 */
#define SAFE_GESTURE_OPEN_KEY       @"SAFE_GESTURE_OPEN_KEY"
#define SAFE_GESTURE_SETTED_KEY       @"SAFE_GESTURE_SETTED_KEY"
#define WARN_PUSH_OPEN_KEY          @"WARN_PUSH_OPEN_KEY"
#define BACK_HOME_REMIND_OPEN_KEY   @"BACK_HOME_REMIND_OPEN_KEY"
#define REGARD_REMIND_OPEN_KEY      @"REGARD_REMIND_OPEN_KEY"
#define TAKE_PHOTO_SETTING_KEY      @"TAKE_PHOTO_SETTING_KEY"

#pragma mark -
#pragma mark QQ互联分享相关资料
/*!
 *  授权
 */
#define kQQAppKey                   @"100551593"
#define kQQAppSecret                @"5ac1877cba3cb93946c4f95e7808aaa4"
#define kQQRedirectURI              @"http://www.hiibox.com"
/*!
 *  储存
 */

#define EPA_QQ_INFO                 @"zg_qq_info"
#define QQ_ID_KEY                   @"zg_qq_user_id"
#define QQ_APP_ID                   @"zg_qq_app_id"
#define QQ_TOKEN_KEY                @"zg_qq_access_token"
#define QQ_EXPIRE_KEY               @"zg_qq_expire_date"

#pragma mark -
#pragma mark sina微博分享相关资料
/*!
 *  授权
 */
#define kSinaAppKey                 @"2714247321"
#define kSinaAppSecret              @"f29008c06a9f7c465e0178d1bbf80f23"
#define kSinaAppRedirectURI         @"http://www.zgantech.com"
/*!
 *  储存
 */
#define EPA_SINA_INFO               @"zg_sina_info"
#define SN_ID_KEY                   @"zg_sina_user_id"
#define SN_TOKEN_KEY                @"zg_sina_access_token"
#define SN_EXPIRE_KEY               @"zg_sina_expire_date"



#define WeiXinAppKey                @"wx96268a9e78471910"
#define WeiXinUrl                   @"https://itunes.apple.com/cn/app/wei-xin/id414478124?mt=8"


#endif
