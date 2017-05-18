//
//  defines.h
//  SocketTrial
//
//  Created by iXcoder on 13-11-29.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//
#include <Foundation/Foundation.h>

#ifndef SocketTrial_defines_h
#define SocketTrial_defines_h

#define LOG_SERVER_PATH         @"cloudlogin1.zgantech.com"
#define LOG_SERVER_PORT         21000//
#define LOG_SERVER_IP           @"61.186.245.252" //61.186.245.252 115.29.147.12
#define LOG_USR                 @"55555555"
#define LOG_PWD                 @"66666666"

//#define NETWORK_TIMEOUT 60

#pragma mark -
#pragma mark ERROR_CODE define

#define ERR_OK                  '0'     // 无错误
#define ERR_NORMAL              '1'     // 常规错误
#define ERR_BUFFER_FALSE		'2'		// 申请缓冲失
#define ERR_NOT_MAIN_FUN		'3'		// 无此主功能号
#define ERR_NOT_SUB_FUN			'4'		// 无此子功能号
#define ERR_DISABLE_LOGIN		'5'		// 禁止登录
#define ERR_RECORD_NOT_EXIST	'6'		// 数据记录不存在
#define ERR_DATA_FORMAT			'7'		// 数据格式错误
#define ERR_USER_NOT_EXIST		'8'		// 用户不存在
#define ERR_DEVICE_NOT_EXIST	'9'		// 设备不存在
#define ERR_NOT_ME              'A'		// 不是家庭卫士服务器的协议
#define ERR_INVALIDATE_PLATFORM	'B'		// 错误的客户端或终端
#define ERR_DEVICE_OLD_CRC		'C'		// 老的CRC码错
#define ERR_DB_INSERT			'D'		// 数据库插入数据错误
#define ERR_DB_MAC_NOT_EXIST	'E'		// MAC地址不存在
#define ERR_FILE_CREATE_FALSE	'G'		// 文件创建失败
#define ERR_FILE_NO_FREEDISK	'H'		// 磁盘空间不够
#define ERR_PARAMS              'I'     // 参数错误, 如错误的序号
#define ERR_DISABLE_DEL_DEV     'J'     // 绑定设备不能删除
#define ERR_RFID_EXISTS         'K'     // RFID已经存在, 不允许重新注册
#define ERR_RFID_BIND           'L'     // RFID不是该设备的

#define PING_TIME_INTERVAL  30      // 以秒计算


#ifndef GBK_ENCODEING
//#define GBK_ENCODEING NSUTF8StringEncoding
#define GBK_ENCODEING CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)
#endif

#ifdef BBLog
#undef BBLog
#endif

#if DEBUG
    #define BBLog(format, ...) {\
        NSDateFormatter *log_df = [[NSDateFormatter alloc] init];\
        [log_df setDateFormat:@"HH:mm:ss"];\
        NSMutableString *log_result = [NSMutableString stringWithString:[log_df stringFromDate:[NSDate date]]];\
        [log_df release];\
        NSString *log_fileName = [NSString stringWithFormat:@"%s",__FILE__];\
        log_fileName = [log_fileName lastPathComponent];\
        [log_result appendFormat:@" %@", log_fileName];\
        [log_result appendFormat:@"[LINE:%d]", __LINE__];\
        NSString *printCtnt = [NSString stringWithFormat:format, ##__VA_ARGS__];\
        [log_result appendFormat:@" %@", printCtnt];\
        printf("\n%s ", [log_result UTF8String]);\
    }
#else
    #define BBLog(format, ...)
#endif


#endif
