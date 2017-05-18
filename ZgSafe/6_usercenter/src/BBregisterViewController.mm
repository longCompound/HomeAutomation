//
//  BBregisterViewController.m
//  ZgSafe
//  用户注册
//  Created by iXcoder on 13-10-29.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBregisterViewController.h"
#import "BBLoginViewController.h"
#import <ZXingWidgetController.h>
#import <QRCodeReader.h>
#import <MultiFormatOneDReader.h>

@interface BBregisterViewController () <ZXingDelegate,UINavigationControllerDelegate,BBLoginClientDelegate>
{
  NSString *scanResult ;      //二维码扫描结果
    MBProgressHUD *_hud;

}
@property (retain, nonatomic) IBOutlet UITextField *mobilePhoneNo;//输入电话号码
@property (retain, nonatomic) IBOutlet UITextField *nickName;//输入昵称
@property (retain, nonatomic) IBOutlet UITextField *password;//输入密码
@property (retain, nonatomic) IBOutlet UITextField *aginPassword;//再次输入密码
@property (retain, nonatomic) IBOutlet UITextField *address;//输入地址
@property (retain, nonatomic) IBOutlet UITextField *deviceNumber;//输入设备号
@property (retain, nonatomic) IBOutlet UITextField *inputValidationCode;//输入验证码
@property (retain, nonatomic) IBOutlet UIScrollView *scollVifew;//scollview
@property (retain, nonatomic) IBOutlet UITextField *msgCodeTf;
@property (retain, nonatomic) IBOutlet UIView *footView;//下面的view
@property (retain, nonatomic) IBOutlet UILabel *verifyCodeLbl;
- (IBAction)go_Back:(UIButton *)sender;//返回
- (IBAction)submitUser:(UIButton *)sender;//提交
- (IBAction)bigButton:(UIButton *)sender;//键盘回收
- (IBAction)inputValidationCode:(UIButton *)sender;//扫描二维码

@end

@implementation BBregisterViewController

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
    
    appDelegate.UserRegister=NO;
    
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (self.view.frame.size.height>480) {
            [_scollVifew setContentSize:CGSizeMake(_scollVifew.frame.size.width, _scollVifew.frame.size.height+1)];
        }else{
            [_scollVifew setContentSize:CGSizeMake(_scollVifew.frame.size.width, _scollVifew.frame.size.height+60)];
        }

    });
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*!
 *@brief        返回上一个页面
 *@function     go_Back
 *@param        sender
 *@return       （void）
 */
- (IBAction)go_Back:(UIButton *)sender {

    [self.presentingViewController dismissModalViewControllerAnimated:YES];
   
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//            [[BBSocketManager getInstance] login:_mobilePhoneNo.text password:_password.text delegate:self];
//        });
//        
   
}
-(void)viewDidAppear:(BOOL)animated{

    self.view.frame=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);

}
- (void)onGetMSGVerifyCode:(id)sender
{
    if(!_mobilePhoneNo.text.length){
        UtilAlert(@"手机号码为空", nil);
        return;
    }else{
        BBLoginClient *logClient = [[[BBLoginClient alloc] init]autorelease];
        [logClient getMSGVerifyCode:_mobilePhoneNo.text delegate:self];
    }
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

/*!
 *@brief        提交注册
 *@function     submitUser
 *@param        sender
 *@return       （void）
 */
- (IBAction)submitUser:(UIButton *)sender {
    
    
    
     NSString *phone=[_mobilePhoneNo.text stringByReplacingOccurrencesOfString:@" " withString:@""];
     NSString *nickName=[_nickName.text stringByReplacingOccurrencesOfString:@" " withString:@""];
     NSString *password=[_password.text stringByReplacingOccurrencesOfString:@" " withString:@""];
     NSString *aginpassword=[_aginPassword.text stringByReplacingOccurrencesOfString:@" " withString:@""];
     NSString *addr=[_address.text stringByReplacingOccurrencesOfString:@" " withString:@""];
     NSString *devicenumber=[_deviceNumber.text stringByReplacingOccurrencesOfString:@" " withString:@""];
     NSString *dataingCode=[_inputValidationCode.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (_mobilePhoneNo.text==nil ||phone.length==0) {
        UtilAlert(@"手机号码为空", nil);
        return;
    }
    
    if (_mobilePhoneNo.text.length>11)
    {
        UtilAlert(@"输入的手机号码大于11位", nil);
        return;
    }
    
    if(_mobilePhoneNo.text.length<11)
    {
        UtilAlert(@"输入的手机号码小于11位", nil);
        return;
    }
    
    if (_nickName.text==nil||nickName.length==0)
    {
        UtilAlert(@"昵称为空", nil);
        return;

    }
    
    if (_password.text==nil ||password.length==0)
    {
        UtilAlert(@"密码为空", nil);
        return;
    }
    
    if (_aginPassword.text==nil || aginpassword.length==0)
    {
        UtilAlert(@"重复密码为空", nil);
        return;
    }else if (![_password.text isEqualToString:_aginPassword.text])
    {
        UtilAlert(@"两次输入的密码不相同", nil);
        return;
    }else if (_address.text==nil||addr.length==0)
    {
        UtilAlert(@"地址为空", nil);
        return;

    }else if(_deviceNumber.text==nil||devicenumber.length==0)
    {
        UtilAlert(@"设备号为空", nil);
        return;
    }else if (_inputValidationCode.text==nil||dataingCode.length==0)
    {
        UtilAlert(@"验证码为空", nil);
        return;
    }else
    {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.labelText = @"正在注册...";
        _hud.labelFont = [UIFont systemFontOfSize:13.0f];
        _hud.removeFromSuperViewOnHide = YES;
        
        
        NSMutableString *param = [[NSMutableString alloc]init];
        [param appendFormat:@"%@\t",_mobilePhoneNo.text];
        [param appendFormat:@"%@\t",_password.text];
        [param appendFormat:@"%@\t",_deviceNumber.text];
        [param appendFormat:@"%@\t",_inputValidationCode.text];
        [param appendFormat:@"%@\t",[NSString stringWithUTF8String:[_address.text UTF8String]]];
        [param appendFormat:@"%@\t",_nickName.text];
        [param appendFormat:@"%@",_msgCodeTf.text];
        
        [[BBSocketManager getInstance]registerNewUser:param delegate:self];
        
        [param release];
        
    }
}




/*!
  *@brief        键盘回收
  *@function     bigButton
  *@param        sender
  *@return       （void）
  */
- (IBAction)bigButton:(UIButton *)sender {
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.25 animations:^{
    
        [_footView setFrame:CGRectMake(0, 80,_footView.frame.size.width, _footView.frame.size.height)];
    }];

}
/*!
 *@brief        扫描二维码
 *@function     inputValidationCode
 *@param        sender
 *@return       （void）
 */
- (IBAction)inputValidationCode:(UIButton *)sender {
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.25 animations:^{
        
        [_footView setFrame:CGRectMake(0, 80,_footView.frame.size.width, _footView.frame.size.height)];
    }];
    
    ZXingWidgetController *wc = [[ZXingWidgetController alloc] initWithDelegate:self showCancel:YES OneDMode:NO];
    NSMutableSet *readers = [[NSMutableSet alloc ] init];
    QRCodeReader *qrcodeReader = [[QRCodeReader alloc] init];
    [readers addObject:qrcodeReader];
    [qrcodeReader release];
    MultiFormatOneDReader *mReader = [[MultiFormatOneDReader alloc] init];
    [readers addObject:mReader];
    [mReader release];
    wc.readers = readers;
    [readers release];
    
   [self presentViewController:wc animated:YES completion:nil];
    [wc release];
    
}
#pragma mark -
#pragma mark ZXingDelegate method
- (void)zxingController:(ZXingWidgetController *)controller didScanResult:(NSString *)result
{
    
    [controller.presentingViewController dismissModalViewControllerAnimated:YES];
    if (scanResult) {
        [scanResult release];
    }
    
    scanResult = [[NSString alloc] initWithFormat:@"%@", result];
    _deviceNumber.text = scanResult;
}

- (void)zxingControllerDidCancel:(ZXingWidgetController *)controller
{
    [controller.presentingViewController dismissModalViewControllerAnimated:YES];
    
}
#pragma mark-
#pragma mark UITextFieldDelegate method
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{

    switch (textField.tag) {
        case 10000:
        {
            break;
        }
        case 10001:
        {
            break;
        }
        case 10002:
        {
            break;
        }
        case 10003:
        {
        [UIView animateWithDuration:0.25 animations:^{
            [_footView setCenter:CGPointMake(self.view.frame.size.width/2,250)];
        }];
        break;
            
        }
        case 10004:
        {
            [UIView animateWithDuration:0.25 animations:^{
                [_footView setCenter:CGPointMake(self.view.frame.size.width/2,230)];
            }];
            break;
        }
        case 10005:
        {
            [UIView animateWithDuration:0.25 animations:^{
                [_footView setCenter:CGPointMake(self.view.frame.size.width/2,150)];
            }];
            break;
        }
        case 10006:
        {
            [UIView animateWithDuration:0.25 animations:^{
                [_footView setCenter:CGPointMake(self.view.frame.size.width/2,140)];
            }];
            break;
        }
        case 10007:
        {
            [UIView animateWithDuration:0.25 animations:^{
                [_footView setCenter:CGPointMake(self.view.frame.size.width/2,100)];
            }];
            break;
        }
        default:
            break;
    }
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
       switch (textField.tag) {
        case 10000:
        {
            [_mobilePhoneNo resignFirstResponder];
            [_password becomeFirstResponder];
            break;
        }
            
        case 10001:
        {
           [_mobilePhoneNo resignFirstResponder];
           [_nickName becomeFirstResponder];

            break;
        }
        case 10002:
        {
            [_mobilePhoneNo resignFirstResponder];
            [_aginPassword becomeFirstResponder];

            break;
        }

        case 10003:
        {
           [_mobilePhoneNo resignFirstResponder];
           [_address becomeFirstResponder];

            break;
        }

        case 10004:
        {
            [_mobilePhoneNo resignFirstResponder];
            [_deviceNumber becomeFirstResponder];

            break;
        }

        case 10005:
        {
            [_mobilePhoneNo resignFirstResponder];
            [_inputValidationCode becomeFirstResponder];

            break;
        }

        case 10006:
        {
            [_mobilePhoneNo resignFirstResponder];
            [UIView animateWithDuration:0.25 animations:^{
                [_footView setFrame:CGRectMake(0, 80,_footView.frame.size.width, _footView.frame.size.height)];

            }];

            break;
        }
        default:
            break;
    }
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame=CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);

}
- (void)dealloc {
    [_scollVifew release];
    [_footView release];
    [_mobilePhoneNo release];
    [_nickName release];
    [_password release];
    [_aginPassword release];
    [_address release];
    [_deviceNumber release];
    [_inputValidationCode release];
    [_verifyCodeLbl release];
    [_msgCodeTf release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setScollVifew:nil];
    [self setFootView:nil];
    [self setMobilePhoneNo:nil];
    [self setNickName:nil];
    [self setPassword:nil];
    [self setAginPassword:nil];
    [self setAddress:nil];
    [self setDeviceNumber:nil];
    [self setInputValidationCode:nil];
    [self setVerifyCodeLbl:nil];
    [self setMsgCodeTf:nil];
    [super viewDidUnload];
}


#pragma mark -
#pragma mark BBLoginClientDelegate method
- (void)registReceiveData:(BBDataFrame *)data
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSString *result = [[NSString alloc]initWithString:[data dataString]];
        NSString *strTxt=@"注册失败";
        
        if(result){
            NSArray *arr = [result componentsSeparatedByString:@"\t"];
            
            if([arr[0] isEqualToString:@"0"]){
                 strTxt = @"注册成功";
                
                [[NSUserDefaults standardUserDefaults]setObject:_mobilePhoneNo.text forKey:@"userName"];
                [[NSUserDefaults standardUserDefaults]setObject:_password.text forKey:@"passWord"];
                
                appDelegate.UserRegister=YES;
                
                [self performSelector:@selector(go_Back:) withObject:nil afterDelay:1.5];
            }else if (arr.count==2){
               strTxt = arr[1];
            }else if([arr[0] isEqualToString:@"N"]){
                strTxt=@"短信验校码错误";
            }
        }
        
        [result release];
        _hud.labelText = strTxt;
        [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5f];
    });
}

- (void)registFailedWithErrorInfo:(NSString *)errorInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _hud.labelText = errorInfo;
        [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5f];
    });
}



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

#pragma mark loginDelegate
-(void)loginReceiveData:(BBDataFrame *)data{
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *result = [[NSString alloc]initWithBytes:[data.data bytes] length:data.data.length encoding:GBK_ENCODEING];
        //        NSArray *arr = [result componentsSeparatedByString:@"\t"];
        //        if ([arr[0] boolValue]) {
        //            _hud.labelText = arr[1];
        //        }else{
        //            _hud.labelText = @"登录成功";
        //
        //            [[NSUserDefaults standardUserDefaults]setObject:_moblePhone.text forKey:@"userName"];
        //            [[NSUserDefaults standardUserDefaults]setObject:_passwordPhone.text forKey:@"passWord"];
        
        BlueBoxer *sysUser = [BlueBoxerManager getCurrentUser];
        sysUser.loged = YES;
        [BlueBoxerManager archiveCurrentUser:sysUser];
        
        [self presentViewController:[BBsigle sigleManager].lNavigation animated:YES completion:nil];
        
        double delayInSeconds = 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            //                [appDelegate.homePageVC getAllDatas];
            [appDelegate.homePageVC registNotices];
        });
        
        //            [self.presentingViewController dismissModalViewControllerAnimated:YES];
        //        }
        //        [_hud performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        //        
        //        [result release];
    });

//    [self presentViewController:[BBsigle sigleManager].lNavigation animated:YES completion:nil];
}
@end
