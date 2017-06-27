//
//  BBTabBarController.m
//  ZgSafe
//
//  Created by Mark on 2017/5/17.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "BBRootTabbarController.h"
#import "ZGanHomeViewController.h"
#import "ZGanMeViewController.h"
#import "ZGanSecurityViewController.h"
#import "ZGanControlViewController.h"
#import "BBLoginViewController.h"
#import "Defines.h"
#import "BBSocketManager.h"


static const NSInteger kBaseTag  =  100;

@interface BBRootTabbarController () <BBSocketClientDelegate,BBLoginClientDelegate,ASIHTTPRequestDelegate>{
    ZGanHomeViewController             * _homeVC;
    ZGanMeViewController               * _meVC;
    ZGanSecurityViewController         * _securityVC;
    ZGanControlViewController          * _controlVC;
    
    UIView                             * _barView;
    
    SEL _selector;
}

@property (nonatomic, weak) UIButton * selectedButton;

@end

@implementation BBRootTabbarController

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

-(void)loadView
{
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.hidden = YES;
    [self initTabBarControllers];
    [self initTabBarItems];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    BlueBoxer *sysUser = [BlueBoxerManager getCurrentUser];
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:@"passWord"];
    
    if ((username==nil || pwd ==nil) && !sysUser.isLoged) {
        //首次登录
        [self toLoginPage];
        
    }else if (!sysUser.isLoged){
        //自动登录
        _P_UserName=username;
        [[BBSocketManager getInstance] login:username password:pwd delegate:self];
    }else{
        
        [self getAllDatas];
    }
}


-(void)toLoginPage{
    BBLoginViewController *logViewController = [[BBLoginViewController alloc]initWithNibName:@"BBLoginViewController" bundle:nil];
    [self presentViewController:logViewController animated:YES completion:^{
        
    }];
}

- (void)initTabBarControllers
{
    _homeVC = [[ZGanHomeViewController alloc] initWithNibName:@"ZGanHomeViewController" bundle:[NSBundle mainBundle]];
    _controlVC = [[ZGanControlViewController alloc] initWithNibName:@"ZGanControlViewController" bundle:[NSBundle mainBundle]];
    _securityVC = [[ZGanSecurityViewController alloc] initWithNibName:@"ZGanSecurityViewController" bundle:[NSBundle mainBundle]];
    _meVC = [[ZGanMeViewController alloc] initWithNibName:@"ZGanMeViewController" bundle:[NSBundle mainBundle]];
    self.viewControllers = @[_homeVC,_controlVC,_securityVC,_meVC];
    
    [self.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * obj, NSUInteger idx, BOOL * stop) {
        obj.view.frame = CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height - BAR_HEIGHT);
    }];
}

- (void)initTabBarItems
{
    _barView = [[UIView alloc]initWithFrame:CGRectMake(0, VIEW_HEIGHT-BAR_HEIGHT, VIEW_WIDTH, BAR_HEIGHT)];
    _barView.userInteractionEnabled = YES;
    _barView.backgroundColor = [UIColor blackColor];
    NSArray * images = @[@"index_btn_flase.png",@"yckz_btn_false.png",@"jtws_btn_false.png",@"self_btn_false.png"];
    NSArray * selectedImages = @[@"index_btn_true.png",@"yckz_btn_true.png",@"jtws_btn_true.png",@"self_btn_true.png"];
    
    CGFloat buttonWidth = VIEW_WIDTH / MAX(images.count, 1);
    [images enumerateObjectsUsingBlock:^(NSString * imageName, NSUInteger idx, BOOL * stop) {
        NSString * selectedImageName = selectedImages[idx];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(buttonWidth *idx, 0, buttonWidth, BAR_HEIGHT);
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = idx + kBaseTag;
        [button setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:selectedImageName] forState:UIControlStateSelected];
        [_barView addSubview:button];
    }];
    
    [self.view addSubview:_barView];
}

- (void)buttonClick:(UIButton *)sender
{
    self.selectedIndex = sender.tag - kBaseTag;
    if (self.selectedButton == sender) {
        return;
    }
    self.selectedButton.selected = NO;
    self.selectedButton = sender;
    self.selectedButton.selected = YES;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * obj, NSUInteger idx, BOOL * stop) {
        obj.view.frame = CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height - BAR_HEIGHT);
    }];
    _barView.frame = CGRectMake(0, VIEW_HEIGHT-BAR_HEIGHT, VIEW_WIDTH, BAR_HEIGHT);
}

#pragma mark --
#pragma mark -- request manage

/*!
 *@description  请求首页所有数据
 *@function     getAllDatas
 *@param        (void)
 *@return       (void)
 */
- (void)getAllDatas
{
    [self getDatas];
    //    self.view.userInteractionEnabled = NO;
}


/*!
 *@description  请求首页所需的温度湿度数据
 *@function     getDatas
 *@param        (void)
 *@return       (void)
 */
- (void)getDatas
{
    [self getCurrentDeviceThenPerformSelector:@selector(getGuardStatusAndScanCard)];
    
    NSMutableString *requestStr = [NSMutableString stringWithString:@"http://msgservice.zgantech.com/zganweather.aspx?did=YL_CX_001"];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:requestStr]];
    request.delegate = self;
    request.timeOutSeconds = NETWORK_TIMEOUT;
    request.requestMethod = @"GET";
    request.shouldAttemptPersistentConnection = NO;
    [request startAsynchronous];
    
}
/*!
 *@description  获取布防状态
 *@function     getGuardStatusAndScanCard
 *@param        (void)
 *@return       (void)
 */
- (void)getGuardStatusAndScanCard
{
    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
    NSString *userId = curUser.userid;
    [mainClient queryCurrentStatus:self param:userId];
    [mainClient scanCard2:self param:userId];
}

/*!
 *@description  获取当前设备
 *@function     getCurrentDeviceThenPerformSelector:
 *@param        selector    --选择事件
 *@return       (void)
 */
- (void)getCurrentDeviceThenPerformSelector:(SEL)selector
{
    _selector = selector;
    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
    NSString *userId = curUser.userid;
    
    [mainClient queryCurrentTerminal:self param:userId];
    
}

/*!
 *@description  注册通知
 *@function     registNotices
 *@param        (void)
 *@return       (void)
 */
- (void)registNotices
{
    //    //消息推送注册
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeSound|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge];
    
    [BBDispatchManager clearStack];
    
    BlueBoxer *user = curUser;
    
    if (user.regardRemindOpened) {
        //注册布s防通知
        [BBDispatchManager registerHandler:self forMainCmd:0x0d subCmd:1];
        //注册撤防通知
        [BBDispatchManager registerHandler:self forMainCmd:0x0d subCmd:2];
    }
    
    if (user.warnPushOpened) {
        //注册入侵报警通知
        [BBDispatchManager registerHandler:self forMainCmd:0x0d subCmd:3];
        //注册温度报警通知
        // [BBDispatchManager registerHandler:self forMainCmd:0x0d subCmd:16];
        ////注册湿度通知
        //[BBDispatchManager registerHandler:self forMainCmd:0x0d subCmd:17];
    }
    
    if (user.backHomeRemindOpened) {
        //注册归家/离家通知
        [BBDispatchManager registerHandler:self forMainCmd:0x0d subCmd:23];
    }
    
    //注册新增图片通知
    [BBDispatchManager registerHandler:self forMainCmd:0x0f subCmd:40];
}

#pragma mark --
#pragma mark -- BBSocketClientDelegate
-(int)onRecevie:(BBDataFrame*)src received:(BBDataFrame*)data
{
    if (src) {
        //不是通知消息
//        if(src.MainCmd == 0x0E && src.SubCmd == 1) {
//            //步防
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self handleReceiveRegard:src data:data];
//            });
//        } else if (src.MainCmd == 0x0E && src.SubCmd == 2) {
//            //撤防
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self handleReceiveCancelRegard:src data:data];
//            });
//            
//        }else if (src.MainCmd == 0x0E && src.SubCmd == 72) {
//            //当前布防状态
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self handleReceiveCurrentRegard:src data:data];
//            });
//        }else
            if (src.MainCmd == 0x0E && src.SubCmd == 74) {
            //获取温度值
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //                [self handleReceiveTemperature:src data:data];
            //            });
            
        }else if (src.MainCmd == 0x0E && src.SubCmd == 75) {
            //获取湿度值
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //                [self handleReceiveHumidity:src data:data];
            //            });
            
        }else if (src.MainCmd == 0x0E && src.SubCmd == 4) {
            //获扫描卡片
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleReceiveRFID:src data:data];
            });
        }else if (src.MainCmd == 0x0E && src.SubCmd == 84) {
            //获取温度曲线
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //                [self handleReceiveTemperatureLine:src data:data];
            //            });
        }else if (src.version==2 && src.MainCmd == 0x0E && src.SubCmd == 80) {
            //获取当前绑定终端
            dispatch_async(dispatch_get_main_queue(), ^{
//                [self handleReceiveUserDeviceID:src data:data];
            });
        }
    }
    
    return 0;
}

-(void)onRecevieError:(BBDataFrame*)src received:(BBDataFrame*)data
{

}

-(void)onTimeout:(BBDataFrame*)sr
{

}

/*!
 *@description  处理获取RFID结果
 *@function     handleReceiveRFID:data:
 *@param        src     --
 *@return       data    --返回数据
 */
- (void)handleReceiveRFID:(BBDataFrame *)src data:(BBDataFrame *)data{
    NSString *result = [[NSString alloc] initWithString:[data dataString]];
    
//    [_members removeAllObjects];
    NSMutableArray *_members = [NSMutableArray array];
    if(result){
        NSArray *aryData=[result componentsSeparatedByString:@"\t"];
        if(aryData.count>2){
            if([aryData[0] intValue]>0){
                int i=2;
                while (i<(aryData.count-1)) {
                    NSDictionary *dic = @{
                                          @"id":aryData[i],
                                          @"name":aryData[i+1],
                                          @"status":aryData[i+2]
                                          };
                    
                    [_members addObject:dic];
                    
                    i=i+4;
                }
                
            }
        }
    }
    
    [self genMemberView:_members];
    
}



/*!
 *@brief        生成成员列表
 *@function     genMemberView:
 *@param        mems
 *@return       (void)
 */
- (void)genMemberView:(NSArray *)mems
{
//#define MEM_VIEW_WIDTH 45.0f
//    for (BBMemberView *view in _memView.subviews) {
//        [view removeFromSuperview];
//    }
//    NSUInteger count = [mems count];
//    CGFloat start = 0;
//    int i = 0;
//    for (NSDictionary *member in mems) {
//        if (i%5==0) {
//            NSInteger last = count - i;
//            if (last >= 5) {
//                start = MEM_VIEW_WIDTH * i;
//            }else{
//                start = MEM_VIEW_WIDTH*(5-last)/2.0f
//                + MEM_VIEW_WIDTH*i;
//            }
//        }
//        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"BBMemberView" owner:nil options:nil];
//        BBMemberView *view = (BBMemberView *)[nibs objectAtIndex:0];
//        view.photo.highlighted = _offLine;
//        CGRect frame = view.frame;
//        frame.origin.x = start + (i%5) * frame.size.width;
//        view.frame = frame;
//        view.name = [[mems[i] valueForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//        view.isOnline = [[mems[i] valueForKey:@"status"]boolValue];
//        view.isMale = YES;
//        [self.memView addSubview:view];
//        i++;
//    }
//    
//    if (count%5 != 0) {
//        count = count + 5-(count+5)%5;
//    }
//    [self.memView setContentSize:CGSizeMake(count*MEM_VIEW_WIDTH, self.memView.frame.size.height)];
}

#pragma mark -
#pragma mark ASIHTTPRequestDelegate method

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingAllowFragments error:nil];
    if (result) {
        NSArray *arr = [result valueForKey:@"data"];
        if (arr && arr.count) {
            NSDictionary *dic = arr[0];
            NSString *str = [dic valueForKey:@"Wd"];
            arr = [str componentsSeparatedByString:@"/"];
            
            NSString *tempStr = [arr[0] stringByReplacingOccurrencesOfString:@"℃" withString:@""];
            CGFloat temperature = [tempStr floatValue];
            
//            _temperatureValueLbl.text = [NSString stringWithFormat:@"%d",(NSInteger)(temperature+0.5f)];
//            
//            if (temperature >= 60.) {
//                [self temperature];
//            }
//            if (temperature > 35.) {
//                _temperatureDescription.text = @"热";
//            }else if (temperature > 26. && temperature <= 35.) {
//                _temperatureDescription.text = @"暖";
//            }else if (temperature > 17. && temperature <= 26.) {
//                _temperatureDescription.text = @"舒适";
//            }else if (temperature >= 10. && temperature <= 17.) {
//                _temperatureDescription.text = @"凉";
//            }else{
//                _temperatureDescription.text = @"冷";
//            }
//            
//            
//            //湿度
//            str = [dic valueForKey:@"Sd"];
//            NSString *humStr = [str stringByReplacingOccurrencesOfString:@"%" withString:@""];
//            
//            CGFloat humidity = [humStr floatValue];
//            _humidityValueLbl.text = [NSString stringWithFormat:@"%d",(NSInteger)(humidity+0.5f)];
//            humidity /= 100.;
//            if (humidity < 0.4f) {
//                _humidityImageView.image = [UIImage imageNamed:@"img8.png"];
//                _humidityDescription.text = @"干燥";
//            }else if (humidity < 0.6f) {
//                _humidityImageView.image = [UIImage imageNamed:@"img7.png"];
//                _humidityDescription.text = @"适宜";
//            }else{
//                _humidityImageView.image = [UIImage imageNamed:@"img2.png"];
//                _humidityDescription.text = @"潮湿";
//            }
            
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
}


-(void)loginReceiveData:(BBDataFrame *)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *result = [[NSString alloc]initWithBytes:[data.data bytes] length:data.data.length encoding:GBK_ENCODEING];
        
        if(result){
            NSArray *arr = [result componentsSeparatedByString:@"\t"];
            
            if ([arr[0] isEqualToString:@"0"]  ) {
                BlueBoxer *sysUser = [BlueBoxerManager getCurrentUser];
                sysUser.loged = YES;
                sysUser.deviceid=nil;
                sysUser.userid=_P_UserName;
                [BlueBoxerManager archiveCurrentUser:sysUser];
                
                BBLoginClient* login = [[BBLoginClient alloc] init];
                [login getServerList:curUser.userid deleagte:self];
//                [self getAllDatas];
//                [self registNotices];
                
            }else{
                [self toLoginErr];
                UtilAlert(@"登录失败！", nil);
            }
            
        }else{
            [self toLoginErr];
        }
        
        
    });
}

//登录失败
-(void)toLoginErr{
    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"passWord"];
    BlueBoxer *sysUser = [BlueBoxerManager getCurrentUser];
    sysUser.loged = NO;
    sysUser.deviceid=nil;
    sysUser.username=nil;
    [BlueBoxerManager archiveCurrentUser:sysUser];
    [self toLoginPage];
}

#pragma mark -
#pragma mark UncaughtExceptionDelegate method
- (void)didIgnoredSignal:(int)sig
{
    
    if (sig == SIGPIPE) {
        
        UtilAlert(@"登录失败！", nil);
        
        //重复登录本地下线

        [self toLoginErr];
        
        BlueBoxer *user = curUser;
        user.loged = NO;
        [BlueBoxerManager archiveCurrentUser:user];
        BBLoginViewController *loginVc = [[BBLoginViewController alloc]init];
        [appDelegate.homePageVC presentViewController:loginVc animated:YES completion:nil];
        
    }
}

- (void)getServerListData:(BBDataFrame *)data
{
    NSArray* result;
    result = [data.dataString componentsSeparatedByString:@"\t"];
    if (result.count < 2) {
        return ;
    }
    
    NSMutableDictionary* dict2 = [[NSMutableDictionary alloc] init];
    
    int count = [result[0] intValue];
    for ( int i = 1 ; i <= count ; i++)
    {
        NSArray* hostinfo = [result[i] componentsSeparatedByString:@":"];
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setObject:hostinfo[0] forKey:@"ip"];
        [dict setObject:hostinfo[1] forKey:@"port"];
        [dict setObject:hostinfo[2] forKey:@"server"];
        
        [dict2 setObject:dict forKey:hostinfo[2]];
    }
    
    [BBSocketManager getInstance].hostInfoDict = dict2;
    [BBSocketManager getInstance].user = curUser.userid;
    NSLog(@"ip dic ===== %@", dict2);
}

- (void)getServerListErrorInfo:(NSString *)errorInfo
{
    
}

@end
