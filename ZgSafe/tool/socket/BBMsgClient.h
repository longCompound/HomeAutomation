//
//  BBMsgClient.h
//  SocketTrial
//
//  Created by iXcoder on 13-12-4.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBSocketClient.h"

/*!
 *  消息服务器socket
 *  主命令关键字:0x0D
 *
 */
@interface BBMsgClient : BBSocketClient

@property (nonatomic, retain) id<BBSocketClientDelegate> frameDelegate;

@end
