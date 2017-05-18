//
//  BBregisterViewController.m
//  ZgSafe
//  用户注册
//  Created by iXcoder on 13-10-29.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBregisterViewController.h"
#import "BBLoginViewController.h"
@interface BBregisterViewController ()
{
  

}
@property (retain, nonatomic) IBOutlet UITextField *mobilePhoneNo;//输入电话号码
@property (retain, nonatomic) IBOutlet UITextField *nickName;//输入昵称
@property (retain, nonatomic) IBOutlet UITextField *password;//输入密码
@property (retain, nonatomic) IBOutlet UITextField *aginPassword;//再次输入密码
@property (retain, nonatomic) IBOutlet UITextField *address;//输入地址
@property (retain, nonatomic) IBOutlet UITextField *deviceNumber;//输入设备号
@property (retain, nonatomic) IBOutlet UITextField *inputValidationCode;//输入验证码
@property (retain, nonatomic) IBOutlet UIScrollView *scollVifew;//scollview
@property (retain, nonatomic) IBOutlet UIView *footView;//下面的view
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

    [self.navigationController popViewControllerAnimated:YES];

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
        UIAlertView *alter=[[UIAlertView alloc]initWithTitle:@"温馨提示"
                                                     message:@"你输入的手机号为空"
                                                    delegate:self
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles: nil];
        [alter show];
        [alter release];
      
    }else if (_mobilePhoneNo.text.length>11)
    {
        UIAlertView *alter=[[UIAlertView alloc]initWithTitle:@"温馨提示"
                                                     message:@"你输入的手机号大于11位"
                                                    delegate:self
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles: nil];
        [alter show];
        [alter release];
       

    }else if(_mobilePhoneNo.text.length<=11)
    {
        UIAlertView *alter=[[UIAlertView alloc]initWithTitle:@"温馨提示"
                                                     message:@"你输入的手机号小于11位"
                                                    delegate:self
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles: nil];
        [alter show];
        [alter release];
      

    }else if (_nickName.text==nil||nickName.length==0)
    {
        UIAlertView *alter=[[UIAlertView alloc]initWithTitle:@"温馨提示"
                                                     message:@"你输入的昵称不能为空"
                                                    delegate:self
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles: nil];
        [alter show];
        [alter release];
     

    }else if (_password.text==nil ||password.length==0)
    {
        UIAlertView *alter=[[UIAlertView alloc]initWithTitle:@"温馨提示"
                                                     message:@"你输入的密码不能为空"
                                                    delegate:self
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles: nil];
        [alter show];
        [alter release];
      
    }else if (_aginPassword.text==nil || aginpassword.length==0)
    {
        UIAlertView *alter=[[UIAlertView alloc]initWithTitle:@"温馨提示"
                                                     message:@"你输入的重复密码不能为空"
                                                    delegate:self
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles: nil];
        [alter show];
        [alter release];
        

    }else if ([_password.text isEqualToString:_aginPassword.text])
    {
        UIAlertView *alter=[[UIAlertView alloc]initWithTitle:@"温馨提示"
                                                     message:@"你两次输入的密码不相同"
                                                    delegate:self
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles: nil];
        [alter show];
        [alter release];
       

    }else if (_address.text==nil||addr.length==0)
    {
        UIAlertView *alter=[[UIAlertView alloc]initWithTitle:@"温馨提示"
                                                     message:@"你输入的地址不能为空"
                                                    delegate:self
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles: nil];
        [alter show];
        [alter release];
      

    }else if(_deviceNumber.text==nil||devicenumber.length==0)
    {
        UIAlertView *alter=[[UIAlertView alloc]initWithTitle:@"温馨提示"
                                                     message:@"你输入的设备号不能为空"
                                                    delegate:self
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles: nil];
        [alter show];
        [alter release];
       
    }else if (_inputValidationCode.text==nil||dataingCode.length==0)
    {
        UIAlertView *alter=[[UIAlertView alloc]initWithTitle:@"温馨提示"
                                                     message:@"你输入的验证码不能为空"
                                                    delegate:self
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles: nil];
        [alter show];
        [alter release];
        return;

    
    }else
    {
    
        NSLog(@"我输正确了");
    }
}
/*!
  *@brief        键盘回收
  *@function     bigButton
  *@param        sender
  *@return       （void）
  */

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (IBAction)bigButton:(UIButton *)sender {
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.25 animations:^{
        [_footView setCenter:CGPointMake(self.view.frame.size.width/2,320)]; 
    }]; 
}
/*!
 *@brief        扫描二维码
 *@function     inputValidationCode
 *@param        sender
 *@return       （void）
 */
- (IBAction)inputValidationCode:(UIButton *)sender {
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"二维码扫描"
                                                 message:@"是否开启二维码扫描？"
                                                delegate:self
                                       cancelButtonTitle:@"取消"
                                       otherButtonTitles:@"确定", nil];
    [alert show];
    [alert release];
    
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
//            self.view.frame = CGRectMake(self.view.frame.origin.x
//                                         , self.view.frame.origin.y-216
//                                         , self.view.frame.size.width
//                                         , self.view.frame.size.height);
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
                [_footView setCenter:CGPointMake(self.view.frame.size.width/2,170)];
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
        default:
            break;
    }
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [UIView animateWithDuration:0.25 animations:^{
        [_footView setCenter:CGPointMake(self.view.frame.size.width/2,320)];
    }];
    switch (textField.tag) {
        case 10000:
        {
            [_mobilePhoneNo resignFirstResponder];
            [_nickName becomeFirstResponder];
            break;
        }
            
        case 10001:
        {
            [_mobilePhoneNo resignFirstResponder];
            [_password becomeFirstResponder];

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

            break;
        }
        default:
            break;
    }
    [textField resignFirstResponder];
    return YES;
}
//- (void)textFieldDidEndEditing:(UITextField *)textField
//{
//    
//}
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
    [super viewDidUnload];
}


@end
