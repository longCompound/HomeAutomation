//
//  ZGSQViewController.m
//  ZgSafe
//
//  Created by Mark on 2017/5/22.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGSQViewController.h"
#import "ZGMapViewController.h"

@interface ZGSQViewController ()

@end

@implementation ZGSQViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.topBar setupBackTrace:nil title:@"社区商圈" rightActionTitle:nil];
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
    self.typeDic = @{@"餐饮美食":@"餐饮",
                     @"棋牌娱乐":@"娱乐",
                     @"便利超市":@"超市",
                     @"宠物美容":@"宠物",
                     @"药房诊所":@"药店",
                     @"汽车美容":@"汽车美容",
                     @"母婴用品":@"母婴",
                     @"鲜花养殖":@"鲜花",
                     @"教育培训":@"学校"};
    self.dataArray = @[[ZGanActionModel modelWithType:0 title:@"餐饮美食" thumbImageName:@"food_btn_bg" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:1 title:@"棋牌娱乐" thumbImageName:@"qipai_btn_bg" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:2 title:@"便利超市" thumbImageName:@"market_btn_bg" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:3 title:@"宠物美容" thumbImageName:@"pet_btn_bg" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:4 title:@"药房诊所" thumbImageName:@"yaof_btn_bg" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:5 title:@"汽车美容" thumbImageName:@"car_btn_bg" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:6 title:@"母婴用品" thumbImageName:@"baby_btn_bg" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:7 title:@"鲜花养殖" thumbImageName:@"flower_btn_bg" url:nil otherInfo:nil],
                       [ZGanActionModel modelWithType:8 title:@"教育培训" thumbImageName:@"edu_btn_bg" url:nil otherInfo:nil]];
}

- (void)cellClickWithInfo:(ZGanActionModel *)model
{
    ZGMapViewController * vc = [[ZGMapViewController alloc] init];
    vc.titleString = model.title;
    vc.keyWord = self.typeDic[model.title];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
