//
//  BBTabBarController.m
//  ZgSafe
//
//  Created by Mark on 2017/5/17.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "BBRootTabbarController.h"
#import "ZGanHomeViewController.h"
#import "ZGanMeViewController.h"
#import "ZGanSecurityViewController.h"
#import "ZGanControlViewController.h"

#define VIEW_HEIGHT self.view.frame.size.height
#define VIEW_WIDTH self.view.frame.size.width
#define BAR_HEIGHT 60

static const NSInteger kBaseTag  =  100;

@interface BBRootTabbarController () {
    ZGanHomeViewController             * _homeVC;
    ZGanMeViewController               * _meVC;
    ZGanSecurityViewController         * _securityVC;
    ZGanControlViewController          * _controlVC;
}

@property (nonatomic, weak) UIButton * selectedButton;

@end

@implementation BBRootTabbarController

- (instancetype)init
{
    if (self = [super init]) {
        self.tabBar.hidden = YES;
    }
    return self;
}

-(void)loadView
{
    [super loadView];
    [self initTabBarControllers];
    [self initTabBarItems];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)initTabBarControllers
{
    _homeVC = [[ZGanHomeViewController alloc] initWithNibName:@"ZGanHomeViewController" bundle:[NSBundle mainBundle]];
    _controlVC = [[ZGanControlViewController alloc] initWithNibName:@"ZGanControlViewController" bundle:[NSBundle mainBundle]];
    _securityVC = [[ZGanSecurityViewController alloc] initWithNibName:@"ZGanSecurityViewController" bundle:[NSBundle mainBundle]];
    _meVC = [[ZGanMeViewController alloc] initWithNibName:@"ZGanMeViewController" bundle:[NSBundle mainBundle]];
    self.viewControllers = @[_homeVC,_securityVC,_controlVC,_meVC];
}

- (void)initTabBarItems
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, VIEW_HEIGHT-BAR_HEIGHT, VIEW_WIDTH, BAR_HEIGHT)];
    view.userInteractionEnabled = YES;
    view.backgroundColor = [UIColor blackColor];
    NSArray * images = @[@"index_btn_flase.png",@"jtws_btn_false.png",@"yckz_btn_false.png",@"self_btn_false.png"];
    NSArray * selectedImages = @[@"index_btn_true.png",@"jtws_btn_true.png",@"yckz_btn_true.png",@"self_btn_true.png"];
    
    CGFloat buttonWidth = VIEW_WIDTH / MAX(images.count, 1);
    [images enumerateObjectsUsingBlock:^(NSString * imageName, NSUInteger idx, BOOL * stop) {
        NSString * selectedImageName = selectedImages[idx];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(buttonWidth *idx, 0, buttonWidth, BAR_HEIGHT);
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = idx + kBaseTag;
        [button setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:selectedImageName] forState:UIControlStateSelected];
        [view addSubview:button];
    }];
    
    [self.view addSubview:view];
}

- (void)buttonClick:(UIButton *)sender
{
    self.selectedIndex = sender.tag - kBaseTag;
    if (self.selectedButton == sender) {
        return;
    }
    self.selectedButton.selected = NO;
    self.selectedButton = sender;
    self.selectedButton.selected = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
