//
//  BBSocketManager.h
//  SocketTrial
//
//  Created by iXcoder on 13-11-29.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBLoginClient.h"
#import "BBMainClient.h"
#import "BBMsgClient.h"
#import "BBFileClient.h"


#define MAIN_CMD    @"MainCmd"
#define SUB_CMD     @"SubCmd"

//void BBLog(NSString *format, ...)
//{
//    NSString *printCtnt = [NSString stringWithFormat:format, ##__VA_ARGS__];
//    NSDateFormatter *df = [[NSDateFormatter alloc] init];
//    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSMutableString *result = [NSMutableString stringWithString:[df stringFromDate:[NSDate date]]];
//    [df release];
//    NSString *fileName = [NSString stringWithFormat:@"%s",__FILE__];
//    fileName = [fileName lastPathComponent];
//    [result appendFormat:@" %@", fileName];
//    [result appendFormat:@"[LINE:%d]", __LINE__];
//    NSString *printCtnt = [NSString stringWithFormat:format, ##__VA_ARGS__];
//    [result appendFormat:@" %@", printCtnt];
//    printf("%s ", [result UTF8String]);
//}

typedef NS_ENUM(NSUInteger, SocketUsageType) {
    kSocketTypeLog = 0,
    kSocketTypeFile,
    kSocketTypePic,
    kSocketTypeMsg
};

@interface BBSocketManager : NSObject

@property(nonatomic,retain) NSMutableDictionary* hostInfoDict;
@property(nonatomic,retain) NSString* user;

+ (instancetype)getInstance;

// 销毁所有socket
- (void)distoryAllSockets;
// 登陆服务器client
- (BBLoginClient *)loginClient;
-(BOOL)login:(NSString *)user password:(NSString *)pwd delegate:(id<BBLoginClientDelegate>) delegate;
// 注册新用户
- (BOOL)registerNewUser:(NSString *)userInfo delegate:(id<BBLoginClientDelegate>)delegate;

// 主服务器client
- (BBMainClient*)mainClient;
// 文件服务器client
- (BBFileClient *)fileClient;
// 消息服务器client
- (BBMsgClient *)messageClient;

@end
