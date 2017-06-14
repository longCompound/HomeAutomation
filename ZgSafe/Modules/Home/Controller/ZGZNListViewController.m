//
//  ZGZNListViewController.m
//  ZgSafe
//
//  Created by Mark on 2017/6/14.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGZNListViewController.h"

static NSString * const kBSZNDetailURLFormat = @"http://msgservice.zgantech.com/zgancontent.aspx?did=%@&method=bsznxx&bid=%@";


@interface ZGZNListViewController () <UITableViewDelegate,UITableViewDataSource> {
    __weak IBOutlet UITableView *_tableView;
    NSMutableArray              *_dataArray;
}

@end

@implementation ZGZNListViewController

- (void)loadView
{
    [super loadView];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _tableView.frame = CGRectMake(0, self.topBar.bottom, self.view.width, self.view.height - self.topBar.bottom);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.topBar setupBackTrace:nil title:@"办事指南" rightActionTitle:nil];
    _dataArray = [NSMutableArray array];
    [self loadData];
    // Do any additional setup after loading the view from its nib.
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
    static NSString * cellID = @"normalCellId";
    UITableViewCell * tableCell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!tableCell) {
        tableCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        tableCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSDictionary * dic = _dataArray[indexPath.row];
    tableCell.textLabel.text = dic[@"title"];
    tableCell.detailTextLabel.text = dic[@"releasetime"];
    return tableCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString * phone = [BBSocketManager getInstance].user;
    NSDictionary * dic = _dataArray[indexPath.row];
    NSString * type = dic[@"id"];
    NSString * urlString = [NSString stringWithFormat:kBSZNDetailURLFormat,phone,type];
    ZGNewsDetailViewController  * vc =  [[ZGNewsDetailViewController alloc] initWithNibName:@"ZGNewsDetailViewController" bundle:[NSBundle mainBundle]];
    vc.titleString = @"办事指南";
    vc.urlString = urlString;
    [self.navigationController pushViewController:vc animated:YES];
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
