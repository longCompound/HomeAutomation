//
//  BBSocketClient.h
//  SocketTrial
//
//  Created by iXcoder on 13-12-3.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBDataFrame.h"
#include <sys/socket.h>
#import "constDef.h"

typedef enum {
    kSocketStatusInitialed = 0,     // 已初始化
    kSocketStatusConnected ,        // 已连接
    kSocketStatusRunning,           // 需要发送心跳包
    kSocketStatusEnded              // 已结束
} BBSocketStatus;



@protocol BBSocketClientDelegate <NSObject>

-(int)onRecevie:(BBDataFrame*)src received:(BBDataFrame*)data;
-(void)onRecevieError:(BBDataFrame*)src received:(BBDataFrame*)data;
-(void)onTimeout:(BBDataFrame*)src;


@end
@protocol BBSocketDelegate <NSObject>

@required
-(void)onRecevieError;
-(void)onTimeout;
-(void)onClose;



@end

@interface BBSocketClient : NSThread
{
    //NSMutableData* buffer;
    NSMutableArray* commandStack;       // 待发送指令
    NSMutableArray *handledStack;       // 已发送指令
    NSMutableArray* sendedCommand;
    //GCDAsyncSocket *socket;
    BOOL _isrunning;
    int _connected;
    int socketfd;
    
}
@property (nonatomic, assign) BBSocketStatus socketStatus;
@property (nonatomic) int connected;
@property(nonatomic,retain) id<BBSocketDelegate> delegate;
@property(nonatomic,retain) NSString* user;
-(id) initWith:(NSString*)user;
-(BOOL)connect:(NSString*)addr port:(int)port;
-(BOOL)connectWithIP:(int)ip port:(int)port;
-(int)queueData:(BBDataFrame*)frame;
-(int)queueData:(BBDataFrame *)frame timeout:(int)time;
-(int)queueData:(BBDataFrame *)frame timeout:(int)time delegate:(id<BBSocketClientDelegate>)delegate;
-(void)stop;
-(int)sendData:(BBDataFrame*)frame;
-(BBDataFrame*)receiveFrame:(NSNumber*)timeout;
-(void)close;
-(BBDataFrame*)createFrame:(int)mainCmd subcmd:(int)subcmd str:(NSString*)data;
-(BBDataFrame*)createFrame:(int)mainCmd subcmd:(int)subcmd data:(NSData*)data;
-(BBDataFrame*)createFrame:(int)intversion version:(int)mainCmd subcmd:(int)subcmd data:(NSString *)data;

-(BBDataFrame*)createLoginFrame;
/*!
 *@brief        创建心跳包
 *@function     linkTestFrame
 *@param        (void)
 *@return       (BBDataFrame)
 */
-(BBDataFrame*)linkTestFrame;


@end

#pragma mark -
#pragma mark BBMultiFrameHandle多包返回处理(总条数，当前包条数)

@interface BBMultiFrameHandle : NSObject<BBSocketClientDelegate>
{
    int total;
    int recvcount;
    NSMutableData* dataBuff;
    id<BBSocketClientDelegate> delegate;
}
//  总条数位置(默认含状态码，totalPosi = 1)
@property (nonatomic, assign) NSUInteger totalPosi;

-(id)initWithDelegate:(id<BBSocketClientDelegate>)delegateref;

@end

#pragma mark -
#pragma mark BBSeqFrameHandle多包返回处理(总条数，当前包序号)
@interface BBSeqFrameHandle : NSObject<BBSocketClientDelegate>
{
    int total;
    int currentSeq;
    NSMutableData* dataBuff;
    id<BBSocketClientDelegate> delegate;
}

@property (nonatomic, assign) BOOL isRFID;//随身保包含头像数据

-(id)initWithDelegate:(id<BBSocketClientDelegate>)delegateref;

@end
