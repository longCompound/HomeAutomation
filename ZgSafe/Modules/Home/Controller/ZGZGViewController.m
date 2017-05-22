//
//  ZGZGViewController.m
//  ZgSafe
//
//  Created by Mark on 2017/5/22.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGZGViewController.h"

@interface ZGZGViewController ()

@end

@implementation ZGZGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.topBar setupBackTrace:nil title:@"招工信息" rightActionTitle:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initData
{
    self.topEdge = 5;
    self.bottomEdge = 5;
    self.numbersInRow = 3;
    self.dataArray = @[[ZGanActionModel modelWithType:0 title:@"服务员" thumbImageName:@"main1" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:1 title:@"保洁" thumbImageName:@"main4" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:2 title:@"司机" thumbImageName:@"main5" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:3 title:@"厨师" thumbImageName:@"main7" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:4 title:@"快递员" thumbImageName:@"main6" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:5 title:@"销售" thumbImageName:@"main3" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:6 title:@"技工" thumbImageName:@"main9" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:7 title:@"客服" thumbImageName:@"main8" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:8 title:@"营业员" thumbImageName:@"main8" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:9 title:@"会计" thumbImageName:@"main8" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:10 title:@"文员" thumbImageName:@"main8" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:11 title:@"其他" thumbImageName:@"main8" url:nil otherInfo:nil]];
}



@end
