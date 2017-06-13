//
//  ZGFWViewController.m
//  ZgSafe
//
//  Created by Mark on 2017/5/22.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGFWViewController.h"
#import "BBSocketManager.h"
#import "ZGFWInfoViewController.h"

static NSString * const kFWFormatURLString = @"http://msgservice.zgantech.com/zgansq.aspx?did=%@&id=%@";

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
    self.typeDic = @{@"家电维修":@1,
                     @"水电维修":@2,
                     @"家政保洁":@4,
                     @"搬家公司":@12,
                     @"月嫂保姆":@13,
                     @"二手回收":@6,
                     @"开锁服务":@3,
                     @"管道疏通":@5,
                     @"洗衣服务":@8
                     };
    self.dataArray = @[[ZGanActionModel modelWithType:0 title:@"家电维修" thumbImageName:@"jiadian_btn_bg" url:[self getURLStringWithTitle:@"家电维修"] otherInfo:nil],
                       [ZGanActionModel modelWithType:1 title:@"水电维修" thumbImageName:@"shuidian_btn_bg" url:[self getURLStringWithTitle:@"水电维修"] otherInfo:nil],
                       [ZGanActionModel modelWithType:2 title:@"家政保洁" thumbImageName:@"jiazhen_btn_bg" url:[self getURLStringWithTitle:@"家政保洁"] otherInfo:nil],
                       [ZGanActionModel modelWithType:3 title:@"搬家公司" thumbImageName:@"banjia_btn_bg" url:[self getURLStringWithTitle:@"搬家公司"] otherInfo:nil],
                       [ZGanActionModel modelWithType:4 title:@"月嫂保姆" thumbImageName:@"yuesao_btn_bg" url:[self getURLStringWithTitle:@"月嫂保姆"] otherInfo:nil],
                       [ZGanActionModel modelWithType:5 title:@"二手回收" thumbImageName:@"ershou_btn_bg" url:[self getURLStringWithTitle:@"二手回收"] otherInfo:nil],
                       [ZGanActionModel modelWithType:6 title:@"开锁服务" thumbImageName:@"kaisuo_btn_bg" url:[self getURLStringWithTitle:@"开锁服务"] otherInfo:nil],
                       [ZGanActionModel modelWithType:7 title:@"管道疏通" thumbImageName:@"guandao_btn_bg" url:[self getURLStringWithTitle:@"管道疏通"] otherInfo:nil],
                       [ZGanActionModel modelWithType:8 title:@"洗衣服务" thumbImageName:@"xiyi_btn_bg" url:[self getURLStringWithTitle:@"洗衣服务"] otherInfo:nil]];
}

- (NSString *)getURLStringWithTitle:(NSString *)title
{
    NSString * phone = [BBSocketManager getInstance].user;
    NSNumber * type = self.typeDic[title];
    return [NSString stringWithFormat:kFWFormatURLString,phone,type];
}

- (void)cellClickWithInfo:(ZGanActionModel *)model
{
    ZGFWInfoViewController * vc = [[ZGFWInfoViewController alloc] initWithNibName:@"ZGFWInfoViewController" bundle:[NSBundle mainBundle]];
    vc.model = model;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
