//
//  BBLoginViewController.m
//  ZgSafe
//  用户登录界面
//  Created by box on 13-10-29.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBLoginViewController.h"
#import "BBregisterViewController.h"
#import "BBSetNetingViewController.h"
#import "BBHomePageController.h"
#import "BBSocketClient.h"
#import "Reachability.h"
#import "BBresetPassWordViewController.h"

@interface BBLoginViewController ()<BBLoginClientDelegate>
{
    NSString *dialNum;
}
@property (retain, nonatomic) IBOutlet UITextField *moblePhone;//用户的手机号
@property (retain, nonatomic) IBOutlet UITextField *passwordPhone;//用户的密码
- (IBAction)longingUser:(UIButton *)sender;//登录
- (IBAction)rigestUser:(UIButton *)sender;//注册
- (IBAction)retrievePassword:(UIButton *)sender;//一键找回密码
- (IBAction)setUpPhone:(UIButton *)sender;//设置网路
- (IBAction)bigButton:(UIButton *)sender;//回收键盘的button
- (IBAction)ressetPassWord:(UIButton *)sender;

@end

@implementation BBLoginViewController

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
    BlueBoxer *user = curUser;
    _moblePhone.text = user.userid?user.userid:@"";
    
    UITapGestureRecognizer *Btap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bBackG:)];
    _backG.userInteractionEnabled=YES;
    [_backG addGestureRecognizer:Btap];
    [Btap release];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (appDelegate.UserRegister) {
        
        NSString *username=[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
        NSString *pwd=[[NSUserDefaults standardUserDefaults]objectForKey:@"passWord"];
        
        if(username!=nil && pwd!=nil){
            [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
                
            }];
            NSLog(@"启动自动登录......");
        }
        
        appDelegate.UserRegister=NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)dealloc {
    [_moblePhone release];
    [_passwordPhone release];
    [_backG release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setMoblePhone:nil];
    [self setPasswordPhone:nil];
    [self setBackG:nil];
    [super viewDidUnload];
}


#pragma mark -
#pragma mark rotate method
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


/*!
 *@brief        用户登录
 *@function     longingUser
 *@param        sender
 *@return       (void)
 */
- (IBAction)longingUser:(UIButton *)sender {
    NSString *moblephoneStr=[_moblePhone.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *passwordStr=[_passwordPhone.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if(_moblePhone.text==nil|| [_moblePhone.text isEqualToString:@""]||moblephoneStr.length==0)
    {
        UtilAlert(@"输入的手机号为空", nil);
        return;
        
    }else if(_moblePhone.text.length>12)
    {
        UtilAlert(@"输入的手机号大于11位", nil);
        return;
        
    }else if(0&&_moblePhone.text.length<11)
    {
        UtilAlert(@"输入的手机号小于11位", nil);
        return;
    }else if(_passwordPhone.text==nil||passwordStr.length==0){
        UtilAlert(@"输入的密码为空", nil);
        return;
    }else if(_passwordPhone.text.length>20){
        UtilAlert(@"密码位数过长", nil);
        return;
    }else{
        NSString *strUserName=_moblePhone.text;
        NSString *strPwd=_passwordPhone.text;
        
        Reachability *reac = [Reachability reachabilityWithHostName:LOG_SERVER_PATH];
        if ([reac currentReachabilityStatus] == NotReachable) {
            UtilAlert(@"服务器异常", nil);
            return;
        }

        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.labelText = @"正在登录...";
        _hud.labelFont = [UIFont systemFontOfSize:13.0f];
        _hud.removeFromSuperViewOnHide = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[BBSocketManager getInstance] login:strUserName password:strPwd delegate:self];
        });
        
  }
}

/*!
 *@brief        推到用户注册界面
 *@function     rigestUser
 *@param        sender
 *@return       (void)
 */
- (IBAction)rigestUser:(UIButton *)sender {
    BBregisterViewController *registers=[[BBregisterViewController alloc]init];
    [self presentModalViewController:registers animated:YES]; 
    [registers release];
}
/*!
 *@brief       一键找回密码
 *@function     retrievePassword
 *@param        sender
 *@return        (void)
 */
- (IBAction)retrievePassword:(UIButton *)sender {
    
    BBresetPassWordViewController *lRset=[[BBresetPassWordViewController alloc]init];
    [self presentModalViewController:lRset animated:YES];
    [lRset release];
    
    
}
/*!
 *@brief        设置网路
 *@function     setUpPhone
 *@param        sender
 *@return       void
 */
- (IBAction)setUpPhone:(UIButton *)sender {
    BBSetNetingViewController *setneting=[[BBSetNetingViewController alloc]init];
    setneting.apModeType = kBBAPModeTypeHttp;
    [self presentModalViewController:setneting animated:YES];
    [setneting release];
}
/*!
 *@brief        键盘回收
 *@function     bigButton
 *@param        sender
 *@return       void
 */
- (IBAction)bigButton:(UIButton *)sender {
    [self.view endEditing:YES];
}

/*!
 *@description  关键盘
 *@function     bBackG:
 *@param        sender     --返回按钮
 *@return       (void)
 */

-(void)bBackG:(UITapGestureRecognizer *)sender{
    
    [_moblePhone resignFirstResponder];
    [_passwordPhone resignFirstResponder];
}
#pragma mark-
#pragma mark UITextFieldDelegate method
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (self.view.frame.size.height<=480) {
        [UIView animateWithDuration:0.25 animations:^{
            [self.view setCenter:CGPointMake(self.view.frame.size.width/2,190)];
        }];
    }else{
        NSLog(@"我的高是580");
        
    }
    
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (self.view.frame.size.height<=480) {
        [UIView animateWithDuration:0.25 animations:^{
            [self.view setCenter:CGPointMake(self.view.frame.size.width/2,230)];
        }];
    }else{
        NSLog(@"我的高还是580");
    }
    
}
#pragma mark -
#pragma mark UIAlertView delegate method
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
       //  NSString *dial_str = [NSString stringWithFormat:@"tel://%@", dialNum];
       //400-1080-580
        NSString *dial_str = [NSString stringWithFormat:@"tel://4001080580"];
        NSURL *dial = [NSURL URLWithString:dial_str];
        if ([[UIApplication sharedApplication] canOpenURL:dial]) {
            [[UIApplication sharedApplication] openURL:dial];
        }
    }
}


#pragma mark -
#pragma mark BBLoginClientDelegate method
-(void)loginReceiveData:(BBDataFrame *)data
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *result = [[NSString alloc]initWithBytes:[data.data bytes] length:data.data.length encoding:GBK_ENCODEING];
        NSString *strTxt=@"登录失败";
        
        if(result){
             NSArray *arr = [result componentsSeparatedByString:@"\t"];
            [result release];
            
            if([arr[0] isEqualToString:@"0"] ){
                [[NSUserDefaults standardUserDefaults] setObject:_moblePhone.text forKey:@"userName"];
                [[NSUserDefaults standardUserDefaults] setObject:_passwordPhone.text forKey:@"passWord"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                strTxt=@"登录成功";
                
                BlueBoxer *sysUser = [BlueBoxerManager getCurrentUser];
                sysUser.loged = YES;
                sysUser.userid = _moblePhone.text;
                sysUser.deviceid=nil;
                [BlueBoxerManager archiveCurrentUser:sysUser];
                
                double delayInSeconds = 0.2;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    //                [appDelegate.homePageVC getAllDatas];
                    [appDelegate.homePageVC registNotices];
                });
                
                [self.presentingViewController dismissModalViewControllerAnimated:YES];
            }else if (arr.count==2){
                strTxt=arr[1];
            }
        }
        
        _hud.labelText = strTxt;
        [_hud performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5f];
        
    });
    
}


- (IBAction)ressetPassWord:(UIButton *)sender {
    
    BBresetPassWordViewController *lRset=[[BBresetPassWordViewController alloc]init];
    [self presentViewController:lRset animated:YES completion:nil];
    [lRset release];
}

@end
