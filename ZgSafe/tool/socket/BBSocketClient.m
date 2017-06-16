//
//  BBSocketClient.m
//  SocketTrial
//
//  Created by iXcoder on 13-12-3.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBSocketClient.h"
#import "BBDispatchManager.h"
#import <netdb.h>
#import <arpa/inet.h>
#import <signal.h>


#include <stdio.h>
#include <time.h>
#include <stdlib.h>


@interface BBSocketClient ()
{
//    SocketStatus socketStatus;      // socket数据发送状态
}

@end

@implementation BBSocketClient

@synthesize connected = _connected;

- (void)dealloc
{
//    [self removeObserver:self forKeyPath:@"sendedCommand"];
    [commandStack removeAllObjects];
    [commandStack release];
    [handledStack removeAllObjects];
    [handledStack release];
    [sendedCommand release];
    [super dealloc];
}
-(id)initWith:(NSString*)user {
    self = [super init];
    if ( self) {
        commandStack = [[NSMutableArray alloc] init];
        handledStack = [[NSMutableArray alloc] init];
        sendedCommand =[[NSMutableArray alloc] init];
        _isrunning  = YES;
        self.socketStatus = kSocketStatusInitialed;
        self.user = user;
        _connected = -1;
    }
    return self;
}

- (NSString*)getIpAddressForHost:(NSString*) theHost
{
    struct hostent *host = gethostbyname([theHost UTF8String]);
    NSString *addressString=LOG_SERVER_IP;
    
    if(host!=nil)
    {
        struct in_addr **list = (struct in_addr **)host->h_addr_list;
        addressString = [NSString stringWithCString:inet_ntoa(*list[0])
                                    encoding:NSUTF8StringEncoding];
    }
    
    return addressString;
}
-(BOOL)connectWithIP:(int)ip port:(int)port
{
    socketfd = socket(AF_INET, SOCK_STREAM, 0);
    if (socketfd == -1) {
        [_delegate onRecevieError];
    }
    struct sockaddr_in their_addr;
    their_addr.sin_family = AF_INET;
    their_addr.sin_addr.s_addr = ip;
    their_addr.sin_port = htons(port);
    bzero(&(their_addr.sin_zero), 8);
    _connected=connect(socketfd, (struct sockaddr*)&their_addr, sizeof(struct sockaddr));
    if (_connected == 0) {
        self.socketStatus = kSocketStatusConnected;
    }
    return _connected == 0 ? YES : NO;
}
-(BOOL)connect:(NSString *)addr port:(int)port
{
    socketfd = socket(AF_INET, SOCK_STREAM, 0);
    if (socketfd == -1) {
        [_delegate onRecevieError];
    }
    struct sockaddr_in their_addr;
    their_addr.sin_family = AF_INET;
    NSString *host = [self getIpAddressForHost:addr];
    if (!host) {
        BBLog(@"解析主机(%@)失败",addr);
        return NO;
    }
    their_addr.sin_addr.s_addr = inet_addr([host UTF8String]);
    BBLog(@"getIpAddressForHost :%@",host);
    
    their_addr.sin_port = htons(port);
    bzero(&(their_addr.sin_zero), 8);
    _connected=connect(socketfd, (struct sockaddr*)&their_addr, sizeof(struct sockaddr));
    if (_connected == 0) {
        self.socketStatus = kSocketStatusConnected;
    }
    return _connected == 0;
    //return  [socket connectToHost:addr onPort:port error:&error];
    
}
-(int)queueData:(BBDataFrame *)frame
{
    return [self queueData:frame timeout:-1];
}
-(int)queueData:(BBDataFrame *)frame timeout:(int)time
{
    return [self queueData:frame timeout:time delegate:nil];
}
-(int)queueData:(BBDataFrame *)frame timeout:(int)time delegate:(id<BBSocketClientDelegate>)delegate
{
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    if (reach.currentReachabilityStatus == NotReachable) {
        
        if (delegate && [delegate respondsToSelector:@selector(onTimeout:)]) {
            double delayInSeconds = 5.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [delegate onTimeout:frame];
            });
        } 
    }
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    if (frame != nil) {
        [dict setObject:frame forKey:@"frame"];
    }
    if (delegate != nil) {
        [dict setObject:delegate forKey:@"delegate"];
    }
    
    [dict setObject:@(time) forKey:@"timeout"];
    @synchronized(commandStack) {
        [commandStack addObject:dict];
    };
    
    [dict release];
    return 0;
}
-(int)sendData:(BBDataFrame *)frame
{
    NSData *sendData = [BBDataFrameTool encodeDataFrame:frame];
 
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    int sendStatus = send(socketfd, [sendData bytes], [sendData length], 0);
    [[UIApplication sharedApplication]  setNetworkActivityIndicatorVisible:NO];
 
    return sendStatus;
}
-(int)receiveData:(NSMutableData*)buffer length:(int)length timeout:(int)time
{
    /*
    time_t t1;
    time(NULL);
     */
    int len=0;
    for (int i = 0;i < 10;i++ ) {
        int rc = [self receiveDataInner:buffer length:length-len timeout:time/10];
        if(rc < 0) {
            return rc;
        }
        len += rc;
        if(len == length) {
            return len;
        }
    }
    return -1;
}
-(int)receiveDataInner:(NSMutableData*)buffer length:(int)length timeout:(int)time
{
    fd_set  readSet;
    struct timeval tv;
    tv.tv_sec = time;
    tv.tv_usec =0;
    char buf[length];
    __DARWIN_FD_ZERO( &readSet );
    
    __DARWIN_FD_SET( socketfd, &readSet );
    int ret =  select(socketfd + 1,&readSet,0,0,&tv);
    if ( ret > 0 ) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        ret = recv(socketfd,buf,length,0);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if( ret <= 0 ){
            ret = -1;
        }
        else {
            [buffer appendBytes:buf length:ret];
        }
        return ret;
    }
    else if( ret < 0 ) {
        
        return  -1;
    }
    else if( ret == 0 ) {
        return -2;//timeout
    }
    return 0;
}
-(BBDataFrame*)receiveFrame:(NSNumber *)timeout
{
    NSMutableData* buffer = [NSMutableData data];
    int rc = [self receiveData:buffer length:11 timeout:[timeout intValue] * 10];
    if ( rc < 11 ) {
        return nil;
    }
//    BBLog(@"<头部>:%@</头部>", buffer);
    Byte bbs[2]={0,0};
    Byte* data = (Byte*)[buffer bytes];
    bbs[0] = data[9];
    bbs[1] = data[10];
    int len = [BBDataFrameTool highLowByteToInt:bbs];
    if(len>=0) {
        rc = [self receiveData:buffer length:len+1 timeout:[timeout intValue]];
        //BBLog(@"<数据>:%@</数据>", buffer);
        if (rc != len+1) {
            return nil;
        }
    }
    BBDataFrame *dataFrame = [BBDataFrameTool decodeDataToFrame:buffer];
    return dataFrame;
    
}

void processSignal(int sig)
{
#if DEBUG
    printf("signal is %d\n", sig);
#endif
    signal(sig, processSignal);
}

-(void)mainSend
{
    while(_isrunning)
    {
        if(commandStack != nil && [commandStack count] > 0) {
            NSMutableDictionary* dict = [commandStack objectAtIndex:0];
            BBDataFrame* src = [dict objectForKey:@"frame"];
            int rc = [self sendData:src];
            if(rc < 0) {
//                id vc = [dict objectForKey:@"delegate"];
//                if (vc && [vc respondsToSelector:@selector(onTimeout:)]) {
//                    [vc onTimeout:src];
//                }
                _isrunning = false;
                break;
            }
            @synchronized(commandStack) {
                @synchronized (sendedCommand) {
                    [sendedCommand addObject:dict];
                    [commandStack removeObjectAtIndex:0];
                }
            };
            
        } else {
            usleep(50000);
        }
    }
}
-(NSDictionary*)findCommand:(BBDataFrame*)f
{
    @synchronized(sendedCommand) {
        for (NSDictionary* dict in sendedCommand) {
            BBDataFrame* src = [dict objectForKey:@"frame"];
            if (src.MainCmd == 0x0e && src.SubCmd == 4) {
                //BBLog(@"find [0x0e ,4], data:%@", [f dataString]);
            }
            if (src.MainCmd == f.MainCmd && src.SubCmd == f.SubCmd ) {
                return dict;
            }
        }
    };
    return nil;
}
- (void)main
{
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if (_connected !=0) {
        //[_delegate onClose];
        return;
    }
    
    int flags = fcntl(socketfd, F_GETFL,0);
    fcntl(socketfd,F_SETFL, flags | O_NONBLOCK);
    signal(SIGPIPE, SIG_IGN);

    BBDataFrame* lframe = [self createLoginFrame];
    [self sendData:lframe];
    BBDataFrame* loginResp = [self receiveFrame:@(PING_TIME_INTERVAL * 10)];
    if([loginResp.dataString compare:@"0"]!=NSOrderedSame) {
        BBLog(@"Auth faild!");
        _isrunning = false;
    }
    NSThread *sendT = nil;
    if(_isrunning) {
        sendT = [[NSThread alloc] initWithTarget:self selector:@selector(mainSend) object:nil];
        [sendT start];
    }
    //    [lframe release];
    int idleCount = 0;
    while (_isrunning) {
        self.socketStatus = kSocketStatusRunning;
//*        { *//
        BBDataFrame* result = [self receiveFrame:@(PING_TIME_INTERVAL)];
        int handleRc = 0;
        
        if(result != nil) {
            idleCount = 0;
            NSDictionary* dict = [self findCommand:result];
            if(dict == nil) {
                [BBDispatchManager recievedUnknownPackage:result];
                continue;
            }
            id<BBSocketClientDelegate> h = [dict objectForKey:@"delegate"];
            if (h != nil
                && [h respondsToSelector:@selector(onRecevie:received:)]) {
                do {
                    BBDataFrame *src = [dict objectForKey:@"frame"];
                    if (src.SubCmd != result.SubCmd || src.MainCmd != result.MainCmd) {
                        BBLog(@"src[%x,%d], result[%x,%d]", src.MainCmd,src.SubCmd,result.MainCmd,result.SubCmd);
                    }
                    handleRc = [h onRecevie:[dict objectForKey:@"frame"] received:result];
                    if(handleRc > 0) {
                        result = [self receiveFrame:[dict objectForKey:@"timeout"]];
                        if (result == nil) {
                            if([h respondsToSelector:@selector(onTimeout:)]) {
                                [h onTimeout:[dict objectForKey:@"frame"]];
                            }
                            break;
                        }
                    } /*else{
                        [sendedCommand removeObject:dict];
                        
                    }*/
                }
                while (handleRc>0) ;
            }
            @synchronized(sendedCommand) {
                [sendedCommand removeObject:dict];
            };
        } else {
            if(idleCount>=2) {
                break;
            }
            BBDataFrame* frame = [self linkTestFrame];
            [self queueData:frame];
            idleCount++;
        }
        /*}
         {
            int ms = 500;
            usleep(ms);
            
            idleCount ++;
            if (idleCount >= PING_TIME_INTERVAL * 2000 ) { // 需要发送心跳包
                BBDataFrame* frame = [self linkTestFrame];
                int sendStatus = [self sendData:frame];
                if (sendStatus < 10) {
                    break;
                }
                [frame release];
                BBDataFrame* response = [self receiveFrame:@(PING_TIME_INTERVAL)];
                if ( response == nil) {
                    BBLog(@"Link Test fail!");
                    [_delegate onTimeout];
                    break;
                } else {
                    BBLog(@"response dataframe:{%x, %d, %@}",response.MainCmd, response.SubCmd, response.data);
                }
                idleCount = 0;
                response = nil;
            }
        }
         */
    }
    
    //关闭线程??
    [self close];
    [commandStack removeAllObjects];
    if (![sendT isFinished]) {
        usleep(60000);
    }
    [sendT cancel];
    [sendT release];
}

-(void)stop
{
    _isrunning = false;
}

-(int)readFrameLength:(NSMutableData*)data
{
    Byte bbs[2];
    Byte* datas = (Byte*)[data bytes];
    bbs[0] = datas[9];
    bbs[1] = datas[10];
    return [BBDataFrameTool highLowByteToInt:bbs];
}

-(void)close
{
    close(socketfd);
    self.socketStatus = kSocketStatusEnded;
    _connected = -1;
    _isrunning = NO;
    if (_delegate != nil && [_delegate respondsToSelector:@selector(onClose)]) {
        [_delegate onClose];
    }
    while (sendedCommand!=nil && [sendedCommand count] > 0) {
        NSDictionary *item = [sendedCommand objectAtIndex:0];
        id del = [item objectForKey:@"delegate"];
        BBDataFrame *src = [item objectForKey:@"frame"];
        if (del && [del respondsToSelector:@selector(onTimeout:)]) {
            [del onTimeout:src];
        }
        [sendedCommand removeObjectAtIndex:0];
    }

    
    BBLog(@"socket thread exited!");
}

-(BBDataFrame*)createFrame:(int)mainCmd subcmd:(int)subcmd data:(NSData *)data
{
    BBDataFrame *df = [[[BBDataFrame alloc] init] autorelease];
    df.data = data;
    df.MainCmd = mainCmd;
    df.SubCmd = subcmd;
    return df;
}

-(BBDataFrame*)createFrame:(int)mainCmd subcmd:(int)subcmd str:(NSString *)data
{
    BBDataFrame *dataf = [self createFrame:mainCmd subcmd:subcmd data:[data dataUsingEncoding:GBK_ENCODEING]];
    return dataf;
}

-(BBDataFrame*)createFrame:(int)intversion version:(int)mainCmd subcmd:(int)subcmd data:(NSString *)data
{
    BBDataFrame *dataf = [self createFrame:mainCmd subcmd:subcmd data:[data dataUsingEncoding:GBK_ENCODEING]];
    
    dataf.version=intversion;
    
    return dataf;
}

/*!
 *@brief        创建验证包
 *@function     createLoginFrame
 *@param        (void)
 *@return       (BBDataFrame)
 */
-(BBDataFrame*)createLoginFrame
{
    return [self createFrame:0x0E subcmd:21 str:self.user];
}

/*!
 *@brief        创建心跳包
 *@function     linkTestFrame
 *@param        (void)
 *@return       (BBDataFrame)
 */
-(BBDataFrame*)linkTestFrame
{
    return [self createFrame:0x00 subcmd:0 data:0x00];
}


@end



#pragma mark -
#pragma mark BBMulitFrameHandle implementaion

@implementation BBMultiFrameHandle


-(id)initWithDelegate:(id<BBSocketClientDelegate>)delegateref
{
    self = [super init];
    if (self) {
        delegate = delegateref;
        total = -1;
        recvcount = 0;
        _totalPosi = 1;
        dataBuff = [[NSMutableData alloc] init];
    }
    return self;
}

-(void)onTimeout:(BBDataFrame *)src {
    if (delegate && [delegate respondsToSelector:@selector(onTimeout:)]) {
        [delegate onTimeout:src];
    }
}
-(void)onRecevieError:(BBDataFrame *)src received:(BBDataFrame *)data {
    if (delegate && [delegate respondsToSelector:@selector(onRecevieError:received:)]) {
        [delegate onRecevieError:src received:data];
    }
    
}
-(int)onRecevie:(BBDataFrame *)src received:(BBDataFrame *)data {
    NSString* str = [data dataString];
    NSArray* dataArr = [str componentsSeparatedByString:@"\t"];
    if(dataArr.count<3) {
        return -1;
    }
    if (total == -1) {
        total = [[dataArr objectAtIndex:_totalPosi] integerValue];
    }
    recvcount += [[dataArr objectAtIndex:_totalPosi + 1] integerValue];
    if (delegate && [delegate respondsToSelector:@selector(onRecevie:received:)]) {
        [delegate onRecevie:src received:data];
    }
    else
    {
        BBLog(@"no respondsToSelector:onRecevie:received:");
    }
    return total-recvcount;
}

-(void)dealloc {
    [dataBuff release];
    [super dealloc];
}

@end


#pragma mark -
#pragma mark BBSeqFrameHandle implementaion
@implementation BBSeqFrameHandle


-(id)initWithDelegate:(id<BBSocketClientDelegate>)delegateref
{
    self = [super init];
    if (self) {
        delegate = delegateref;
        total = -1;
        currentSeq = 0;
        dataBuff = [[NSMutableData alloc] init];
    }
    return self;
}

-(void)onTimeout:(BBDataFrame *)src {
    [delegate onTimeout:src];
}
-(void)onRecevieError:(BBDataFrame *)src received:(BBDataFrame *)data {
    NSLog(@"data string :%@", data.dataString);
    [delegate onRecevieError:src received:data];
}
-(int)onRecevie:(BBDataFrame *)src received:(BBDataFrame *)data {
    if (self.isRFID) {
        NSData *d = [NSData dataWithData:data.data];
        if (total == -1) {
            char lenChar = -1;
            if ([d length] > 2) {
                [d getBytes:&lenChar range:NSMakeRange(2, 1)];
            }
            
            if (lenChar > 0) {
                NSString *lenStr = [NSString stringWithFormat:@"%c", lenChar];
                total = [lenStr intValue];
            }
        }
        char currChar = -1;
        if ([d length] > 4) {
            [d getBytes:&currChar range:NSMakeRange(4, 1)];
        }
        
        if (currChar > 0) {
            NSString *currStr = [NSString stringWithFormat:@"%c", currChar];
            currentSeq = [currStr intValue];
        }
        unsigned int len = [[BBDataFrameTool encodeDataFrame:data] length];
        if (len <= 4096) {
            if (delegate && [delegate respondsToSelector:@selector(onRecevie:received:)]) {
                [delegate onRecevie:src received:data];
            }
        }
        return currentSeq < total - 1 ? 1 : 0 ;
    }
//        NSData *d = [NSData dataWithData:data.data];
//        if (total == -1) {
//            NSData *lenData = [d subdataWithRange:NSMakeRange(2, 1)];
//            total = [[NSString stringWithFormat:@"%@", lenData] integerValue];
//        }
//        NSData *currData = [d subdataWithRange:NSMakeRange(4, 1)];
//        currentSeq = [[NSString stringWithFormat:@"%@", currData] integerValue];
//        unsigned int len = [[BBDataFrameTool encodeDataFrame:data] length];
//        if (len <= 4096) {
//            if (delegate && [delegate respondsToSelector:@selector(onRecevie:received:)]) {
//                [delegate onRecevie:src received:data];
//            }
//        }
//        return currentSeq < total - 1 ? 1 : 0 ;
    
    NSString* str = [data dataString];
    NSLog(@"data string :%@", data.dataString);
    NSArray* dataArr = [str componentsSeparatedByString:@"\t"];
    [delegate onRecevie:src received:data];
    if(dataArr.count <= 2) {
        
        return -1;
    }
    if (total == -1) {
        total = [[dataArr objectAtIndex:1] integerValue];
    }
    
    currentSeq = [[dataArr objectAtIndex:2] integerValue];
//    [delegate onRecevie:src received:data];
    BBLog(@"============%@",dataArr[2]);
    return total- currentSeq - 1;
}

-(void)dealloc {
    [dataBuff release];
    [super dealloc];
}

@end




