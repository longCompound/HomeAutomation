//
//  BBFileClient.h
//  SocketTrial
//
//  Created by iXcoder on 13-12-4.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBSocketClient.h"

static NSString *FileSocketErrorDomain = @"FileSocketErrorDomain";

typedef NS_ENUM(NSInteger, FileUploadError) {
    kFileUploadErrorUnknown = -1,   // 未知错误
    kFileUploadErrorNone,           // 允许保存
    kFileUploadErrorNoPermission,   // 权限不足
    kFileUploadErrorLackOfSpace,    // 磁盘空间不足
    kFileUploadErrorDataFormat,     // 客户端数据格式错误
};



/*!
 *  文件服务器socket
 *  主命令关键字:0x0F
 *
 */
@interface BBFileClient : BBSocketClient

/*!
 *@brief        客户端文件读取请求(子命令关键字:39)
 *@function     getFileRequest:param:
 *@param        delegate        -- 文件数据
 *@param        param           -- 其他参数
 *@return       (void)
 */
- (void)getFileRequest:(id<BBSocketClientDelegate>)delegate
                 param:(NSString *)param;

/*!
 *@brief        客户端文件保存请求(包含文件请求:18和文件写入:19)
 *@function     writeFile:withParam:callbackHandler:
 *@param        data       -- 文件数据
 *@param        param      -- 其他参数
 *                         参数格式:time(2013-12-14 15:16:00),type(0:其他,1:入侵,2:即时抓拍,3:定时)
 *                         以\t分割
 *                          e.g.   2013-12-14 15:16:00\t0
 *@param        delegate   -- 回调代理
 *@return       (void)
 */
- (void)writeFile:(NSData *)data withParam:(NSString *)param callbackHandler:(id<BBSocketClientDelegate>)delegate;


/*!
 *@brief        请求删除文件(子命令关键字:41)
 *@function     requestForDeleteFile:param:
 *@param        delegate            -- 回调代理
 *@param        param               -- 请求参数
 *@return       (void)
 */
- (void)requestForDeleteFile:(id<BBSocketClientDelegate>)delegate
                       param:(NSString *)param;


/*!
 *@brief        请求上传文件(子命令关键字:18)
 *@function     requestForWriteFile:param:
 *@param        delegate            -- 回调代理
 *@param        param               -- 请求参数
 *@return       (void)
 */
-(void)requestForWriteFile:(id<BBSocketClientDelegate>)delegate
                     param:(NSString *)param;
@end
