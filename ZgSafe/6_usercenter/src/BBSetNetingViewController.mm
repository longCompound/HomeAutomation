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
#import <ZXingWidgetController.h>
#import <QRCodeReader.h>
#import <MultiFormatOneDReader.h>
#import <IOTCamera/Camera.h>
#import <IOTCamera/AVIOCTRLDEFs.h>
//#import "MyCamera.h"
#import "my51c_deviceDiscover.h"
#import "My51cUdpSearcher.h"

#define CAMERA_IP @"192.168.234.1"
#define CAMERA_WIFI_NAME @"Hoxlox"

@interface BBSetNetingViewController ()<UIAlertViewDelegate,ZXingDelegate,CameraDelegate,ASIHTTPRequestDelegate>
{
    NSMutableArray *_dataArray;
    BOOL _pickerHide;
    CGFloat _sysVersion;
    Camera *myCamera;
    MBProgressHUD *_hud;
    NSInteger selectedRow;
    NSTimer *_timeOutTimer;
    
    My51cUdpSearcher *searcher;
}

@property (retain, nonatomic) IBOutlet UITextField *wifi;//WIFI
@property (retain, nonatomic) IBOutlet UIPickerView *wifiPicker;//WIFI picker
@property (retain, nonatomic) IBOutlet UITextField *codeTf;
@property (retain, nonatomic) IBOutlet UIView *deviceNumView;
@property (retain, nonatomic) IBOutlet UIView *httpView;
@property (retain, nonatomic) IBOutlet UILabel *curWifiNameLbl;
@property (retain, nonatomic) IBOutlet UITextField *passwordTf;

@property (retain, nonatomic) IBOutlet UITextField *password;//密码 
- (IBAction)go_buckLogin:(UIButton *)sender;//取消
- (IBAction)setUp:(UIButton *)sender;//确定
- (IBAction)onScanCode:(UIButton *)sender;
- (IBAction)onNextStep:(UIButton *)sender;
- (IBAction)onStartHttpSetting:(UIButton *)sender;

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
    _timeOutTimer = nil;
    _dataArray = [[NSMutableArray alloc]init];
    CGRect frame = _wifiPicker.frame;
    if (ISIP5) {
        frame.origin.y = 568.;
    }else{
        frame.origin.y = 480.;
    }
    _wifiPicker.frame = frame;
    
    
    if (kBBAPModeTypeHttp == _apModeType) {
        if([_curWifiNameLbl.text isEqualToString:@"未连接"]){
            
            _deviceNumView.hidden = YES;
            _lastView.hidden = YES;
            
            CFArrayRef ssids = CNCopySupportedInterfaces();
            NSString *ssid = nil;
            
            for (int i = 0; ssids && i < CFArrayGetCount(ssids); i ++) {
                CFDictionaryRef s = CNCopyCurrentNetworkInfo((CFStringRef)CFArrayGetValueAtIndex(ssids, i));
                NSString *key = (__bridge NSString *)kCNNetworkInfoKeySSID;
                if(0 != i){
                    [ssid release];
                }
                ssid = [(__bridge NSDictionary *)s objectForKey:key];
                
                if(ssid!=nil){
                    [ssid retain];
                    BBLog(@"ssid:%@", ssid);
                    CFRelease(s);
                }                

            }
            
            if (!ssid)
            {
                UtilAlert(@"当前未连接网络或不支持该网络，请更换为可用的网络连接。", nil);
            }else{
                _curWifiNameLbl.text = ssid;
                [ssid release];
            }
        }
    }else{
        
        [Camera initIOTC];
        myCamera = [[Camera alloc] initWithName:@"摄像头"];
        myCamera.delegate = self;
    }
    
}

- (void)dealloc {
    [_wifi release];
    [_password release];
    [_wifiPicker release];
    [_lastView release];
    [_codeTf release];
    [_deviceNumView release];
    [myCamera release];
    [_httpView release];
    [_curWifiNameLbl release];
    [_passwordTf release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setWifi:nil];
    [self setPassword:nil];
    [self setWifiPicker:nil];
    [self setLastView:nil];
    [self setCodeTf:nil];
    [self setDeviceNumView:nil];
    [self setHttpView:nil];
    [self setCurWifiNameLbl:nil];
    [self setPasswordTf:nil];
    [super viewDidUnload];
}

/*!
 *@description  跳转到下一个要么
 *@function     gotoNextPage
 *@param        (void)
 *@return       (void)
 */
- (void)gotoNextPage
{
    CGPoint center = _deviceNumView.center;
    CGPoint newCenter = CGPointMake(-160., center.y);
    [UIView animateWithDuration:0.25f animations:^{
        _lastView.center = center;
        _deviceNumView.center = newCenter;
    }];
}

/*!
 *@brief        返回上一个页面
 *@function     setUp
 *@param        sender
 *@return       （void）
 */
- (IBAction)go_buckLogin:(UIButton *)sender{
    
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.presentingViewController dismissModalViewControllerAnimated:YES];
    }
}

/*!
 *@brief        确定设置
 *@function     setUp
 *@param        sender
 *@return       （void）
 */
- (IBAction)setUp:(UIButton *)sender {
//    SMsgAVIoctrlSetWifiReq
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
 *@description  响应点击扫描二维码按钮事件
 *@function     onScanCode:
 *@param        sender     --按钮
 *@return       (void)
 */
- (IBAction)onScanCode:(UIButton *)sender {
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

/*!
 *@description  处理网络超时
 *@function     onNextWorkTimeout:
 *@param        sender
 *@return       (void)
 */
- (void)onNextWorkTimeout:(id)sender
{
    if (_hud && [_hud respondsToSelector:@selector(hide:)]) {
        _hud.labelText = @"请求超时";
        [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        _hud = nil;
    }
    _timeOutTimer = nil;
}

/*!
 *@description  响应点击输入设备号的确定按钮事件
 *@function     onNextStep:
 *@param        sender     --按钮
 *@return       (void)
 */
- (IBAction)onNextStep:(UIButton *)sender {
    
    _timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:NETWORK_TIMEOUT target:self selector:@selector(onNextWorkTimeout:) userInfo:nil repeats:NO];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
    [_hud setLabelText:@"正在连接设备..."];
    [_hud setRemoveFromSuperViewOnHide:YES];
    
    [myCamera connect:_codeTf.text];
	[myCamera startShow:0 ScreenObject:self];
    
}

/*!
 *@description  响应点击http设置时的确定按钮事件
 *@function     onStartHttpSetting:
 *@param        sender     --按钮
 *@return       (void)
 */
- (IBAction)onStartHttpSetting:(UIButton *)sender {
    NSString *pw = [_passwordTf text];
    if (pw == nil || [pw length] < 8) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:NOTICE_TITLE
                                                       message:@"尚未输入WiFi密码"
                                                      delegate:nil
                                             cancelButtonTitle:@"好"
                                             otherButtonTitles:nil];
        [alert show];
        [alert release];
        return ;
    }
    
    
    CFArrayRef ssids = CNCopySupportedInterfaces();
    NSString *ssid = nil;
    
    for (int i = 0; ssids && i < CFArrayGetCount(ssids); i ++) {
        CFDictionaryRef s = CNCopyCurrentNetworkInfo((CFStringRef)CFArrayGetValueAtIndex(ssids, i));
        NSString *key = (__bridge NSString *)kCNNetworkInfoKeySSID;
        if(0 != i){
            [ssid release];
        }
        ssid = [(__bridge NSDictionary *)s objectForKey:key];
        [ssid retain];
        BBLog(@"ssid:%@", ssid);
        CFRelease(s);
    }
    if (!ssid || ![ssid isEqualToString:CAMERA_WIFI_NAME])
    {
        NSString *msg = [NSString stringWithFormat:@"请先将手机连接到%@网络再设置",CAMERA_WIFI_NAME];
        UIAlertView *alter = [[UIAlertView alloc]initWithTitle:NOTICE_TITLE
                                                       message:msg
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:@"好", nil];
        alter.delegate = self;
        [alter show];
        [alter release];
    }else{
        [self setWifiForHttp];
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
        
        CGRect frame = _wifiPicker.frame;
        frame.origin.y -= 216.;
        [UIView animateWithDuration:0.5 animations:^{
            [_wifiPicker setFrame:frame];
            
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
    
    CGRect frame = _wifiPicker.frame;
    frame.origin.y += 216.;
    [UIView animateWithDuration:0.5 animations:^{
        [_wifiPicker setFrame:frame];
        
    }];
    _pickerHide =YES;
}

///*!
// *@description  网页请求wifi列表
// *@function     getWifiListFromHttp
// *@param        (void)
// *@return       (void)
// */
//- (void)getWifiListFromHttp
//{
//    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
//    [_hud setLabelText:@"正在获取网络列表..."];
//    [_hud setRemoveFromSuperViewOnHide:YES];
//    
//    NSString *urlStr = [NSString stringWithFormat:@"http://%@/cgi-bin/listwifiap.cgi",CAMERA_IP];
//    NSURL *url = [NSURL URLWithString:urlStr];
//    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//    request.delegate = self;
//    request.timeOutSeconds = NETWORK_TIMEOUT;
//    request.requestMethod = @"GET";
//    request.shouldAttemptPersistentConnection = NO;
//    [request startAsynchronous];
//    
//}


- (NSArray *)parseStr:(NSString *)wifiStr
{
    NSArray *arr = [wifiStr componentsSeparatedByString:@";"];
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"\""];
    for (int i=0; i<arr.count-1; i+=3) {
        
        NSString *ssid = [arr[i] componentsSeparatedByString:@"="][1];
        NSString *signal = [arr[i+1] componentsSeparatedByString:@"="][1];
        NSString *secret = [arr[i+2] componentsSeparatedByString:@"="][1];
        NSDictionary *dic = @{@"ssid":[ssid stringByTrimmingCharactersInSet:set],
                              @"signal":[signal stringByTrimmingCharactersInSet:set],
                              @"secret":[secret stringByTrimmingCharactersInSet:set]};
        [_dataArray addObject:dic];
    }
    return _dataArray;
}



/*!
 *@description  网页请求设置wifi
 *@function     setWifiForHttp
 *@param        (void)
 *@return       (void)
 */
- (void)setWifiForHttp
{
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
    [_hud setLabelText:@"正在设置柚保网络请稍后..."];
    [_hud setRemoveFromSuperViewOnHide:YES];
    
//    NSString *urlStr = [NSString stringWithFormat:@"http://%@/cgi-bin/setwifiattr.cgi?cmd=setwifiattr&-ssid=%@&-wktype=3&-enable=1&-key=%@",CAMERA_IP,_curWifiNameLbl.text,_passwordTf.text];
//    NSURL *url = [NSURL URLWithString:urlStr];
//    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
//    request.tag = 10000;
//    request.delegate = self;
//    request.timeOutSeconds = NETWORK_TIMEOUT;
//    request.requestMethod = @"GET";
//    request.shouldAttemptPersistentConnection = NO;
//    [request startAsynchronous];
    
    
    
    [self retain];
    searcher = [[My51cUdpSearcher alloc]init];
    [searcher startSearchWithTimeout:NETWORK_TIMEOUT delegate:self];
    
}

#pragma mark -
#pragma mark ASIHTTPRequestDelegate method

- (void)requestFinished:(ASIHTTPRequest *)request
{
//    [self parseStr:request.responseString];
    if (10000 == request.tag) {
        
        [_hud setLabelText:@"正在校验..."];
        NSString *urlStr = [NSString stringWithFormat:@"http://%@/cgi-bin/getwifiattr.cgi?cmd=getwifiattr",CAMERA_IP];
        NSURL *url = [NSURL URLWithString:urlStr];
        ASIHTTPRequest *requestCheck = [ASIHTTPRequest requestWithURL:url];
        requestCheck.tag = 10001;
        requestCheck.delegate = self;
        requestCheck.timeOutSeconds = NETWORK_TIMEOUT;
        requestCheck.requestMethod = @"GET";
        requestCheck.shouldAttemptPersistentConnection = NO;
        [requestCheck startAsynchronous];
    }else if(10001 == request.tag){
        BOOL suc = NO;
        NSArray *arr = [request.responseString componentsSeparatedByString:@";"];
        for (NSString *str in arr) {
            if ([str rangeOfString:@"wifissid"].length != 0) {
                NSArray *ssidArr = [str componentsSeparatedByString:@"="];
                if ([ssidArr[1] rangeOfString:_curWifiNameLbl.text].length != 0) {
                    suc = YES;
                    break;
                }
            }
        }
        if (suc) {
            [_hud setLabelText:@"设置成功,正在重启..."];
            ASIHTTPRequest *requestRestart = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/cgi-bin/hi3510/sysreboot.cgi",CAMERA_IP]]];
            requestRestart.delegate = self;
            requestRestart.timeOutSeconds = NETWORK_TIMEOUT;
            requestRestart.requestMethod = @"GET";
            requestRestart.shouldAttemptPersistentConnection = NO;
            [requestRestart startAsynchronous];
        }else{
            [_hud setLabelText:@"设置失败"];
        }
        [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [_hud setLabelText:@"请求失败"];
    [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
}

#pragma mark -
#pragma mark UIPickerViewDelegate method
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _dataArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSData *data = _dataArray[row];
    NSString *str = [[[NSString alloc]initWithData:[data subdataWithRange:NSMakeRange(0, 32)] encoding:NSUTF8StringEncoding]autorelease];
    return str;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
   
    selectedRow = row;
    
    NSData *data = _dataArray[row];
    _wifi.text= [[[NSString alloc]initWithBytes:[[data subdataWithRange:NSMakeRange(0, 32)] bytes] length:32 encoding:NSUTF8StringEncoding]autorelease];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-
#pragma mark UIAlertViewDelegate method;

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
//    if (1 == buttonIndex) {
//        if (kBBAPModeTypeCamera == _apModeType) {
//            NSData *origData = _dataArray[selectedRow];
//            NSMutableData *data = [NSMutableData dataWithCapacity:sizeof(SMsgAVIoctrlSetWifiReq)];
//            [data appendData:[origData subdataWithRange:NSMakeRange(0, 32)]];
//            [data appendData:[NSData dataWithBytes:[_password.text UTF8String] length:32]];
//            [data appendData:[origData subdataWithRange:NSMakeRange(31, 1)]];
//            [data appendData:[origData subdataWithRange:NSMakeRange(32, 1)]];
//            [data appendData:[NSData dataWithBytes:"" length:10]];
//            
//            
//            _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//            [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
//            [_hud setLabelText:@"正在设置网络..."];
//            [_hud setRemoveFromSuperViewOnHide:YES];
//            [myCamera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_SETWIFI_REQ Data:(char *)data DataSize:sizeof(SMsgAVIoctrlSetWifiReq)];
//            
//            if (_timeOutTimer) {
//                [_timeOutTimer invalidate];
//            }
//            _timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:NETWORK_TIMEOUT target:self selector:@selector(onNextWorkTimeout:) userInfo:nil repeats:NO];
//        }else{
//            
//            [self setWifiForHttp];
//
//        }
//    }
   
}


#pragma mark -
#pragma mark ZXingDelegate method
- (void)zxingController:(ZXingWidgetController *)controller didScanResult:(NSString *)result
{
//    BBAppDelegate *delegate = (BBAppDelegate *)[UIApplication sharedApplication].delegate;
//    //    UINavigationController *navi = delegate.navigationController;
//    [delegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];

    [controller.presentingViewController dismissModalViewControllerAnimated:YES];
    _codeTf.text = result;
    
}

- (void)zxingControllerDidCancel:(ZXingWidgetController *)controller
{
//    BBAppDelegate *delegate = (BBAppDelegate *)[UIApplication sharedApplication].delegate;
//    UINavigationController *navi = (UINavigationController *)delegate.window.rootViewController;
//    [navi dismissViewControllerAnimated:YES completion:nil];

    
    [controller.presentingViewController dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark MyCamera delegate method
- (void)camera:(Camera *)camera didChangeChannelStatus:(NSInteger)channel ChannelStatus:(NSInteger)status
{
}

- (void)camera:(Camera *)camera didChangeSessionStatus:(NSInteger)status
{
//    if (status == kCameraSessionStateConnected) {
//        BBLog(@"连接成功！");
//        [_hud setLabelText:@"正在获取网络列表..."];
//        
//        if (_timeOutTimer) {
//            [_timeOutTimer invalidate];
//        }
//        _timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:NETWORK_TIMEOUT target:self selector:@selector(onNextWorkTimeout:) userInfo:nil repeats:NO];
//        
//        
//        [myCamera start:0 viewAccount:@"admin" viewPassword:@"admin" is_playback:FALSE];
//        SMsgAVIoctrlListWifiApReq *req = (SMsgAVIoctrlListWifiApReq *)malloc(sizeof(SMsgAVIoctrlListWifiApReq));
//        [myCamera sendIOCtrlToChannel:0
//                               Type:IOTYPE_USER_IPCAM_LISTWIFIAP_REQ
//                               Data:(char *)req
//                           DataSize:sizeof(SMsgAVIoctrlListWifiApReq)];
//        free(req);
//        
//    }else if(status == kCameraSessionStateConnecting){
//        BBLog(@"正在连接设备...");
//    }else if(status == kCameraSessionStateTimeOut){
//        BBLog(@"连接失败");
//        if (_hud) {
//            [_hud setLabelText:@"连接失败"];
//            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
//        }
//        _hud = nil;
//        [_timeOutTimer invalidate];
//        _timeOutTimer = nil;
//    }
}

- (void)camera:(Camera *)camera didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size
{
    if (type == IOTYPE_USER_IPCAM_LISTWIFIAP_RESP) {
        NSData *dataRev = [NSData dataWithBytes:data length:size];
        NSLog(@"recv data len:%d", [dataRev length]);
        if (dataRev && [dataRev length] > 40) {
            for (int i = 4; i < [dataRev length]; i += 36) {
                NSData *itemData = [dataRev subdataWithRange:NSMakeRange(i, 36)];
                
                [_dataArray addObject:itemData];
            }
            NSLog(@"wifi list :%@", _dataArray);
            dispatch_async(dispatch_get_main_queue(), ^{
                [_hud setLabelText:@"获取网络列表成功"];
                [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
                [_wifiPicker reloadAllComponents];
                [self gotoNextPage];
                
                _hud = nil;
                [_timeOutTimer invalidate];
                _timeOutTimer = nil;
            });
            
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [_hud setLabelText:@"获取网络列表失败"];
                [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
                
                _hud = nil;
                [_timeOutTimer invalidate];
                _timeOutTimer = nil;
            });
            
        }
    }else if(type == IOTYPE_USER_IPCAM_SETWIFI_RESP){
        
        //        NSData *data = [NSData dataWithBytes:dataBytes length:size];
        //        BBLog(@"%@",data);
        //        char *ss = (char *)[data bytes];
        //        BBLog(@"%s",ss);
        [_hud setLabelText:@"设置网络成功"];
        [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        
        _hud = nil;
        [_timeOutTimer invalidate];
        _timeOutTimer = nil;
    }
}

#pragma mark-
#pragma mark- My51cUdpSearchDelegate method
-(void)onMy51cUdpSearchGotInfo:(DeviceInfo_t)info fromHost:(char*)host port:(int)port
{
    BBLog(@"%s",info.szMacAddr_WIFI);
    strcpy(info.szWiFiSSID, [_curWifiNameLbl.text UTF8String]);
    strcpy(info.szWiFiPwd, [_passwordTf.text UTF8String]);
    info.nEnableWiFi = 1;
    
    printf("info.szWiFiSSID == %s",info.szWiFiSSID);
    printf("info.szWiFiSSID == %s",info.szWiFiPwd);
    [searcher reBroadcastWithInfo:info];
    BBLog(@"正在设置wifi");
    
//    [searcher stopSearch];
}

-(void)onMy51cUdpSearchDone
{
    [self release];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_hud){
            [_hud setLabelText:@"柚保网络设置失败，请重新设置"];
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        }        

    });
}

- (void)didSetSuccess
{
    BBLog(@"didSetSuccess");
    dispatch_async(dispatch_get_main_queue(), ^{
        [_hud setLabelText:@"柚保网络设置成功，设备将在60秒后重新连接网络"];
        [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        [self performSelector:@selector(go_buckLogin:) withObject:nil afterDelay:1.5f];
    });
    
}

- (void)didSetFailed
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_hud setLabelText:@"柚保网络设置失败，请重新设置"];
        [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
    });
}

@end
