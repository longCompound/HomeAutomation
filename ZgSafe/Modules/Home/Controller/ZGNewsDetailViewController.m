//
//  ZGNewsDetailViewController.m
//  ZgSafe
//
//  Created by Mark on 2017/6/14.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGNewsDetailViewController.h"
#import "ZGWebViewCell.h"
#import "ZGNewsTitleCell.h"

@interface ZGNewsDetailViewController () <UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate> {
    __weak IBOutlet UITableView *_tableView;
}

@property (nonatomic, assign) CGFloat webViewHeight;

@end

@implementation ZGNewsDetailViewController

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
    [self.topBar setupBackTrace:nil title:self.titleString rightActionTitle:nil];
    [self loadData];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData
{
    __weak __typeof(self) weakSelf = self;
    [DemoDataRequest requestWithParameters:nil withRequestUrl:_urlString withIndicatorView:nil withCancelSubject:@"" onRequestStart:^(ITTBaseDataRequest *request) {
        
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
    _infoDic = [data lastObject];
    if (_infoDic) {
        [_tableView reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 64;
    } else if (indexPath.row == 1){
        return self.webViewHeight;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0){
        static NSString *ZGNewsTitleCellID = @"ZGNewsTitleCell";
        ZGNewsTitleCell * cell = [tableView dequeueReusableCellWithIdentifier:ZGNewsTitleCellID];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:ZGNewsTitleCellID owner:nil options:nil] lastObject];
        }
        if (_infoDic && [_infoDic isKindOfClass:[NSDictionary class]]) {
            cell.titleLabel.text = _infoDic[@"title"];
            cell.dateLabel.text = _infoDic[@"releasetime"];
        }
        return cell;
    } else if (indexPath.row == 1){
        static NSString *SSAWebViewCellID = @"ZGWebViewCell";
        ZGWebViewCell * cell = [tableView dequeueReusableCellWithIdentifier:SSAWebViewCellID];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:SSAWebViewCellID owner:nil options:nil] lastObject];
            cell.webView.delegate = self;
        }
        if (_infoDic && [_infoDic isKindOfClass:[NSDictionary class]] &&_infoDic[@"content"]) {
            [cell.webView loadHTMLString:_infoDic[@"content"] baseURL:nil];
        }
        return cell;
    }
    return nil;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGSize actualSize = [webView sizeThatFits:CGSizeMake(self.view.width - 10, 0)];
    CGRect newFrame = webView.frame;
    newFrame.size.height = actualSize.height;
    webView.frame = newFrame;
    
    if(self.webViewHeight != CGRectGetHeight(webView.frame)) {
        self.webViewHeight = CGRectGetHeight(webView.frame);
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}


@end
