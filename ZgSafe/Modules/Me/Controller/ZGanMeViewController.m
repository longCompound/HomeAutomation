//
//  ZGanMeViewController.m
//  ZgSafe
//
//  Created by Mark on 2017/5/18.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGanMeViewController.h"
#import "ZGRowModel.h"
#import "ZGHeaderCell.h"
#import "ZGTextCell.h"
#import "ZGContentCell.h"

@interface ZGanMeViewController () <UITableViewDelegate,UITableViewDataSource> {
    __weak IBOutlet UITableView *_tableView;
    NSArray                       *_dataArray;
}

@end

@implementation ZGanMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topBar.hidesLeftBtn = YES;
    [self.topBar setupBackTrace:nil title:@"个人中心" rightActionTitle:nil];
    [self initDataSource];
    _tableView.backgroundColor = [ColorUtil getColor:@"#efefef" alpha:1];
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * temp = _dataArray[section];
    return temp.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * temp = _dataArray[indexPath.section];
    ZGRowModel * model = temp[indexPath.row];
    if (model.cellType == ZGCellType_TextCell) {
       static NSString * textCellID = @"ZGTextCell";
        ZGTextCell * cell = [tableView dequeueReusableCellWithIdentifier:textCellID];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:textCellID owner:nil options:nil] lastObject];
        }
        cell.model = model;
        return cell;
    } else if (model.cellType == ZGCellType_TitleCell) {
       static NSString * titleCellID = @"ZGHeaderCell";
        ZGHeaderCell * cell = [tableView dequeueReusableCellWithIdentifier:titleCellID];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:titleCellID owner:nil options:nil] lastObject];
        }
        cell.model = model;
        return cell;
    } else if (model.cellType == ZGCellType_ContentCell) {
        static NSString * contentCellID = @"ZGContentCell";
        ZGContentCell * cell = [tableView dequeueReusableCellWithIdentifier:contentCellID];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:contentCellID owner:nil options:nil] lastObject];
        }
        cell.model = model;
        return cell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 20)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray * temp = _dataArray[indexPath.section];
    ZGRowModel * model = temp[indexPath.row];
    if (model.cellType == ZGCellType_TextCell) {
        if (model.editable) {
            [self showTextEditWithModel:model indexPath:indexPath];
        }
    } else if (model.cellType == ZGCellType_TitleCell) {
        // do nothing
    } else if (model.cellType == ZGCellType_ContentCell) {
        [self goToDetailPageWithModel:model];
    }
}

- (void)showTextEditWithModel:(ZGRowModel *)model indexPath:(NSIndexPath *)indexPath
{
    __weak __typeof(self) weakSelf  = self;
    NSString * title = [model.title stringByReplacingOccurrencesOfString:@" :" withString:@""];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title message:@"" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textFiled = [alert textFieldAtIndex:0];
    textFiled.placeholder = [@"请输入" stringByAppendingString:title];
    textFiled.text = model.content;
    [alert showWithCompleteBlock:^(NSInteger btnIndex) {
        if (btnIndex == 1) {
            [weakSelf refreshDisplayWithModel:model indexPath:indexPath content:textFiled.text];
        }
    }];
}

- (void)goToDetailPageWithModel:(ZGRowModel *)model
{
    
}

- (void)refreshDisplayWithModel:(ZGRowModel *)model indexPath:(NSIndexPath *)indexPath content:(NSString *)content
{
    model.content = content;
    [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)initDataSource
{
    ZGRowModel *model0 = [ZGRowModel modelWithTitle:@"基本信息" bgImageName:@"self_center_title_bg_1.png" content:@"" cellType:ZGCellType_TitleCell editable:NO];
    ZGRowModel *model1 = [ZGRowModel modelWithTitle:@"手机号 :" bgImageName:@"self_center_ling_bg_1.png" content:@"" cellType:ZGCellType_TextCell editable:NO];
    ZGRowModel *model2 = [ZGRowModel modelWithTitle:@"昵称 :" bgImageName:@"self_center_ling_bg_1.png" content:@"" cellType:ZGCellType_TextCell editable:YES];
    ZGRowModel *model3 = [ZGRowModel modelWithTitle:@"楼座号 :" bgImageName:@"self_center_ling_bg_1.png" content:@"" cellType:ZGCellType_TextCell editable:NO];
    ZGRowModel *model4 = [ZGRowModel modelWithTitle:@"紧急联系 :" bgImageName:@"self_center_ling_bg_2.png" content:@"" cellType:ZGCellType_TextCell editable:YES];
    ZGRowModel *model5 = [ZGRowModel modelWithTitle:@"设备管理" bgImageName:@"self_center_title_bg_1.png" content:@"" cellType:ZGCellType_TitleCell editable:NO];
    ZGRowModel *model6 = [ZGRowModel modelWithTitle:@"家庭卫士 : (设备号)" bgImageName:@"self_center_ling_bg_1.png" content:@"" cellType:ZGCellType_ContentCell editable:YES];
    ZGRowModel *model7 = [ZGRowModel modelWithTitle:@"远程控制 : (设备号)" bgImageName:@"self_center_ling_bg_2.png" content:@"" cellType:ZGCellType_ContentCell editable:YES];
    ZGRowModel *model8 = [ZGRowModel modelWithTitle:@"基本设置" bgImageName:@"self_center_title_bg_1.png" content:@"" cellType:ZGCellType_TitleCell editable:NO];
    ZGRowModel *model9 = [ZGRowModel modelWithTitle:@"密码设置" bgImageName:@"self_center_ling_bg_1.png" content:@"" cellType:ZGCellType_ContentCell editable:YES];
    ZGRowModel *model10 = [ZGRowModel modelWithTitle:@"RFID卡设置" bgImageName:@"self_center_ling_bg_1.png" content:@"" cellType:ZGCellType_ContentCell editable:YES];
    ZGRowModel *model11 = [ZGRowModel modelWithTitle:@"推送设置" bgImageName:@"self_center_ling_bg_2.png" content:@"" cellType:ZGCellType_ContentCell editable:YES];
    ZGRowModel *model12 = [ZGRowModel modelWithTitle:@"关于" bgImageName:@"self_center_title_bg_1.png" content:@"" cellType:ZGCellType_TitleCell editable:NO];
    ZGRowModel *model13 = [ZGRowModel modelWithTitle:@"版本与更新" bgImageName:@"self_center_ling_bg_1.png" content:@"" cellType:ZGCellType_ContentCell editable:YES];
    ZGRowModel *model14 = [ZGRowModel modelWithTitle:@"意见反馈" bgImageName:@"self_center_ling_bg_2.png" content:@"" cellType:ZGCellType_ContentCell editable:YES];
    _dataArray = @[@[model0,model1,model2,model3,model4],
                   @[model5,model6,model7],
                   @[model8,model9,model10,model11],
                   @[model12,model13,model14]];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _tableView.frame = CGRectMake(0, self.topBar.bottom, self.view.width, self.view.height - self.topBar.bottom - BAR_HEIGHT);
}


@end
