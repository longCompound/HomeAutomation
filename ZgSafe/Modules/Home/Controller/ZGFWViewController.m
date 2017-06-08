//
//  ZGFWViewController.m
//  ZgSafe
//
//  Created by Mark on 2017/5/22.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGFWViewController.h"

@interface ZGFWViewController ()

@end

@implementation ZGFWViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     [self.topBar setupBackTrace:nil title:@"社区服务" rightActionTitle:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initData
{
    self.topEdge = 5;
    self.bottomEdge = 40;
    self.numbersInRow = 3;
    self.dataArray = @[[ZGanActionModel modelWithType:0 title:@"家电维修" thumbImageName:@"jiadian_btn_bg" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:1 title:@"水电维修" thumbImageName:@"shuidian_btn_bg" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:2 title:@"家政保洁" thumbImageName:@"jiazhen_btn_bg" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:3 title:@"搬家公司" thumbImageName:@"banjia_btn_bg" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:4 title:@"月嫂保姆" thumbImageName:@"yuesao_btn_bg" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:5 title:@"二手回收" thumbImageName:@"ershou_btn_bg" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:6 title:@"开锁服务" thumbImageName:@"kaisuo_btn_bg" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:7 title:@"管道疏通" thumbImageName:@"guandao_btn_bg" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:8 title:@"洗衣服务" thumbImageName:@"xiyi_btn_bg" url:nil otherInfo:nil]];
}

@end
