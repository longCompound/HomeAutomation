//
//  BBAddAdressViewController.m
//  ZgSafe
//
//  Created by YANGReal on 13-10-31.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBAddAdressViewController.h"
#import <ZXingWidgetController.h>
#import <QRCodeReader.h>
#import <MultiFormatOneDReader.h>
#import "BBAdressManageViewController.h"

@interface BBAddAdressViewController ()<UITextFieldDelegate,ZXingDelegate,UINavigationControllerDelegate,UIAlertViewDelegate,BBLoginClientDelegate>
{
    NSString *scanResult ;      //二维码扫描结果
    MBProgressHUD *_hud;
}
@property (retain, nonatomic) IBOutlet UITextField *addresstxt; //地址
@property (retain, nonatomic) IBOutlet UITextField *Dnumtxt;//设备号
@property (retain, nonatomic) IBOutlet UITextField *VcodeTxt;// 验证码


- (IBAction)DimensionalcodeClick:(id)sender;

- (IBAction)goback:(id)sender; //返回
- (IBAction)Submit:(id)sender; //提交

@end

@implementation BBAddAdressViewController

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
#pragma mark -
#pragma mark system define method
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    [_addresstxt release];
    [_Dnumtxt release];
    [_VcodeTxt release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setAddresstxt:nil];
    [self setDnumtxt:nil];
    [self setVcodeTxt:nil];
    [super viewDidUnload];
}
#pragma mark -
#pragma mark touchesBegan method
/*!
 *@brief        键盘回收
 *@function     keyboarddiddismiss
 *@return       （void）
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark UITextFieldDelegate method
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 170) {
        [_addresstxt resignFirstResponder];
        [_Dnumtxt becomeFirstResponder];
        return YES;
        
    }else if (textField.tag == 171){
        [_Dnumtxt resignFirstResponder];
        [_VcodeTxt becomeFirstResponder];
        return YES;
    }else{
        [_VcodeTxt resignFirstResponder];
        return YES;
    }
    
}

#pragma mark -
#pragma mark self define button method
//扫描二维码
- (IBAction)DimensionalcodeClick:(id)sender {
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
    BBAppDelegate *delegate = (BBAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.window.rootViewController presentViewController:wc animated:YES completion:nil];
    [wc release];
}


/*!
 *@brief        返回上一个页面
 *@function     goback
 *@param        sender
 *@return       （void）
 */
- (IBAction)goback:(id)sender {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.presentingViewController dismissModalViewControllerAnimated:YES];
    }
}


/*!
 *@brief        提交地址
 *@function     Submit
 *@param        sender
 *@return       （void）
 */
- (IBAction)Submit:(id)sender {
    if (!_Dnumtxt.text.length) {
        UtilAlert(@"请填写设备号", nil);
        return;
    }
    if (!_VcodeTxt.text.length) {
        UtilAlert(@"请填写验证码", nil);
        return;
    }
    
    UIAlertView *dialAlert = [[UIAlertView alloc] initWithTitle:NOTICE_TITLE
                                                        message:@"确定要添加这个地址吗？"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
    [dialAlert show];
    [dialAlert release];
    
}



#pragma mark -
#pragma mark ZXingDelegate method
- (void)zxingController:(ZXingWidgetController *)controller didScanResult:(NSString *)result
{
    BBAppDelegate *delegate = (BBAppDelegate *)[UIApplication sharedApplication].delegate;
    //    UINavigationController *navi = delegate.navigationController;
    [delegate.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
    if (scanResult) {
        [scanResult release];
    }
    
    scanResult = [[NSString alloc] initWithFormat:@"%@", result];
    _Dnumtxt.text = scanResult;
    
}

- (void)zxingControllerDidCancel:(ZXingWidgetController *)controller
{
    BBAppDelegate *delegate = (BBAppDelegate *)[UIApplication sharedApplication].delegate;
    UINavigationController *navi = (UINavigationController *)delegate.window.rootViewController;
    [navi dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark -
#pragma mark UIAlertView delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (!_Dnumtxt.text.length) {
            UtilAlert(@"请填写设备号", nil);
            return;
        }else if (!_VcodeTxt.text.length) {
            UtilAlert(@"请填写验证码", nil);
            return;
        }
        
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
        [_hud setLabelText:@"正在添加地址..."];
        [_hud setRemoveFromSuperViewOnHide:YES];
        
        NSString *param = [NSString stringWithFormat:@"%@\t%@\t%@\t%@",curUser.userid,_Dnumtxt.text,_VcodeTxt.text,_addresstxt.text];
        
        BBLoginClient *logClient = [[[BBLoginClient alloc] init]autorelease];
        [logClient bindTerminal:param delegate:self];

    }
}



#pragma mark -
#pragma mark BBLoginClientDelegate method

- (void)bindReceiveData:(BBDataFrame *)data
{
    NSString *result = [[NSString alloc]initWithFormat:@"%@",[data dataString]];
    NSString *strMsg=@"添加地址失败";
    
    if(result){
        NSArray *arr = [result componentsSeparatedByString:@"\t"];
        
        if([arr[0] isEqualToString:@"0" ]){
            strMsg=@"添加地址成功";
            
            BBAdressManageViewController *vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count-2];
            
            _addresstxt.text = @"";
            _Dnumtxt.text = @"";
            _VcodeTxt.text = @"";            
            
            [vc getDatas];
            [self performSelector:@selector(goback:) withObject:nil afterDelay:1.0f];
        }else if (arr.count==2){
            strMsg=arr[1];
        }
    }
    [_hud setLabelText:strMsg];
    [result release];
    [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5f];

}

- (void)bindFailedWithErrorInfo:(NSString *)errorInfo
{
    [_hud setLabelText:errorInfo];
    [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
}


@end
