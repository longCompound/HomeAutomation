//
//  ZGAddressDetailViewController.m
//  ZgSafe
//
//  Created by Mark on 2017/6/14.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGAddressDetailViewController.h"
#import "ZGWebViewCell.h"
#import "ZGNewsTitleCell.h"

@interface ZGAddressDetailViewController () <UIWebViewDelegate>

@end

@implementation ZGAddressDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0){
        static NSString *ZGNewsTitleCellID = @"ZGNewsTitleCell";
        ZGNewsTitleCell * cell = [tableView dequeueReusableCellWithIdentifier:ZGNewsTitleCellID];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:ZGNewsTitleCellID owner:nil options:nil] lastObject];
        }
        if (self.infoDic && [self.infoDic isKindOfClass:[NSDictionary class]]) {
            cell.titleLabel.text = self.infoDic[@"name"];
            cell.dateLabel.text = @"";
        }
        return cell;
    } else if (indexPath.row == 1){
        static NSString *SSAWebViewCellID = @"ZGWebViewCell";
        ZGWebViewCell * cell = [tableView dequeueReusableCellWithIdentifier:SSAWebViewCellID];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:SSAWebViewCellID owner:nil options:nil] lastObject];
            cell.webView.delegate = self;
        }
        if (self.infoDic && [self.infoDic isKindOfClass:[NSDictionary class]]) {
            NSString * content = @"";
            NSString * addr = self.infoDic[@"addr"];
            NSString * addlx = self.infoDic[@"addlx"];
            NSString * tel = self.infoDic[@"tel"];
            if (addr.length > 0) {
                content = [content stringByAppendingFormat:@"<p>\n\t地址:%@\n</p>\n",addr];
            }
            if (addlx.length > 0) {
                content = [content stringByAppendingFormat:@"<p>\n\t%@\n</p>\n",addlx];
            }
            if (tel.length > 0) {
                content = [content stringByAppendingFormat:@"<p>\n\t联系电话:%@\n</p>\n",tel];
            }
            [cell.webView loadHTMLString:content baseURL:nil];
        }
        return cell;
    }
    return nil;
}

@end
