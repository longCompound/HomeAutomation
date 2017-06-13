//
//  BBRootViewController.m
//  JiangbeiEPA
//
//  Created by iXcoder on 13-9-16.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBRootViewController.h"
#import "BBMarkViewController.h"

@interface BBRootViewController ()

@property (nonatomic, strong) MBProgressHUD * toastHUD;

@end

@implementation BBRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    _topBar = [[[NSBundle mainBundle] loadNibNamed:@"ZGanTopBar" owner:nil options:nil] lastObject];
    if (IOS_VERSION>=7.0) {
        _topBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64);
    } else {
        _topBar.frame = CGRectMake(0, 20, CGRectGetWidth(self.view.frame), 44);
    }
    _topBar.delegate = self;
    [self.view addSubview:_topBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.topBar setupBackTrace:@"返回" title:self.titleString rightActionTitle:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onReceiveWaringNotificaiton:) name:BBDidReceiveWarningNotificaiton object:nil];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (IOS_VERSION>=7.0) {
        _topBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 64);
    } else {
        _topBar.frame = CGRectMake(0, 20, CGRectGetWidth(self.view.frame), 44);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    appDelegate.statusBg.frame = [[UIApplication sharedApplication] statusBarFrame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (IOS_VERSION>=7.0) {
        return UIStatusBarStyleLightContent;
    }else{
        return UIStatusBarStyleDefault;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}
//#pragma mark -
//#pragma mark UIView rotate method
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)onReceiveWaringNotificaiton:(NSNotification *)notice
{
    UIViewController *topVC = appDelegate.homePageVC.navigationController.topViewController;
    if (self == topVC){
        
        if (![topVC isKindOfClass:[BBMarkViewController class]]//不在印记页面
            ||
            ([topVC isKindOfClass:[BBMarkViewController class]]//在，但是不在报警页面
             && ((BBMarkViewController *)topVC).currentPageType != BBMarkPageTypeWarningRecord)) {
                
            [topVC.navigationController popToRootViewControllerAnimated:NO];
            
            BBMarkViewController *markVC = [[BBMarkViewController alloc]init];
            markVC.currentPageType = BBMarkPageTypeWarningRecord;
            [appDelegate.homePageVC.navigationController pushViewController:markVC animated:YES];
            [markVC release];
            }else{
                BBMarkViewController *markVC = (BBMarkViewController *)topVC;
                [markVC getDatasWhileSelectType:YES];
            }
    }else{
        if (self.presentingViewController) {
            [self.presentingViewController dismissViewControllerAnimated:NO completion:^{
                
            }];
        }
    }
}

- (void)touchTopBarLeftButton:(ZGanTopBar *)bar
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchTopBarRightButton:(ZGanTopBar *)bar
{
    
}

- (void)toast:(NSString *)message
{
[[ProgressHUD instance] showToast:self.view title:message duration:2];
}

- (MBProgressHUD *)toastHUD
{
    if (!_toastHUD) {
        _toastHUD = [[MBProgressHUD alloc] initWithView:self.view];
        [_toastHUD setLabelFont:[UIFont systemFontOfSize:13.0f]];
        [_toastHUD setRemoveFromSuperViewOnHide:YES];
        _toastHUD.mode = MBProgressHUDModeCustomView;
    }
    return _toastHUD;
}

@end
