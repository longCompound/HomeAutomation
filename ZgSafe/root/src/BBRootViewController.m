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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onReceiveWaringNotificaiton:) name:BBDidReceiveWarningNotificaiton object:nil];
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    appDelegate.statusBg.frame = [[UIApplication sharedApplication]statusBarFrame];
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

- (NSUInteger)supportedInterfaceOrientations
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
            [self.presentingViewController dismissModalViewControllerAnimated:NO];
        }
    }
 
}

@end
