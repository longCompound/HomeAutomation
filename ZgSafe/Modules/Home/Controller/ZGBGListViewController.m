//
//  ZGBGListViewController.m
//  ZgSafe
//
//  Created by Mark on 2017/6/14.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGBGListViewController.h"
#import "ZGAddressDetailViewController.h"

static NSString * const kZBGListURLFormat = @"http://msgservice.zgantech.com/zgancontent.aspx?did=%@&method=bgdd";
static NSString * const kZBGDetailURLFormat = @"http://msgservice.zgantech.com/zgancontent.aspx?did=%@&method=bgddxx&bid=%@";

@interface ZGBGListViewController () <UITableViewDelegate,UITableViewDataSource> {
    __weak IBOutlet UITableView *_tableView;
    NSMutableArray              *_dataArray;
}


@end

@implementation ZGBGListViewController

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
    [self.topBar setupBackTrace:nil title:@"办公地点" rightActionTitle:nil];
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
    tableCell.textLabel.text = dic[@"name"];
    tableCell.detailTextLabel.text = dic[@""];
    return tableCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString * phone = [BBSocketManager getInstance].user;
    NSDictionary * dic = _dataArray[indexPath.row];
    NSString * type = dic[@"id"];
    NSString * urlString = [NSString stringWithFormat:kZBGDetailURLFormat,phone,type];
    ZGAddressDetailViewController  * vc =  [[ZGAddressDetailViewController alloc] initWithNibName:@"ZGNewsDetailViewController" bundle:[NSBundle mainBundle]];
    vc.titleString = @"办公地点";
    vc.urlString = urlString;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)loadData
{
    __weak __typeof(self) weakSelf = self;
    NSString * phone = [BBSocketManager getInstance].user;
    NSString * url = [NSString stringWithFormat:kZBGListURLFormat,phone];
    [DemoDataRequest requestWithParameters:nil withRequestUrl:url withIndicatorView:nil withCancelSubject:@"" onRequestStart:^(ITTBaseDataRequest *request) {
        
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