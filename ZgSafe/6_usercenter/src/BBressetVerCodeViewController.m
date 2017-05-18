//
//  BBressetVerCodeViewController.m
//  ZgSafe
//
//  Created by apple on 14-5-26.
//  Copyright (c) 2014年 iXcoder. All rights reserved.
//

#import "BBressetVerCodeViewController.h"

@interface BBressetVerCodeViewController ()<BBLoginClientDelegate,BBSocketClientDelegate>{
    MBProgressHUD *_hud;
}

@property (retain, nonatomic) IBOutlet UITextField *txt_SMSCode;
@property (retain, nonatomic) IBOutlet UITextField *txt_Password;
@property (retain, nonatomic) IBOutlet UITextField *txt_PasswordConfirm;
@property (retain, nonatomic) IBOutlet UILabel *verifyCodeLbl;
@property (nonatomic, assign) NSString *P_SMSTime;//短信时间戳

- (IBAction)onSureModify:(UIButton *)sender;
- (IBAction)goBack:(UIButton *)sender;

@end

@implementation BBressetVerCodeViewController

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
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onGetMSGVerifyCode:)];
    [_verifyCodeLbl addGestureRecognizer:tap];
    [tap release];

    UITapGestureRecognizer *btap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bBackG:)];
    _BbackG.userInteractionEnabled=YES;
    [_BbackG addGestureRecognizer:btap];
    [btap release];


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
 *@description  关键盘
 *@function     bBackG:
 *@param        sender     --返回按钮
 *@return       (void)
 */

-(void)bBackG:(UITapGestureRecognizer *)sender{
    
    [_txt_SMSCode resignFirstResponder];
    [_txt_Password resignFirstResponder];
    [_txt_PasswordConfirm resignFirstResponder];
}

/*!
 *@description  响应点击确认修改按钮事件
 *@function     onSureModify:
 *@param        sender     --返回按钮
 *@return       (void)
 */
- (IBAction)onSureModify:(UIButton *)sender {

    if(!_txt_SMSCode.text.length && _P_SMSTime!=nil){
        UtilAlert(@"请输短信校验证码", nil);
        return;
    }
    
    if(!_txt_Password.text.length){
        UtilAlert(@"请输入新验证码", nil);
        return;
    }
    
    if (!_txt_PasswordConfirm.text.length) {
        UtilAlert(@"请输入确认验证码", nil);
        return;
    }

    if (![_txt_Password.text isEqualToString:_txt_PasswordConfirm.text]) {
        UtilAlert(@"两次输入验证码不一致", nil);
        return;
    }
    
    if(_txt_Password.text.length>20){
        UtilAlert(@"验证码位数过长", nil);
        return;
    }

    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
    [_hud setLabelText:@"正在重置设备验证码..."];
    [_hud setRemoveFromSuperViewOnHide:YES];
    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
    
    NSString *param = [NSString stringWithFormat:@"%@\t%@\t%@",_txt_SMSCode.text,_P_SMSTime,_txt_Password.text];

    [mainClient resetVerifyCode:self param:param];
}

- (void)onGetMSGVerifyCode:(id)sender
{
    NSString *strUserId=curUser.userid;
    
    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];

    [mainClient toSendMSMCode:self param:strUserId];
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
#pragma mark BBSocketClientDelegate method

-(int)onRecevie:(BBDataFrame *)src received:(BBDataFrame *)data
{
    if(src.MainCmd == 0x0E && src.SubCmd == 95) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc]initWithString:[data dataString]];
            
            if(result && [result isEqualToString:@"0"]){
                _hud.labelText = @"重置设备验证码成功";
                [self performSelector:@selector(goBack:) withObject:nil afterDelay:1.3];
            }else{
                 _hud.labelText = @"重置设备验证码失败";
            }

            [result release];
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
            
        });
    }else if (src.MainCmd == 0x0E && src.SubCmd == 94) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc]initWithString:[data dataString]];
            
            if(result){
                NSArray *arr = [result componentsSeparatedByString:@"\t"];
                
                if(arr.count==2 && [arr[0] isEqualToString:@"0"]){
                    
                    _P_SMSTime = [[NSString alloc] initWithFormat:@"%@", arr[1]];
                    
                    UtilAlert(@"短信校验码已发送，请注意查收", nil);
                }else{
                    UtilAlert(@"获取短信校验码失败", nil);
                }
                
            }else{
                UtilAlert(@"获取短信校验码失败", nil);
            }
            
            
            [result release];
            
            _verifyCodeLbl.text = @"59秒";
            _verifyCodeLbl.userInteractionEnabled = NO;
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(getMSGVerifyCodeTimer:) userInfo:nil repeats:YES];
        });
    }
    
    return 0;
}

-(void)onTimeout:(BBDataFrame *)src
{
    if(src.MainCmd == 0x0E && src.SubCmd == 95) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _hud.labelText = @"重置设备验证码超时";
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }else if(src.MainCmd == 0x0E && src.SubCmd == 94) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _hud.labelText = @"获取短信校验码失败";
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }
}


-(void)onRecevieError:(BBDataFrame*)src received:(BBDataFrame*)data
{
    if(src.MainCmd == 0x0E && src.SubCmd == 95) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _hud.labelText = @"重置设备验证码出现错误";
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }else if(src.MainCmd == 0x0E && src.SubCmd == 94) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _hud.labelText = @"获取短信校验码失败";
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }
}
//获取时间戳
-(NSString *)getdate{
    NSString* date;
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"hh:mm:ss:SSS"];
    date = [formatter stringFromDate:[NSDate date]];
    NSString *timeNow = [[NSString alloc] initWithFormat:@"%@", date];

    return timeNow;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [_msVer release];
    [_txt_PasswordConfirm release];
    [_txt_Password release];
    [_txt_SMSCode release];
    [_BbackG release];
    [_P_SMSTime release];
    [super dealloc];

}
-(void)viewDidUnload{
    [self setTxt_Password:nil];
    [self setTxt_PasswordConfirm:nil];
    [self setTxt_SMSCode:nil];
    [self setVerifyCodeLbl:nil];
    [self setBbackG:nil];
    [self setP_SMSTime:nil];
    [super viewDidUnload];
}
@end
