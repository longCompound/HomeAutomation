//
//  ZGanSecurityViewController.m
//  ZgSafe
//
//  Created by Mark on 2017/5/18.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGanSecurityViewController.h"
#import "BBNewsEyesViewController.h"

@interface ZGanSecurityViewController () {
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
    
}

- (IBAction)photoLibClick:(UIButton *)sender
{
    
}

@end
