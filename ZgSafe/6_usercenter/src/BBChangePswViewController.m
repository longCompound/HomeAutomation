//
//  BBChangePswViewController.m
//  ZgSafe
//
//  Created by YANGRea/Users/david/Desktop/中感-家庭卫士/ZgSafe/ZgSafe/6_usercenter/src/BBChangePswViewController.ml on 13-11-6.
//  密码设置
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBChangePswViewController.h"

@interface BBChangePswViewController ()<UITextFieldDelegate,UIAlertViewDelegate,BBSocketClientDelegate>
{
    MBProgressHUD *_hud;
}

@property (retain, nonatomic) IBOutlet UIView *bgView;
@property (retain, nonatomic) IBOutlet UIView *backRemindView;
@property (retain, nonatomic) IBOutlet UIButton *backCancelBtn;
@property (retain, nonatomic) IBOutlet UIButton *backSureBtn;
@property (retain, nonatomic) IBOutlet UIView *backCenterView;

- (IBAction)goback:(id)sender;
- (IBAction)onCancelBack:(UIButton *)sender;
- (IBAction)onSureBack:(UIButton *)sender;


- (IBAction)ConfirmChangeBtn:(id)sender;

@property (retain, nonatomic) IBOutlet UITextField *oldPsw;//旧的密码
@property (retain, nonatomic) IBOutlet UITextField *newPsw;//新的密码
@property (retain, nonatomic) IBOutlet UITextField *ConfirmPsw;//确认密码

@end

@implementation BBChangePswViewController

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
    
    _backCancelBtn.layer.borderWidth = 1.;
    _backCancelBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    _backSureBtn.layer.borderWidth = 1.;
    _backSureBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    _backSureBtn.layer.cornerRadius = 6.;
    _backSureBtn.clipsToBounds = YES;
    _backCancelBtn.layer.cornerRadius = 6.;
    _backCancelBtn.clipsToBounds = YES;
    _backCenterView.layer.cornerRadius = 11.;
    _backCenterView.clipsToBounds = YES;

}
- (void)dealloc {
    [_oldPsw release];
    [_newPsw release];
    [_ConfirmPsw release];
    [_bgView release];
    [_backRemindView release];
    [_backCancelBtn release];
    [_backSureBtn release];
    [_backCenterView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setOldPsw:nil];
    [self setNewPsw:nil];
    [self setConfirmPsw:nil];
    [self setBgView:nil];
    [self setBackRemindView:nil];
    [self setBackCancelBtn:nil];
    [self setBackSureBtn:nil];
    [self setBackCenterView:nil];
    [super viewDidUnload];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*!
 *@brief        点击屏幕键盘消失
 *@function     touchesBegan
 *@param        sener
 *@return       (void)
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
     [self.view endEditing:YES];
}

#pragma mark -
#pragma mark UITextFieldDelegate method 
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag ==30001) {
        [_oldPsw resignFirstResponder];
        [_newPsw becomeFirstResponder];
    }else if (textField.tag == 30002){
        [_newPsw resignFirstResponder];
        [_ConfirmPsw becomeFirstResponder];
    }else{
        [_ConfirmPsw resignFirstResponder];
    }
    return YES;
}


#pragma mark self define button method
/*!
 *@brief       返回上一个页面
 *@function     goback
 *@param        sener
 *@return       (void)
 */
- (IBAction)goback:(id)sender {
    [self.view endEditing:YES];
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.presentingViewController dismissModalViewControllerAnimated:YES];
    }}

/*!
 *@description  响应点击取消返回按钮事件
 *@function     onCancelBack:
 *@param        sender     --按钮
 *@return       (void)
 */
- (IBAction)onCancelBack:(UIButton *)sender {
    _backRemindView.hidden = YES;
}

/*!
 *@description  响应点击确定返回按钮事件
 *@function     onSureBack:
 *@param        sender     --按钮
 *@return       (void)
 */
- (IBAction)onSureBack:(UIButton *)sender {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.presentingViewController dismissModalViewControllerAnimated:YES];
    }
}
/*!
 *@brief        确认修改密码
 *@function     ConfirmChangeBtn
 *@param        sender
 *@return       （void）
 */
- (IBAction)ConfirmChangeBtn:(id)sender {
    
    [self.view endEditing:YES];
    
    NSString *oldPasswords=[_oldPsw.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *newPasswords=[_newPsw.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *aginPassword=[_ConfirmPsw.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (_oldPsw.text==nil || oldPasswords.length==0) {
        UtilAlert(@"旧密码为空", nil);
        return;
    }else if (_oldPsw.text.length>20){
        UtilAlert(@"旧密码位数过长", nil);
        return;
    }
    else if(_newPsw.text==nil || newPasswords.length==0){
        UtilAlert(@"新密码为空", nil);
        return;
    }else if(_ConfirmPsw.text==nil || aginPassword.length==0)
    {
        UtilAlert(@"确认密码为空", nil);
        return;
    
    }else if(![_ConfirmPsw.text isEqualToString:_newPsw.text]){
        UtilAlert(@"两次密码不相同", nil);
        return;

    }else if (_newPsw.text.length>20){
        UtilAlert(@"密码位数过长", nil);
        return;
    }else{
        
        UIAlertView *alt = [[UIAlertView alloc] initWithTitle:NOTICE_TITLE
                                                      message:@"是否修改密码"
                                                     delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alt show];
        [alt release];
    }
}

#pragma mark -
#pragma mark UIAlertViewDelegate method
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==1) {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
        [_hud setLabelText:@"正在修改密码..."];
        [_hud setRemoveFromSuperViewOnHide:YES];
        
        NSString *param = [[[NSString alloc]initWithFormat:@"%@\t%@\t%@",curUser.userid,_oldPsw.text,_ConfirmPsw.text]autorelease];
        BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
        [mainClient modifyDevPassword:self param:param];
    }
}


#pragma mark -
#pragma mark BBSocketClientDelegate method

-(int)onRecevie:(BBDataFrame *)src received:(BBDataFrame *)data
{
    if(src.MainCmd == 0x0E && src.SubCmd == 20) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc]initWithString:[data dataString]];
            if (result && [result isEqualToString:@"0"]) {
                [_hud setLabelText:@"修改登录密码成功"];
                _oldPsw.text = @"";
                _newPsw.text = @"";
                _ConfirmPsw.text = @"";
                
                if (self.navigationController) {
                    [self.navigationController popViewControllerAnimated:YES];
                }else{
                    [self.presentingViewController dismissModalViewControllerAnimated:YES];
                }
            }else{
                [_hud setLabelText:@"修改登录密码失败"];
            }
            
            [_hud performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
            
            [result release];
            

        });
    }
    return 0;
}

-(void)onTimeout:(BBDataFrame *)src
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Timeout src = %d",src.SubCmd);
        [_hud setLabelText:@"修改登录密码超时"];
        [_hud performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
    });
}


-(void)onRecevieError:(BBDataFrame*)src received:(BBDataFrame*)data
{
    NSLog(@"RecevieError");
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Timeout src = %d",src.SubCmd);
        [_hud setLabelText:@"修改登录密码出错"];
        [_hud performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
    });
}


@end
