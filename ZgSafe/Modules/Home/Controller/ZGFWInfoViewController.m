//
//  ZGFWInfoViewController.m
//  ZgSafe
//
//  Created by Mark on 2017/6/13.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGFWInfoViewController.h"
#import "ZGFWInfoCell.h"

@interface ZGFWInfoViewController () {
    __weak IBOutlet UITableView *_tableView;
    NSMutableArray              *_dataArray;
}

@end

@implementation ZGFWInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.topBar setupBackTrace:nil title:_model.title rightActionTitle:nil];
    _dataArray = [NSMutableArray array];
    _tableView.rowHeight = 230;
    [self loadData];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _tableView.frame = CGRectMake(0, self.topBar.bottom, self.view.width, self.view.height - self.topBar.bottom);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * textCellID = @"ZGFWInfoCell";
    ZGFWInfoCell * cell = [tableView dequeueReusableCellWithIdentifier:textCellID];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:textCellID owner:nil options:nil] lastObject];
    }
    cell.infoDic = _dataArray[indexPath.row];
    return cell;
}

- (void)loadData
{
    __weak __typeof(self) weakSelf = self;
    [DemoDataRequest requestWithParameters:nil withRequestUrl:_model.url withIndicatorView:nil withCancelSubject:@"" onRequestStart:^(ITTBaseDataRequest *request) {
        
    } onRequestFinished:^(ITTBaseDataRequest *request) {
        NSDictionary * dic = request.handleredResult;
        NSArray * data = dic[@"data"];
        if (data && [data isKindOfClass:[NSArray class]]) {
            [weakSelf loadDisplayData:data];
        } else {
            [weakSelf toast:@"暂无数据"];
        }
    } onRequestCanceled:^(ITTBaseDataRequest *request) {
        
    } onRequestFailed:^(ITTBaseDataRequest *request) {
        [weakSelf toast:@"暂无数据"];
    }];
    
}

- (void)loadDisplayData:(NSArray *)data
{
    [_dataArray addObjectsFromArray:data];
    [_tableView reloadData];
}

@end
