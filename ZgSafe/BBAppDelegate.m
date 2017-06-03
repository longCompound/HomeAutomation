//
//  BBAppDelegate.m
//  ZgSafe
//
//  Created by iXcoder on 13-10-24.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBAppDelegate.h"
#import "BBInformationView.h"
#import "BBLoginViewController.h"
#import "BBUnlockView.h"
#import "BBAlDetailsViewController.h"
#import "BBshowADcorl.h"
#import "BBHomePageController.h"
#import "WXApi.h"
#import <MediaPlayer/MediaPlayer.h>
#import "BBDataFrame.h"
#import <AudioToolbox/AudioSession.h>
#import "MyCamera.h"


@interface BBAppDelegate()<WeiboSDKDelegate,TencentSessionDelegate,WXApiDelegate,UncaughtExceptionDelegate,BBLoginClientDelegate>
{
    BBshowADcorl *adShower;
    BOOL _alreadyShowWarnAlert;//界面上已经显示了报警的alertView
}

@end

@implementation BBAppDelegate

- (void)dealloc
{
    [_window release];
    [_homePageVC release];
    [adShower release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [application setStatusBarHidden:NO];
    BBLog(@"application launched");
    if (IOS_VERSION >= 7.0f) {
        [application setStatusBarStyle:UIStatusBarStyleLightContent];
    } else {
        [application setStatusBarStyle:UIStatusBarStyleDefault];
    }
    [self initialSettingInfo];
    _EyesVCShowwing = NO;
    _EyesIsOpen=NO;
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    if (IOS_VERSION >= 7.0) {
        _statusBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        _statusBg.backgroundColor = [UIColor blackColor];
        [self.window addSubview:_statusBg];
        [_statusBg release];
    }
    
//    if (ISIP5) {
//        _homePageVC = [[BBHomePageController alloc]initWithNibName:@"BBHomePageController"
//                                                            bundle:nil];
//    } else {
//        _homePageVC = [[BBHomePageController alloc]initWithNibName:@"BBHomePageController_iPhone4"
//                                                            bundle:nil];;
//    }
    
    _rootVC = [[BBRootTabbarController alloc] init];
    _navigationController = [[BBNavigationController alloc] initWithRootViewController:_rootVC];
    [_navigationController setNavigationBarHidden:YES animated:NO];
    self.window.rootViewController = _navigationController;
    
    [BBsigle sigleManager].lNavigation=_navigationController;
    
    if (IOS_VERSION>=7.0) {
        [self.window bringSubviewToFront:_statusBg];
    }
    
    [self.window makeKeyAndVisible];
    
    [BBDispatchManager initStack];
    [BBUncaughtExceptionHandler regHandler:self forSignal:SIGPIPE];
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    [reach startNotifier];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChangeHandler:) name:kReachabilityChangedNotification object:nil];    
    
    return YES;
}

- (void)networkChangeHandler:(id)sender
{
    UtilAlert(@"网络异常", nil);
}



/*!
 *@description  初始化各种设置信息
 *@function     initialSettingInfo
 *@param        (void)
 *@return       (void)
 */
- (void)initialSettingInfo
{
    BlueBoxer *user = curUser;
    if (user.isFirstLogOnDevice) {
        //默认初始设置
        user.safeGestureOpened = NO;
        user.warnPushOpened = YES;
        user.backHomeRemindOpened = YES;
        user.regardRemindOpened = YES;
        user.gestureUnlock = nil;
    }
    user.loged = NO;
    [BlueBoxerManager archiveCurrentUser:user];
}

/*!
 *@brief        上拉或下滑活动页
 *@function     slideADPageToShow:
 *@param        show        -- 展示或隐藏
 *@return       (void)
 */
- (void)slideADPageToShow:(BOOL)show
{
    if (show) {
        [UIView animateWithDuration:0.7
                         animations:^{
                             adShower.frame = CGRectMake(0
                                                         , 0
                                                         , adShower.frame.size.width
                                                         , adShower.frame.size.height);
                         }];
    } else {
        [UIView animateWithDuration:0.7
                         animations:^{
                             adShower.frame = CGRectMake(0
                                                         , -adShower.frame.size.height
                                                         , adShower.frame.size.width
                                                         , adShower.frame.size.height);
                         }];
    }
}

/*!
 *@brief        展示广告视图
 *@function     readyForActivitiesView
 *@param        (void)
 *@return       (void)
 */
- (void)readyForActivitiesView
{
    NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"BBshowADController" owner:self options:nil];
    adShower = [(BBshowADcorl *)[nibs objectAtIndex:0] retain];
    [adShower setFrame:self.window.frame];
    [self.window insertSubview:adShower belowSubview:_statusBg];
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [MyCamera initIOTC];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    application.applicationIconBadgeNumber = 0;
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [MyCamera uninitIOTC];
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification*)notification
{
    //    NSLog(@"-------------%@",[notification.userInfo objectForKey:@"key"]);
    //    if ([[notification.userInfo objectForKey:@"key"] isEqualToString:@"name"]) {
    //    }
    // 图标上的数字减1
    application.applicationIconBadgeNumber -= 1;
}

//获取DeviceToken成功
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString* strToken = [NSString stringWithFormat:@"%@",deviceToken];
    NSString *pushToken = [[[[strToken
                              stringByReplacingOccurrencesOfString:@"<" withString:@""]
                             stringByReplacingOccurrencesOfString:@">" withString:@""]
                            stringByReplacingOccurrencesOfString:@" " withString:@""] retain];
    
    appDelegate.Zgan_DeviceToken=pushToken;
    
    BlueBoxer *user = curUser;
    
    NSString *param = [NSString stringWithFormat:@"%@\t%@",user.userid,pushToken];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [[[BBSocketManager getInstance] loginClient]sendDeviceToken:param delegate:self];
    });
    
    NSLog(@"apns -> 注册推送服务器成功 DeviceToken:[%@]",pushToken);
    //这里进行的操作，是将Device Token发送到服务端
}

//注册消息推送失败
- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"apns -> 注册推送功能时发生错误， 错误信息:[%@]", error);
}

//处理收到的消息推送
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
{        

    
    //NSLog(@"apns -> 接收到推送消息:[%@]", userInfo);
    
    //消息内容
    NSString *strMmessage=[[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"];
    //主功能号
    NSInteger intMainfun=[[[userInfo objectForKey:@"zgsoft"] objectForKey:@"mainfun"] intValue];
    //子功能号
    NSInteger intSubfun=[[[userInfo objectForKey:@"zgsoft"] objectForKey:@"subfun"] intValue];
    //平台ID
    NSInteger intSysid=[[[userInfo objectForKey:@"zgsoft"] objectForKey:@"sysid"] intValue ];
    //版本号
    NSInteger intVersion=[[[userInfo objectForKey:@"zgsoft"] objectForKey:@"version"] intValue];
    
    if (strMmessage==nil) {
        strMmessage=[[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    }
    
    //判断消息类型 平台为家庭卫士的消息
    if(intSysid==7){
        if (intVersion==1
            && intMainfun==13 && intSubfun==1) {
            //收到布防通知
            
            [BBNoticeSender showNotice:strMmessage];
            [self sendLocalNoticeWithTitle:strMmessage];
            [appDelegate.homePageVC toRecevieMsg:@"1"];
        }else if (intVersion==1
                  && intMainfun==13 && intSubfun==2){
            //收到撤防通知
            
            [BBNoticeSender showNotice:strMmessage];
            [self sendLocalNoticeWithTitle:strMmessage];
            [appDelegate.homePageVC toRecevieMsg:@"2"];
        }else if (intVersion==1
                  && intMainfun==13 && intSubfun==3){
            //收到入侵报警通知
           
            [BBNoticeSender showNotice:strMmessage];
            [self sendLocalNoticeWithTitle:strMmessage];
            if (!_alreadyShowWarnAlert && !appDelegate.EyesVCShowwing) {
                [self toShowAlertView:strMmessage];
                _alreadyShowWarnAlert=YES;
            }
            
        }else if (intVersion==1
                  && intMainfun==13 && intSubfun==23){
            //收到归家离家通知
            
            [BBNoticeSender showNotice:strMmessage];
            [self sendLocalNoticeWithTitle:strMmessage];
            [appDelegate.homePageVC toRecevieMsg:@"23"];
        }
    }
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex==0){
        UIApplication *app = [UIApplication sharedApplication];
        
        if (app.applicationIconBadgeNumber>0) {
            app.applicationIconBadgeNumber--;
        }
        
        [[NSNotificationCenter defaultCenter]postNotificationName:BBDidReceiveWarningNotificaiton object:nil];
        _alreadyShowWarnAlert=NO;
    }
}

//弹出报警框
-(void)toShowAlertView:(NSString *)strMsg{
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:NOTICE_TITLE
                               message:strMsg
                              delegate:self
                     cancelButtonTitle:@"查看"
                     otherButtonTitles:nil];

    [alert show];
    [alert release];
}

//本地推送消息
- (void)sendLocalNoticeWithTitle:(NSString *)title
{
    UILocalNotification *notification = [[[UILocalNotification alloc] init] autorelease];
    if (notification != nil) {
        // 设置推送时间
        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        // 设置时区
        //        notification.timeZone = [NSTimeZone defaultTimeZone];
        // 设置重复间隔
        notification.repeatInterval = 0;
        // 推送声音
        notification.soundName = UILocalNotificationDefaultSoundName;
        // 推送内容
        notification.alertBody = title;
        
        //notification.alertAction = @"打开";
        //显示在icon上的红色圈中的数子
        UIApplication *app = [UIApplication sharedApplication];
        notification.applicationIconBadgeNumber = app.applicationIconBadgeNumber+1;
        //设置userinfo 方便在之后需要撤销的时候使用
        //        NSDictionary *info = [NSDictionary dictionaryWithObject:@"name"forKey:@"key"];
        //        notification.userInfo = info;
        //添加推送到UIApplication
        [app scheduleLocalNotification:notification];
        
        AudioServicesPlaySystemSound(1007);//系统的通知声音
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);//震动
    }
}

-(void)sendDeviceTokenReceiveData:(BBDataFrame *)data{
 
}

-(void)sendDeviceTokenErrInfo:(NSString *)errorInfo{
 
}

@end
