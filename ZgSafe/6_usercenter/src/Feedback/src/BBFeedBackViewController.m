//
//  BBFeedBackViewController.m
//  ZgSafe
//  意见反馈
//  Created by YANGReal on 13-10-31.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBFeedBackViewController.h"

@interface BBFeedBackViewController ()<UITextViewDelegate,BBSocketClientDelegate>
{
    MBProgressHUD *_hud;
}



- (IBAction)goback:(id)sender;//返回上一个页面

- (IBAction)sendMessage:(id)sender;//发表反馈

@property (retain, nonatomic) IBOutlet UITextView *adviceTxt;//发表意见的text


@end

@implementation BBFeedBackViewController

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
#pragma mark system method
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}- (void)dealloc {
    [_adviceTxt release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setAdviceTxt:nil];
    [super viewDidUnload];
}
#pragma mark -
#pragma mark self define button method
/*!
 *@description       返回
 *@function         goback
 *@param            sender     --添加按钮
 *@return           (void)
 */
- (IBAction)goback:(id)sender {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.presentingViewController dismissModalViewControllerAnimated:YES];
    }
}
/*!
 *@description       发送意见反馈
 *@function         sendMessage
 *@param            sender     --添加按钮
 *@return           (void)
 */
- (IBAction)sendMessage:(id)sender {
    NSString *textstr=[_adviceTxt.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *textstrs=[_adviceTxt.text stringByReplacingOccurrencesOfString:@"请输入反馈意见...." withString:@""];
    
    if (_adviceTxt.text==nil || textstr.length==0 ||textstrs.length==0) {
        UtilAlert(@"意见反馈的内容为空", nil);
        return;
    }else{
        UIAlertView *alter=[[UIAlertView alloc]initWithTitle:NOTICE_TITLE message:@"确定要发表意见和反馈"delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alter show];
        [alter release];
    }
}
#pragma mark -
#pragma mark UITextViewDelegate method
/*!
 *@description      设置提示
 *@function         touchesBegan:
 *@param            sender     --添加按钮
 *@return           (void)
 */
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text length] > 0 && [textView.text isEqualToString:@"请输入反馈意见...."]) {
        [textView setText:@""];
        textView.textColor = [UIColor getColorWithHexString:@"#616161"];
    }
}
-(void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text length] == 0 || [textView.text isEqualToString:@"请输入反馈意见...."]) {
        [textView setText:@"请输入反馈意见...."];
        [textView setTextColor: [UIColor lightGrayColor]];
    }
}
#pragma mark -
#pragma mark touchesBegan method

/*!
 *@description      点击屏幕 键盘消失
 *@function         touchesBegan:
 *@param            sender     --添加按钮
 *@return           (void)
 */
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_adviceTxt resignFirstResponder];
}

#pragma mark -
#pragma mark UIAlertView delegate method

/*!
 *@description      返回上一个页面
 *@function         touchesBegan:
 *@param            sender     --添加按钮
 *@return           (void)
 */
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
    [_hud setLabelText:@"正在反馈..."];
    [_hud setRemoveFromSuperViewOnHide:YES];
    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
    NSString *param = [NSString stringWithFormat:@"%@\t%@",curUser.userid,_adviceTxt.text];
    [mainClient userFeedBack:self param:param];
    
    //    if (self.navigationController) {
    //        [self.navigationController popViewControllerAnimated:YES];
    //    }else{
    //        [self.presentingViewController dismissModalViewControllerAnimated:YES];
    //    }
}


#pragma mark -
#pragma mark BBSocketClientDelegate method

-(int)onRecevie:(BBDataFrame *)src received:(BBDataFrame *)data
{
    if(src.MainCmd == 0x0E && src.SubCmd == 81) {
        //意见反馈
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc]initWithData:data.data encoding:NSUTF8StringEncoding];
            
            if(result && [result isEqualToString:@"0" ]){
                [_hud setLabelText:@"反馈成功"];
            }else{
                [_hud setLabelText:@"反馈失败"];

            }

            [_hud performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
            [result release];
        });
    }
    
    return 0;
}

-(void)onTimeout:(BBDataFrame *)src
{
    [_hud setLabelText:@"反馈超时"];
    [_hud performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
}


-(void)onRecevieError:(BBDataFrame*)src received:(BBDataFrame*)data
{
    NSLog(@"RecevieError src.SubCmd=%d",src.SubCmd);
}


@end
