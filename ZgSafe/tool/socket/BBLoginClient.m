//
//  BBLoginClient.m
//  SocketTrial
//
//  Created by iXcoder on 13-12-4.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBLoginClient.h"
#import "constDef.h"

@implementation BBLoginClient
@synthesize username;
@synthesize password;
-(id)initWith:(NSString *)user password:(NSString *)pwd
{
    self = [super init];
    if ( self ) {
        self.username = user;
        self.password = pwd;
        
    }
    return self;
}

- (NSArray *)sepByDataString:(NSString *)dataString
{
    return [dataString componentsSeparatedByString:@"\t"];
}

-(BBDataFrame*)createLoginFrame
{    
    NSString *udid=[@"ZG"stringByAppendingString:username];
    
   //NSString *udid1=appDelegate.Zgan_DeviceToken;
    
    NSMutableString *para = [NSMutableString string];
    [para appendString:username];
    [para appendFormat:@"\t"];
    
    [para appendString:password];
    [para appendString:@"\t"];
    
    //DeviceToken
    [para appendString:udid];
    [para appendString:@"\t"];
    
    //APP版本
    [para appendString:@"1"];
    [para appendString:@"\t"];
    
    //手机类型
    [para appendString:@"1"];
    
    return [self createFrame:0x01 subcmd:1 str:para];
}



-(void)logWithDelegate:(id<BBLoginClientDelegate>)delegate
{
    int flags = fcntl(socketfd, F_GETFL,0);
    fcntl(socketfd,F_SETFL, flags | O_NONBLOCK);
    BBDataFrame* loginFrame = [self createLoginFrame];
    BOOL connected = [self connect:LOG_SERVER_PATH port:LOG_SERVER_PORT];
    if (!connected) {
        BBLog(@"连接失败");
        if (delegate && [delegate respondsToSelector:@selector(loginFailedWithErrorInfo:)]) {
            [delegate loginFailedWithErrorInfo:@"连接失败"];
        }
        return ;
    }
    [self sendData:loginFrame];
    
    BBDataFrame* loginResp = [self receiveFrame:@30];
    if (loginResp != nil) {
        NSArray *dataArr = [self sepByDataString:loginResp.dataString];
        if (dataArr.count > 1 && [dataArr.firstObject isEqualToString:@"0"]) {
            BBLog(@"Login success");
//            BBDataFrame* hostInfo = [self receiveFrame:@30];
//            BBLog(@"%@",hostInfo.dataString);
//            self.hostInfoFrame = hostInfo;
            if (delegate && [delegate respondsToSelector:@selector(loginReceiveData:)]) {
                [delegate loginReceiveData:loginResp];
            }
        } else {
            BBLog(@"Login Fail");
            if (delegate && [delegate respondsToSelector:@selector(loginReceiveData:)]) {
                [delegate loginReceiveData:loginResp];
            }
        }
    } else {
        NSLog(@"登陆超时");
        if (delegate && [delegate respondsToSelector:@selector(loginFailedWithErrorInfo:)]) {
            [delegate loginFailedWithErrorInfo:@"登陆超时"];
        }
    }
    //    [loginFrame release];
    [self close];
}

//获取服务器地址
- (int)getServerList:(NSString *)userID deleagte:(id<BBLoginClientDelegate>)delegate
{
    int flags = fcntl(socketfd, F_GETFL,0);
    fcntl(socketfd,F_SETFL, flags | O_NONBLOCK);
    NSData *data = [userID dataUsingEncoding:GBK_ENCODEING];
    BBDataFrame *getServerListFrame = [self createFrame:0x01 subcmd:4 data:data];
    BOOL connected = [self connect:LOG_SERVER_PATH port:LOG_SERVER_PORT];
    if (!connected) {
        if (!connected) {
            if (delegate && [delegate respondsToSelector:@selector(registFailedWithErrorInfo:)] ) {
                [delegate registFailedWithErrorInfo:@"连接登陆服务器失败"];
            }
            return -1;
        }
    }
    int sendStatus = [self sendData:getServerListFrame];
    if (sendStatus < 0) {
        BBLog(@"发送消息失败");
        if (delegate && [delegate respondsToSelector:@selector(getServerListErrorInfo:)] ) {
            [delegate getServerListErrorInfo:@"发送消息失败"];
        }
        return -2;
    }
    BBDataFrame* logoutResp = [self receiveFrame:@30];
    NSArray *array = [self sepByDataString:logoutResp.dataString];
    if (array.count > 0) {
        if([array[0] compare:@"0"] == NSOrderedSame) {
        BBLog(@"获取短信失败");
        if (delegate && [delegate respondsToSelector:@selector(getServerListErrorInfo:)] ) {
            [delegate getServerListErrorInfo:@"发送消息失败"];
        }
        [self close];
        return -3;
    }
    
    BBLog(@"获取短信 SUCCESS");
    if (delegate && [delegate respondsToSelector:@selector(getServerListData:)] ) {
        [delegate getServerListData:logoutResp];
    }
    }
    
    [self close];
    
    return 0;
}
/*!
 *@brief        注册新用户
 *@function     registerNewUser:
 *@param        newUserInfo
 *@return       (void)
 */
- (int)registerANewUser:(NSString *)newUserInfo delegate:(id<BBLoginClientDelegate>)delegate
{
    int flags = fcntl(socketfd, F_GETFL,0);
    fcntl(socketfd,F_SETFL, flags | O_NONBLOCK);

    NSData *data = [newUserInfo dataUsingEncoding:GBK_ENCODEING];
    BBDataFrame* regFrame = [self createFrame:0x01 subcmd:3 data:data];
    BOOL connected = [self connect:LOG_SERVER_PATH port:LOG_SERVER_PORT];
    if (!connected) {
#if DEBUG
        BBLog(@"连接登陆服务器失败");
#endif
        if (delegate && [delegate respondsToSelector:@selector(registFailedWithErrorInfo:)] ) {
            [delegate registFailedWithErrorInfo:@"连接登陆服务器失败"];
        }
        return -1;
    }
    int sendStatus = [self sendData:regFrame];
    if (sendStatus < 0) {
#if DEBUG
        BBLog(@"发送注册消息失败");
#endif
        if (delegate && [delegate respondsToSelector:@selector(registFailedWithErrorInfo:)] ) {
            [delegate registFailedWithErrorInfo:@"发送注册消息失败"];
        }
        return -2;
    }
    BBDataFrame* regResp = [self receiveFrame:@30];
    if (regResp == nil || regResp.dataString == nil || ![regResp.dataString isEqualToString:@"0"]) {
#if DEBUG
        BBLog(@"注册失败");
#endif
        if (delegate && [delegate respondsToSelector:@selector(registReceiveData:)] ) {
            [delegate registReceiveData:regResp];
        }
        [self close];
        return -3;
    }

    BBLog(@"register action SUCCESS");
    if (delegate && [delegate respondsToSelector:@selector(registReceiveData:)] ) {
        [delegate registReceiveData:regResp];
    }
    
    [self close];
    return 0;
}

// 绑定终端
- (int)bindTerminal:(NSString *)deviceInfo delegate:(id<BBLoginClientDelegate>)delegate
{
    int flags = fcntl(socketfd, F_GETFL,0);
    fcntl(socketfd,F_SETFL, flags | O_NONBLOCK);
 
    NSData *data = [deviceInfo dataUsingEncoding:GBK_ENCODEING];
    BBDataFrame* bindFrame = [self createFrame:0x01 subcmd:2 data:data];
    BOOL connected = [self connect:LOG_SERVER_PATH port:LOG_SERVER_PORT];
    if (!connected) {
#if DEBUG
        BBLog(@"连接登陆服务器失败");
#endif
        if (delegate && [delegate respondsToSelector:@selector(bindFailedWithErrorInfo:)] ) {
            [delegate bindFailedWithErrorInfo:@"连接登陆服务器失败"];
        }
        return -1;
    }
    int sendStatus = [self sendData:bindFrame];
    if (sendStatus < 0) {
#if DEBUG
        BBLog(@"发送绑定终端消息失败");
#endif
        if (delegate && [delegate respondsToSelector:@selector(bindFailedWithErrorInfo:)] ) {
            [delegate bindFailedWithErrorInfo:@"发送绑定终端消息失败"];
        }
        return -2;
    }
    BBDataFrame* bindResp = [self receiveFrame:@30];
    if (bindResp == nil || bindResp.dataString == nil
        || ![bindResp.dataString isEqualToString:@"0"]) {
#if DEBUG
        BBLog(@"绑定失败");
#endif
        if (delegate && [delegate respondsToSelector:@selector(bindReceiveData:)] ) {
            [delegate bindReceiveData:bindResp];
        }
        [self close];
        return -3;
    }
    
    BBLog(@"bind action SUCCESS");
    if (delegate && [delegate respondsToSelector:@selector(bindReceiveData:)] ) {
        [delegate bindReceiveData:bindResp];
    }
    
    [self close];
    
    return 0;
}



// 注销
- (int)logout:(NSString *)param delegate:(id<BBLoginClientDelegate>)delegate
{
    int flags = fcntl(socketfd, F_GETFL,0);
    fcntl(socketfd,F_SETFL, flags | O_NONBLOCK);
    
    NSData *data = [param dataUsingEncoding:GBK_ENCODEING];
    BBDataFrame* logoutFrame = [self createFrame:0x01 subcmd:5 data:data];
    BOOL connected = [self connect:LOG_SERVER_PATH port:LOG_SERVER_PORT];
    if (!connected) {
#if DEBUG
        BBLog(@"连接登陆服务器失败");
#endif
        if (delegate && [delegate respondsToSelector:@selector(logoutFailedWithErrorInfo:)] ) {
            [delegate logoutFailedWithErrorInfo:@"连接登陆服务器失败"];
        }
        return -1;
    }
    int sendStatus = [self sendData:logoutFrame];
    if (sendStatus < 0) {
#if DEBUG
        BBLog(@"发送注销消息失败");
#endif
        if (delegate && [delegate respondsToSelector:@selector(logoutFailedWithErrorInfo:)] ) {
            [delegate logoutFailedWithErrorInfo:@"发送注销消息失败"];
        }
        return -2;
    }
    BBDataFrame* logoutResp = [self receiveFrame:@30];
    if (logoutResp == nil || logoutResp.dataString == nil
        || ![logoutResp.dataString isEqualToString:@"0"]) {
#if DEBUG
        BBLog(@"注销失败");
#endif
        if (delegate && [delegate respondsToSelector:@selector(logoutReceiveData:)] ) {
            [delegate logoutReceiveData:logoutResp];
        }
        [self close];
        return -3;
    }
    
    BBLog(@"logout SUCCESS");
    if (delegate && [delegate respondsToSelector:@selector(logoutReceiveData:)] ) {
        [delegate logoutReceiveData:logoutResp];
    }
    
    [self close];
    
    return 0;
}




// 获取短信验证码
- (int)getMSGVerifyCode:(NSString *)param delegate:(id<BBLoginClientDelegate>)delegate
{
    int flags = fcntl(socketfd, F_GETFL,0);
    fcntl(socketfd,F_SETFL, flags | O_NONBLOCK);
    
    NSData *data = [param dataUsingEncoding:GBK_ENCODEING];
    BBDataFrame* logoutFrame = [self createFrame:0x01 subcmd:8 data:data];
    BOOL connected = [self connect:LOG_SERVER_PATH port:LOG_SERVER_PORT];
    if (!connected) {
#if DEBUG
        BBLog(@"连接服务器失败");
#endif
        if (delegate && [delegate respondsToSelector:@selector(getMSGVerifyCodeFailedWithErrorInfo:)] ) {
            [delegate getMSGVerifyCodeFailedWithErrorInfo:@"连接服务器失败"];
        }
        return -1;
    }
    int sendStatus = [self sendData:logoutFrame];
    if (sendStatus < 0) {
#if DEBUG
        BBLog(@"发送消息失败");
#endif
        if (delegate && [delegate respondsToSelector:@selector(getMSGVerifyCodeFailedWithErrorInfo:)] ) {
            [delegate getMSGVerifyCodeFailedWithErrorInfo:@"发送消息失败"];
        }
        return -2;
    }
    BBDataFrame* logoutResp = [self receiveFrame:@30];
    if (logoutResp == nil || logoutResp.dataString == nil
        || ![logoutResp.dataString isEqualToString:@"0"]) {
#if DEBUG
        BBLog(@"获取短信失败");
#endif
        if (delegate && [delegate respondsToSelector:@selector(getMSGVerifyCodeReceiveData:)] ) {
            [delegate getMSGVerifyCodeReceiveData:logoutResp];
        }
        [self close];
        return -3;
    }
    
    BBLog(@"获取短信 SUCCESS");
    if (delegate && [delegate respondsToSelector:@selector(getMSGVerifyCodeReceiveData:)] ) {
        [delegate getMSGVerifyCodeReceiveData:logoutResp];
    }
    
    [self close];
    
    return 0;
}
//重置密码
- (int)resetPassWord:(NSString *)param delegate:(id<BBLoginClientDelegate>)delegate{
    
    int flags = fcntl(socketfd, F_GETFL,0);
    fcntl(socketfd,F_SETFL, flags | O_NONBLOCK);
    
    NSData *data = [param dataUsingEncoding:GBK_ENCODEING];
    BBDataFrame* logoutFrame = [self createFrame:0x01 subcmd:7 data:data];
    BOOL connected = [self connect:LOG_SERVER_PATH port:LOG_SERVER_PORT];
    if (!connected) {
#if DEBUG
        BBLog(@"连接服务器失败");
#endif
        if (delegate && [delegate respondsToSelector:@selector(resetPassWordErrInfo:)] ) {
                [delegate resetPassWordErrInfo:@"连接服务器失败"];
            
        }
        return -1;
    }
    int sendStatus = [self sendData:logoutFrame];
    if (sendStatus < 0) {
#if DEBUG
        BBLog(@"发送消息失败");
#endif
        if (delegate && [delegate respondsToSelector:@selector(resetPassWordErrInfo:)] ) {
            [delegate resetPassWordErrInfo:@"发送消息失败"];
        }
        return -2;
    }
    BBDataFrame* logoutResp = [self receiveFrame:@30];
    if (logoutResp == nil || logoutResp.dataString == nil
        || ![logoutResp.dataString isEqualToString:@"0"]) {
#if DEBUG
        BBLog(@"重置密码失败");
#endif
        if (delegate && [delegate respondsToSelector:@selector(resetPassWordReceiveData:)] ) {
            [delegate resetPassWordReceiveData:logoutResp];
        }
        [self close];
        return -3;
    }
    
    BBLog(@"重置密码 SUCCESS");
    if (delegate && [delegate respondsToSelector:@selector(resetPassWordReceiveData:)] ) {
        [delegate resetPassWordReceiveData:logoutResp];
    }
    
    [self close];
    
    return 0;


}

//发送DeviceToken
- (int)sendDeviceToken:(NSString *)param delegate:(id<BBLoginClientDelegate>)delegate{
    
    int flags = fcntl(socketfd, F_GETFL,0);
    fcntl(socketfd,F_SETFL, flags | O_NONBLOCK);
    
    NSData *data = [param dataUsingEncoding:GBK_ENCODEING];
    BBDataFrame* logoutFrame = [self createFrame:0x01 subcmd:10 data:data];
    BOOL connected = [self connect:LOG_SERVER_PATH port:LOG_SERVER_PORT];
    if (!connected) {
#if DEBUG
        BBLog(@"连接服务器失败");
#endif
        if (delegate && [delegate respondsToSelector:@selector(sendDeviceTokenErrInfo:)] ) {
            [delegate sendDeviceTokenErrInfo:@"连接服务器失败"];
            
        }
        return -1;
    }
    int sendStatus = [self sendData:logoutFrame];
    if (sendStatus < 0) {
#if DEBUG
        BBLog(@"发送DeviceToken失败");
#endif
        if (delegate && [delegate respondsToSelector:@selector(sendDeviceTokenErrInfo:)] ) {
            [delegate sendDeviceTokenErrInfo:@"发送DeviceToken失败"];
        }
        return -2;
    }
    BBDataFrame* logoutResp = [self receiveFrame:@30];
    if (logoutResp == nil || logoutResp.dataString == nil
        || ![logoutResp.dataString isEqualToString:@"0"]) {
#if DEBUG
        BBLog(@"重发送DeviceToken失败");
#endif
        if (delegate && [delegate respondsToSelector:@selector(sendDeviceTokenReceiveData:)] ) {
            [delegate sendDeviceTokenReceiveData:logoutResp];
        }
        [self close];
        return -3;
    }
    
    BBLog(@"发送DeviceToken成功");
    if (delegate && [delegate respondsToSelector:@selector(sendDeviceTokenReceiveData:)] ) {
        [delegate sendDeviceTokenReceiveData:logoutResp];
    }
    
    [self close];
    
    return 0;
    
    
}
@end
