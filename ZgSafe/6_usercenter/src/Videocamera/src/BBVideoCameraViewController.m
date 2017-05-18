//
//  BBVideoCameraViewController.m
//  ZgSafe
//
//  Created by YANGReal on 13-10-31.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBVideoCameraViewController.h" 
#import "BBUnlockView.h"
#import "BBAppDelegate.h"
#import "SDImageCache.h"

#define picker_number 262
@interface BBVideoCameraViewController ()<UITableViewDataSource,UITableViewDelegate,BBUnlockViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate,BBSocketClientDelegate>
{
    NSArray *_pageArray;
    BOOL isOpen;
    BOOL dataisOpen;
    MBProgressHUD *_hud;
}
- (IBAction)onSafeGestureSet:(UIButton *)sender;
- (IBAction)goback:(id)sender;
- (IBAction)Gesture:(id)sender;
- (IBAction)Screenquality:(id)sender;
- (IBAction)chooseCaptureNum:(id)sender;
- (IBAction)settime:(id)sender;
- (IBAction)FormatSDCard:(id)sender;
- (IBAction)captureSwitch:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *pageButtonLable;

@property (retain, nonatomic) IBOutlet UITableView *pageTableView;

@property (retain, nonatomic) IBOutlet UIScrollView *videoScro;

@property (retain, nonatomic) IBOutlet UIImageView *safeImg;
@property (retain, nonatomic) IBOutlet UILabel *safeLab;
@property (retain, nonatomic) IBOutlet UIButton *safeBtn;

@property (retain, nonatomic) IBOutlet UILabel *Capturelab;
@property (retain, nonatomic) IBOutlet UIImageView *CaptureImg;
@property (retain, nonatomic) IBOutlet UIButton *captureBtn;
@property (retain, nonatomic) IBOutlet UIView *backGroundView;

@property (retain, nonatomic) IBOutlet UILabel *dataLable;//时间的lable
@property (retain, nonatomic) IBOutlet UILabel *pageLable;//张数的lable
@property (retain, nonatomic) IBOutlet UILabel *quilitLable;//质量的lable

- (IBAction)setUpButton:(UIButton *)sender;//确定的button
- (IBAction)cancelButton:(UIButton *)sender;//取消的button
@property (retain, nonatomic) IBOutlet UIDatePicker *datePicker;//时间picker
@property (retain, nonatomic) IBOutlet UIView *dateView;//时间picker 的view
- (IBAction)bigButton:(UIButton *)sender;//大button
- (IBAction)timeButton:(UIButton *)sender;//点击用于回收时间；
@property (retain, nonatomic) IBOutlet UIButton *settimebutton;//用于控制时间的隐藏


@end

@implementation BBVideoCameraViewController

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
    isOpen=YES;
    dataisOpen=YES;
    _pageArray = [[NSArray alloc]initWithObjects:@"一张",@"二张",@"三张",nil];
    [self getCurrentBindDevice];
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:60];
    NSDateFormatter *fmt = [[NSDateFormatter alloc]init];
    [fmt setDateFormat:@"HH:mm"];
    NSString *str = [fmt stringFromDate:date];
    [_dataLable setText:str];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    BlueBoxer *user = curUser;
    //手势开关按钮初始化
    [self handleSwitchWith:_safeBtn
                stateLable:_safeLab
        andBackgroundImage:_safeImg
                      open:user.safeGestureOpened
                  animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -
#pragma mark system define method
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (void)dealloc {
    [_videoScro release];
    [_safeImg release];
    [_safeLab release];
    [_Capturelab release];
    [_CaptureImg release];
    [_dataLable release];
    [_pageLable release];
    [_quilitLable release];
    [_pageTableView release];
    [_pageButtonLable release];
    [_datePicker release];
    [_dateView release];
    [_backGroundView release];
    [_safeBtn release];
    [_captureBtn release];
    [_settimebutton release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setVideoScro:nil];
    [self setSafeImg:nil];
    [self setSafeLab:nil];
    [self setCapturelab:nil];
    [self setCaptureImg:nil];
    [self setDataLable:nil];
    [self setPageLable:nil];
    [self setQuilitLable:nil];
    [self setPageTableView:nil];
    [self setPageButtonLable:nil];
    [self setDatePicker:nil];
    [self setDateView:nil];
    [self setBackGroundView:nil];
    [self setSafeBtn:nil];
    [self setCaptureBtn:nil];
    [self setSettimebutton:nil];
    [super viewDidUnload];
}


#pragma mark -
#pragma mark self define button method

/*!
 *@description  获取抓拍设置数据
 *@function     getDatas
 *@param        (void)
 *@return       (void)
 */
- (void)getDatasWithDeviceNumber:(NSString *)device
{
//    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
//    [_hud setLabelText:@"正在当前抓拍设置..."];
//    [_hud setRemoveFromSuperViewOnHide:YES];

    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
    [mainClient querySnapCount:self param:device];
    [mainClient querySnapParam:self param:device];
    [mainClient Getvideoquality:self param:device];
}


/*!
 *@description  获取当前绑定设备
 *@function     getCurrentBindDevice
 *@param        (void)
 *@return       (void)
 */
- (void)getCurrentBindDevice
{
    NSString *strDeviceId=curUser.deviceid;
    
    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
    
    //获取抓拍设置数据
    [mainClient querySnapCount:self param:strDeviceId];
    [mainClient querySnapParam:self param:strDeviceId];
    [mainClient Getvideoquality:self param:strDeviceId];
}

/*!
 *@description      处理按钮的开关效果
 *@function         handleSwitchWith:stateLable:andBackgroundImage:open:animated
 *@param            aButton         --开关按钮
 *@param            stateLable      --显示当前开关状态的lable
 *@param            bgImageView     --背景图片
 *@param            open            --要设置的开关状态
 *@param            animated        --是否需要动画
 *@return           (void)
 */
- (void)handleSwitchWith:(UIButton *)aButton
              stateLable:(UILabel *)stateLable
      andBackgroundImage:(UIImageView *)bgImageView
                    open:(BOOL)open
                animated:(BOOL)animated{
    
    if (!open && [stateLable.text isEqualToString:@"开"]) {
        
        if (animated) {
            [UIView animateWithDuration:0.25f animations:^{
                [aButton setCenter:CGPointMake(aButton.center.x+27
                                               , aButton.center.y)];
            }];
        }else{
            [aButton setCenter:CGPointMake(aButton.center.x+27
                                           , aButton.center.y)];
        }
        
        stateLable.text = @"关";
        bgImageView.image = [UIImage imageNamed:@"close_bg"];
        
    }else if (open && [stateLable.text isEqualToString:@"关"]){
        
        if (animated) {
            [UIView animateWithDuration:0.25f animations:^{
                
                [aButton setCenter:CGPointMake(aButton.center.x-27
                                               , aButton.center.y)];
            }];
        }else{
            [aButton setCenter:CGPointMake(aButton.center.x-27
                                           , aButton.center.y)];
        }
        stateLable.text = @"开";
        bgImageView.image = [UIImage imageNamed:@"open_bg"];
    }
    
}


/*!
 *@description      返回
 *@function         goback:
 *@param            sender
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
 *@description      响应点击安全手势设置
 *@function         onSafeGestureSet:
 *@param            sender     --安全手势设置按钮
 *@return           (void)
 */
- (IBAction)onSafeGestureSet:(UIButton *)sender {
    
    BBUnlockView *unlockView = [[BBUnlockView alloc]initWithFrame:self.view.frame];
    [unlockView setBackgroundColor:[UIColor colorWithRed:0. green:0. blue:0. alpha:0.7]];
    unlockView.isModifyPswd = YES;
    unlockView.delegate = self;
    unlockView.tag = 11000;
    [self.view addSubview:unlockView];
    [unlockView release];
    
    CATransition *anim = [CATransition animation];
    anim.duration = 0.5f;
    anim.type = kCATransitionPush;
    anim.subtype = kCATransitionFromTop;
    [unlockView.layer addAnimation:anim forKey:nil];
    
}

/*!
 *@description      响应点击安全手势按钮
 *@function         onClickCameraSettingBtn:
 *@param            sender     --开或者关按钮
 *@return           (void)
 */
- (IBAction)Gesture:(id)sender {
    
    BlueBoxer *user = curUser;
    if (user.gestureUnlock) {
        
        BBUnlockView *unlockView = [[BBUnlockView alloc]initWithFrame:self.view.frame];
        [unlockView setBackgroundColor:[UIColor colorWithRed:0. green:0. blue:0. alpha:0.7]];
        unlockView.isModifyPswd = NO;
        unlockView.delegate = self;
        unlockView.tag = 11001;
        [self.view addSubview:unlockView];
        [unlockView release];
        
        CATransition *anim = [CATransition animation];
        anim.duration = 0.5f;
        anim.type = kCATransitionPush;
        anim.subtype = kCATransitionFromTop;
        [unlockView.layer addAnimation:anim forKey:nil];
        
    }else{
        UtilAlert(@"请先设置安全手势", nil);
    }
}
/*!
 *@description      响应点击视屏质量按钮
 *@function         onClickCameraSettingBtn:
 *@param            sender     --视屏质量按钮
 *@return           (void)
 */
- (IBAction)Screenquality:(id)sender {
    
//    UtilAlert(@"图片的质量为中", nil);

//    这里用于以后设置改变是控制图片的质量，目前只有中；
    UIActionSheet *actionsheet=[[UIActionSheet alloc]initWithTitle:@"请选择视频质量"
                                                          delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"高清" otherButtonTitles:@"标清", nil];
    actionsheet.tag=2;
    
    [actionsheet showInView:self.view];
    [actionsheet release];
}

/*!
 *@description      响应点击抓拍张数按钮
 *@function         onClickCameraSettingBtn:
 *@param            sender     --抓拍张数按钮
 *@return           (void)
 */
- (IBAction)chooseCaptureNum:(id)sender {
    UIActionSheet *chk_PicCount=[[UIActionSheet alloc]initWithTitle:@"请选择抓拍张数"
                                                          delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"一张" otherButtonTitles:@"二张",@"三张", nil];
    chk_PicCount.tag=1;
    
    [chk_PicCount showInView:self.view];
    [chk_PicCount release];
    
}
/*!
 *@brief        点击回收照片张数
 *@function     touchesBegan
 *@param        event
 *@return       （void）
 */
- (IBAction)bigButton:(UIButton *)sender {
    [UIView animateWithDuration:0.5 animations:^{
        
        _pageTableView.frame= CGRectMake(_pageTableView.frame.origin.x, _pageTableView.frame.origin.y, _pageTableView.frame.size.width, 0);
    }];
    isOpen = YES;

}
/*!
 *@description      响应点击时间设置按钮
 *@function         settime:
 *@param            sender     --时间设置按钮
 *@return           (void)
 */
- (IBAction)settime:(id)sender {
    if (dataisOpen==YES) {
        [_settimebutton setHidden:NO];
        [self datapickerheight:-picker_number];
        dataisOpen=NO;
    }
}
/*!
 *@description      清除缓存
 *@function         FormatSDCard:
 *@param            sender     --格式化SD卡按钮
 *@return           (void)
 */
- (IBAction)FormatSDCard:(id)sender {
    
//    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
//    [_hud setLabelText:@"正在清除缓存..."];
//    [_hud setRemoveFromSuperViewOnHide:YES];
//    
//    [[SDImageCache sharedImageCache]clearDisk];
//    [[SDImageCache sharedImageCache]cleanDisk];
//    
//    double delayInSeconds = 1.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [_hud setLabelText:@"清除完成"];
//        [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
//    });
}


/*!
 *@description      响应点击定时抓拍按钮
 *@function         captureSwitch:
 *@param            sender     --定时抓拍按钮
 *@return           (void)
 */
- (IBAction)captureSwitch:(id)sender {
    [self handleSwitchWith:sender
                stateLable:_Capturelab
        andBackgroundImage:_CaptureImg
                      open:[_Capturelab.text isEqualToString:@"关"]
                  animated:YES];
    [self setSnap];
}
/*!
 *@brief        设置时间
 *@function     setUpButton
 *@param        sender
 *@return       （void）
 */
- (IBAction)setUpButton:(UIButton *)sender {
    
    NSDate *date = [_datePicker date];
    NSDateFormatter *fmt = [[NSDateFormatter alloc]init];
    [fmt setDateFormat:@"HH:mm"];
    NSString *str = [fmt stringFromDate:date];
    [_dataLable setText:str];
    [fmt release]; 
    
    if (dataisOpen==NO) {
        [_settimebutton setHidden:YES];
        [self datapickerheight:picker_number];
        dataisOpen=YES;
    }
    
    [self setSnap];
    
}
/*!
 *@brief        取消设置时间
 *@function     cancelButton
 *@param        sender
 *@return       （void）
 */
- (IBAction)cancelButton:(UIButton *)sender {
    if (dataisOpen==NO) {
        [_settimebutton setHidden:YES];
        [self datapickerheight:picker_number];
        
        dataisOpen=YES;
    }
    
}
/*!
 *@brief        用于回收时间；
 *@function     timeButton
 *@param        sender
 *@return       （void）
 */
- (IBAction)timeButton:(UIButton *)sender {
    if (dataisOpen==NO) {
        [_settimebutton setHidden:YES];
        [self datapickerheight:picker_number];
        
        dataisOpen=YES;
    }
}
/*!
 *@brief        控制datapicker的高
 *@function     datapickerheight
 *@param        sender
 *@return       （void）
 */
-(void)datapickerheight:(NSInteger)sender
{
    [_backGroundView setHidden:YES];
    [UIView animateWithDuration:0.5 animations:^{
        [_dateView setFrame:CGRectMake(_dateView.frame.origin.x, _dateView.frame.origin.y+sender, _dateView.frame.size.width, _dateView.frame.size.height)];
        
    }];
}


/*!
 *@description  抓拍设置
 *@function     setSnap
 *@param        (void)
 *@return       (void)
 */
- (void)setSnap
{
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
    [_hud setLabelText:@"正在修改抓拍设置..."];
    [_hud setRemoveFromSuperViewOnHide:YES];
    
    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
    NSString *param = [NSString stringWithFormat:@"%@\t%@\t%d",curUser.userid,[_dataLable.text stringByAppendingString:@":00"],[_Capturelab.text isEqualToString:@"关"]];
    [mainClient setTrimCapture:self param:param];
}

/*!
 *@description  设置抓拍数量
 *@function     setSnapCount
 *@param        (void)
 *@return       (void)
 */
- (void)setSnapCount:(int) intIndex
{
    if(intIndex!=3){
    
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
        [_hud setLabelText:@"正在设置抓拍数量..."];
        [_hud setRemoveFromSuperViewOnHide:YES];
    
        NSInteger coun=1;
        
        if(intIndex==0){
            _pageLable.text=@"一张";
            coun=1;
        }else if (intIndex==1){
            _pageLable.text=@"二张";
            coun=2;
        }else if (intIndex==2){
            _pageLable.text=@"三张";
            coun=3;
        }

    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    
    NSString *param = [NSString stringWithFormat:@"%@\t%d\t%@",curUser.userid,coun,dateStr];
    [mainClient snapSetting:self param:param];
    }

}

/*!
 *@description  设置置视频质量
 *@function     setvideoquality
 *@param        (void)
 *@return       (void)
 */
-(void)setvideoquality:(int) intIndex{
    if(intIndex!=2){
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
        [_hud setLabelText:@"正在设置视频质量..."];
        [_hud setRemoveFromSuperViewOnHide:YES];
        
        BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
        NSInteger intvideoquality=1;
        
        if (intIndex == 0) {
            _quilitLable.text=@"高清";
            intvideoquality=1;
        }
        
        if (intIndex == 1) {
            _quilitLable.text=@"标清";
            intvideoquality=3;
        }
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
        [dateFormatter release];
        
        NSString *param = [NSString stringWithFormat:@"%@\t%d\t%@",curUser.userid,intvideoquality,dateStr];
        [mainClient videoqualitySetting:self param:param];
    }
}

#pragma mark-
#pragma mark uiviewactionSheet method


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag==1) {
        [self setSnapCount:buttonIndex];
    }else if(actionSheet.tag==2){
        [self setvideoquality:buttonIndex];
    }
}

#pragma mark -
#pragma mark uitableViewDelegate method

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _pageArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cell_ide = @"cell_ide111111";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_ide];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:cell_ide] autorelease];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.textLabel.text = [_pageArray objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:12.0f];
    cell.textLabel.textColor=[UIColor whiteColor];
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30.0f ;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [UIView animateWithDuration:0.5 animations:^{
//        
//        [_pageLable setText:[NSString stringWithFormat:@"%@",[_pageArray objectAtIndex:indexPath.row]]];
//        _pageTableView.frame= CGRectMake(_pageTableView.frame.origin.x, _pageTableView.frame.origin.y, _pageTableView.frame.size.width, 0);
//    }];
//    isOpen = YES;
//    [self setSnapCount];
}

#pragma mark -
#pragma mark BBUnlockViewDelegate method
- (void)didSetPasswordCompleted:(BBUnlockView *)unlockView
{
    if (unlockView.tag == 11000) {
        UtilAlert(@"安全手势设置成功",nil);
    }
}

- (void)didTouchBackgroundBegan:(BBUnlockView *)unlockView
{
    [UIView animateWithDuration:0.5f animations:^{
        unlockView.alpha = 0.;
    }completion:^(BOOL finished) {
        [unlockView removeFromSuperview];
    }];
}

- (void)didUnlockSuccessed:(BBUnlockView *)unlockView
{
    if (unlockView.tag == 11001) {
        
        [UIView animateWithDuration:0.5f animations:^{
            unlockView.alpha = 0.;
        }completion:^(BOOL finished) {
            [unlockView removeFromSuperview];
            BlueBoxer *user = curUser;
            user.safeGestureOpened = [_safeLab.text isEqualToString:@"关"];
            
            [self handleSwitchWith:_safeBtn
                        stateLable:_safeLab
                andBackgroundImage:_safeImg
                              open:user.safeGestureOpened
                          animated:YES];
            [BlueBoxerManager archiveCurrentUser:user];
        }];
    }
}

- (void)didUnlockFailed:(BBUnlockView *)unlockView
{
    UtilAlert(@"安全手势错误", nil);
}

#pragma mark -
#pragma mark BBSocketClientDelegate method

-(int)onRecevie:(BBDataFrame *)src received:(BBDataFrame *)data
{
    if(src.MainCmd == 0x0E && src.SubCmd == 12) {
        //抓拍设置
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc]initWithString:[data dataString]];
            NSString *strTxt=@"设置抓拍失败";
            
            if (result && [result isEqualToString:@"0"]) {
                strTxt=@"设置抓拍成功";
            }
            
            [_hud setLabelText:strTxt];
            
            [result release];
            
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }else if(src.MainCmd == 0x0E && src.SubCmd == 7) {
        //抓拍数量设置
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc]initWithString:[data dataString]];
            NSString *strTxt=@"设置抓拍张数失败";
            
            if (result && [result isEqualToString:@"0"]) {
                strTxt=@"设置抓拍张数成功";
            }
            
            [_hud setLabelText:strTxt];
            
            [result release];
                 
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
            
        });
    }
    else if(src.MainCmd == 0x0E && src.SubCmd == 88) {
        //获取抓怕张数
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc]initWithString:[data dataString]];
            NSString *strCount=@"--";
            
            if(result){
                NSArray *arr = [result componentsSeparatedByString:@"\t"];
                
                if (arr.count==2 && [arr[0] isEqualToString:@"0"]) {
                    NSInteger count = [arr[1] integerValue];
                    if (count == 1) {
                        strCount = @"一张";
                    }else if (count == 2) {
                        strCount = @"二张";
                    }else if(count == 3){
                        strCount = @"三张";
                    }
                }
            }
            
            _pageLable.text=strCount;
 
            [result release];
        });
    }else if(src.MainCmd == 0x0E && src.SubCmd == 26){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc]initWithString:[data dataString]];
            NSString *strTxt=@"标清";
            
            if(result){
                NSArray *arr = [result componentsSeparatedByString:@"\t"];
                if (arr.count==2 && [arr[0] isEqualToString:@"0"]) {
                    NSInteger count = [arr[1] integerValue];
                    if (count == 3) {
                        strTxt = @"标清";
                    }else if (count == 1) {
                        strTxt= @"高清";
                    }
                }else{
                    _quilitLable.text = @"标清";
                }
            }
            
            _quilitLable.text=strTxt;
            
            [result release];
        });
    }
    else if(src.MainCmd == 0x0E && src.SubCmd == 24){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc]initWithString:[data dataString]];
            NSString *strTxt=@"设置失败";
            
            if(result && [result isEqualToString:@"0"]){
                strTxt=@"设置成功";
            }
            
            [_hud setLabelText:strTxt];
            
            [result release];
            
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }
    
    else if(src.MainCmd == 0x0E && src.SubCmd == 90) {
        //获取定时抓拍参数
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc]initWithString:[data dataString]];
            NSString *strTxt=@"--:--";
            
            if(result){
                NSArray *arr = [result componentsSeparatedByString:@"\t"];
                
                if(arr.count==3 && [arr[0] isEqualToString:@"0"]){
                    
                    if(arr[1]!=nil && ![arr[1] isEqualToString:@""]){
                        NSArray *timeArr = [arr[1] componentsSeparatedByString:@":"];
                        
                        if(timeArr.count>=2){
                            strTxt = [NSString stringWithFormat:@"%02d:%02d",[timeArr[0] integerValue],[timeArr[1] integerValue]];
                        }                        
                        
                    }
                    [self handleSwitchWith:_captureBtn
                                stateLable:_Capturelab
                        andBackgroundImage:_CaptureImg
                                      open:![arr[2] boolValue]
                                  animated:YES];
                }
            }
            
             _dataLable.text = strTxt;
            
            [result release];
        });
    }
    
    return 0;
}

-(void)onTimeout:(BBDataFrame *)src
{
    
    if(src.MainCmd == 0x0E && src.SubCmd == 12) {
        //抓拍设置
        dispatch_async(dispatch_get_main_queue(), ^{
            [_hud setLabelText:@"设置抓拍超时"];
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }else if(src.MainCmd == 0x0E && src.SubCmd == 7) {
        //抓拍数量设置
        dispatch_async(dispatch_get_main_queue(), ^{
            [_hud setLabelText:@"设置抓拍张数超时"];
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }else if(src.MainCmd == 0x0E && src.SubCmd == 80) {
        //获取当前绑定设备
        dispatch_async(dispatch_get_main_queue(), ^{
            [_hud setLabelText:@"获取当前绑定设备超时"];
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }else if(src.MainCmd == 0x0E && src.SubCmd == 24) {
        //获取视频质量
        dispatch_async(dispatch_get_main_queue(), ^{
            [_hud setLabelText:@"设置视频质量超时"];
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }
    else if(src.MainCmd == 0x0E && src.SubCmd == 26) {
        //获取视频质量
        dispatch_async(dispatch_get_main_queue(), ^{
            [_hud setLabelText:@"获取视频质量超时"];
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }
    
}


-(void)onRecevieError:(BBDataFrame*)src received:(BBDataFrame*)data
{
    NSLog(@"RecevieError src.SubCmd=%d",src.SubCmd);
    if(src.MainCmd == 0x0E && src.SubCmd == 12) {
        //抓拍设置
        dispatch_async(dispatch_get_main_queue(), ^{
            [_hud setLabelText:@"设置抓拍出错"];
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f]; 
        });
    }else if(src.MainCmd == 0x0E && src.SubCmd == 7) {
        //抓拍数量设置
        dispatch_async(dispatch_get_main_queue(), ^{
            [_hud setLabelText:@"设置抓拍张数出错"];
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }else if(src.MainCmd == 0x0E && src.SubCmd == 80) {
        //获取当前绑定设备
        dispatch_async(dispatch_get_main_queue(), ^{
            [_hud setLabelText:@"获取当前绑定设备出错"];
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }
}
@end
