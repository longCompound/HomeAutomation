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


static const NSInteger kBaseTag  =  100;

@interface BBRootTabbarController () {
    ZGanHomeViewController             * _homeVC;
    ZGanMeViewController               * _meVC;
    ZGanSecurityViewController         * _securityVC;
    ZGanControlViewController          * _controlVC;
    
    UIView                             * _barView;
}

@property (nonatomic, weak) UIButton * selectedButton;

@end

@implementation BBRootTabbarController

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

-(void)loadView
{
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBar.hidden = YES;
    [self initTabBarControllers];
    [self initTabBarItems];
}

- (void)initTabBarControllers
{
    _homeVC = [[ZGanHomeViewController alloc] initWithNibName:@"ZGanHomeViewController" bundle:[NSBundle mainBundle]];
    _controlVC = [[ZGanControlViewController alloc] initWithNibName:@"ZGanControlViewController" bundle:[NSBundle mainBundle]];
    _securityVC = [[ZGanSecurityViewController alloc] initWithNibName:@"ZGanSecurityViewController" bundle:[NSBundle mainBundle]];
    _meVC = [[ZGanMeViewController alloc] initWithNibName:@"ZGanMeViewController" bundle:[NSBundle mainBundle]];
    self.viewControllers = @[_homeVC,_securityVC,_controlVC,_meVC];
    
    [self.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * obj, NSUInteger idx, BOOL * stop) {
        obj.view.frame = CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height - BAR_HEIGHT);
    }];
}

- (void)initTabBarItems
{
    _barView = [[UIView alloc]initWithFrame:CGRectMake(0, VIEW_HEIGHT-BAR_HEIGHT, VIEW_WIDTH, BAR_HEIGHT)];
    _barView.userInteractionEnabled = YES;
    _barView.backgroundColor = [UIColor blackColor];
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
        [_barView addSubview:button];
    }];
    
    [self.view addSubview:_barView];
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

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * obj, NSUInteger idx, BOOL * stop) {
        obj.view.frame = CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height - BAR_HEIGHT);
    }];
    _barView.frame = CGRectMake(0, VIEW_HEIGHT-BAR_HEIGHT, VIEW_WIDTH, BAR_HEIGHT);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
