
//  BBUserCenterViewController.m
//  ZgSafe
//
//  Created by YANGReal on 13-10-30.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBUserCenterViewController.h"
#import "BBRFIDMaintainViewController.h"
#import "BBFeedBackViewController.h"
#import "BBAdressManageViewController.h"
#import "BBVideoCameraViewController.h"
#import "BBExchangeScoreViewController.h"
#import "BBSideBarView.h"
#import "BBHuiAplViewController.h"
#import "BBMarkViewController.h"
#import "BBAlbumsViewController.h"
#import "BBNewsEyesViewController.h"
#import "BBChangePswViewController.h"
#import "BBLoginViewController.h"
#import "BBAboutViewController.h"
#import "BBSetNetingViewController.h"
#import "BBVerifyCodeSettingViewController.h"

@interface BBUserCenterViewController ()<UIAlertViewDelegate,BBSideBarViewDelegate,UITextFieldDelegate,BBSocketClientDelegate,BBLoginClientDelegate,UIAlertViewDelegate>
{
    BBSideBarView *_sidebar;
    UIButton *btn1 ;
    UIButton *btn;
    MBProgressHUD *_hud;
}
- (IBAction)onClickWarnInfoBtn:(UIButton *)sender;
- (IBAction)onClickBackHomeBtn:(UIButton *)sender;
- (IBAction)onClickSetReagrdBtn:(UIButton *)sender;
@property (retain, nonatomic) IBOutlet UIView *checkCode;

- (IBAction)goback:(id)sender;
- (IBAction)onClickRFIDCardMainTainBtn:(UIButton *)sender;
- (IBAction)onClickAddressAdminBtn:(UIButton *)sender;
- (IBAction)onClickFeedBackBtn:(UIButton *)sender;
- (IBAction)onClickCameraSettingBtn:(UIButton *)sender;
- (IBAction)quitLogin:(id)sender;
- (IBAction)onClickModifyNickNameBtn:(UIButton *)sender;
- (IBAction)onClickModifyTelBtn:(UIButton *)sender;
- (IBAction)changePswBtn:(UIButton *)sender;
- (IBAction)onClickAboutBtn:(UIButton *)sender;

@property (retain, nonatomic) IBOutlet UIButton *modifyNickNameBtn;
@property (retain, nonatomic) IBOutlet UIButton *modifyTelBtn;
@property (retain, nonatomic) IBOutlet UITextField *telTf;
@property (retain, nonatomic) IBOutlet UITextField *nickNameTf;
@property (retain, nonatomic) IBOutlet UILabel *telNum;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UILabel *warnStateLable;
@property (retain, nonatomic) IBOutlet UILabel *backHomeStateLable;
@property (retain, nonatomic) IBOutlet UILabel *regardStateLable;
@property (retain, nonatomic) IBOutlet UILabel *soundSwitchLbl;
@property (retain, nonatomic) IBOutlet UIImageView *warnInfoBg;
@property (retain, nonatomic) IBOutlet UIImageView *backHomeBg;
@property (retain, nonatomic) IBOutlet UIImageView *setRegardBg;
@property (retain, nonatomic) IBOutlet UIImageView *soundSwitchBg;
@property (retain, nonatomic) IBOutlet UIButton *soundSwitchBtn;


@property (retain, nonatomic) IBOutlet UIButton *niknameLableButton;

@property (retain, nonatomic) IBOutlet UIButton *phoneLableButton;

@end

@implementation BBUserCenterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_scrollView setContentSize:CGSizeMake(320.0f
                                           , 805.)];
    _sidebar =[BBSideBarView siderBarWithBesideView:self.view];
    _sidebar.delegate=self;
    
    [self getDatas];
      
}

- (void)viewWillAppear:(BOOL)animated
{
    _checkCode.hidden=YES;
    
    [super viewWillAppear:animated];
    
    BlueBoxer *user = curUser;
//
//    [self handleSwitchWith:_warnPushBtn
//                stateLable:_warnStateLable
//        andBackgroundImage:_warnInfoBg
//                      open:user.warnPushOpened
//                  animated:NO];
//    
//    [self handleSwitchWith:_backHomeRemindBtn
//                stateLable:_backHomeStateLable
//        andBackgroundImage:_backHomeBg
//                      open:user.backHomeRemindOpened
//                  animated:NO];
//    
//    [self handleSwitchWith:_regardRemindBtn
//                stateLable:_regardStateLable
//        andBackgroundImage:_setRegardBg
//                      open:user.regardRemindOpened
//                  animated:NO]; 
    
    _telNum.text = user.userid;
    
}

#pragma mark -
#pragma mark system method
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [_telNum release];
    [_scrollView release];
    [_warnStateLable release];
    [_backHomeStateLable release];
    [_regardStateLable release];
    [_warnInfoBg release];
    [_backHomeBg release];
    [_setRegardBg release];
    [_sidebar remove];
    [_nickNameTf release];
    [_telTf release];
    [_niknameLableButton release];
    [_phoneLableButton release];
    [_modifyNickNameBtn release];
    [_modifyTelBtn release];
    [_soundSwitchBtn release];
    [_soundSwitchLbl release];
    [_soundSwitchBg release];
    [_checkCode release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTelNum:nil];
    [self setScrollView:nil];
    [self setWarnStateLable:nil];
    [self setBackHomeStateLable:nil];
    [self setRegardStateLable:nil];
    [self setWarnInfoBg:nil];
    [self setBackHomeBg:nil];
    [self setSetRegardBg:nil];
    [self setNickNameTf:nil];
    [self setTelTf:nil];
    [self setNiknameLableButton:nil];
    [self setPhoneLableButton:nil];
    [self setModifyNickNameBtn:nil];
    [self setModifyTelBtn:nil];
    [self setSoundSwitchBtn:nil];
    [self setSoundSwitchLbl:nil];
    [self setSoundSwitchBg:nil];
    [super viewDidUnload];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


#pragma mark -
#pragma mark self define method

/*!
 *@description  请求用户信息数据
 *@function     getDatas
 *@param        (void)
 *@return       (void)
 */
- (void)getDatas
{
    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
    NSString *userId = curUser.userid;
    [mainClient queryUserInfo:self param:userId];
    [mainClient getDeviceSoundState:self param:userId];
}


/*!
 *@description  修改用户信息接口
 *@function     modifyUserInfo
 *@param        (void)
 *@return       (void)
 */
- (void)modifyUserInfo
{
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
    [_hud setLabelText:@"正在请修改用户信息..."];
    [_hud setRemoveFromSuperViewOnHide:YES];
    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
    NSString *userId = curUser.userid;
    NSString *param = [NSString stringWithFormat:@"%@\t%@\t%@",userId,_nickNameTf.text,_telTf.text];
    [mainClient changeUserInfo:self param:param];
}

/*!
 *@description      处理按钮的开关效果
 *@function         handleSwitchWith:stateLable:andBackgroundImage:open:animated
 *@param            aButton         --开关按钮
 *@param            stateLable      --显示当前开关状态的lable
 *@param            bgImageView     --背景图片
 *@param            animated        --是否需要动画
 *@return           (void)
 */
- (void)handleSwitchWith:(UIButton *)aButton
              stateLable:(UILabel *)stateLable
      andBackgroundImage:(UIImageView *)bgImageView
                    open:(BOOL)open
                animated:(BOOL)animated{
    
    if (!open && [stateLable.text isEqualToString:@"开"]) {
        
        if (animated) {
            [UIView animateWithDuration:0.25f animations:^{
                [aButton setCenter:CGPointMake(aButton.center.x+27
                                           , aButton.center.y)];
            }];
        }else{
            [aButton setCenter:CGPointMake(aButton.center.x+27
                                       , aButton.center.y)];
        }
        
        stateLable.text = @"关";
        bgImageView.image = [UIImage imageNamed:@"close_bg"];
        
    }else if (open && [stateLable.text isEqualToString:@"关"]){
        
        if (animated) {
            [UIView animateWithDuration:0.25f animations:^{
                [aButton setCenter:CGPointMake(aButton.center.x-27
                                           , aButton.center.y)];
            }];
        }else{
            [aButton setCenter:CGPointMake(aButton.center.x-27
                                       , aButton.center.y)];
        }
        stateLable.text = @"开";
        bgImageView.image = [UIImage imageNamed:@"open_bg"];
    }
    
}

/*!
 *@description      响应点击报警信息推送按钮事件
 *@function         onClickWarnInfoBtn:
 *@param            sender     --返回按钮
 *@return           (void)
 */
- (IBAction)onClickWarnInfoBtn:(UIButton *)sender {
    
    [self handleSwitchWith:sender
                stateLable:_warnStateLable
        andBackgroundImage:_warnInfoBg
                      open:[_warnStateLable.text isEqualToString:@"关"]
                  animated:YES];
    
    BlueBoxer *user = curUser;
    user.warnPushOpened = [_warnStateLable.text isEqualToString:@"开"];
    [BlueBoxerManager archiveCurrentUser:user];
    
    [appDelegate.homePageVC registNotices];
}

/*!
 *@description      响应点击归家信息按钮事件
 *@function         onClickBackHomeBtn:
 *@param            sender     --返回按钮
 *@return           (void)
 */
- (IBAction)onClickBackHomeBtn:(UIButton *)sender {
    
    [self handleSwitchWith:sender
                stateLable:_backHomeStateLable
        andBackgroundImage:_backHomeBg
                      open:[_backHomeStateLable.text isEqualToString:@"关"]
                  animated:YES];
    
    BlueBoxer *user = curUser;
    user.backHomeRemindOpened = [_backHomeStateLable.text isEqualToString:@"开"];
    [BlueBoxerManager archiveCurrentUser:user];
    
    [appDelegate.homePageVC registNotices];
}

/*!
 *@description      响应点击布防撤防按钮事件
 *@function         onClickSetReagrdBtn:
 *@param            sender     --返回按钮
 *@return           (void)
 */
- (IBAction)onClickSetReagrdBtn:(UIButton *)sender {
    
    [self handleSwitchWith:sender
                stateLable:_regardStateLable
        andBackgroundImage:_setRegardBg
                      open:[_regardStateLable.text isEqualToString:@"关"]
                  animated:YES];
    
    BlueBoxer *user = curUser;
    user.regardRemindOpened = [_regardStateLable.text isEqualToString:@"开"];
    [BlueBoxerManager archiveCurrentUser:user];
    
    [appDelegate.homePageVC registNotices];
}



/*!
 *@description      响应点击设备静音开关按钮事件
 *@function         onClickSoundSwitchBtn:
 *@param            sender     --返回按钮
 *@return           (void)
 */
- (IBAction)onClickSoundSwitchBtn:(UIButton *)sender {
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
    [_hud setLabelText:@"正在切换..."];
    [_hud setRemoveFromSuperViewOnHide:YES];
    
    NSString *strType;
    
    if([_soundSwitchLbl.text isEqualToString:@"开"]){
        strType=@"0";
    }else{
        strType=@"1";
    }

    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
    NSString *userId = curUser.userid;
    NSString *param = [NSString stringWithFormat:@"%@\t%@",userId,strType];
    [mainClient openOrCloseDeviceSound:self param:param];
}

/*!
 *@description      响应点击返回按钮事件
 *@function         goback:
 *@param            sender     --返回按钮
 *@return           (void)
 */
- (IBAction)goback:(id)sender {
    [_sidebar hide];
    if (self.navigationController) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        UIViewController *vc = self;
        while (![vc isKindOfClass:[UINavigationController class]]) {
            UIViewController *tempVC = vc.presentingViewController;
            if ([tempVC isKindOfClass:[UINavigationController class]]) {
                [vc dismissModalViewControllerAnimated:YES];
            }else{
                [vc dismissModalViewControllerAnimated:NO];
            }
            vc = tempVC;
        }
    }
}

/*!
 *@description      响应点击随身保维护按钮事件
 *@function         onClickRFIDCardMainTainBtn:
 *@param            sender     --返回按钮
 *@return           (void)
 */
- (IBAction)onClickRFIDCardMainTainBtn:(UIButton *)sender {
    [_sidebar hide];
    BBRFIDMaintainViewController *vc = [[BBRFIDMaintainViewController alloc]init];
    if (self.navigationController) {
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self presentModalViewController:vc animated:YES];
    }
    [vc release];
}


/*!
 *@description      响应点击地址管理按钮事件
 *@function         onClickAddressAdminBtn:
 *@param            sender     --返回按钮
 *@return           (void)
 */
- (IBAction)onClickAddressAdminBtn:(UIButton *)sender {
    [_sidebar hide];
    BBAdressManageViewController *vc = [[BBAdressManageViewController alloc] init];
    if (self.navigationController) {
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self presentModalViewController:vc animated:YES];
    }
    [vc release];
}


/*!
 *@description      响应点击意见反馈按钮事件
 *@function         onClickFeedBackBtn:
 *@param            sender     --返回按钮
 *@return           (void)
 */
- (IBAction)onClickFeedBackBtn:(UIButton *)sender {
    [_sidebar hide];
    BBFeedBackViewController *vc = [[BBFeedBackViewController alloc] init];
    if (self.navigationController) {
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self presentModalViewController:vc animated:YES];
    }
    [vc release];
}


/*!
 *@description      响应点击相机设置按钮事件
 *@function         onClickCameraSettingBtn:
 *@param            sender     --返回按钮
 *@return           (void)
 */
- (IBAction)onClickCameraSettingBtn:(UIButton *)sender {
    [_sidebar hide];
    BBVideoCameraViewController *vc = [[BBVideoCameraViewController alloc] init];
    if (self.navigationController) {
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self presentModalViewController:vc animated:YES];
    }
    [vc release];
}




/*!
 *@description      响应点击相机设置按钮事件
 *@function         onClickNetworkSettingBtn:
 *@param            sender     --返回按钮
 *@return           (void)
 */
- (IBAction)onClickNetworkSettingBtn:(UIButton *)sender {
    [_sidebar hide];
    BBSetNetingViewController *vc =[[BBSetNetingViewController alloc]init];
    vc.apModeType = kBBAPModeTypeHttp;
    if (self.navigationController) {
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self presentModalViewController:vc animated:YES];
    }
    [vc release];
}




/*!
 *@description      响应点击验证码设置按钮事件
 *@function         onClickVerifyCodeSettingBtn:
 *@param            sender     --返回按钮
 *@return           (void)
 */
- (IBAction)onClickVerifyCodeSettingBtn:(UIButton *)sender {
    [_sidebar hide];
    BBVerifyCodeSettingViewController *vc =[[BBVerifyCodeSettingViewController alloc]init];
    vc.telNum = _telNum.text;
    if (self.navigationController) {
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self presentModalViewController:vc animated:YES];
    }
    [vc release];
}



/*!
 *@description      响应点击修改昵称按钮事件
 *@function         onClickModifyNickNameBtn:
 *@param            sender     --修改昵称按钮
 *@return           (void)
 */
- (IBAction)onClickModifyNickNameBtn:(UIButton *)sender {
    if (!_modifyNickNameBtn.selected) {
        _modifyNickNameBtn.selected = YES;
        _niknameLableButton.selected = YES;
        _nickNameTf.enabled = YES;
        [_nickNameTf becomeFirstResponder];
    }else{
        
        if(_nickNameTf.text==nil|| [_nickNameTf.text isEqualToString:@""]||_nickNameTf.text.length==0)
        {
            UtilAlert(@"输入的呢称为空", nil);
            
        }else{
        _modifyNickNameBtn.selected = NO;
        _niknameLableButton.selected = NO;
        _nickNameTf.enabled = NO;
        
        _modifyTelBtn.selected = NO;
        _phoneLableButton.selected = NO;
        _telTf.enabled = NO;
        
        [self.view endEditing:YES];
        
        [self modifyUserInfo];
    }
    }
}

/*!
 *@description      响应点击修改电话号码按钮事件
 *@function         onClickModifyTelBtn:
 *@param            sender     --修改电话号码按钮
 *@return           (void)
 */
- (IBAction)onClickModifyTelBtn:(UIButton *)sender {
   
    if (!_modifyTelBtn.selected) {
        _modifyTelBtn.selected = YES;
        _phoneLableButton.selected = YES;
        _telTf.enabled = YES;
        [_telTf becomeFirstResponder];
    }else{
        
        if(_telTf.text==nil|| [_telTf.text isEqualToString:@""]||_telTf.text.length==0)
        {
            UtilAlert(@"输入的手机号为空", nil);
        
        }else{
            _modifyTelBtn.selected = NO;
        _phoneLableButton.selected = NO;
        _telTf.enabled = NO;
        
        _modifyNickNameBtn.selected = NO;
        _niknameLableButton.selected = NO;
        _nickNameTf.enabled = NO;
        
        [self.view endEditing:YES];
        
        [self modifyUserInfo];
    }
        
}
}


-(BOOL) isValidateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}


/*!
 *@description      响应点击修改密码事件
 *@function         changePswBtn:
 *@param            sender     --修改密码换按钮
 *@return           (void)
 */
- (IBAction)changePswBtn:(UIButton *)sender {
    [_sidebar hide];
    BBChangePswViewController *vc = [[BBChangePswViewController alloc] init];
    if (self.navigationController) {
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self presentModalViewController:vc animated:YES];
    }
    [vc release];
}

/*!
 *@description      响应点击关于按钮事件
 *@function         onClickAboutBtn:
 *@param            sender     --关于按钮
 *@return           (void)
 */
- (IBAction)onClickAboutBtn:(UIButton *)sender {
    BBAboutViewController *vc = [[BBAboutViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
}


/*!
 *@description      响应点击推出登陆事件
 *@function         quitLogin:
 *@param            sender     --推出登陆按钮
 *@return           (void)
 */
- (IBAction)quitLogin:(id)sender {
    
    BlueBoxer *user = curUser;
    if (user.userid) {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
        [_hud setLabelText:@"正在注销..."];
        [_hud setRemoveFromSuperViewOnHide:YES];
        NSString *param = [NSString stringWithFormat:@"%@",curUser.userid];
        BBLoginClient *logClient = [[[BBLoginClient alloc] init]autorelease];
        [logClient logout:param delegate:self];
    }

    [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"passWord"];

}


#pragma mark -
#pragma mark - BBSideBarViewDelegate method-

- (void)didSelectedButtonAtIndex:(NSInteger)index{
    
    [_sidebar hide];
    UIViewController *vc = nil;
    if (index==0) {
       // [BBCloudEyesViewController verifyThenPushWithVC:self];
    }else if(index==1){
        vc=[[BBMarkViewController alloc]init];
    }else if(index==2){
        
        vc=[[BBAlbumsViewController alloc]init];
    }else if (index==3)
    {
        vc=[[BBHuiAplViewController alloc]init];
    }else if (index==4)
    {
//        vc=[[BBUserCenterViewController alloc]init];
    }
    
    if (vc) {
        if (self.navigationController) {
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            [self presentModalViewController:vc animated:YES];
        }
        [vc release];
    }
}


#pragma mark -
#pragma mark UITextField method
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    [_niknameLableButton setImage:[UIImage imageNamed:@"pencil.png"] forState:UIControlStateNormal];
    [_phoneLableButton setImage:[UIImage imageNamed:@"pencil.png"] forState:UIControlStateNormal];
    return YES;
}


#pragma mark -
#pragma mark BBSocketClientDelegate method

-(int)onRecevie:(BBDataFrame *)src received:(BBDataFrame *)data
{
    if(src.MainCmd == 0x0E && src.SubCmd == 77) {
        //获取用户信息
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc]initWithString:[data dataString]];
            
            if(result){
                NSArray *arr = [result componentsSeparatedByString:@"\t"];
                if (arr.count==3 && ![arr[0] boolValue]) {
                    _nickNameTf.text = arr[1];
                    _telTf.text = arr[2];
                }
            }
            
            [result release];
        });
    }else if(src.MainCmd == 0x0E && src.SubCmd == 78) {
        //获取用户信息
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc]initWithString:[data dataString]];
            NSString *strTxt=@"修改用户信息失败";
            
            
            if (result && [result isEqualToString:@"0"]) {
               strTxt = @"修改用户信息成功";
            }
            
            _hud.labelText = strTxt;
            
            [result release];
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }else if(src.MainCmd == 0x0E && src.SubCmd == 98) {
        //获取声音开关状态
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc]initWithString:[data dataString]];
            
            if(result){
                NSArray *arr = [result componentsSeparatedByString:@"\t"];
                if (arr.count==2 && [arr[0] isEqualToString:@"0" ]) {
                    
                    if([arr[1] isEqualToString:@"1" ]){
                        //开
                        _soundSwitchLbl.text=@"开";
                        
                    }else{
                        //关
                        _soundSwitchLbl.text=@"开";
                        
                        [self setSoundData];
                    }
                    
                    
                }
            }
            
            [result release];
        });
    }
    else if(src.MainCmd == 0x0E && src.SubCmd == 86){
        //获取最新版本
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc]initWithString:[data dataString]];
            
            if(result){
                NSString *currvier=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
                
                NSString *temp = @".";
                NSRange rang = [currvier rangeOfString:temp];
                currvier= [currvier stringByReplacingCharactersInRange:rang withString:@""];
                
                rang = [currvier rangeOfString:temp];
                currvier= [currvier stringByReplacingCharactersInRange:rang withString:@""];
                
                NSArray *aryData = [result componentsSeparatedByString:@"\t"];
                
                if(aryData.count==3 && [aryData[0] isEqualToString:@"0"]){
                    NSString *strVar=aryData[1];
                    
                    rang = [strVar rangeOfString:temp];
                    strVar= [strVar stringByReplacingCharactersInRange:rang withString:@""];
                    rang = [strVar rangeOfString:temp];
                    strVar= [strVar stringByReplacingCharactersInRange:rang withString:@""];
                    
                    if(strVar.intValue>currvier.intValue){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIAlertView *lAler=[[UIAlertView alloc]initWithTitle:@"" message:@"检查到新版本，是否更新？" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
                            [lAler show];
                            
                            [lAler release];});
                    }else{
                        
                        UtilAlert(@"当前已是最新版本", nil);
                        
                    }
                }
            }else{
                UtilAlert(@"当前已是最新版本", nil);
            }
            [result release];
        });
    }
    else if(src.MainCmd == 0x0E && src.SubCmd == 97) {
        //设备声音开关状态
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc]initWithString:[data dataString]];
            
            if(result && [result isEqualToString:@"0"]){
                _hud.labelText = @"切换成功";
                
                [self setSoundData];
            }else{
                 _hud.labelText = @"切换失败";
            }
            
            [result release];
            
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
       
        });
    }
    
    
    return 0;
}

-(void)setSoundData{
    BOOL open = [_soundSwitchLbl.text isEqualToString:@"关"];
    
    [self handleSwitchWith:_soundSwitchBtn
                stateLable:_soundSwitchLbl
        andBackgroundImage:_soundSwitchBg
                      open:open
                  animated:YES];

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    switch (buttonIndex) {
        case 0:{
            NSString *strUrl = [NSString stringWithFormat:@"http://download.zgantech.com/houseshelter.html"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strUrl]];
            break;}
            
        default:
            break;
    }
}

-(void)onTimeout:(BBDataFrame *)src
{
    if(src.MainCmd == 0x0E && src.SubCmd == 77) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _hud.labelText = @"请求用户信息超时";
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }else if(src.MainCmd == 0x0E && src.SubCmd == 78) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _hud.labelText = @"修改用户信息超时";
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }
}


-(void)onRecevieError:(BBDataFrame*)src received:(BBDataFrame*)data
{
    if(src.MainCmd == 0x0E && src.SubCmd == 77) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _hud.labelText = @"请求用户信息出现错误";
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }else if(src.MainCmd == 0x0E && src.SubCmd == 78) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _hud.labelText = @"修改用户信息出现错误";
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }
}


#pragma mark -
#pragma mark BBLoginClientDelegate method

- (void)logoutReceiveData:(BBDataFrame *)data
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *result = [[NSString alloc] initWithString:[data dataString]];
        if (!result) {
            _hud.labelText = @"注销失败";
        }else{
            NSArray *arr = [result componentsSeparatedByString:@"\t"];
            if ([arr[0] isEqualToString:@"0"]) {
                _hud.labelText = @"注销成功";
                
                [BBDispatchManager clearStack];
                [appDelegate.homePageVC genMemberView:[NSArray array]];//删除首页成员列表
                BlueBoxer *user = curUser;
                user.loged = NO;
                [BlueBoxerManager archiveCurrentUser:user];
                
                BBLoginViewController *loginVc = [[BBLoginViewController alloc]init];
                [self presentViewController:loginVc animated:YES completion:nil];
                [loginVc release];
                
            }else{
                _hud.labelText = arr[1];
            }
        }
        [result release];
        [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        
        [self exitApplication];
    });
}

- (void)logoutFailedWithErrorInfo:(NSString *)errorInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _hud.labelText = @"注销错误";
        [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
    });
}

- (void)exitApplication {
    BBAppDelegate *app = [UIApplication sharedApplication].delegate;
    UIWindow *window = app.window;
    
    [UIView animateWithDuration:1.0f animations:^{
        window.alpha = 0;
        window.frame = CGRectMake(0, window.bounds.size.width, 0, 0);
    } completion:^(BOOL finished) {
        exit(0);
    }];
}

//发送APP下载
- (IBAction)btnVer:(UIButton *)sender {
    
    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
    NSString *userId = curUser.userid;
    NSString *param = [NSString stringWithFormat:@"%@\t%@\t%@",userId,@"4",@"1"];
    
    [mainClient openOrCloseVer:(id)self param:param];
    
}
@end
