//
//  BBDispatchManager.m
//  SocketTrial
//  接收到为发送信息
//  Created by iXcoder on 13-12-31.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#define FRM_INFO        @"frameInfo"
#define FRM_HANDLER     @"frameHandler"

#import "BBDispatchManager.h"

static BBDispatchManager *sharedManager = nil;

// 存放需要处理的指令集
// 每个item为字典
static NSMutableArray *handlerStack = nil;

@interface BBDataFrame (equals)

- (BOOL)isSameCommand:(BBDataFrame *)src;

@end

@implementation BBDataFrame(equals)

- (BOOL)isSameCommand:(BBDataFrame *)src
{
    BOOL flag = NO;
    if (src.MainCmd == self.MainCmd && src.SubCmd == self.SubCmd) {
        flag = YES;
    }
    return flag;
}

@end

@interface NSMutableArray(pop)

- (id)pop;

@end

@implementation NSMutableArray (pop)

- (id)pop
{
    if ([self count] > 0) {
        id obj = [[self lastObject] retain];
        [self removeLastObject];
        return [obj autorelease];
    }
    return nil;
}

@end

@implementation BBDispatchManager

+ (id)sharedManager
{
    @synchronized(self) {
        if (sharedManager == nil) {
            sharedManager = [[BBDispatchManager alloc] init];
            handlerStack = [[NSMutableArray alloc] init];
        }
        return sharedManager;
    }
}

+ (void)initStack
{
    if (handlerStack != nil) {
        return;
    }
    handlerStack = [[NSMutableArray alloc] init];
}

+ (void)clearStack
{
    [handlerStack removeAllObjects];
}

/*!
 *@brief        注册监听
 *@function     registerHandler:forFrame:
 *@param        handler         -- 监听对象
 *@param        frame           -- 被监听对象
 *@return       (void)
 */
+ (void)registerHandler:(id<BBSocketClientDelegate>)handler forFrame:(BBDataFrame *)frame
{
    if (handler == nil) {
        BBLog(@"Can't set nil handler, nil handler will be ignored.");
        return ;
    }
    BBDataFrame *temp = [[BBDataFrame alloc] init];
    temp.MainCmd = frame.MainCmd;
    temp.SubCmd = frame.SubCmd;
    BOOL repeated = NO;
    for (NSDictionary *item in handlerStack) {
        id hand = [item objectForKey:FRM_HANDLER];
        BBDataFrame *cachedFrame = [item objectForKey:FRM_INFO];
        if (hand == handler && cachedFrame.MainCmd == temp.MainCmd
            && cachedFrame.SubCmd == temp.SubCmd) {
            repeated = YES;
            break;
        }
    }

    if (!repeated) {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:handler, FRM_HANDLER, temp, FRM_INFO, nil];
        [handlerStack addObject:dic];
    }
#if !__has_feature(objc_arc)
    [temp release];
#endif
}

/*!
 *@brief        注册监听
 *@function     registerHandler:forMainCmd:subCmd:
 *@param        handler         -- 监听对象
 *@param        maincmd         -- 监听主命令
 *@param        subcmd          -- 监听子命令
 *@return       (void)
 */
+ (void)registerHandler:(id<BBSocketClientDelegate>)handler
             forMainCmd:(Byte)maincmd
                 subCmd:(NSUInteger)subcmd
{
    BBDataFrame *df = [[BBDataFrame alloc] init];
    df.MainCmd = maincmd;
    df.SubCmd = subcmd;
    [self registerHandler:handler forFrame:df];
#if !__has_feature(objc_arc)
    [df release];
#endif
}

/*!
 *@brief        移除监听
 *@function     removeHandler:
 *@param        handler         -- 被移除的监听
 *@return       (void)
 */
+ (void)removeHandler:(id)handler
{
    for (NSDictionary *item in handlerStack) {
        id hand = [item objectForKey:FRM_HANDLER];
        if (hand && hand == handler) {
            [handlerStack removeObject:item];
        }
    }
}

/*!
 *@brief        查找监听处理信息
 *@function     findRelativeInfo:
 *@param        src             -- 消息源
 *@return       (NSDictionary)  -- 注册的消息
 */
+ (NSDictionary *)findRelativeInfo:(BBDataFrame *)src
{
    for (NSDictionary *item in handlerStack) {
        BBDataFrame *df = (BBDataFrame *)[item objectForKey:FRM_INFO];
        if (src.MainCmd == df.MainCmd && src.SubCmd == df.SubCmd) {
            return item;
        }
    }
    return nil;
}

/*!
 *@brief        收到未发出的消息
 *@function     recievedUnknownPackage:
 *@param        unknown         -- 消息
 *@return       (void)
 */
+ (void)recievedUnknownPackage:(BBDataFrame *)unknown
{
    BBLog(@"Recieved Unknown package[%x, %d]", unknown.MainCmd, unknown.SubCmd);
    NSDictionary *findRst = [BBDispatchManager findRelativeInfo:unknown];
    if (!findRst) {
        BBLog(@"Can't find dataFrame[%x, %d] handler, ignore it", unknown.MainCmd, unknown.SubCmd);
        return;
    }
    id<BBSocketClientDelegate> delegate = [findRst objectForKey:FRM_HANDLER];
    if (delegate && [delegate respondsToSelector:@selector(onRecevie:received:)]) {
        [delegate onRecevie:nil received:unknown];
    }
}

@end
