//
//  BBVerifyCodeSettingViewController.m
//  ZgSafe
//
//  Created by box on 14-5-7.
//  Copyright (c) 2014年 iXcoder. All rights reserved.
//

#import "BBVerifyCodeSettingViewController.h"
#import "BBressetVerCodeViewController.h"
@interface BBVerifyCodeSettingViewController ()<BBSocketClientDelegate>{
    MBProgressHUD *_hud;
}

@property (retain, nonatomic) IBOutlet UITextField *oldPasswordTf;
@property (retain, nonatomic) IBOutlet UITextField *newPasswordTf;
@property (retain, nonatomic) IBOutlet UITextField *newPasswordConfirmTf;
@property (retain, nonatomic) IBOutlet UITextField *msgVerifyCodeTf;


- (IBAction)onSureModify:(UIButton *)sender;
- (IBAction)goBack:(UIButton *)sender;
- (IBAction)ressetVer:(UIButton *)sender;

@end

@implementation BBVerifyCodeSettingViewController

- (void)dealloc {
    [_oldPasswordTf release];
    [_newPasswordTf release];
    [_newPasswordConfirmTf release];
    [_msgVerifyCodeTf release];
    [super dealloc];
}


- (void)viewDidUnload {
    [self setOldPasswordTf:nil];
    [self setNewPasswordTf:nil];
    [self setNewPasswordConfirmTf:nil];
    [self setMsgVerifyCodeTf:nil];
    [self setVerifyCodeLbl:nil];
    [super viewDidUnload];
}

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
    // Do any additional setup after loading the view from its nib.
  
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark self define method
/*!
 *@description  响应点击返回按钮事件
 *@function     goBack:
 *@param        sender     --返回按钮
 *@return       (void)
 */
- (IBAction)goBack:(UIButton *)sender {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.presentingViewController dismissModalViewControllerAnimated:YES];
    }
}
/*!
 *@description  响应点击重置设备密码按钮事件
 *@function     ressetVer:
 *@param        sender     --返回按钮
 *@return       (void)
 */
- (IBAction)ressetVer:(UIButton *)sender {
    
    BBressetVerCodeViewController *lresset=[[BBressetVerCodeViewController alloc]init];
    lresset.telNum=_telNum;
    [self.navigationController pushViewController:lresset animated:YES];
    [lresset release];
    
    
    
}

/*!
 *@description  响应点击确认修改按钮事件
 *@function     onSureModify:
 *@param        sender     --返回按钮
 *@return       (void)
 */
- (IBAction)onSureModify:(UIButton *)sender {
    
    if (!_oldPasswordTf.text.length) {
        UtilAlert(@"请输入旧验证码", nil);
        return;
    }
    
    if(_oldPasswordTf.text.length>20){
        UtilAlert(@"旧验证码位数过长", nil);
        return;
    }
    
    if (!_newPasswordTf.text.length || !_newPasswordConfirmTf.text.length ) {
        UtilAlert(@"请输入两次新验证码", nil);
        return;
    }
    
    if (![_newPasswordConfirmTf.text isEqualToString:_newPasswordTf.text]) {
        UtilAlert(@"两次输入新验证码不一致", nil);
        return;
    }
    
    if(_newPasswordTf.text.length>20){
        UtilAlert(@"验证码位数过长", nil);
        return;
    }
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
    [_hud setLabelText:@"正在修改设备验证码..."];
    [_hud setRemoveFromSuperViewOnHide:YES];
    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
    NSString *userId = curUser.userid;
    NSString *param = [NSString stringWithFormat:@"%@\t%@\t%@",userId,_oldPasswordTf.text,_newPasswordTf.text];
    [mainClient setDeviceVerifyCode:self param:param];
}

- (void)onGetMSGVerifyCode:(id)sender
{
    if (_telNum.length != 11) {
        UtilAlert(@"获取手机号失败", nil);
        return;
    }
    BBLoginClient *logClient = [[[BBLoginClient alloc] init]autorelease];
    [logClient getMSGVerifyCode:_telNum delegate:self];
}



#pragma mark -
#pragma mark BBLoginClientDelegate method

- (void)getMSGVerifyCodeFailedWithErrorInfo:(NSString *)errorInfo{
    BBLog(@"%@",errorInfo);
    
}


#pragma mark -
#pragma mark BBSocketClientDelegate method

-(int)onRecevie:(BBDataFrame *)src received:(BBDataFrame *)data
{
    if(src.MainCmd == 0x0E && src.SubCmd == 92) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc]initWithString:[data dataString]];            
            NSString *strTxt=@"修改设备验证码失败";
            
            if (result && [result isEqualToString:@"0"]) {
                strTxt=@"修改设备验证码成功";
                
                [self performSelector:@selector(goBack:) withObject:nil afterDelay:1.3];
            }
            
            _hud.labelText = strTxt;            
            
            [result release];
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
            
        });
    }
    
    return 0;
}

-(void)onTimeout:(BBDataFrame *)src
{
    if(src.MainCmd == 0x0E && src.SubCmd == 92) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _hud.labelText = @"修改设备验证码超时";
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }
}


-(void)onRecevieError:(BBDataFrame*)src received:(BBDataFrame*)data
{
    if(src.MainCmd == 0x0E && src.SubCmd == 92) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _hud.labelText = @"修改设备验证码出现错误";
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }
}

@end
