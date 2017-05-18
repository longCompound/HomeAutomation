//
//  BlueBoxer.h
//  JiangbeiEPA
//
//  Created by iXcoder on 13-9-6.
//  Copyright (c) 2013年 bulebox. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - 
#pragma mark BlueBoxer define
//||--------------------------------------------||
//||                                            ||
//||                 用户信息                    ||
//||                                            ||
//||--------------------------------------------||
@interface BlueBoxer : NSObject <NSCoding>

// 用户id
@property (nonatomic, retain) NSString *userid;
// 用户编号
@property (nonatomic, retain) NSString *usercode;
// 用户名
@property (nonatomic, retain) NSString *username;
// 是否已登录
@property (nonatomic, assign, getter=isLoged) BOOL loged;
// 相关用户信息
@property (nonatomic, retain) NSDictionary *userInfo;
//解锁手势
@property (nonatomic,retain) NSArray *gestureUnlock;
//首次在设备上登录
@property (nonatomic,assign,getter=isFirstLogOnDevice)BOOL firstLogOnDevice;
@property(nonatomic,assign)BOOL safeGestureOpened;//安全手势开启
@property(nonatomic,assign)BOOL warnPushOpened;//报警信息推送开启
@property(nonatomic,assign)BOOL backHomeRemindOpened;//归家提醒开启
@property(nonatomic,assign)BOOL regardRemindOpened;//布防撤防开启

//用户绑定设备号
@property (nonatomic, retain) NSString *deviceid;

@end

#pragma mark -
#pragma mark BlueBoxerManager define
//||--------------------------------------------||
//||                                            ||
//||                 用户管理                    ||
//||                                            ||
//||--------------------------------------------||
@interface BlueBoxerManager : NSObject

// 储存当前用户信息
+ (void)archiveCurrentUser:(BlueBoxer *)currentUser;
// 获取当前用户信息
+ (BlueBoxer *)getCurrentUser;

@end