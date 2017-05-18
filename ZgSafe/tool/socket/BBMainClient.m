//
//  BBMainClient.m
//  SocketTrial
//
//  Created by iXcoder on 13-12-4.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBMainClient.h"

@interface BBMainClient ()<BBSocketClientDelegate>
{
    id<BBSocketClientDelegate> regDel;  // 注册回调代理
    NSArray *regParam;                 // 注册参数
}
@end

@implementation BBMainClient

/*!
 *@brief        布防(子命令关键字1)
 *@function     addControl:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)addControl:(id<BBSocketClientDelegate>)delegate
             param:(NSString*)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:1 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
    
}

/*!
 *@brief        撤防(子命令关键字2)
 *@function     cancelControl:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)cancelControl:(id<BBSocketClientDelegate>)delegate
                param:(NSString*)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:2 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
    
}

/*!
 *@brief        报警抓拍(子命令关键字:3)
 *@function     warningSnap:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)warningSnap:(id<BBSocketClientDelegate>)delegate
              param:(NSString*)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:3 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
}

/*!
 *@brief        扫描卡片(子命令关键字:4)
 *@function     scanCard:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)scanCard:(id<BBSocketClientDelegate>)delegate
           param:(NSString*)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:4 str:param];
    BBSeqFrameHandle *seqDelegate = [[BBSeqFrameHandle alloc] initWithDelegate:delegate];
    seqDelegate.isRFID = YES;// 随身保带图片信息
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:seqDelegate];
    [seqDelegate release];
}

/*!
 *@brief        扫描卡片(子命令关键字:4，协议:2)
 *@function     scanCard:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)scanCard2:(id<BBSocketClientDelegate>)delegate
           param:(NSString*)param
{
    BBDataFrame *df=[self createFrame:2 version:0x0E subcmd:4 data:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
}

/*!
 *@brief        请求注册卡片(子命令关键字:5)
 *@function     applyForRegistCard :param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)applyForRegistCard:(id<BBSocketClientDelegate>)delegate
                     param:(NSString*)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:5 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
}


/*!
 *@brief        注册卡片(子命令关键字:5)
 *@function     registCard:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)registCard:(id<BBSocketClientDelegate>)delegate
                     param:(NSData*)data
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:5 data:data];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
}

/*!
 *@brief        注册卡片(子命令关键字:5)
 *@function     registerCard:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)registerCard:(id<BBSocketClientDelegate>)delegate
               param:(NSArray *)param
{
    if (regDel != nil) {
        [regDel release];
    }
    regDel = [delegate retain];
    
    if (regParam != nil) {
        [regParam release];
    }
    regParam = [param retain];
    //step 1:申请注册卡片
    NSString *p = [NSString stringWithFormat:@"0\t%@\t\t\t", self.user];
    BBDataFrame *df = [self createFrame:0x0E subcmd:5 str:p];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:self];
}

/*!
 *@brief        注销卡片(子命令关键字:6)
 *@function     withdrawCard:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)withdrawCard:(id<BBSocketClientDelegate>)delegate
               param:(NSString*)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:6 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
    
}

/*!
 *@brief        抓拍设置(子命令关键字:7)
 *@function     snapSetting:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)snapSetting:(id<BBSocketClientDelegate>)delegate
              param:(NSString*)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:7 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
    
}

/*!
 *@brief        设置视频质量(子命令关键字:24)
 *@function     videoqualitySetting:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)videoqualitySetting:(id<BBSocketClientDelegate>)delegate
              param:(NSString*)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:24 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
    
}

/*!
 *@brief        获取视频质量(子命令关键字:26)
 *@function     videoqualitySetting:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)Getvideoquality:(id<BBSocketClientDelegate>)delegate
                      param:(NSString*)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:26 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
    
}

/*!
 *@brief        抓拍间隔时间(子命令关键字:8)
 *@function     snapTimeInterval:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)snapTimeInterval:(id<BBSocketClientDelegate>)delegate
                   param:(NSString*)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:8 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
    
}

/*!
 *@brief        视频密码(子命令关键字:9)
 *@function     videoPassword:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)videoPassword:(id<BBSocketClientDelegate>)delegate
                param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:9 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
    
}

/*!
 *@brief        视频密码校验(子命令关键字:10)
 *@function     checkVideoPassword:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)checkVideoPassword:(id<BBSocketClientDelegate>)delegate
                     param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:10 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
    
}

/*!
 *@brief        抓拍分辨率设置(子命令关键字:11)
 *@function     setResolution:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)setResolution:(id<BBSocketClientDelegate>)delegate
                param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:11 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
    
}

/*!
 *@brief        定时抓拍时间(子命令关键字:12)
 *@function     setTrimCapture:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)setTrimCapture:(id<BBSocketClientDelegate>)delegate
                 param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:12 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
    
}

// 蜂鸣控制(子命令关键字13)
//      -- 开启(1)
/*!
 *@brief        开启蜂鸣
 *@function     startBeep:
 *@param        delegate        -- 回调代理
 *@return       (void)
 */
-(void)startBeep:(id<BBSocketClientDelegate>)delegate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    
    NSString *param = [NSString stringWithFormat:@"%@\t1\t%@",curUser.userid,dateStr];
    
    BBDataFrame *df = [self createFrame:0x0E subcmd:13 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
    
}
//      -- 关闭(0)
/*!
 *@brief        关闭蜂鸣
 *@function     stopBeep:
 *@param        delegate        -- 回调代理
 *@return       (void)
 */
-(void)stopBeep:(id<BBSocketClientDelegate>)delegate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    
    NSString *param = [NSString stringWithFormat:@"%@\t0\t%@",curUser.userid,dateStr];
    
    BBDataFrame *df = [self createFrame:0x0E subcmd:13 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
}

/*!
 *@brief        修改设备密码(子命令关键字:20)
 *@function     modifyDevPassword:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)modifyDevPassword:(id<BBSocketClientDelegate>)delegate
                    param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:20 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
    
}

/*!
 *@brief        出入记录查询(子命令关键字:68)
 *@function     queryInOutHistory:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)queryInOutHistory:(id<BBSocketClientDelegate>)delegate
                    param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:68 str:param];
    BBMultiFrameHandle *dl2 = [[[BBMultiFrameHandle alloc] initWithDelegate:delegate] autorelease];
    dl2.totalPosi = 0;
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:dl2];
    
    
}

/*!
 *@brief        布防记录查询(子命令关键字:69)
 *@function     queryAlarmOrCanncelHistory:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)queryAlarmOrCanncelHistory:(id<BBSocketClientDelegate>)delegate
                             param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:69 str:param];
    BBMultiFrameHandle *mutilDelegate = [[BBMultiFrameHandle alloc] initWithDelegate:delegate];
    mutilDelegate.totalPosi = 0;
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:mutilDelegate];
    [mutilDelegate release];
}

/*!
 *@brief        报警记录查询(子命令关键字:70)
 *@function     queryWarningHistory:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)queryWarningHistory:(id<BBSocketClientDelegate>)delegate
                      param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:70 str:param];
    BBMultiFrameHandle *multiDelegate = [[BBMultiFrameHandle alloc] initWithDelegate:delegate];
    multiDelegate.totalPosi = 0;
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:multiDelegate];
    [multiDelegate release];
}

/*!
 *@brief        切换终端(子命令关键字:71)
 *@function     changeTerminal:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)changeTerminal:(id<BBSocketClientDelegate>)delegate
                 param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:71 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
}

/*!
 *@brief        当前布防状态(子命令关键字:72)
 *@function     queryCurrentStatus:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)queryCurrentStatus:(id<BBSocketClientDelegate>)delegate
                     param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:72 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
}

/*!
 *@brief        获取用户等级(子命令关键字:73)
 *@function     queryUserRank:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)queryUserRank:(id<BBSocketClientDelegate>)delegate
                param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:73 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
}

/*!
 *@brief        获取温度值(子命令关键字:74)
 *@function     queryCurrentTemp:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)queryCurrentTemp:(id<BBSocketClientDelegate>)delegate
                   param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:74 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
    
    
}

/*!
 *@brief        获取湿度值(子命令关键字:75)
 *@function     queryCurrentHumidity:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)queryCurrentHumidity:(id<BBSocketClientDelegate>)delegate
                       param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:75 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
    
}

/*!
 *@brief        获取积分(子命令关键字:76)
 *@function     queryCurrentScore:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)queryCurrentScore:(id<BBSocketClientDelegate>)delegate
                    param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:76 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
    //malloc_error_break
    
}

/*!
 *@brief        获取用户信息(子命令关键字:77)
 *@function     queryUserInfo:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)queryUserInfo:(id<BBSocketClientDelegate>)delegate
                param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:77 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
    
}

/*!
 *@brief        修改用户信息(子命令关键字:78)
 *@function     changeUserInfo:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)changeUserInfo:(id<BBSocketClientDelegate>)delegate
                 param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:78 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
    
}

/*!
 *@brief        获取紧急联系电话(子命令关键字:79)
 *@function     queryEmergencyNumber:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)queryEmergencyNumber:(id<BBSocketClientDelegate>)delegate
                param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:79 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
    
}

/*!
 *@brief        获取当前绑定终端
 *@function     queryCurrentTerminal:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)queryCurrentTerminal:(id<BBSocketClientDelegate>)delegate
                       param:(NSString *)param
{
    BBDataFrame *df=[self createFrame:2 version:0x0e subcmd:80 data:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
}

/*!
 *@brief        用户反馈信息
 *@function     userFeedBack:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)userFeedBack:(id<BBSocketClientDelegate>)delegate
               param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:81 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
}

/*!
 *@brief        获取当前用户设备信息
 *@function     queryUserDevices:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)queryUserDevices:(id<BBSocketClientDelegate>)delegate
                   param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:2 version:0x0E subcmd:82 data:param];
    
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
}


/*!
 *@brief        慧应用广告URL
 *@function     queryHuiAppUrls:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)queryHuiAppUrls:(id<BBSocketClientDelegate>)delegate
                  param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:83 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
}


/*!
 *@brief        获取温度曲线表
 *@function     queryTemperatureLine:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)queryTemperatureLine:(id<BBSocketClientDelegate>)delegate
                       param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:84 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
}

/*!
 *@brief        获取关于信息
 *@function     queryAboutUrl:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)queryAboutUrl:(id<BBSocketClientDelegate>)delegate
                param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:85 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
}

/*!
 *@brief        设备版本
 *@function     queryAboutUrl:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)queryDeviceCode:(id<BBSocketClientDelegate>)delegate
                param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:96 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
}


/*!
 *@brief        慧应用下载
 *@function     huiAppDownLoad:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)huiAppDownLoad:(id<BBSocketClientDelegate>)delegate
                 param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:86 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
}


/*!
 *@brief        删除绑定设备
 *@function     deleteDevice:param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)deleteDevice:(id<BBSocketClientDelegate>)delegate
               param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:87 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
}



/*!
 *@brief        获取抓拍张数
 *@function     querySnapCount :param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)querySnapCount:(id<BBSocketClientDelegate>)delegate
                 param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:88 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
}



/*!
 *@brief        获取定时抓拍参数
 *@function     querySnapCount :param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)querySnapParam:(id<BBSocketClientDelegate>)delegate
                 param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:90 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
}


/*!
 *@brief        修改设备密码
 *@function     setDeviceVerifyCode :param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)setDeviceVerifyCode:(id<BBSocketClientDelegate>)delegate
                         param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:92 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
}

/*!
 *@brief        重置设备密码
 *@function     resetVerifyCode :param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)resetVerifyCode:(id<BBSocketClientDelegate>)delegate
                param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:95 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
}

/*!
 *@brief        发送短信校验码
 *@function     resetVerifyCode :param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
-(void)toSendMSMCode:(id<BBSocketClientDelegate>)delegate
               param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:94 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
}

/*!
 *@brief        开关终端声音
 *@function     openOrCloseDeviceSound :param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)openOrCloseDeviceSound:(id<BBSocketClientDelegate>)delegate
                         param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:97 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
}

/*!
 *@brief        版本更新
 *@function     openOrCloseVer :param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)openOrCloseVer:(id<BBSocketClientDelegate>)delegate
                         param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:2 version:0x0E subcmd:86 data:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
}


/*!
 *@brief        获取终端声音状态
 *@function     openOrCloseDeviceSound :param:
 *@param        delegate        -- 回调代理
 *@param        param           -- 参数
 *@return       (void)
 */
- (void)getDeviceSoundState:(id<BBSocketClientDelegate>)delegate
                         param:(NSString *)param
{
    BBDataFrame *df = [self createFrame:0x0E subcmd:98 str:param];
    [self queueData:df timeout:NETWORK_TIMEOUT delegate:delegate];
}

#pragma mark -
#pragma mark generate PING package
/*!
 *@brief        创建心跳包
 *@function     linkTestFrame
 *@param        (void)
 *@return       (BBDataFrame)
 */
-(BBDataFrame*)linkTestFrame
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    BBLog(@">MainClient< PING AT %@", [df stringFromDate:[NSDate date]]);
    [df release];
    return [super linkTestFrame];
}


#pragma mark -
#pragma mark BBSocketClientDelegate method
- (int)onRecevie:(BBDataFrame *)src received:(BBDataFrame *)data
{
    if (src.MainCmd == 0x0E && src.SubCmd == 5) {// 请求注册卡片返回
//        NSString *dataString = data.dataString;
//        BBLog(@"register result:%@", dataString);
//        NSArray *results = [dataString componentsSeparatedByString:@"\t"];
//        if (!results || [results count] < 2
//            ||![results[0] isEqualToString:@"0"]) {
//            BBLog(@">MainClient< 请求注册卡片失败");
//            if (regDel && [regDel respondsToSelector:@selector(onRecevieError:received:)]) {
//                [regDel onRecevieError:src received:data];
//                [regDel release];
//                regDel = nil;
//                [regParam release];
//                regParam = nil;
//            }
        } else {
//            // step 2: 发送注册信息
//            NSMutableData *data = [NSMutableData data];
//            //      模式:1
//            [data appendData:[@"1" dataUsingEncoding:GBK_ENCODEING]];
//            //      用户ID
//            NSString *userID = [NSString stringWithFormat:@"\t%@", self.user];
//            [data appendData:[userID dataUsingEncoding:GBK_ENCODEING]];
//            //      卡片ID
//            NSString *cardID = [NSString stringWithFormat:@"\t%@", results[1]];
//            [data appendData:[cardID dataUsingEncoding:GBK_ENCODEING]];
//            //      昵称
//            NSString *nickName = [regParam objectAtIndex:0];
//            [data appendData:[nickName dataUsingEncoding:GBK_ENCODEING]];
//            //      头像数据
//            [data appendData:[regParam objectAtIndex:1]];
//            BBDataFrame *df = [self createFrame:0x0E subcmd:5 data:data];
//            [self queueData:df timeout:NETWORK_TIMEOUT delegate:regDel];
//            [regDel release];
//            [regParam release];
//        }
    }
    return 0;
}

- (void)onRecevieError:(BBDataFrame *)src received:(BBDataFrame *)data
{
    if (src.MainCmd == 0x0E && src.SubCmd == 5) {// 请求注册卡片返回
        if (regDel && [regDel respondsToSelector:@selector(onRecevieError:received:)]) {
            [regDel onRecevieError:src received:data];
            [regDel release];
            regDel = nil;
            [regParam release];
            regParam = nil;
        }
    }
}

- (void)onTimeout:(BBDataFrame *)src
{
    if (src.MainCmd == 0x0E && src.SubCmd == 5) {// 请求注册卡片返回
        if (regDel && [regDel respondsToSelector:@selector(onTimeout:)]) {
            [regDel onTimeout:src];
            [regDel release];
            regDel = nil;
            [regParam release];
            regParam = nil;
        }
    }
    
    
    
}

@end
