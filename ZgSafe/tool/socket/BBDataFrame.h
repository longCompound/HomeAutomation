//
//  BBDataFrame.h
//  SocketTrial
//
//  Created by iXcoder on 13-11-30.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

#define Frame_MainCmd_Login     0x01        // 登陆标志
#define Frame_MainCmd_Center    0x0C        // 中心服务器返回
#define Frame_MainCmd_Client    0x0E        // 家庭卫士服务器自身协议
#define Frame_MainCmd_Ping      0x00        // 心跳包

#pragma mark -
#pragma mark BBDataFrame class
@interface BBDataFrame : NSObject

/*! 平台代码
 * app终端为4
 */
@property (nonatomic, assign) NSInteger platform;

/*! 协议版本
 * 初始化版本为1
 */
@property (nonatomic, assign) NSInteger version;

/*! 主功能命令字
 * 登陆:0x01
 * 中心服务器返回:0x0C
 * 家庭服务器自身:0x0E
 * 心跳包:0x00
 */
@property (nonatomic, assign) Byte MainCmd;

/*! 子功能命令字
 */
@property (nonatomic, assign) NSInteger SubCmd;

/*! 要发送的数据
 */
@property (nonatomic, retain) NSData *data;

-(NSString*)dataString;

@end
