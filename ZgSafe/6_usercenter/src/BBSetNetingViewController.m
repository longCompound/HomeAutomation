//
//  BBSetNetingViewController.m
//  ZgSafe
//
//  Created by iXcoder on 13-10-29.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBSetNetingViewController.h"
#import "BBLoginViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface BBSetNetingViewController ()<UIAlertViewDelegate>
{
    NSArray *_dataArray;
    BOOL _pickerHide;
    CGFloat _sysVersion;
}

@property (retain, nonatomic) IBOutlet UITextField *wifi;//WIFI
@property (retain, nonatomic) IBOutlet UIPickerView *wifiPicker;//WIFI picker

@property (retain, nonatomic) IBOutlet UITextField *password;//密码
@property (retain, nonatomic) IBOutlet UITextField *ip;//服务器ip
- (IBAction)go_buckLogin:(UIButton *)sender;//取消
- (IBAction)setUp:(UIButton *)sender;//确定

- (IBAction)checkButton:(UIButton *)sender;//差看有那些wifi
@property (retain, nonatomic) IBOutlet UIView *lastView;

@end

@implementation BBSetNetingViewController

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
    _pickerHide=YES;
   _dataArray = [[NSArray alloc]initWithObjects:@"许嵩",@"周杰伦",@"梁静茹",@"许飞",@"凤凰传奇",@"阿杜",@"方大同",@"林俊杰",@"胡夏",@"邱永传", nil];
    [self getDeviceSSID];
}


- (NSString *) getDeviceSSID
{
    
    NSArray *ifs = (__bridge id)CNCopySupportedInterfaces();
    
    id info = nil;
    
    for (NSString *ifnam in ifs) {
        
        info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        
        if (info && [info count]) {
            
            break;
            
        }
        
    }
    
    NSDictionary *dctySSID = (NSDictionary *)info;
    
    NSString *ssid = [[dctySSID objectForKey:@"SSID"] lowercaseString];
    
    return ssid;
    
}

/*!
 *@brief        返回上一个页面
 *@function     setUp
 *@param        sender
 *@return       （void）
 */
- (IBAction)go_buckLogin:(UIButton *)sender{
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}
/*!
 *@brief        确定设置
 *@function     setUp
 *@param        sender
 *@return       （void）
 */
- (IBAction)setUp:(UIButton *)sender {
    NSString *passwordStr=[_password.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (_password.text==nil || passwordStr.length==0) {
        UtilAlert(@"密码为空", nil);
        return;

    }else{
    UIAlertView *alter=[[UIAlertView alloc]initWithTitle:NOTICE_TITLE
                                                 message:@"你确定是否要更改设置?"
                                                delegate:self
                                       cancelButtonTitle:@"取消"
                                       otherButtonTitles:@"确定", nil];
    [alter show];
    [alter release];
    }
}

/*!
 *@brief        键盘回收
 *@function     touchesBegan
 *@param        sender
 *@return       （void）
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    if (_pickerHide==NO) {
        [self uiviewPicker];
    }
}
/*!
 *@brief        查看有那写wifi
 *@function     checkButton
 *@param        sender
 *@return       （void）
 */
- (IBAction)checkButton:(UIButton *)sender {
    [self.view endEditing:YES];
    if (_pickerHide==YES) {
    
        [UIView animateWithDuration:0.5 animations:^{
                       [_wifiPicker setFrame:CGRectMake(0, _wifiPicker.frame.origin.y-216, self.view.frame.size.width, self.view.frame.size.height)];
            
        }];
        _pickerHide=NO;
        
    }else {
        [self uiviewPicker];
    }
    
}
/*!
 *@brief        设置picker的返回值
 *@function     uiviewPicker
 *@param        sender
 *@return       （void）
 */
-(void)uiviewPicker
{
    
    [UIView animateWithDuration:0.5 animations:^{
        
        [_wifiPicker setFrame:CGRectMake(0, _wifiPicker.frame.origin.y+216, self.view.frame.size.width, self.view.frame.size.height)];
    }];
    _pickerHide =YES;

}

#pragma mark-
#pragma maer UIPickerViewDelegate method
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _dataArray.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_dataArray objectAtIndex:row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
   
    _wifi.text=[_dataArray objectAtIndex:row];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-
#pragma mare UIAlertViewDelegate method;

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self dismissModalViewControllerAnimated:YES];
   
}
- (void)dealloc {
    [_wifi release];
    [_password release];
    [_ip release];
    [_wifiPicker release];
    [_lastView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setWifi:nil];
    [self setPassword:nil];
    [self setIp:nil];
    [self setWifiPicker:nil];
    [self setLastView:nil];
    [super viewDidUnload];
}

@end
