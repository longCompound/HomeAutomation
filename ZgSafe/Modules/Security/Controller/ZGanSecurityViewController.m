//
//  ZGanSecurityViewController.m
//  ZgSafe
//
//  Created by Mark on 2017/5/18.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGanSecurityViewController.h"
#import "BBNewsEyesViewController.h"
#import "BBAlbumsViewController.h"
#import "BBMarkViewController.h"

@interface ZGanSecurityViewController ()<BBSocketClientDelegate> {
    __weak IBOutlet UIImageView *_bgImageView;
    __weak IBOutlet UIButton *_cloudEyeBtn;
    __weak IBOutlet UIButton *_historyBtn;
    __weak IBOutlet UIButton *_photoLibBtn;
    __weak IBOutlet UIImageView *_topImageView;
}

@end

@implementation ZGanSecurityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topBar.hidesLeftBtn = YES;
    [self.topBar.rightButton setImage:[UIImage imageNamed:@"chefang_btn.png"] forState:UIControlStateNormal];
    [self.topBar.rightButton setImage:[UIImage imageNamed:@"bufang_btn.png"] forState:UIControlStateSelected];
    [self.topBar setupBackTrace:nil title:@"家庭卫士" rightActionTitle:nil];
    self.topBar.rightButton.hidden = NO;
    
    
}

/*!
 *@description  获取布防状态
 *@function     getGuardStatusAndScanCard
 *@param        (void)
 *@return       (void)
 */
- (void)getGuardStatusAndScanCard
{
    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
    NSString *userId = curUser.userid;
    [mainClient queryCurrentStatus:self param:userId];
    [mainClient scanCard2:self param:userId];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _bgImageView.frame = CGRectMake(0, self.topBar.bottom - 5, self.view.width, self.view.height -  self.topBar.bottom - BAR_HEIGHT + 10);
    _cloudEyeBtn.frame = CGRectMake(0, self.topBar.bottom, self.view.width,self.view.width);
    self.topBar.rightButton.frame = CGRectMake(self.topBar.width - 100, self.topBar.height - 40, 95, 37);
    
    CGFloat width = self.view.width - 20 * 2;
    CGFloat totalHeight = width * 67 / 357 + width / 2 * 56 / 177;
    
    _topImageView.frame = CGRectMake(20,self.view.height - BAR_HEIGHT - 10 - totalHeight, width,width * 67 / 357);
    _historyBtn.frame = CGRectMake(_topImageView.left, _topImageView.bottom + 1, width/2-1, width/2 * 56 / 177);
    _photoLibBtn.frame =  CGRectMake(_historyBtn.right + 0.5, _topImageView.bottom + 1,_historyBtn.width,_historyBtn.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --
#pragma mark -- ZGanTopBarDelegate --
- (void)touchTopBarRightButton:(ZGanTopBar *)bar
{
    self.topBar.rightButton.selected = !self.topBar.rightButton.selected;
    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
    NSDateFormatter *fmt = [[NSDateFormatter alloc]init];
    [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [fmt stringFromDate:[NSDate date]];
    NSString *param = [NSString stringWithFormat:@"%@\t%@",curUser.userid,dateStr];
    if (self.topBar.rightButton.selected) {
        [mainClient addControl:self param :param ];
    } else {
        [mainClient cancelControl:self param:param];
    }
}



#pragma mark --
#pragma mark -- CustomMethods --

- (IBAction)cloudClick:(UIButton *)sender
{
    if(!appDelegate.EyesIsOpen){
        //appDelegate.EyesIsOpen=YES;
        BBNewsEyesViewController *eyesVC;
        
        if (ISIP5){
            eyesVC = [[BBNewsEyesViewController alloc]initWithNibName:@"BBNewsEyesViewController_4" bundle:nil];
        }else{
            eyesVC = [[BBNewsEyesViewController alloc]initWithNibName:@"BBNewsEyesViewController" bundle:nil];
        }
        
        eyesVC.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:eyesVC animated:YES];
    }
}

- (IBAction)historyClick:(UIButton *)sender
{
    BBMarkViewController *viewController = [[BBMarkViewController alloc] initWithNibName:@"BBMarkViewController" bundle:nil];
    viewController.currentPageType = BBMarkPageTypeWarningRecord;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)photoLibClick:(UIButton *)sender
{
    BBAlbumsViewController *vc = [[BBAlbumsViewController alloc] initWithNibName:@"BBAlbumsViewController" bundle:nil];
    appDelegate.EyesVCBtn=YES;
    [self.navigationController pushViewController:vc animated:YES];
}


-(int)onRecevie:(BBDataFrame*)src received:(BBDataFrame*)data
{
    if (src) {
        //不是通知消息
        if(src.MainCmd == 0x0E && src.SubCmd == 1) {
            //步防
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleReceiveRegard:src data:data];
            });
        } else if (src.MainCmd == 0x0E && src.SubCmd == 2) {
            //撤防
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleReceiveCancelRegard:src data:data];
            });
            
        }else if (src.MainCmd == 0x0E && src.SubCmd == 72) {
            //当前布防状态
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleReceiveCurrentRegard:src data:data];
            });
        }else if (src.MainCmd == 0x0E && src.SubCmd == 74) {
            //获取温度值
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //                [self handleReceiveTemperature:src data:data];
            //            });
            
        }else if (src.MainCmd == 0x0E && src.SubCmd == 75) {
            //获取湿度值
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //                [self handleReceiveHumidity:src data:data];
            //            });
            
        }else if (src.MainCmd == 0x0E && src.SubCmd == 4) {
            //获扫描卡片
            dispatch_async(dispatch_get_main_queue(), ^{
//                [self handleReceiveRFID:src data:data];
            });
        }else if (src.MainCmd == 0x0E && src.SubCmd == 84) {
            //获取温度曲线
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //                [self handleReceiveTemperatureLine:src data:data];
            //            });
        }else if (src.version==2 && src.MainCmd == 0x0E && src.SubCmd == 80) {
            //获取当前绑定终端
            dispatch_async(dispatch_get_main_queue(), ^{
//                [self handleReceiveUserDeviceID:src data:data];
            });
        }
        
    }
    return 0;
}

-(void)onRecevieError:(BBDataFrame*)src received:(BBDataFrame*)data
{

}

-(void)onTimeout:(BBDataFrame*)src
{

}


#pragma mark --
#pragma mark -- handler message
/*!
 *@description  处理获取到当前布防状态结果
 *@function     handleReceiveCurrentRegard:data:
 *@param        src     --
 *@return       data    --返回数据
 */
- (void)handleReceiveCurrentRegard:(BBDataFrame *)src data:(BBDataFrame *)data{
    
    NSString *result = [[NSString alloc] initWithData:data.data encoding:NSUTF8StringEncoding];
    
    if(result){
        NSArray *arr = [result componentsSeparatedByString:@"\t"];
        
        if(arr.count==2 && [arr[0] isEqualToString:@"0"]){
            if ([arr[1] integerValue] == 1) {
                self.topBar.rightButton.selected = NO;
            }else{
                self.topBar.rightButton.selected = YES;
            }
            
        }
    }
}

/*!
 *@description  处理布防结果
 *@function     handleReceiveRegard:data:
 *@param        src     --
 *@return       data    --返回数据
 */
- (void)handleReceiveRegard:(BBDataFrame *)src data:(BBDataFrame *)data{
    
    NSString *result = [[NSString alloc] initWithData:data.data encoding:NSUTF8StringEncoding];
    
    if(result){
        NSArray *arr = [result componentsSeparatedByString:@"\t"];
        if ([arr[0] isEqualToString:@"0" ]) {
            self.topBar.rightButton.selected = YES;
        } else {
            self.topBar.rightButton.selected = NO;
        }
    }

}


/*!
 *@description  处理撤防结果
 *@function     handleReceiveCancelRegard:data:
 *@param        src     --
 *@return       data    --返回数据
 */
- (void)handleReceiveCancelRegard:(BBDataFrame *)src data:(BBDataFrame *)data{
    
    NSString *result = [[NSString alloc] initWithData:data.data encoding:NSUTF8StringEncoding];
    
    if (result) {
        NSArray *arr = [result componentsSeparatedByString:@"\t"];
        if ([arr[0] isEqualToString:@"0" ]) {
            self.topBar.rightButton.selected = NO;
        } else {
            self.topBar.rightButton.selected = YES;
        }
    }
}
@end
