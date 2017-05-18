//
//  BBFileClient.m
//  SocketTrial
//
//  Created by iXcoder on 13-12-4.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBFileClient.h"

@interface BBFileClient()<BBSocketClientDelegate>
{
    BOOL writing;              // 是否可以写入
    NSData *fileData;           // 要写入的文件数据
    id<BBSocketClientDelegate> callback;        // 回调代理
}
// 请求写文件(子命令关键字:18)
- (void)requestForWriteFile:(id<BBSocketClientDelegate>)delegate
                     param:(NSString *)param;
// 文件写入(子命令关键字:19)
- (void)writeActionForFile:(NSData *)fileData;

@end

@implementation BBFileClient

- (void)dealloc
{
    [fileData release];
    [super dealloc];
}

-(id)initWith:(NSString*)user {
    self = [super initWith:user];
    if ( self) {
        writing = NO;
        fileData = [[NSData alloc] init];
    }
    return self;
}

#pragma mark -
#pragma mark file operations method

/*!
 *@brief        客户端文件读取请求
 *@function     getFileRequest:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)getFileRequest:(id<BBSocketClientDelegate>)delegate
                 param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0F subcmd:39 str:param];
    BBMultiFrameHandle *multiDelegate = [[[BBMultiFrameHandle alloc] initWithDelegate:delegate] autorelease];
    multiDelegate.totalPosi = 1;
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:multiDelegate];
}

/*!
 *@brief        请求写文件(子命令关键字:18)
 *@function     reqestForWriteFile:param:
 *@param        delegate            -- 回调代理
 *@param        param               -- 请求参数
 *@return       (void)
 */
- (void)requestForWriteFile:(id<BBSocketClientDelegate>)delegate
                      param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0F subcmd:18 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:self];
}

/*!
 *@brief        请求删除文件(子命令关键字:41)
 *@function     requestForDeleteFile:param:
 *@param        delegate            -- 回调代理
 *@param        param               -- 请求参数
 *@return       (void)
 */
- (void)requestForDeleteFile:(id<BBSocketClientDelegate>)delegate
                      param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0F subcmd:41 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
}

/*!
 *@brief        将10进制整数转化为长度为8的16进制字符串
 *@function     decNumber2HexString:
 *@param        num         -- 要转换的数据
 *@return       (NSString)
 */
- (NSString *)decNumber2HexString:(int)num
{
    NSMutableString *target = [NSMutableString stringWithFormat:@"%x", num];
    while ([target length] < 8) {
        [target insertString:@"0" atIndex:0];
    }
    return target;
}

/*!
 *@brief        构造要发送的数据包
 *@function     generateFileUploadFrame:
 *@param        data        -- 要发送的数据源
 *@return       (NSArray)
 */
- (NSArray *)generateFileUploadFrame:(NSData *)data
{
#define PACKAGE_SIZE            (1024 * 2)     // 每个发送包大小2K
    int headerLen = 8;          // 头部长度，包含平台，版本，主命令，子命令，数据长度，校验码
    headerLen += 4;
    int posiLen = 4 * 2;        // 数据中增加起始和结束标志位，各为4(8个16进制字符)
    posiLen += 2;               // 加上始末位后增加两个'\t'标志位
    int dataSizePerPkg = (PACKAGE_SIZE - headerLen - posiLen);// 18为位置
    int size = [data length];
    int pageCount = size % dataSizePerPkg == 0 ? size / dataSizePerPkg : size / dataSizePerPkg + 1;
    
    NSMutableArray *dataArr = [NSMutableArray array];
    for (int i = 0; i < pageCount; i++) {
        int start = i * dataSizePerPkg ;
        int end = MIN((i + 1) * dataSizePerPkg - 1 , size - 1);
        char scape = '\t';
        NSString *start_str = [NSString stringWithFormat:@"%@", [self decNumber2HexString:start]];
        NSString *end_str = [NSString stringWithFormat:@"%@", [self decNumber2HexString:end]];
        NSString *posi = [NSString stringWithFormat:@"%@\t%@\t", start_str, end_str];
        NSMutableData *sendData = [NSMutableData data];
//        [sendData appendBytes:&start length:4];
//        [sendData appendBytes:&scape length:1];
//        [sendData appendBytes:&end length:4];
//        [sendData appendBytes:&scape length:1];
        [sendData appendData:[posi dataUsingEncoding:GBK_ENCODEING]];
        NSRange range = NSMakeRange(start, end - start + 1);
        NSData *subData = [data subdataWithRange:range];
        [sendData appendData:subData];
        BBDataFrame *df = [self createFrame:0x0F subcmd:19 data:sendData];
        [dataArr addObject:df];
    }
    
    return dataArr;
}

/*!
 *@brief        文件写入(子命令关键字:19)
 *@function     writeActionForFile:
 *@param        fData           -- 文件数据
 *@return       (void)
 */
- (void)writeActionForFile:(NSData *)fData
{
    writing = YES;
    NSArray *filePkg = [self generateFileUploadFrame:fData];
    BBDataFrame *lastFrame = nil;
    for (BBDataFrame *df in filePkg) {
        int sendStatus = [self sendData:df];
        if (sendStatus < 0) {
#if DEBUG
            BBLog(@"send data failed with error code :%d", sendStatus);
#endif
            break;
        }
        lastFrame = df;
    }
    BBDataFrame *dataFrame = [self receiveFrame:@30];
    if (dataFrame != nil) {
        [self onRecevie:lastFrame received:dataFrame];
    } else {
        [self onTimeout:lastFrame];
    }
    
}

/*!
 *@brief        客户端文件保存请求(包含文件请求:18和文件写入:19)
 *@function     writeFile:withParam:callbackHandler:
 *@param        data       -- 文件数据
 *@param        param      -- 其他参数
 *                         参数格式:time(2013-12-14 15:16:00),type(0 入侵告警图片 1上传2 定时抓拍3 及时抓拍)
 *                         以\t分割
 *                          e.g.   2013-12-14 15:16:00\t0
 *@param        delegate   -- 回调代理
 *@return       (void)
 */
- (void)writeFile:(NSData *)data
        withParam:(NSString *)param
  callbackHandler:(id<BBSocketClientDelegate>)delegate
{
    if (writing) {
        NSString *msg = @"正在处理上一次写入请求";
#if DEBUG
        BBLog(@">FileClient<%@", msg);
#endif
        if (delegate != nil
            && [delegate respondsToSelector:@selector(onRecevieError:received:)]) {
            BBDataFrame *error = [[BBDataFrame alloc] init];
            error.data = [msg dataUsingEncoding:GBK_ENCODEING];
            [delegate onRecevieError:nil received:error];
            [error release];
        }
        return;
    }
    if (fileData) {
        [fileData release];
    }
    fileData = [[NSData alloc] initWithData:data];
    callback = delegate;
    
    NSMutableString *parameter = [NSMutableString string];
    [parameter appendFormat:@"%@\t", self.user];
    [parameter appendFormat:@"%d\t", [data length]];
    [parameter appendString:param];
    [self requestForWriteFile:self param:parameter];
}

/*!
 *@brief        请求上传文件回调处理
 *@function     requestUploadCallback:from:
 *@param        data        -- 返回的数据
 *@param        src         -- 原发送数据
 *@return       (void)
 */
- (void)requestUploadCallback:(BBDataFrame *)data from:(BBDataFrame *)src
{
    NSString *status = [NSString stringWithFormat:@"%@", data.dataString];
    if (status == nil) {
#if DEBUG
        BBLog(@"请求错误");
#endif
        return ;
    }
    if ([status integerValue] == 0) {
        [self writeActionForFile:fileData];
        [fileData release];
    } else {
        if (callback == nil
            || ![callback respondsToSelector:@selector(onRecevieError:received:)]) {
            return ;
        }
        NSString *msg = nil;
        switch ([status integerValue]) {
            case kFileUploadErrorNoPermission:
                msg = @"权限不足";
                break;
            case kFileUploadErrorLackOfSpace:
                msg = @"磁盘空间不足";
                break;
            case kFileUploadErrorDataFormat:
                msg = @"请求格式错误";
                break;
            default:
                msg = @"未知错误";
                break;
        }
        BBLog(@">ERROR<:%@", msg);
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:msg
                                                             forKey:@"reason"];
        NSError *error = [NSError errorWithDomain:FileSocketErrorDomain
                                             code:[status integerValue]
                                         userInfo:userInfo];
        BBDataFrame *df = [[BBDataFrame alloc] init];
        df.data = [[error description] dataUsingEncoding:GBK_ENCODEING];
        [callback onRecevieError:src received:df];
        [df release];
    }
}

/*!
 *@brief        上传文件回调处理
 *@function     uploadFileCallback:
 *@param        data
 *@return       (void)
 */
- (void)uploadFileCallback:(BBDataFrame *)data from:(BBDataFrame *)src
{
    writing = NO;
    NSArray *rtnArr = [data.dataString componentsSeparatedByString:@"\t"];
    BOOL success = NO;
    BOOL closeConn = NO;
    if (rtnArr == nil || [rtnArr count] < 2) {
        success = NO;
    } else {
        NSString *uploadStatus = [rtnArr objectAtIndex:0];
        success = [uploadStatus isEqualToString:@"0"] ? YES : NO;
        NSString *shouldClose = [rtnArr objectAtIndex:1];
        closeConn = [shouldClose isEqualToString:@"0"] ? YES : NO;
    }
    if (!success) {
        BBLog(@">FileClient< 上传数据错误");
        if (callback && [callback respondsToSelector:@selector(onRecevieError:received:)]) {
            [callback onRecevieError:src received:data];
        }
    } else {
        BBLog(@">FileClient< 上传数据成功");
        [callback onRecevie:src received:data];
    }
    if (closeConn) {
//        [self close];
    }
}


#pragma mark -
#pragma mark 文件服务器验证包

/*!
 *@brief        创建验证包
 *@function     createLoginFrame
 *@param        (void)
 *@return       (BBDataFrame)
 */
-(BBDataFrame*)createLoginFrame
{
    return [self createFrame:0x0F subcmd:21 str:self.user];
}

#pragma mark -
#pragma mark 文件服务器心跳包
/*!
 *@brief        创建心跳包
 *@function     linkTestFrame
 *@param        (void)
 *@return       (BBDataFrame)
 */
-(BBDataFrame*)linkTestFrame
{
#if DEBUG
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    BBLog(@">FileClient< PING AT %@", [df stringFromDate:[NSDate date]]);
    [df release];
#endif
    return [super linkTestFrame];
}

#pragma mark -
#pragma mark BBSocketClient delegate method
- (int)onRecevie:(BBDataFrame *)src received:(BBDataFrame *)data
{
    if (src.MainCmd == 0x0F && src.SubCmd == 18) {
        [self requestUploadCallback:data from:src];
        return 0;
    } else if (src.MainCmd == 0x0F && src.SubCmd == 19){
        [self uploadFileCallback:data from:src];
    }
    return 0;
}

- (void)onRecevieError:(BBDataFrame *)src received:(BBDataFrame *)data
{
    if (callback && [callback respondsToSelector:@selector(onRecevieError:received:)]) {
        [callback onRecevieError:src received:data];
    }
}

- (void)onTimeout:(BBDataFrame *)src
{
    [callback onTimeout:src];
}

@end
