//
//  BBMsgClient.m
//  SocketTrial
//
//  Created by iXcoder on 13-12-4.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBMsgClient.h"
#import "BBDispatchManager.h"

@implementation BBMsgClient

/*!
 *@brief        创建验证包
 *@function     createLoginFrame
 *@param        (void)
 *@return       (BBDataFrame)
 */
-(BBDataFrame*)createLoginFrame
{
    return [self createFrame:0x0D subcmd:21 str:self.user];
}

/*!
 *@brief        创建心跳包
 *@function     linkTestFrame
 *@param        (void)
 *@return       (BBDataFrame)
 */
-(BBDataFrame*)linkTestFrame
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
  
    [dateFormatter release];
    return [super linkTestFrame];
}

- (void)main
{
    if (_connected !=0) {
        return;
    }
    int flags = fcntl(socketfd, F_GETFL,0);
    fcntl(socketfd,F_SETFL, flags | O_NONBLOCK);
    //
    BBDataFrame* lframe = [self createLoginFrame];
    [self sendData:lframe];
    
    BBDataFrame* loginResp = [self receiveFrame:@(PING_TIME_INTERVAL * 10)];
    if([loginResp.dataString compare:@"0"]!=NSOrderedSame) {;
        _isrunning = false;
    }
    int idleCount = 0;
    while (_isrunning) {
        BBDataFrame *df = [self receiveFrame:@(PING_TIME_INTERVAL)];
        if (df == nil) {
//            int ms = 500;
            //usleep(ms);
            //idleCount ++;
            //if (idleCount >= PING_TIME_INTERVAL * 1000 )
            { // 需要发送心跳包
                BBDataFrame* frame = [self linkTestFrame];
                [self sendData:frame];
                BBDataFrame* response = [self receiveFrame:@(PING_TIME_INTERVAL)];
                if ( response == nil) {
          
                    [self.delegate onTimeout];
                    break;
                } else {
                   
                }
                idleCount = 0;
                response = nil;
            }
        } else if(df.SubCmd!=21 && df.platform==7){
            NSArray *info = [df.dataString componentsSeparatedByString:@"\t"];
            if (info == nil || [info count] <= 1) {
                return ;
            }
            NSString *msgId = [info objectAtIndex:1];
            NSString *rtnMsg = [NSString stringWithFormat:@"%@\t0", msgId];

            BBDataFrame *replyFrame = [[BBDataFrame alloc] init];
            replyFrame.MainCmd = df.MainCmd;
            replyFrame.SubCmd = df.SubCmd;
            replyFrame.data = [rtnMsg dataUsingEncoding:NSUTF8StringEncoding];
            [self sendData:replyFrame];
            [BBDispatchManager recievedUnknownPackage:df];
            if ([self.frameDelegate respondsToSelector:@selector(onRecevie:received:)]) {
                
            }
        }
    }
    [self close];
}

@end
