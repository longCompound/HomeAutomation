//
//  BBresetPassWordViewController.m
//  ZgSafe
//
//  Created by apple on 14-5-26.
//  Copyright (c) 2014年 iXcoder. All rights reserved.
//

#import "BBresetPassWordViewController.h"

@interface BBresetPassWordViewController ()<BBLoginClientDelegate,BBSocketClientDelegate>{

    MBProgressHUD *_hud;
}
@property (retain, nonatomic) IBOutlet UILabel *verifyCodeLbl;
@property (retain, nonatomic) IBOutlet UITextField *mobilePhoneNo;
@property (retain, nonatomic) IBOutlet UITextField *newPasswordTf;
@property (retain, nonatomic) IBOutlet UITextField *newPasswordConfirmTf;
@property (retain, nonatomic) IBOutlet UITextField *msgVerifyCodeTf;


- (IBAction)onSureModify:(UIButton *)sender;
- (IBAction)goBack:(UIButton *)sender;


@end
@implementation BBresetPassWordViewController

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
    
    BlueBoxer *user = curUser;
    _mobilePhoneNo.text = user.userid?user.userid:@"";
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onGetMSGVerifyCode:)];
    [_verifyCodeLbl addGestureRecognizer:tap];
    [tap release];
    
    UITapGestureRecognizer *Btap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bBackG:)];
    _backG.userInteractionEnabled=YES;
    [_backG addGestureRecognizer:Btap];
    [Btap release];
    
    [_newPasswordConfirmTf setSecureTextEntry:YES];
    [_newPasswordTf setSecureTextEntry:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*!
 *@description  关键盘
 *@function     bBackG:
 *@param        sender     --返回按钮
 *@return       (void)
 */

-(void)bBackG:(UITapGestureRecognizer *)sender{

    [_msgVerifyCodeTf resignFirstResponder];
    [_mobilePhoneNo resignFirstResponder];
    [_newPasswordTf resignFirstResponder];
    [_newPasswordConfirmTf resignFirstResponder];
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
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

/*!
 *@description  响应点击确认修改按钮事件
 *@function     onSureModify:
 *@param        sender     --返回按钮
 *@return       (void)
 */
- (IBAction)onSureModify:(UIButton *)sender {
    
    if (!_mobilePhoneNo.text.length || !_mobilePhoneNo.text.length ) {
        UtilAlert(@"请输入手机号", nil);
        return;
    }
    
    if(_mobilePhoneNo.text.length>12)
    {
        UtilAlert(@"输入的手机号大于11位", nil);
        return;
    }
    if (![_msgVerifyCodeTf.text isEqualToString:_msgVerifyCodeTf.text]) {
        UtilAlert(@"请输入短信校验码", nil);
        return;
    }
    
    if (!_newPasswordTf.text.length || !_newPasswordConfirmTf.text.length ) {
        UtilAlert(@"请输入新密码", nil);
        return;
    }
    
    if (![_newPasswordConfirmTf.text isEqualToString:_newPasswordTf.text]) {
        UtilAlert(@"请输入确认密码", nil);
        return;
    }
    
    if (!_newPasswordTf.text.length>20) {
        UtilAlert(@"密码位数过长", nil);
        return;
    }
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
    [_hud setLabelText:@"正在重置密码..."];
    [_hud setRemoveFromSuperViewOnHide:YES];

    NSString *param = [NSString stringWithFormat:@"%@\t%@\t%@",_msgVerifyCodeTf.text,_mobilePhoneNo.text,_newPasswordTf.text];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
       [[[BBSocketManager getInstance] loginClient]resetPassWord:param delegate:self];
    });
    
}


- (void)onGetMSGVerifyCode:(id)sender
{
    if (_mobilePhoneNo.text.length != 11) {
        UtilAlert(@"请输入手机号", nil);
        return;
    }
    
    BBLoginClient *logClient = [[[BBLoginClient alloc] init]autorelease];
    [logClient getMSGVerifyCode:_mobilePhoneNo.text delegate:self];
}



- (void)getMSGVerifyCodeTimer:(NSTimer *)timer
{
    NSInteger last = [_verifyCodeLbl.text integerValue]-1;
    if (last) {
        _verifyCodeLbl.text = [NSString stringWithFormat:@"%d秒",last];
    }else{
        _verifyCodeLbl.text = @"获取";
        _verifyCodeLbl.userInteractionEnabled = YES;
        [timer invalidate];
    }
}

#pragma mark -
#pragma mark BBLoginClientDelegate method

- (void)getMSGVerifyCodeReceiveData:(BBDataFrame *)data{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *result = [[NSString alloc]initWithString:[data dataString]];
        BBLog(@"%@",result);
        [result release];
        
        _verifyCodeLbl.text = @"59秒";
        _verifyCodeLbl.userInteractionEnabled = NO;
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getMSGVerifyCodeTimer:) userInfo:nil repeats:YES];
    });
}

- (void)getMSGVerifyCodeFailedWithErrorInfo:(NSString *)errorInfo{
    BBLog(@"%@",errorInfo);
    
}

#pragma mark BBSocketClientDelegate method
-(void)resetPassWordReceiveData:(BBDataFrame *)data{

    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *result = [[NSString alloc]initWithBytes:[data.data bytes] length:data.data.length encoding:GBK_ENCODEING];
        
        if(result && [result isEqualToString:@"0"] ){
            _hud.labelText = @"重置密码成功";  
        }else{
            _hud.labelText = @"重置密码失败";
        }
        
        [result release];
        [_hud performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        
    });


}


-(void)dealloc{    
    [_verifyCodeLbl release];
    [_newPasswordTf release];
    [_newPasswordConfirmTf release];
    [_backG release];
    [super dealloc];
}
-(void)viewDidUnload{
    [self setNewPasswordTf:nil];
    [self setNewPasswordConfirmTf:nil];
    [self setMsgVerifyCodeTf:nil];
    [self setVerifyCodeLbl:nil];
    [self setBackG:nil];
    [super viewDidUnload];
}

@end
