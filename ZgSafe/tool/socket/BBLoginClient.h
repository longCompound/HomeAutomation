//
//  BBLoginClient.h
//  SocketTrial
//
//  Created by iXcoder on 13-12-4.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBSocketClient.h"

@protocol BBLoginClientDelegate;
/*!
 *  登陆服务器socket
 *  主命令关键字:0x01
 *
 */
@interface BBLoginClient : BBSocketClient
{
    
}
@property(nonatomic,retain) NSString* username;
@property(nonatomic,retain) NSString* password;

@property(nonatomic,retain) BBDataFrame* hostInfoFrame;

-(id)initWith:(NSString*)user password:(NSString*)pwd;
// 登陆
-(void)logWithDelegate:(id<BBLoginClientDelegate>)delegate;
//获取服务器地址
- (void)getServerList:(NSString *)userID deleagte:(id<BBLoginClientDelegate>)delegate;
// 注册新用户
- (int)registerANewUser:(NSString *)newUserInfo delegate:(id<BBLoginClientDelegate>)delegate;
// 绑定终端
- (int)bindTerminal:(NSString *)deviceInfo delegate:(id<BBLoginClientDelegate>)delegate;
// 注销
- (int)logout:(NSString *)param delegate:(id<BBLoginClientDelegate>)delegate;
// 获取短信验证码
- (int)getMSGVerifyCode:(NSString *)param delegate:(id<BBLoginClientDelegate>)delegate;
//重置密码
- (int)resetPassWord:(NSString *)param delegate:(id<BBLoginClientDelegate>)delegate;
//发送DeviceToken
-(int)sendDeviceToken:(NSString *)param delegate:(id<BBLoginClientDelegate>)delegate;

@end

@protocol BBLoginClientDelegate <NSObject>

@optional
- (void)loginReceiveData:(BBDataFrame *)data;
- (void)loginFailedWithErrorInfo:(NSString *)errorInfo;

- (void)getServerListData:(BBDataFrame *)data;
- (void)getServerListErrorInfo:(NSString *)errorInfo;

- (void)bindReceiveData:(BBDataFrame *)data;
- (void)bindFailedWithErrorInfo:(NSString *)errorInfo;

- (void)registReceiveData:(BBDataFrame *)data;
- (void)registFailedWithErrorInfo:(NSString *)errorInfo;

- (void)logoutReceiveData:(BBDataFrame *)data;
- (void)logoutFailedWithErrorInfo:(NSString *)errorInfo;

- (void)getMSGVerifyCodeReceiveData:(BBDataFrame *)data;
- (void)getMSGVerifyCodeFailedWithErrorInfo:(NSString *)errorInfo;

- (void)resetPassWordReceiveData:(BBDataFrame *)data;
- (void)resetPassWordErrInfo:(NSString *)errorInfo;

- (void)sendDeviceTokenReceiveData:(BBDataFrame *)data;
- (void)sendDeviceTokenErrInfo:(NSString *)errorInfo;
@end
