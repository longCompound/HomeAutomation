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


static const NSInteger kBaseTag  =  100;

@interface BBRootTabbarController () <BBSocketClientDelegate,BBLoginClientDelegate>{
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
    //to do 此处布放消息请求先注释  新版没看到布放的内容
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

#pragma mark --
#pragma mark -- BBSocketClientDelegate
-(int)onRecevie:(BBDataFrame*)src received:(BBDataFrame*)data
{
    return 1;
}

-(void)onRecevieError:(BBDataFrame*)src received:(BBDataFrame*)data
{

}

-(void)onTimeout:(BBDataFrame*)sr
{

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
                
                [self getAllDatas];
                
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


@end
