//
//  BBAboutViewController.m
//  ZgSafe
//
//  Created by box on 13-12-21.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBAboutViewController.h"

@interface BBAboutViewController ()<BBSocketClientDelegate,BBSocketDelegate>
{
    MBProgressHUD *_hud;
    UIView *_aboutVew;
}

@property (retain, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation BBAboutViewController


#pragma mark -
#pragma mark system method
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

    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
    [mainClient queryDeviceCode:self param:curUser.userid];
    
    self.youBaoVer.text=[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
  
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    

}


#pragma mark -
#pragma mark self define method
/*!
 *@description  响应点击返回按钮事件
 *@function     goBack:
 *@param        sender     --返回按钮
 *@return       (void)
 */
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark BBSocketClientDelegate method

-(int)onRecevie:(BBDataFrame *)src received:(BBDataFrame *)data
{
    if(src.MainCmd == 0x0E && src.SubCmd == 96) {
        //关于信息
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc]initWithData:data.data encoding:NSUTF8StringEncoding];
            NSString *strTxt=@"";
            
            if(result){
                NSArray *arr = [result componentsSeparatedByString:@"\t"];
                if (arr.count==2 && [arr[0] integerValue]==0) {
                    strTxt=arr[1];
                }
            }
            _deviceVer.text=strTxt;
            [result release];
        });
    }
    return 0;
}

-(void)onTimeout:(BBDataFrame *)src
{
    if(src.MainCmd == 0x0E && src.SubCmd == 96) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UtilAlert(@"请求超时", nil);
        });
    }
}


-(void)onRecevieError:(BBDataFrame*)src received:(BBDataFrame*)data
{
    if(src.MainCmd == 0x0E && src.SubCmd == 96) {
        dispatch_async(dispatch_get_main_queue(), ^{
             UtilAlert(@"请求超时", nil);
        });
    }
}

- (void)dealloc {
    [_webView release];
    [_youBaoVer release];
    [_deviceVer release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setWebView:nil];
    [self setYouBaoVer:nil];
    [self setDeviceVer:nil];
    [super viewDidUnload];
}
@end
