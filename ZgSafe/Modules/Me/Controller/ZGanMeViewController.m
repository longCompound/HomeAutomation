//
//  ZGanMeViewController.m
//  ZgSafe
//
//  Created by Mark on 2017/5/18.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGanMeViewController.h"

@interface ZGanMeViewController () <UITableViewDelegate,UITableViewDataSource> {
    __weak IBOutlet UITableView *_tableView;
    NSMutableArray              *_dataArray;
}

@end

@implementation ZGanMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topBar.hidesLeftBtn = YES;
    [self.topBar setupBackTrace:nil title:@"个人中心" rightActionTitle:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
