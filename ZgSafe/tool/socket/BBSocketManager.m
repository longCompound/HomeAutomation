 //
//  BBSocketManager.m
//  SocketTrial
//
//  Created by iXcoder on 13-11-29.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBSocketManager.h"

#define LOG_USER_DATA       1L
#define FILE_USER_DATA      2L
#define PIC_USER_DATA       3L
#define MSG_USER_DATA       4L

static BBSocketManager *sharedManager = nil;

@interface BBSocketManager()
{
    BBLoginClient *logClient;
    BBMainClient *mainClient;
    BBFileClient *fileClient;
    BBMsgClient *msgClient; 
}

@end

@implementation BBSocketManager

#pragma mark -
#pragma mark Singleton method
+ (instancetype)getInstance
{
    @synchronized (self) {
        if (sharedManager == nil) {
            sharedManager = [[BBSocketManager alloc] init];
        }
    }
    return sharedManager;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    @synchronized(self) {
        if (sharedManager == nil) {
            sharedManager = [super allocWithZone:zone];
        }
    }
    return sharedManager;
}

- (instancetype)retain
{
    return sharedManager;
}
- (oneway void)release
{
    
}

- (instancetype)autorelease
{
    return self;
}

- (NSUInteger)retainCount
{
    return UINT_MAX;
}

// 销毁所有socket
- (void)distoryAllSockets
{
    if (logClient != nil) {
        [logClient stop];
        [logClient close];
        if ([logClient isExecuting]) {
            [logClient cancel];
        }
    }
    if (mainClient != nil) {
        [mainClient stop];
        [mainClient close];
        if ([mainClient isExecuting]) {
            [mainClient cancel];
        }
    }
    if (msgClient != nil) {
        [msgClient stop];
        [msgClient close];
        if ([msgClient isExecuting]) {
            [msgClient cancel];
        }
    }
    if (fileClient != nil) {
        [fileClient stop];
        [fileClient close];
        if ([fileClient isExecuting]) {
            [fileClient cancel];
        }
    }
}

#pragma mark -
#pragma mark ZG business method

-(BOOL)login:(NSString *)user password:(NSString *)pwd delegate:(id<BBLoginClientDelegate>) delegate
{
    
    BBLoginClient* login = [[BBLoginClient alloc] initWith:user password:pwd];
    login.username = user;
    login.password = pwd;
    [login logWithDelegate:delegate];
    
    
    NSString* data = login.hostInfoFrame.dataString;
    NSArray* result;
    result = [data componentsSeparatedByString:@"\t"];
    if (result.count < 2) {
        [login release];
        return NO;
    }
    
    NSMutableDictionary* dict2 = [[NSMutableDictionary alloc] init];
    
    int count = [result[0] intValue];
    for ( int i = 1 ; i <= count ; i++)
    {
        NSArray* hostinfo = [result[i] componentsSeparatedByString:@":"];
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setObject:hostinfo[0] forKey:@"ip"];
        [dict setObject:hostinfo[1] forKey:@"port"];
        [dict setObject:hostinfo[2] forKey:@"server"];
        
        [dict2 setObject:dict forKey:hostinfo[2]];
    }
    self.hostInfoDict = dict2;
    [dict2 release];
    [login release];
    self.user = user;
    //停止消息服务
//    [self messageClient];
    return YES;
}

// 注册新用户
- (BOOL)registerNewUser:(NSString *)userInfo delegate:(id<BBLoginClientDelegate>)delegate
{
    if (logClient == nil) {
        logClient = [[BBLoginClient alloc] init];
    }
    int res = [logClient registerANewUser:userInfo delegate:delegate];
    BBLog(@"注册结果:%d(0:SUCCESS, -1:FALSE)", res);
    return res == 0;
}

#pragma mark -
#pragma mark All Clients getter method

- (BBLoginClient *)loginClient
{
    if (logClient == nil) {
        logClient = [[BBLoginClient alloc] init];
    }
    if (logClient.socketStatus == kSocketStatusEnded) {
        [logClient release];
        logClient = [[BBLoginClient alloc] init];
        BBLog(@">RE-BUILD< Login Client");
    }
    
    return logClient;
    
}


/*!
 *@brief        主服务器client
 *@function     mainClient
 *@param        (void)
 *@return       (BBMainClient)
 */
-(BBMainClient*)mainClient
{
    NSMutableDictionary* dict = [self.hostInfoDict objectForKey:@"6"];
    if(dict == nil) {
        return nil;
    }
    if (mainClient == nil) {
        mainClient = [[BBMainClient alloc] initWith:self.user];
    }
    if (mainClient.socketStatus == kSocketStatusEnded) {
        [mainClient release];
        mainClient = [[BBMainClient alloc] initWith:self.user];
        BBLog(@">RE-BUILD< Main Client");
    }
    if (mainClient.connected != 0) {
        if (![mainClient connectWithIP:[[dict objectForKey:@"ip"] intValue]
                                 port:[[dict objectForKey:@"port"] intValue]]) {
            BBLog(@">MainClient< socket connect failed.");
            return nil;
        }
    }
    if (![mainClient isExecuting]) {
        [mainClient start];
    }
    
    return mainClient;
}

/*!
 *@brief        消息服务器client
 *@function     messageClient
 *@param        (void)
 *@return       (void)
 */
- (BBMsgClient *)messageClient
{
    NSMutableDictionary* dict = [self.hostInfoDict objectForKey:@"7"];
    if(dict == nil) {
        return nil;
    }
    if (msgClient == nil) {
        msgClient = [[BBMsgClient alloc] initWith:self.user];
    }
    if (msgClient.socketStatus == kSocketStatusEnded) {
        [msgClient release];
        msgClient = [[BBMsgClient alloc] initWith:self.user];
        BBLog(@">RE-BUILD< Message Client");
    }
    if (msgClient.connected != 0) {
        BOOL connectStatus = [msgClient connectWithIP:[[dict objectForKey:@"ip"] intValue]
                                                 port:[[dict objectForKey:@"port"] intValue]];
        if (!connectStatus) {
            BBLog(@">MsgClient< socket connect failed.");
            return nil;
        }
    }
    if (![msgClient isExecuting]) {
        [msgClient start];
    }
    return msgClient;
}


/*!
 *@brief        文件服务器client
 *@function     fileClient
 *@param        (void)
 *@return       (BBFileClient)
 */
- (BBFileClient *)fileClient
{
    NSMutableDictionary* dict = [self.hostInfoDict objectForKey:@"8"];
    if(dict == nil) {
        return nil;
    }
    if (fileClient == nil) {
        fileClient = [[BBFileClient alloc] initWith:self.user];
    }
    if (fileClient.socketStatus == kSocketStatusEnded) {
        [fileClient release];
        fileClient = [[BBFileClient alloc] initWith:self.user];
        BBLog(@">RE-BUILD< File Client");
    }
    if (fileClient.connected != 0) {
        if (![fileClient connectWithIP:[[dict objectForKey:@"ip"] intValue]
                                 port:[[dict objectForKey:@"port"] intValue]]) {
            BBLog(@">FileClient<socket connect failed.");
            return nil;
        };
    }
    if (![fileClient isExecuting]) {
        [fileClient start];
    }
    return fileClient;
}


@end
