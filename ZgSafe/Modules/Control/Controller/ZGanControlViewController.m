//
//  ZGanControlViewController.m
//  ZgSafe
//
//  Created by Mark on 2017/5/18.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGanControlViewController.h"
#import "SDCycleScrollView.h"

@interface ZGanControlViewController () <SDCycleScrollViewDelegate> {
    SDCycleScrollView      *_scrollImageView;
    NSArray                *_dataSource;
}

@end

@implementation ZGanControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topBar.hidesLeftBtn = YES;
    [self.topBar setupBackTrace:nil title:@"远程控制" rightActionTitle:nil];
    
    [self.view addSubview:({
        _scrollImageView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0,self.topBar.bottom,self.view.width, self.view.height-self.topBar.bottom-BAR_HEIGHT)
                                                              delegate:self
                                                      placeholderImage:nil];
        
        _scrollImageView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
        _scrollImageView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
        _scrollImageView.autoScroll = NO;
        _scrollImageView.currentPageDotColor = [UIColor orangeColor];
        _scrollImageView.pageDotColor = [UIColor whiteColor];
        _scrollImageView.titleLabelBackgroundColor = [UIColor clearColor];
        _scrollImageView;
    })];
    
    _dataSource = @[[ZGDeviceModel modelWithType:0 title:@"智能插座" imagePath:@"deng_false" highLightImagePath:@"deng_true" state:NO],
                    [ZGDeviceModel modelWithType:0 title:@"智能主二位开关" imagePath:@"deng_double_false" highLightImagePath:@"deng_double_true" state:NO],
                    [ZGDeviceModel modelWithType:0 title:@"主卧一位开关" imagePath:@"deng_false" highLightImagePath:@"deng_true" state:NO],
                    [ZGDeviceModel modelWithType:0 title:@"次卧一位开关" imagePath:@"deng_false" highLightImagePath:@"deng_true" state:NO],
                    [ZGDeviceModel modelWithType:0 title:@"智能主一位开关" imagePath:@"deng_false" highLightImagePath:@"deng_true" state:NO],
                    [ZGDeviceModel modelWithType:0 title:@"智能主一位开关" imagePath:@"deng_false" highLightImagePath:@"deng_true" state:NO],
                    [ZGDeviceModel modelWithType:0 title:@"智能主一位开关" imagePath:@"deng_false" highLightImagePath:@"deng_true" state:NO],
                    [ZGDeviceModel modelWithType:0 title:@"智能主一位开关" imagePath:@"deng_false" highLightImagePath:@"deng_true" state:NO]];
    _scrollImageView.adsGroup = _dataSource;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _scrollImageView.frame = CGRectMake(0,self.topBar.bottom,self.view.width, self.view.height-self.topBar.bottom-BAR_HEIGHT);
}

#pragma mark --
#pragma mark -- SDCycleScrollViewDelegate --
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    ZGDeviceModel * model = [_dataSource objectAtIndex:index];
    model.state = YES;
}

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index
{
    
}

@end
