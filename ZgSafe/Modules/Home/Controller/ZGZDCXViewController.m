//
//  ZGZDCXViewController.m
//  ZgSafe
//
//  Created by Mark on 2017/6/16.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGZDCXViewController.h"
#import "ZGDatePicker.h"
#import "ZGZDDetailCell.h"

@interface ZGZDCXViewController () <UITableViewDelegate,UITableViewDataSource>{
    ZGDatePicker           *_datePicker;
    __weak IBOutlet UITableView *_tableView;
    NSMutableArray         *_dataArray;
}

@end

@implementation ZGZDCXViewController

- (NSUInteger)minYear
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSDate * date = [NSDate dateWithTimeIntervalSinceNow:-5 * 365 * 24 * 3600];
    NSString * str = [dateFormatter stringFromDate:date];
    return [str integerValue];
}

- (NSUInteger)maxYear
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    NSDate * date = [NSDate dateWithTimeIntervalSinceNow:5 * 365 * 24 * 3600];
    NSString * str = [dateFormatter stringFromDate:date];
    return [str integerValue];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _datePicker.frame = CGRectMake(0, self.topBar.bottom, self.view.width, 150);
    _tableView.frame = CGRectMake(0, _datePicker.bottom, self.view.width, self.view.height - _datePicker.bottom);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray array];
    _datePicker = [[ZGDatePicker alloc] initWithFrame: CGRectMake(0, self.topBar.bottom, [UIScreen mainScreen].bounds.size.width, 150)
                                              minYear:[self minYear]
                                              maxYear:[self maxYear]
                                                 date:[NSDate date]];
    [self.view addSubview:_datePicker];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.frame = CGRectMake(0, _datePicker.bottom, self.view.width, self.view.height - _datePicker.bottom);
     [self.topBar setupBackTrace:nil title:@"查询账单" rightActionTitle:@"查询   "];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyyMM"];
    NSString *value = [dateFormatter stringFromDate:[NSDate date]];
    [self loadData:value];
    // Do any additional setup after loading the view from its nib.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary * dic = _dataArray[indexPath.row];
    return [ZGZDDetailCell caculateHeight:dic];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellID = @"ZGZDDetailCell";
    ZGZDDetailCell * tableCell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!tableCell) {
        tableCell = [[[NSBundle mainBundle] loadNibNamed:cellID owner:nil options:nil] lastObject];
    }
    NSDictionary * dic = _dataArray[indexPath.row];
    tableCell.infoDic = dic;
    return tableCell;
}

- (void)loadData:(NSString *)dateString
{
    NSString * phone = [BBSocketManager getInstance].user;
    NSString * url = [NSString stringWithFormat:@"http://msgservice.zgantech.com/zganwyzd.aspx?did=%@&ny=%@",phone,dateString];
    __weak __typeof(self) weakSelf = self;
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
    [_dataArray removeAllObjects];
    [_dataArray addObjectsFromArray:data];
    [_tableView reloadData];
}

- (void)touchTopBarRightButton:(ZGanTopBar *)bar
{
    [self loadData:[_datePicker selectedYearMonthString]];
}


@end
