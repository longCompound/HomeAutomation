//
//  BBViewController.m
//  ZgSafe
//
//  Created by iXcoder on 13-10-24.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBHomePageController.h"
#import "BBMemberView.h"
#import "BBNewsEyesViewController.h"
#import "BBMarkViewController.h"
#import "BBAlbumsViewController.h"
#import "BBHuiAplViewController.h"
#import "BBUserCenterViewController.h"
#import "BBSideBarView.h"
#import "BBTemperatureLineView.h"
#import "BBLoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "BBNoticeSender.h"
#include <string.h>


@interface BBHomePageController ()<UIGestureRecognizerDelegate,BBSocketClientDelegate,ASIHTTPRequestDelegate>
{
    BBSideBarView *_sidebar;
    MBProgressHUD *_hud;
    BOOL _alreadyShowWarnAlert;//界面上已经显示了报警的alertView
    SEL _selector;
    BOOL _offLine;
}

@property (copy,nonatomic)NSString *currentDeviceID;
@property (retain, nonatomic) IBOutlet UIButton *showLineBtn;
@property (retain, nonatomic) IBOutlet UIImageView *topImageView;
@property (retain, nonatomic) IBOutlet UIImageView *temperatureCounter;
@property (retain, nonatomic) IBOutlet UILabel *temperatureDescription;
@property (retain, nonatomic) IBOutlet UILabel *humidityDescription;
@property (retain, nonatomic) IBOutlet UIImageView *humidityImageView;
@property (nonatomic, retain) IBOutlet UIScrollView *memView; 
@property (retain, nonatomic) IBOutlet UIImageView *eyesBg;
@property (retain, nonatomic) IBOutlet UILabel *humidityValueLbl;//湿度值
@property (retain, nonatomic) IBOutlet UILabel *temperatureValueLbl;
@property (retain, nonatomic) IBOutlet UIButton *regardView;//布防点击图片
@property (retain, nonatomic) IBOutlet UIImageView *regardLine;//布防默认图片
@property (retain, nonatomic) IBOutlet UIButton *cloudyAlbumBtn;
@property (retain, nonatomic) IBOutlet UIButton *markingBtn;
@property (retain, nonatomic) IBOutlet UIButton *huiAppBtn;
@property (retain, nonatomic) IBOutlet UIButton *userCenterBtn;
@property (retain, nonatomic) IBOutlet UIImageView *morenImaer;//撤防默认图片
@property (retain, nonatomic) IBOutlet UIButton *coudeButton;//云眼的button 的image
@property (retain, nonatomic) IBOutlet UIView *regardBgView;

@property (nonatomic, retain) NSString *P_UserName;//用户名

- (IBAction)cefangButton:(UIButton *)sender;//撤防的button
- (IBAction)bufangButton:(UIButton *)sender;//布防的button
- (IBAction)onClickBtns:(UIButton *)sender;
- (IBAction)onTouchEyeDown:(UIButton *)sender;
- (IBAction)onClickShowTemperatureLineBtn:(UIButton *)sender;

@end

@implementation BBHomePageController

- (void)dealloc
{
    [_members release];
    [_memView release];
    [_regardView release];
    [_regardLine release];
    [_coudeButton release];
    [_cloudyAlbumBtn release];
    [_markingBtn release];
    [_huiAppBtn release];
    [_userCenterBtn release];
    [_morenImaer release];
    [_humidityValueLbl release];
    [_temperatureValueLbl release];
    [_eyesBg release];
    [_humidityImageView release];
    [_temperatureDescription release];
    [_humidityDescription release];
    [_topImageView release];
    [_temperatureCounter release];
    [_regardBgView release];
    [_showLineBtn release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _members = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void)viewDidUnload {
    [self setRegardView:nil];
    [self setRegardLine:nil];
    [self setCoudeButton:nil];
    [self setCloudyAlbumBtn:nil];
    [self setMarkingBtn:nil];
    [self setHuiAppBtn:nil];
    [self setUserCenterBtn:nil];
    [self setMorenImaer:nil];
    [self setHumidityValueLbl:nil];
    [self setTemperatureValueLbl:nil];
    [self setEyesBg:nil];
    [self setHumidityImageView:nil];
    [self setTemperatureDescription:nil];
    [self setHumidityDescription:nil];
    [self setTopImageView:nil];
    [self setTemperatureCounter:nil];
    [self setRegardBgView:nil];
    [self setShowLineBtn:nil];
    [super viewDidUnload];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    _isRegard = YES;
    [self setModalPresentationStyle:UIModalPresentationPageSheet];
    
    //布防撤防的手势
    UISwipeGestureRecognizer *leftGes = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(onSetRegard:)];
    [leftGes setDirection:UISwipeGestureRecognizerDirectionLeft];
    [_regardView addGestureRecognizer:leftGes];
    leftGes.delegate = self;
    [leftGes release];
    
    //家庭成员列表滚动
    UISwipeGestureRecognizer *memberGesNext = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(srollMemberViewToNextPage:)];
    [memberGesNext setDirection:UISwipeGestureRecognizerDirectionLeft];
    [_memView addGestureRecognizer:memberGesNext];
    [memberGesNext release];
    
    UISwipeGestureRecognizer *memberGesLast = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(srollMemberViewToLastPage:)];
    [memberGesLast setDirection:UISwipeGestureRecognizerDirectionRight];
    [_memView addGestureRecognizer:memberGesLast];
    [memberGesLast release];   
    
    
    //将_regardView旋转180度
    _regardView.transform = CGAffineTransformMakeRotation(M_PI);
    
    //布防的
    _morenImaer.layer.cornerRadius=6;
    _morenImaer.layer.masksToBounds=YES;
    
    
    CGRect frame = CGRectMake(80, 5, 40, 20);
    
    _cloudAlbumBadge.backgroundColor = [UIColor greenColor];
    _cloudAlbumBadge = [[MKNumberBadgeView alloc]initWithFrame:frame];
    _cloudAlbumBadge.hideWhenZero = YES;
    _cloudAlbumBadge.alignment = UITextAlignmentCenter;
    _cloudAlbumBadge.value = 0;
    _cloudAlbumBadge.shadow = NO;
    _cloudAlbumBadge.font = [UIFont systemFontOfSize:13];
    _cloudAlbumBadge.strokeColor = [UIColor yellowColor];
    [_cloudyAlbumBtn addSubview:_cloudAlbumBadge];
    [_cloudAlbumBadge release];

//    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(as) userInfo:nil repeats:YES];
}
//
//- (void)as
//{
//    BBLog(@"运行中....");
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    BlueBoxer *sysUser = [BlueBoxerManager getCurrentUser];
    
    NSString *username=[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    NSString *pwd=[[NSUserDefaults standardUserDefaults]objectForKey:@"passWord"];

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*!
 *@brief        判断点击的是不是布放
 *@function     touchesBegan
 *@param        touches
 *@param        event
 *@return       （void）
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _canMove = NO;
    return;
    
    CGPoint point = [[touches anyObject]locationInView:_regardView];
    if ( CGRectContainsPoint(_regardView.bounds, point) ) {
        _canMove = YES;
    }else{
        _canMove = NO;
    }
}


/*!
 *@brief        判断_regardView移动了多少
 *@function     touchesMoved
 *@param        touches
 *@param        event
 *@return       （void）
 */
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_canMove) {
        return;
    }
    CGPoint point = [[touches anyObject]locationInView:self.view];
    if (point.x > _regardLine.frame.origin.x
        && point.x < _regardLine.frame.origin.x+_regardLine.frame.size.width) {
        _regardView.center = CGPointMake(point.x, _regardView.center.y);
        NSLog(@"%f",_regardView.frame.origin.x);
        [_morenImaer setFrame:CGRectMake(62, _morenImaer.frame.origin.y, _regardView.frame.origin.x-47, _morenImaer.frame.size.height)];
       // [_regardLine setImage:[UIImage imageNamed:@"sdcard_bg.png"]];
    }
}

/*!
 *@brief        判断_regardView移动了多少
 *@function     touchesEnded
 *@param        touches
 *@param        event
 *@return       （void）
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject]locationInView:_regardView];
    if (CGRectContainsPoint(_regardView.bounds, point)) {
        _canMove = NO;
        if (_isRegard) {
            if (_regardView.center.x<_regardLine.center.x) {
                [self cancelRegard];
            }else{
                [self setRegard];
            }
        }else if (!_isRegard){
            if (_regardView.center.x>_regardLine.center.x) {
                [self setRegard];
            }else{
                [self cancelRegard];
            }
        }
    }
}



#pragma mark -
#pragma mark self defined method

/*!
 *@description  请求首页所需的温度湿度数据
 *@function     getDatas
 *@param        (void)
 *@return       (void)
 */
- (void)getDatas
{
    [self getCurrentDeviceThenPerformSelector:@selector(getGuardStatusAndScanCard)];
    //[self getGuardStatusAndScanCard];
    
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
 *@description  将家庭成员视图滚动到下一页
 *@function     srollMemberViewToNextPage:
 *@param        gesture     --手势
 *@return       (void)
 */
- (void)srollMemberViewToNextPage:(UISwipeGestureRecognizer *)gesture
{
    if (_memView.contentOffset.x
        + _memView.frame.size.width != _memView.contentSize.width) {
        CGPoint offset = _memView.contentOffset;
        offset.x += _memView.frame.size.width;
        [_memView setContentOffset:offset animated:YES];
    }
}


/*!
 *@description  将家庭成员视图滚动到上一页
 *@function     srollMemberViewToLastPage:
 *@param        gesture     --手势
 *@return       (void)
 */
- (void)srollMemberViewToLastPage:(UISwipeGestureRecognizer *)gesture
{
    if (_memView.contentOffset.x != 0) {
        CGPoint offset = _memView.contentOffset;
        offset.x -= _memView.frame.size.width;
        [_memView setContentOffset:offset animated:YES];
    }
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

/*!
 *@description  发送本地通知
 *@function     sendLocalNoticeWithTitle:
 *@param        title   --标题
 *@return       (void)
 */
- (void)sendLocalNoticeWithTitle:(NSString *)title
{
    UILocalNotification *notification = [[[UILocalNotification alloc] init] autorelease];
    if (notification != nil) {
        // 设置推送时间
        notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:0];
        // 设置时区
//        notification.timeZone = [NSTimeZone defaultTimeZone];
        // 设置重复间隔
        notification.repeatInterval = 0;
        // 推送声音
        notification.soundName = UILocalNotificationDefaultSoundName;
        // 推送内容
        notification.alertBody = title;
//        notification.alertAction = @"打开";
        //显示在icon上的红色圈中的数子
        UIApplication *app = [UIApplication sharedApplication];
        notification.applicationIconBadgeNumber = app.applicationIconBadgeNumber+1;
        //设置userinfo 方便在之后需要撤销的时候使用
//        NSDictionary *info = [NSDictionary dictionaryWithObject:@"name"forKey:@"key"];
//        notification.userInfo = info;
        //添加推送到UIApplication 
        [app scheduleLocalNotification:notification];
         
        AudioServicesPlaySystemSound(1007);//系统的通知声音
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);//震动
    }
}

/*!
 *@description  响应点击关闭温度折线图事件
 *@function     onCloseTemperatureView:
 *@param        sender     --按钮
 *@return       (void)
 */
- (void)onCloseTemperatureView:(id)sender {
    
    _temperatureLineView.hidden = YES;
    CATransition *anim = [CATransition animation];
    anim.type = kCATransitionPush;
    anim.subtype = kCATransitionFromBottom;
    anim.duration = 0.5f;
    [_temperatureLineView.layer addAnimation:anim forKey:nil];
    
    double delayInSeconds = 0.5f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [_temperatureLineView removeFromSuperview];
    });
}


/*!
 *@brief        如果温度大于60度掉用这里
 *@function     temperature
 *@return       （void）
 */
-(void)temperature
{
    if (ISIP5) {
        [_coudeButton setImage:[UIImage imageNamed:@"eye-bg1_1136.png"] forState:UIControlStateNormal];
        [_coudeButton setImage:[UIImage imageNamed:@"eye-bg1_1136.png"] forState:UIControlStateHighlighted];
    }else{
        [_coudeButton setImage:[UIImage imageNamed:@"eye-bg1_960.png"] forState:UIControlStateNormal];
        [_coudeButton setImage:[UIImage imageNamed:@"eye-bg1_960.png"] forState:UIControlStateHighlighted];
    }
    
    _eyesBg.highlighted = YES;
    _topImageView.highlighted = YES;
    _temperatureCounter.highlighted = YES;
 
}

/*!
 *@description  请求温度曲线
 *@function     getTemperatureLine
 *@param        (void)
 *@return       (void)
 */
- (void)getTemperatureLine
{
    _showLineBtn.enabled = NO;
    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    NSString *userId = curUser.userid;
    NSString *param = [NSString stringWithFormat:@"%@\t%@",userId,dateStr];
    [mainClient queryTemperatureLine:self param:param];
}
        

/*!
 *@description  温度弹窗
 *@function     showTemperatureView:
 *@param        temperatureArr  --温度数组
 *@return       (void)
 */
- (void)showTemperatureViewWithArr:(NSArray *)temperatureArr
{
//    NSMutableArray *temperatureArr = [[[NSMutableArray alloc]initWithObjects:@"0",@"-20",@"18",@"20",@"13",@"15",@"38",@"43",@"80",@"15", nil]autorelease];
    
    BBTemperatureLineView *line = [[[NSBundle mainBundle]loadNibNamed:@"BBTemperatureLineView" owner:self options:nil]lastObject];
    line.temperatureArr = [NSArray arrayWithArray:temperatureArr];
    
    
    //加关闭按钮
    UIImageView *views=[[UIImageView alloc]init];
    [views setImage:[UIImage imageNamed:@"close_Btn"]];
    [views setFrame:CGRectMake(270, 20, 13, 13)];
    [line addSubview:views];
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setFrame:CGRectMake(265, 15, 30,30)];
    [closeBtn addTarget:self action:@selector(onCloseTemperatureView:) forControlEvents:UIControlEventTouchUpInside];
    [line addSubview:closeBtn];
    
    _temperatureLineView = [[UIView alloc]initWithFrame:self.view.frame];
    _temperatureLineView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    _temperatureLineView.alpha = 1.0;
    
    
    
    [line setCenter:_temperatureLineView.center];
    [_temperatureLineView addSubview:line];
    
    
    [line setCurTemp:[NSString stringWithFormat:@"%@℃",_temperatureValueLbl.text]];
    
    NSDate *curDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateStr = [dateFormatter stringFromDate:curDate];
    NSArray *dateArr = [dateStr componentsSeparatedByString:@" "];
    [line setDateStr:dateArr[0]];
    [line setToTime:dateArr[1]];
    
    NSDate *halfDate = [curDate dateByAddingTimeInterval:-1800];
    [dateFormatter setDateFormat:@"HH:mm"];
    [line setFromTime:[dateFormatter stringFromDate:halfDate]];
    
    [dateFormatter release];
    
    [self.view addSubview:_temperatureLineView];
    [_temperatureLineView release];
    [views release];
    
    CATransition *anim = [CATransition animation];
    anim.type = kCATransitionPush;
    anim.subtype = kCATransitionFromTop;
    anim.duration = 0.5f;
    [_temperatureLineView.layer addAnimation:anim forKey:nil];
}


/*!
 *@brief        生成成员列表
 *@function     genMemberView:
 *@param        mems
 *@return       (void)
 */
- (void)genMemberView:(NSArray *)mems
{
#define MEM_VIEW_WIDTH 45.0f
    for (BBMemberView *view in _memView.subviews) {
        [view removeFromSuperview];
    }
    NSUInteger count = [mems count];
    CGFloat start = 0;
    int i = 0;
    for (NSDictionary *member in mems) {
        if (i%5==0) {
            NSInteger last = count - i;
            if (last >= 5) {
                start = MEM_VIEW_WIDTH * i;
            }else{
                start = MEM_VIEW_WIDTH*(5-last)/2.0f
                      + MEM_VIEW_WIDTH*i;
            }
        }
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"BBMemberView" owner:nil options:nil];
        BBMemberView *view = (BBMemberView *)[nibs objectAtIndex:0];
        view.photo.highlighted = _offLine;
        CGRect frame = view.frame;
        frame.origin.x = start + (i%5) * frame.size.width;
        view.frame = frame;
        view.name = [[mems[i] valueForKey:@"name"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        view.isOnline = [[mems[i] valueForKey:@"status"]boolValue];
        view.isMale = YES;
        [self.memView addSubview:view];
        i++;
    }
    
    if (count%5 != 0) {
        count = count + 5-(count+5)%5;
    }
    [self.memView setContentSize:CGSizeMake(count*MEM_VIEW_WIDTH, self.memView.frame.size.height)];
}

- (void)pushToCloudEyesVC
{
    //[BBCloudEyesViewController verifyThenPushWithVC:self];
}

/*!
 *@brief        响应点击云眼事件
 *@function     onclickCloudEyes:
 *@param        sender      --云眼按钮
 *@return       (void)
 */
- (IBAction)onclickCloudEyes:(UIButton *)sender {
    
    if(!appDelegate.EyesIsOpen && !_offLine){
        //appDelegate.EyesIsOpen=YES;
        BBNewsEyesViewController *eyesVC;
        
        if (ISIP5){
            eyesVC = [[BBNewsEyesViewController alloc]initWithNibName:@"BBNewsEyesViewController_4" bundle:nil];
        }else{
            eyesVC = [[BBNewsEyesViewController alloc]initWithNibName:@"BBNewsEyesViewController" bundle:nil];
        }
        
        eyesVC.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:eyesVC animated:YES];
        
        [eyesVC release];
    }

}

/*!
 *@description  响应云眼按钮的各种事件 移除动画
 *@function     onRemoveAnimation:
 *@param        sender     --云眼按钮
 *@return       (void)
 */
- (IBAction)onRemoveAnimation:(UIButton *)sender {
    for (int i=0; i<2; i++) {
        UIView *imageView = [self.view viewWithTag:4200+i];
        if (imageView) {
            [imageView removeFromSuperview];
        }
    }
}

/*!
 *@description      响应点击主界面4个按钮的事件
 *@function         onClickBtns:
 *@param            sender  --按钮
 *@return           (void)
 */


- (IBAction)onClickBtns:(UIButton *)sender {
 
    UIViewController *vc = nil;
    
    switch (sender.tag) {
            
        case 11001:
        {
            BBMarkViewController *markVC = [[BBMarkViewController alloc]init];
            vc = markVC;
            break;
        }
        case 11002:
        {
            vc = [[BBAlbumsViewController alloc]init];
            break;
        }
            
        case 11003:
            vc = [[BBHuiAplViewController alloc] init];
            break;
        case 11004:
            vc = [[BBUserCenterViewController alloc] init];
            break;
            
        default:
            break;
    }
    
    if (vc) {
        [_sidebar hide];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    }
}

/*!
 *@description  响应按下云眼按钮加动画事件
 *@function     onTouchEyeDown:
 *@param        sender     --云眼按钮
 *@return       (void)
 */
- (IBAction)onTouchEyeDown:(UIButton *)sender {
    CGFloat duration = 1.0f;
    int n = 2;
    for (int i = 0; i<n; i++) {
        CGRect frame = _coudeButton.frame;
//        if (ISIP5) {
//            frame = CGRectMake(71, 129, 177, 75);
//        }else{
//            frame = CGRectMake(140, 108, 45, 45);
//        }
//        if (IOS_VERSION>=7.0) {
//            frame.origin.y+=20;
//        }
        UIImageView *imgV = [[UIImageView alloc]initWithFrame:frame];
        imgV.tag = 4200+i;
        imgV.layer.opacity = 0.01f;
        imgV.image = [UIImage imageNamed:@"gray_temp"];
        [self.view addSubview:imgV];
        [self.view insertSubview:imgV belowSubview:_eyesBg];
 
        double delayInSeconds = (duration*(i))/(CGFloat)n;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            anim.duration = duration; 
            anim.autoreverses = NO;
            anim.repeatCount = UINT_MAX;
            anim.fromValue = [NSNumber  numberWithFloat:1.0f];
            anim.toValue = [NSNumber  numberWithFloat:1.4f];
            
            CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
            opacity.duration = duration;
            opacity.fillMode = @"backwards";
            opacity.autoreverses = NO;
            opacity.repeatCount = UINT_MAX;
            opacity.fromValue = [NSNumber  numberWithFloat:1.0f];
            opacity.toValue = [NSNumber  numberWithFloat:0.01f];
            
            CAAnimationGroup *group = [CAAnimationGroup animation];
            group.animations = [NSArray arrayWithObjects:anim, opacity, nil];
            group.delegate = self;
            group.duration = duration;
            group.repeatCount = UINT_MAX;
            [imgV.layer addAnimation:group forKey:@"asd"];
        });
        
        
        [imgV release];
        
    }
    
}

/*!
 *@description  响应点击显示温度曲线按钮事件
 *@function     onClickShowTemperatureLineBtn:
 *@param        sender     --按钮
 *@return       (void)
 */
- (IBAction)onClickShowTemperatureLineBtn:(UIButton *)sender {
//    [self getTemperatureLine];
}

/*!
 *@description  响应布防撤防手势事件
 *@function     onSetRegard:
 *@param        gesture     --手势
 *@return       (void)
 */
- (void)onSetRegard:(UISwipeGestureRecognizer *)gesture
{
    if (_regardView.center.x < _regardLine.center.x) {
        //布防
        [self getCurrentDeviceThenPerformSelector:@selector(setRegard)]; 
    
    
    }else if (_regardView.center.x > _regardLine.center.x) {
        //撤防
        [self getCurrentDeviceThenPerformSelector:@selector(cancelRegard)];
    }
}

/*!
 *@description  布防
 *@function     setRegard
 *@param        (void)
 *@return       (void)
 */
- (void)setRegard
{
//    self.view.userInteractionEnabled = NO;
//    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    _hud.labelText = @"正在布防...";
//    _hud.labelFont = [UIFont systemFontOfSize:13.0f];
//    _hud.removeFromSuperViewOnHide = YES;
    
    _regardView.selected = YES;
    
    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
    NSDateFormatter *fmt = [[NSDateFormatter alloc]init];
    [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [fmt stringFromDate:[NSDate date]];
    [fmt release];
    NSString *param = [NSString stringWithFormat:@"%@\t%@",curUser.userid,dateStr];
    [mainClient addControl:self param :param ];
}


/*!
 *@description  撤防
 *@function     cancelRegard
 *@param        (void)
 *@return       (void)
 */
- (void)cancelRegard
{
//    self.view.userInteractionEnabled = NO;
//    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    _hud.labelText = @"正在撤防...";
//    _hud.labelFont = [UIFont systemFontOfSize:13.0f];
//    _hud.removeFromSuperViewOnHide = YES;
    
    _regardView.selected = YES;
    
    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
    NSDateFormatter *fmt = [[NSDateFormatter alloc]init];
    [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [fmt stringFromDate:[NSDate date]];
    [fmt release];
    NSString *param = [NSString stringWithFormat:@"%@\t%@",curUser.userid,dateStr];
    [mainClient cancelControl:self param:param];
}

/*!
 *@brief        撤防的button
 *@function     cefangButton
 *@param        sender
 *@return       （void）
 */
- (IBAction)cefangButton:(UIButton *)sender {
    [self cancelRegard];
   }
/*!
 *@brief        布防的button
 *@function     bufangButton
 *@param        sender
 *@return       （void）
 */
- (IBAction)bufangButton:(UIButton *)sender {

    [self setRegard];
}

/*!
 *@description  切换为布防状态
 *@function     showRegardAnimated
 *@param        animated    --是否需要动画
 *@return       (void)
 */
- (void)showRegardAnimated:(BOOL)animated
{
    CGFloat duration = 0.5f;
    if (!animated) {
        duration = 0.0f;
    }
    [UIView animateWithDuration:duration animations:^{
        [_regardView setCenter:CGPointMake(_regardLine.frame.origin.x+_regardLine.frame.size.width
                                           , _regardView.center.y)];
        [_morenImaer setFrame:CGRectMake(62, _morenImaer.frame.origin.y, 194, _morenImaer.frame.size.height)];
    }completion:^(BOOL finished) {
        _isRegard = YES;
        
        _regardView.transform = CGAffineTransformMakeRotation(0);
        
    }];
    
}

/*!
 *@description  切换为撤防状态
 *@function     showCancelRegardAnimated
 *@param        animated    --是否需要动画
 *@return       (void)
 */
- (void)showCancelRegardAnimated:(BOOL)animated
{
    CGFloat duration = 0.5f;
    if (!animated) {
        duration = 0.0f;
    }
    [UIView animateWithDuration:duration animations:^{
        [_regardView setCenter:CGPointMake(_regardLine.frame.origin.x
                                           , _regardView.center.y)];
        [_morenImaer setFrame:CGRectMake(62, _morenImaer.frame.origin.y, 1, _morenImaer.frame.size.height)];
    }completion:^(BOOL finished) {
        _isRegard = NO;
        
        _regardView.transform = CGAffineTransformMakeRotation(M_PI);
    }];
}



#pragma mark -
#pragma mark 处理收到服务器通知
/*!
 *@description  处理收到增加图片的通知
 *@function     handleReceiveImageNotice :data:
 *@return       data    --返回数据
 */
- (void)handleReceiveImageNotice:(BBDataFrame *)data{
    //            新增图片通知
    //            1)	服务器下发: 类型(报警3,抓拍15)\t数量
    //            2)	客户端返回:状态码
    NSString *result = [[NSString alloc]initWithString:[data dataString]];
    if (result) {
        NSArray *arr = [result componentsSeparatedByString:@"\t"];
        
        NSInteger total = _cloudAlbumBadge.value + [arr[1] integerValue];
        if (total >= 10 && _cloudAlbumBadge.frame.origin.x == 80) {
            _cloudAlbumBadge.frame = CGRectMake(75, 5, 40, 20);
        }
        _cloudAlbumBadge.value = total;
        
        NSMutableString *infoStr = [NSMutableString stringWithFormat:@"您的柚保有%@张",arr[1]];
        if ([arr[0] isEqualToString:@"3"]) {
            [infoStr appendString:@"新报警图片"];
        }else{
            [infoStr appendString:@"新抓拍图片"];
        }
        [self sendLocalNoticeWithTitle:infoStr];

        //        [self [self sendLocalNoticeWithTitle:infoStr];
             [BBNoticeSender showNotice:infoStr];
        //       UtilAlert(infoStr, nil);
    }
    
    [result release];
}


/*!
 *@description  收到布防通知
 *@function     handleReceiveSetRegardNotice :data:
 *@return       data    --返回数据
 */
- (void)handleReceiveSetRegardNotice:(BBDataFrame *)data{
//    2.	服务器->客户端(转发)：终端ID\t消息ID\t开启布防时间\t类型【0是APP控制，1是终端控制】 \t妮称
    NSString *result = [[NSString alloc]initWithString:[data dataString]];
    if (result) {
        [self showRegardAnimated:YES];
        NSArray *arr = [result componentsSeparatedByString:@"\t"];
        
        if (arr.count==5) {
            NSMutableString *infoStr = [NSMutableString string];
            NSString *str = [arr[4] stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
            NSArray *timeArr = [arr[2] componentsSeparatedByString:@" "];
            timeArr = [timeArr[1] componentsSeparatedByString:@":"];
            NSString *timeStr = [NSString stringWithFormat:@"%@:%@",timeArr[0],timeArr[1]];
            if (str.length == 0
                && ((NSString *)arr[4]).length == 11
                && [arr[4] characterAtIndex:0] == '1') {
                [infoStr appendFormat:@"您家人的手机号%@,于%@时间进行了启动布防。",arr[4],timeStr];
            }else{
                [infoStr appendFormat:@"您的家人%@,于%@时间进行了启动布防。",arr[4],timeStr];
            }
            [self sendLocalNoticeWithTitle:infoStr];
            [BBNoticeSender showNotice:infoStr];
        }

        [result release];
    }
}



/*!
 *@description  收到撤防通知
 *@function     handleReceiveCancelRegardNotice :data:
 *@return       data    --返回数据
 */
- (void)handleReceiveCancelRegardNotice:(BBDataFrame *)data{
    //    2.	服务器->客户端(转发)：终端ID\t消息ID\t停止布防时间\t类型【0是APP控制，1是终端控制】 \t妮称
    NSString *result = [[NSString alloc]initWithString:[data dataString]];
    if (result) {
        [self showCancelRegardAnimated:YES];
        NSArray *arr = [result componentsSeparatedByString:@"\t"];
        
        if(arr.count==5){
            NSMutableString *infoStr = [NSMutableString string];
            NSString *str = [arr[4] stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
            NSArray *timeArr = [arr[2] componentsSeparatedByString:@" "];
            timeArr = [timeArr[1] componentsSeparatedByString:@":"];
            NSString *timeStr = [NSString stringWithFormat:@"%@:%@",timeArr[0],timeArr[1]];
            if (str.length == 0
                && ((NSString *)arr[4]).length == 11
                && [arr[4] characterAtIndex:0] == '1') {
                [infoStr appendFormat:@"您家人的手机号%@,于%@时间进行了撤销布防。",arr[4],timeStr];
            }else{
                [infoStr appendFormat:@"您的家人%@,于%@时间进行了撤销布防。",arr[4],timeStr];
            }
            [self sendLocalNoticeWithTitle:infoStr];
            [BBNoticeSender showNotice:infoStr];
        }
        [result release];
    }
}

/*!
 *@description  收到入侵报警通知
 *@function     handleReceiveInvadeNotice :data:
 *@return       data    --返回数据
 */
- (void)handleReceiveInvadeNotice:(BBDataFrame *)data{
//    ２.	服务器->客户端：终端ID\t消息ID\t入侵时间
    NSString *result = [[NSString alloc]initWithString:[data dataString]];
    if (result) {
        NSMutableString *infoStr = [NSMutableString stringWithString:@"您家中有人非法入侵，请尽快确认处理。"];
        [self sendLocalNoticeWithTitle:infoStr];
        [BBNoticeSender showNotice:infoStr];
        
        if (!_alreadyShowWarnAlert) {
            
            _alreadyShowWarnAlert = YES;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NOTICE_TITLE
                                                            message:infoStr
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"查看", nil];
            [alert show];
            [alert release];
        }
        
        [result release];
    }
    
}




/*!
 *@description  收到温度报警通知
 *@function     handleReceiveTemperatureNotice :data:
 *@return       data    --返回数据
 */
- (void)handleReceiveTemperatureNotice:(BBDataFrame *)data{
//    ２.	服务器->客户端：终端ID\t消息ID\t温度值[15分钟之内数据库记录的最大温差值]
    NSString *result = [[NSString alloc]initWithString:[data dataString]];
    if (result) {
        [self getDatas];
        [self getTemperatureLine];
        NSArray *arr = [result componentsSeparatedByString:@"\t"];
        if ([arr[2] floatValue] >= 60.0f) {
            [self temperature];
        }
        NSMutableString *infoStr = [NSMutableString stringWithString:@"温度异常报警：您家中温度异常，请尽快确认处理。"];
        [self sendLocalNoticeWithTitle:infoStr];
        [BBNoticeSender showNotice:infoStr];
//        UtilAlert(infoStr, nil);
        [result release];
    }
}

/*!
 *@description  收到湿度通知
 *@function     handleReceiveHumidityNotice :data:
 *@return       data    --返回数据
 */
- (void)handleReceiveHumidityNotice:(BBDataFrame *)data{
//    ２.	服务器->客户端：终端ID\t消息ID\t湿度值[15分钟之内数据库记录的最大湿度差值]
    NSString *result = [[NSString alloc]initWithString:[data dataString]];
    if (result) {
        [self getDatas];
        NSArray *arr = [result componentsSeparatedByString:@"\t"];
        NSMutableString *infoStr = [NSMutableString stringWithFormat:@"警告：15分钟最大湿度差值%@",arr[2]];
        [self sendLocalNoticeWithTitle:infoStr];
        [BBNoticeSender showNotice:infoStr];
//        UtilAlert(infoStr, nil);
        [result release];
    }
}

/*!
 *@description  收到归家离家通知
 *@function     handleReceiveInOutNotice :data:
 *@return       data    --返回数据
 */
- (void)handleReceiveInOutNotice:(BBDataFrame *)data{
    //    终端ID\t消息ID\t昵称\t归家离家状态【0表示离家、1表示归家】\t归家离家时间\t卡片ID
    NSString *result = [[NSString alloc]initWithString:[data dataString]];
    if (result) {
        NSArray *arr = [result componentsSeparatedByString:@"\t"];
        
        if(arr.count==6){
            NSMutableString *infoStr = [NSMutableString stringWithFormat:@"您的家人%@,于%@时间已",arr[2],arr[4]];
            if ([arr[3] isEqualToString:@"0"]) {
                [infoStr appendString:@"离家"];
            }else{
                [infoStr appendString:@"回家。"];
            }
            [self sendLocalNoticeWithTitle:infoStr];
            [BBNoticeSender showNotice:infoStr];
            
            BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
            NSString *userId = curUser.userid;
            [mainClient scanCard:self param:userId];
        }
        [result release];
    }
}





#pragma mark -
#pragma mark 处理请求接口返回数据
/*!
 *@description  处理获得温度曲线
 *@function     handleReceiveTemperatureLine:data:
 *@param        src     --
 *@return       data    --返回数据
 */
- (void)handleReceiveTemperatureLine:(BBDataFrame *)src data:(BBDataFrame *)data
{
    _showLineBtn.enabled = YES;
    NSString *result = [[NSString alloc] initWithString:[data dataString]];
    NSLog(@"温度曲线结果:%@", data.data);
    NSArray *arr = [result componentsSeparatedByString:@"\t"];
    if ([arr[0] boolValue]) {
        UtilAlert(@"获取温度曲线失败", nil);
    }else{
        NSMutableArray *temperatureArr = [NSMutableArray array];
        for (int i=arr.count-1; i>0; i--) {//返回数据是时间倒序的
            [temperatureArr addObject:arr[i]];
        }
        [self showTemperatureViewWithArr:temperatureArr];
    }
    [result release];
}


/*!
 *@description  处理获得用户设备ID
 *@function     handleReceiveUserDeviceID:data:
 *@param        src     --
 *@return       data    --返回数据
 */
- (void)handleReceiveUserDeviceID:(BBDataFrame *)src data:(BBDataFrame *)data
{
    NSString *result = [[NSString alloc] initWithString:[data dataString]];
    
    if(result){
        NSArray *arr = [result componentsSeparatedByString:@"\t"];
        if (arr.count==3 && [arr[0] isEqualToString:@"0"] ) {
            self.currentDeviceID = arr[1];
            
            BlueBoxer *sysUser = [BlueBoxerManager getCurrentUser];
            sysUser.deviceid=[arr[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ];
            [BlueBoxerManager archiveCurrentUser:sysUser];
            
            NSInteger status = [arr[2] intValue];
            
            [self toSetPageStatus:status];
        }
    }
    

    [result release];
}

/*!
 *@description  处理获得用户设备信息
 *@function     toSetPageStatus
 */
-(void) toSetPageStatus:(int)status{
    if (status==3) {
        [self performSelector:_selector withObject:nil];
        if (ISIP5) {
            [_coudeButton setImage:[UIImage imageNamed:@"eye-bg_1136.png"] forState:UIControlStateNormal];
            [_coudeButton setImage:[UIImage imageNamed:@"eye-bg_1136.png"] forState:UIControlStateHighlighted];
        }else{
            [_coudeButton setImage:[UIImage imageNamed:@"eye-bg_960.png"] forState:UIControlStateNormal];
            [_coudeButton setImage:[UIImage imageNamed:@"eye-bg_960.png"] forState:UIControlStateHighlighted];
        }
        _regardView.selected = NO;
        _offLine = NO;
    }else{
        _offLine = YES;
        _regardView.selected = YES;
        [_morenImaer setFrame:CGRectMake(62, _morenImaer.frame.origin.y, 194, _morenImaer.frame.size.height)];
        if (ISIP5) {
            [_coudeButton setImage:[UIImage imageNamed:@"eye-bg_gray_1136.png"] forState:UIControlStateNormal];
            [_coudeButton setImage:[UIImage imageNamed:@"eye-bg_gray_1136.png"] forState:UIControlStateHighlighted];
        }else{
            [_coudeButton setImage:[UIImage imageNamed:@"eye-bg_gray_960.png"] forState:UIControlStateNormal];
            [_coudeButton setImage:[UIImage imageNamed:@"eye-bg_gray_960.png"] forState:UIControlStateHighlighted];
        }
        
        BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
        NSString *userId = curUser.userid;
        [mainClient scanCard:self param:userId];
        
         UtilAlert(@"柚保已离线", nil);
    }
}

/*!
 *@description  处理获得用户设备信息
 *@function     handleReceiveUserDeviceInfo:data:
 *@param        src     --
 *@return       data    --返回数据
 */
- (void)handleReceiveUserDeviceInfo:(BBDataFrame *)src data:(BBDataFrame *)data
{
    NSString *result = [[NSString alloc] initWithString:[data dataString]];
    NSArray *arr = [result componentsSeparatedByString:@"\t"];
    
    if(result){
        if (arr.count>3 && [arr[0] isEqualToString:@"0"]) {
            //
            NSInteger status = [arr[2] intValue];
            
        }
    }
    
    
    if ([arr[0] boolValue]) {
        UtilAlert(@"获取当前用户设备信息失败", nil);
    }else{
        for (int i=2; i<arr.count; i++) {
            NSArray *infoArr = [arr[i] componentsSeparatedByString:@"\n"];
            if ([infoArr[0] isEqualToString:_currentDeviceID]) {
                NSInteger status = [infoArr[2] intValue];
                if (status & 1) {
                    
                    [self performSelector:_selector withObject:nil];
                    if (ISIP5) {
                        [_coudeButton setImage:[UIImage imageNamed:@"eye-bg_1136.png"] forState:UIControlStateNormal];
                        [_coudeButton setImage:[UIImage imageNamed:@"eye-bg_1136.png"] forState:UIControlStateHighlighted];
                    }else{
                        [_coudeButton setImage:[UIImage imageNamed:@"eye-bg_960.png"] forState:UIControlStateNormal];
                        [_coudeButton setImage:[UIImage imageNamed:@"eye-bg_960.png"] forState:UIControlStateHighlighted];
                    }
                    _regardView.selected = NO;
                    _offLine = NO;
                }else{
                    _offLine = YES;
                    _regardView.selected = YES;
                    [_morenImaer setFrame:CGRectMake(62, _morenImaer.frame.origin.y, 194, _morenImaer.frame.size.height)];
                    if (ISIP5) {
                        [_coudeButton setImage:[UIImage imageNamed:@"eye-bg_gray_1136.png"] forState:UIControlStateNormal];
                        [_coudeButton setImage:[UIImage imageNamed:@"eye-bg_gray_1136.png"] forState:UIControlStateHighlighted];
                    }else{
                        [_coudeButton setImage:[UIImage imageNamed:@"eye-bg_gray_960.png"] forState:UIControlStateNormal];
                        [_coudeButton setImage:[UIImage imageNamed:@"eye-bg_gray_960.png"] forState:UIControlStateHighlighted];
                    }
                    
                    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
                    NSString *userId = curUser.userid;
                    [mainClient scanCard:self param:userId];
                    
                    UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(0, 0,230, 50)];
                    lbl.center = self.view.center;
                    lbl.textAlignment = NSTextAlignmentCenter;
                    lbl.textColor = [UIColor whiteColor];
                    lbl.shadowColor = [UIColor clearColor];
                    lbl.backgroundColor = [UIColor blackColor];
                    lbl.font = [UIFont systemFontOfSize:13.];
                    lbl.numberOfLines = 0;
                    lbl.text = @"柚保设备已断线，请检查设备网络";
                    [self.view addSubview:lbl];
                    [lbl release];
                    
                    lbl.layer.cornerRadius = 5.0f;
                    lbl.clipsToBounds = YES;
                    
                    [lbl performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.];
                    
                }
            }
        }
    }
    [result release];
}


/*!
 *@description  处理布防结果
 *@function     handleReceiveRegard:data:
 *@param        src     --
 *@return       data    --返回数据
 */
- (void)handleReceiveRegard:(BBDataFrame *)src data:(BBDataFrame *)data{

    NSString *result = [[NSString alloc] initWithData:data.data encoding:NSUTF8StringEncoding];
    
    if(result){
        NSArray *arr = [result componentsSeparatedByString:@"\t"];
        if ([arr[0] isEqualToString:@"0" ]) {
           [self showRegardAnimated:YES];
        }
    }
    
    [self.view performSelector:@selector(setUserInteractionEnabled:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
    
    [result release];

    _regardView.selected = NO;
}


/*!
 *@description  处理撤防结果
 *@function     handleReceiveCancelRegard:data:
 *@param        src     --
 *@return       data    --返回数据
 */
- (void)handleReceiveCancelRegard:(BBDataFrame *)src data:(BBDataFrame *)data{
    
    NSString *result = [[NSString alloc] initWithData:data.data encoding:NSUTF8StringEncoding];
    
    if (result) {
        NSArray *arr = [result componentsSeparatedByString:@"\t"];
        if ([arr[0] isEqualToString:@"0" ]) {
            [self showCancelRegardAnimated:YES];
        }
    }

    [self.view performSelector:@selector(setUserInteractionEnabled:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
    [result release];
    
    _regardView.selected = NO;
}


/*!
 *@description  处理获取到当前布防状态结果
 *@function     handleReceiveCurrentRegard:data:
 *@param        src     --
 *@return       data    --返回数据
 */
- (void)handleReceiveCurrentRegard:(BBDataFrame *)src data:(BBDataFrame *)data{
   
    NSString *result = [[NSString alloc] initWithData:data.data encoding:NSUTF8StringEncoding];
    
    if(result){
        NSArray *arr = [result componentsSeparatedByString:@"\t"];
        
        if(arr.count==2 && [arr[0] isEqualToString:@"0"]){
            if ([arr[1] integerValue]) {
                [self showCancelRegardAnimated:YES];
            }else{
                [self showRegardAnimated:YES];
            }
            
        }
    }
    
    [result release];
}



/*!
 *@description  处理获取到温度结果
 *@function     handleReceiveTemperature :data:
 *@param        src     --
 *@return       data    --返回数据
 */
- (void)handleReceiveTemperature:(BBDataFrame *)src data:(BBDataFrame *)data{
    NSString *result = [[NSString alloc] initWithData:data.data encoding:NSUTF8StringEncoding];
    NSArray *arr = [result componentsSeparatedByString:@"\t"];
    if ([arr[0] integerValue]) {
        NSLog(@"获取温度失败");
    }else{
        _temperatureValueLbl.text = [NSString stringWithFormat:@"%d",(NSInteger)([arr[1] floatValue]+0.5f)];
        CGFloat temperature = [arr[1] floatValue];
        
        if (temperature >= 60.) {
            [self temperature];
        }
        if (temperature > 35.) {
            _temperatureDescription.text = @"热";
        }else if (temperature > 26. && temperature <= 35.) {
            _temperatureDescription.text = @"暖";
        }else if (temperature > 17. && temperature <= 26.) {
            _temperatureDescription.text = @"舒适";
        }else if (temperature >= 10. && temperature <= 17.) {
            _temperatureDescription.text = @"凉";
        }else{
            _temperatureDescription.text = @"冷";
        }
    }
    [result release];
}

+ (NSArray *)parseData:(BBDataFrame *)data
{
    [data retain];
    char *str = malloc(data.data.length+1);
    strcpy(str , [data.data bytes]);
    int n=0,strLen = -1;
    for (int i=0; i<data.data.length; i++) {
        if (str[i] == '\t') {
            n++;
            if (n == 6) {
                strLen = i+1;//前面的数据长度（除图片外的）
            }
        }
    }
    free(str);
    
    NSData *strData;
    
    NSMutableArray *dataArr = [[NSMutableArray alloc]init];
    
    if (strLen != -1) {
        
        strData = [data.data subdataWithRange:NSMakeRange(0, strLen)];
        NSString *dataStr = [[NSString alloc]initWithData:strData encoding:GBK_ENCODEING];
        [dataArr addObject:dataStr];
        [dataStr release];
        
//        imageData = [data.data subdataWithRange:NSMakeRange(strLen, data.data.length-strLen)];
//        UIImage *image = [UIImage imageWithData:imageData];
//        if (image) {
//            [dataArr addObject:image];
//        }
        
        
    }else{
        [dataArr addObject:[data dataString]];
    }
    [data release];
    return [dataArr autorelease];
    
}

/*!
 *@description  处理获取RFID结果
 *@function     handleReceiveRFID:data:
 *@param        src     --
 *@return       data    --返回数据
 */
- (void)handleReceiveRFID:(BBDataFrame *)src data:(BBDataFrame *)data{
    NSString *result = [[NSString alloc] initWithString:[data dataString]];
    
    [_members removeAllObjects];
    
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

    
    [result release];
}

/*!
 *@description  处理获取到湿度结果
 *@function     handleReceiveHumidity :data:
 *@param        src     --
 *@return       data    --返回数据
 */
- (void)handleReceiveHumidity:(BBDataFrame *)src data:(BBDataFrame *)data{
    NSString *result = [[NSString alloc] initWithData:data.data encoding:NSUTF8StringEncoding];
    NSArray *arr = [result componentsSeparatedByString:@"\t"];
    if ([arr[0] integerValue]) {
        NSLog(@"获取湿度失败");
    }else{
        _humidityValueLbl.text = [NSString stringWithFormat:@"%d",(NSInteger)([arr[1] floatValue]+0.5f)];
        CGFloat humidity = [arr[1] floatValue];
        humidity /= 100.;
        if (humidity < 0.4f) {
            _humidityImageView.image = [UIImage imageNamed:@"img8.png"];
            _humidityDescription.text = @"干燥";
        }else if (humidity < 0.6f) {
            _humidityImageView.image = [UIImage imageNamed:@"img7.png"];
            _humidityDescription.text = @"适宜";
        }else{
            _humidityImageView.image = [UIImage imageNamed:@"img2.png"];
            _humidityDescription.text = @"潮湿";
        }
    }
    [result release];
}

#pragma mark -
#pragma mark - UIGestureRecognizerDelegate method

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.view == _temperatureLineView) {
        return NO;
    }
    _canMove = NO;
    return YES;
}

#pragma mark -
#pragma mark UIAlertView delegate method
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[NSNotificationCenter defaultCenter]postNotificationName:BBDidReceiveWarningNotificaiton object:nil];
    }
    _alreadyShowWarnAlert = NO;
}

#pragma mark -
#pragma mark BBSocketClientDelegate method

-(void)toRecevieMsg:(NSString *)strJson{    
    [self getAllDatas];
}

-(int)onRecevie:(BBDataFrame *)src received:(BBDataFrame *)data
{
    if (src) {
        //不是通知消息
        if(src.MainCmd == 0x0E && src.SubCmd == 1) {
            //步防
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleReceiveRegard:src data:data];
            });
        } else if (src.MainCmd == 0x0E && src.SubCmd == 2) {
            //撤防
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleReceiveCancelRegard:src data:data];
            });
            
        }else if (src.MainCmd == 0x0E && src.SubCmd == 72) {
            //当前布防状态
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleReceiveCurrentRegard:src data:data];
            });
        }else if (src.MainCmd == 0x0E && src.SubCmd == 74) {
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
                [self handleReceiveUserDeviceID:src data:data];
            });
        }

    }
    
    return 0;
}

-(void)onTimeout:(BBDataFrame *)src
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *msg = nil;
        switch (src.SubCmd) {
                
            case 1:
            {
                msg = @"布防超时";
                [_hud setLabelText:msg];
                [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
                _regardView.selected = NO;
                self.view.userInteractionEnabled = YES;
                break;
            }
                
            case 2:
            {
                msg = @"撤防超时";
                [_hud setLabelText:msg];
                [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
                _regardView.selected = NO;
                self.view.userInteractionEnabled = YES;
                break;
            }
                
            case 4:
            {
                [_members removeAllObjects];
                [self genMemberView:_members];
                break;
            }
                
            case 84:
            {
                _showLineBtn.enabled = YES;
                break;
            }
                
            default:
//                UtilAlert(@"请求超时", nil);
                break;
        }
    });
}


-(void)onRecevieError:(BBDataFrame*)src received:(BBDataFrame*)data
{
    NSLog(@"RecevieError src.SubCmd=%d",src.SubCmd);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        NSString *msg = nil;
        switch (src.SubCmd) {
                
            case 1:
            {
                msg = @"布防出错";
                [_hud setLabelText:msg];
                [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
                _regardView.selected = NO;
                self.view.userInteractionEnabled = YES;
                break;
            }
                
            case 2:
            {
                msg = @"撤防出错";
                [_hud setLabelText:msg];
                [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
                _regardView.selected = NO;
                self.view.userInteractionEnabled = YES;
                break;
            }
                
            case 4:
            {
                [_members removeAllObjects];
                [self genMemberView:_members];
                break;
            }
                
            case 84:
            {
                _showLineBtn.enabled = YES;
                break;
            }
                
            default:
//                UtilAlert(@"请求出错", nil);
                break;
        }
    });
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
            
            _temperatureValueLbl.text = [NSString stringWithFormat:@"%d",(NSInteger)(temperature+0.5f)];
            
            if (temperature >= 60.) {
                [self temperature];
            }
            if (temperature > 35.) {
                _temperatureDescription.text = @"热";
            }else if (temperature > 26. && temperature <= 35.) {
                _temperatureDescription.text = @"暖";
            }else if (temperature > 17. && temperature <= 26.) {
                _temperatureDescription.text = @"舒适";
            }else if (temperature >= 10. && temperature <= 17.) {
                _temperatureDescription.text = @"凉";
            }else{
                _temperatureDescription.text = @"冷";
            }
            
            
            //湿度
            str = [dic valueForKey:@"Sd"];
            NSString *humStr = [str stringByReplacingOccurrencesOfString:@"%" withString:@""];
            
            CGFloat humidity = [humStr floatValue];
            _humidityValueLbl.text = [NSString stringWithFormat:@"%d",(NSInteger)(humidity+0.5f)];
            humidity /= 100.;
            if (humidity < 0.4f) {
                _humidityImageView.image = [UIImage imageNamed:@"img8.png"];
                _humidityDescription.text = @"干燥";
            }else if (humidity < 0.6f) {
                _humidityImageView.image = [UIImage imageNamed:@"img7.png"];
                _humidityDescription.text = @"适宜";
            }else{
                _humidityImageView.image = [UIImage imageNamed:@"img2.png"];
                _humidityDescription.text = @"潮湿";
            }

        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
}

-(void)toLoginPage{
    BBLoginViewController *logViewController = [[BBLoginViewController alloc]init];
    [self presentModalViewController:logViewController animated:YES];
    [logViewController release];
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
                
                [self registNotices];
                [self getAllDatas];
                
            }else{
                [self toLoginErr];
                UtilAlert(@"登录失败！", nil);
            }
            
        }else{
            [self toLoginErr];
        }
        

        [result release];
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
        [loginVc release];
        
    }
}

@end


