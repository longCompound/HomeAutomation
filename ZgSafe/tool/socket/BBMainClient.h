//
//  BBMainClient.h
//  SocketTrial
//
//  Created by iXcoder on 13-12-4.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBSocketClient.h"

/*!
 *  家庭卫视主服务器socket
 *  主命令关键字:0x0E
 *
 */
@interface BBMainClient : BBSocketClient
{
    
}

// 布防(子命令关键字:1)
- (void)addControl:(id<BBSocketClientDelegate>)delegate
             param:(NSString*)param;

// 撤防(子命令关键字:2)
- (void)cancelControl:(id<BBSocketClientDelegate>)delegate
                param:(NSString*)param;

// 报警抓拍(子命令关键字:3)
- (void)warningSnap:(id<BBSocketClientDelegate>)delegate
              param:(NSString*)param;

// 扫描卡片(子命令关键字:4)
- (void)scanCard:(id<BBSocketClientDelegate>)delegate
           param:(NSString*)param;

- (void)scanCard2:(id<BBSocketClientDelegate>)delegate
           param:(NSString*)param;

//请求注册卡片(子命令关键字:5)
- (void)applyForRegistCard:(id<BBSocketClientDelegate>)delegate
                     param:(NSString*)param;
// 注册卡片(子命令关键字:5)
//   param格式:[昵称, 头像], e.g. [@"NickName", 0x245a6525 ... 0x2315]
- (void)registerCard:(id<BBSocketClientDelegate>)delegate
               param:(NSArray *)param;
//注册卡片(子命令关键字:5)
- (void)registCard:(id<BBSocketClientDelegate>)delegate
             param:(NSData*)data;

// 注销卡片(子命令关键字:6)
- (void)withdrawCard:(id<BBSocketClientDelegate>)delegate
               param:(NSString*)param;

// 抓拍设置(子命令关键字:7)
- (void)snapSetting:(id<BBSocketClientDelegate>)delegate
              param:(NSString*)param;

// 抓拍间隔时间(子命令关键字:8)
- (void)snapTimeInterval:(id<BBSocketClientDelegate>)delegate
                   param:(NSString*)param;

// 设置视频质量(子命令关键字:24)
- (void)videoqualitySetting:(id<BBSocketClientDelegate>)delegate
                   param:(NSString*)param;

// 获取视频质量(子命令关键字:26)
- (void)Getvideoquality:(id<BBSocketClientDelegate>)delegate
                      param:(NSString*)param;

// 视频密码(子命令关键字:9)
- (void)videoPassword:(id<BBSocketClientDelegate>)delegate
                param:(NSString *)param;

// 视频密码校验(子命令关键字:10)
- (void)checkVideoPassword:(id<BBSocketClientDelegate>)delegate
                     param:(NSString *)param;

// 抓拍分辨率设置(子命令关键字:11)
- (void)setResolution:(id<BBSocketClientDelegate>)delegate
                param:(NSString *)param;

// 定时抓拍时间(子命令关键字:12)
- (void)setTrimCapture:(id<BBSocketClientDelegate>)delegate
                 param:(NSString *)param;

// 蜂鸣控制(子命令关键字13)
//      -- 开启(1)
-(void)startBeep:(id<BBSocketClientDelegate>)delegate;
//      -- 关闭(0)
-(void)stopBeep:(id<BBSocketClientDelegate>)delegate;

// 修改设备密码(子命令关键字:20)
- (void)modifyDevPassword:(id<BBSocketClientDelegate>)delegate
                    param:(NSString *)param;

// 出入记录查询(子命令关键字:68)
- (void)queryInOutHistory:(id<BBSocketClientDelegate>)delegate
                param:(NSString *)param;

// 布防记录查询(子命令关键字:69)
- (void)queryAlarmOrCanncelHistory:(id<BBSocketClientDelegate>)delegate
                             param:(NSString *)param;

// 报警记录查询(子命令关键字:70)
- (void)queryWarningHistory:(id<BBSocketClientDelegate>)delegate
                      param:(NSString *)param;

// 切换终端(子命令关键字:71)
- (void)changeTerminal:(id<BBSocketClientDelegate>)delegate
                 param:(NSString *)param;

// 当前布防状态(子命令关键字:72)
- (void)queryCurrentStatus:(id<BBSocketClientDelegate>)delegate
                     param:(NSString *)param;

- (void)setDeviceVerifyCode:(id<BBSocketClientDelegate>)delegate
                      param:(NSString *)param;
// 获取用户等级(子命令关键字:73)
- (void)queryUserRank:(id<BBSocketClientDelegate>)delegate
                param:(NSString *)param;

// 获取温度值(子命令关键字:74)
- (void)queryCurrentTemp:(id<BBSocketClientDelegate>)delegate
                   param:(NSString *)param;

// 获取湿度值(子命令关键字:75)
- (void)queryCurrentHumidity:(id<BBSocketClientDelegate>)delegate
                       param:(NSString *)param;

// 获取积分(子命令关键字:76)
- (void)queryCurrentScore:(id<BBSocketClientDelegate>)delegate
                    param:(NSString *)param;

- (void)openOrCloseDeviceSound:(id<BBSocketClientDelegate>)delegate
                         param:(NSString *)param;
// 获取用户信息(子命令关键字:77)
- (void)queryUserInfo:(id<BBSocketClientDelegate>)delegate
                param:(NSString *)param;

// 修改用户信息(子命令关键字:78)
- (void)changeUserInfo:(id<BBSocketClientDelegate>)delegate
                 param:(NSString *)param;

// 获取紧急联系电话(子命令关键字:79)
- (void)queryEmergencyNumber:(id<BBSocketClientDelegate>)delegate
                       param:(NSString *)param;

// 获取当前绑定终端
- (void)queryCurrentTerminal:(id<BBSocketClientDelegate>)delegate
                       param:(NSString *)param;
//用户反馈信息

- (void)userFeedBack:(id<BBSocketClientDelegate>)delegate
               param:(NSString *)param;
- (void)getDeviceSoundState:(id<BBSocketClientDelegate>)delegate
                      param:(NSString *)param;
//获取当前用户设备信息
- (void)queryUserDevices:(id<BBSocketClientDelegate>)delegate
                   param:(NSString *)param;
//慧应用广告URL
- (void)queryHuiAppUrls:(id<BBSocketClientDelegate>)delegate
                  param:(NSString *)param;
//获取温度曲线表
- (void)queryTemperatureLine:(id<BBSocketClientDelegate>)delegate
                       param:(NSString *)param;
//获取关于信息
- (void)queryAboutUrl:(id<BBSocketClientDelegate>)delegate
                param:(NSString *)param;
//慧应用下载
- (void)huiAppDownLoad:(id<BBSocketClientDelegate>)delegate
                 param:(NSString *)param;

//删除绑定设备
- (void)deleteDevice:(id<BBSocketClientDelegate>)delegate
               param:(NSString *)param;
//获取抓拍张数
- (void)querySnapCount:(id<BBSocketClientDelegate>)delegate
                 param:(NSString *)param;

//获取定时抓拍参数
- (void)querySnapParam:(id<BBSocketClientDelegate>)delegate
                 param:(NSString *)param;
//设备版本
- (void)queryDeviceCode:(id<BBSocketClientDelegate>)delegate
                  param:(NSString *)param;
//重置验证码
-(void)resetVerifyCode:(id<BBSocketClientDelegate>)delegate
                 param:(NSString *)param;

- (void)openOrCloseVer:(id<BBSocketClientDelegate>)delegate
                 param:(NSString *)param;
//发送短信校验码
-(void)toSendMSMCode:(id<BBSocketClientDelegate>)delegate
               param:(NSString *)param;

@end
