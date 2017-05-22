//
//  ZGZNViewController.m
//  ZgSafe
//
//  Created by Mark on 2017/5/22.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGZNViewController.h"

@interface ZGZNViewController ()

@end

@implementation ZGZNViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.topBar setupBackTrace:nil title:@"办事指南" rightActionTitle:nil];
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
    self.dataArray = @[[ZGanActionModel modelWithType:0 title:@"户籍" thumbImageName:@"main1" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:1 title:@"社保" thumbImageName:@"main4" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:2 title:@"就业" thumbImageName:@"main5" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:3 title:@"车辆" thumbImageName:@"main7" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:4 title:@"公证" thumbImageName:@"main6" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:5 title:@"婚姻" thumbImageName:@"main3" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:6 title:@"生育" thumbImageName:@"main9" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:7 title:@"纳税" thumbImageName:@"main8" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:8 title:@"房屋" thumbImageName:@"main8" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:9 title:@"出入境" thumbImageName:@"main8" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:10 title:@"公租房" thumbImageName:@"main8" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:11 title:@"兵役" thumbImageName:@"main8" url:nil otherInfo:nil]];
}


@end
