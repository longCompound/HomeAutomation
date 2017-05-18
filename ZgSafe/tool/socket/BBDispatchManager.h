//
//  BBDispatchManager.h
//  SocketTrial
//
//  Created by iXcoder on 13-12-31.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBDispatchManager : NSObject

//+ (id)sharedManager;

+ (void)initStack;
+ (void)clearStack;

#pragma mark -
#pragma mark 监听注册与清除
+ (void)registerHandler:(id<BBSocketClientDelegate>)handler
               forFrame:(BBDataFrame *)frame;

+ (void)registerHandler:(id<BBSocketClientDelegate>)handler
             forMainCmd:(Byte)maincmd
                 subCmd:(NSUInteger)subcmd;

+ (void)removeHandler:(id)handler;

#pragma mark -
#pragma mark 收到不能处理的消息

+ (void)recievedUnknownPackage:(BBDataFrame *)unknown;

@end
