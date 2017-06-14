//
//  ZGanHomeViewController.m
//  ZgSafe
//
//  Created by Mark on 2017/5/18.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGanHomeViewController.h"
#import "DDCollectionViewFlowLayout.h"
#import "ZGanCollectionViewCell.h"
#import "ZGFWViewController.h"
#import "ZGSQViewController.h"
#import "ZGZGViewController.h"
#import "ZGZNViewController.h"
#import "ZGZWYWViewController.h"

#define kPickPerLine  4


static NSString * const zgxxURL = @"http://cq.58.com/";

@interface ZGanHomeViewController () <UICollectionViewDataSource,UICollectionViewDelegate,DDCollectionViewDelegateFlowLayout,ZGanCollectionViewCellDelegate>{
    NSArray                       *_dataArray;
    __weak IBOutlet UIImageView *_topImageView;
    __weak IBOutlet UIButton *_notiButton;
    __weak IBOutlet UIView *_blueBar;
    __weak IBOutlet UIImageView *_adImageView;
    __weak IBOutlet UICollectionView *_collectionView;
}

@end

@implementation ZGanHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topBar.hidden = YES;
    [self createUI];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _topImageView.frame = CGRectMake(0, 0, self.view.width, 95.0 * self.view.width / 375);
    _blueBar.frame = CGRectMake(0, _topImageView.bottom, self.view.width, 37);
    _adImageView.frame = CGRectMake(0, _blueBar.bottom, self.view.width, 140.0 * self.view.width / 375);
    _collectionView.frame = CGRectMake(0, _adImageView.bottom, self.view.width, self.view.height - _adImageView.bottom - BAR_HEIGHT);
    _notiButton.frame = CGRectMake(0, 0, _blueBar.height, _blueBar.height);
}

- (void)createUI
{
    _dataArray = @[[ZGanActionModel modelWithType:0 title:@"社区服务" thumbImageName:@"main1" url:nil otherInfo:nil],
                   [ZGanActionModel modelWithType:1 title:@"社区商圈" thumbImageName:@"main4" url:nil otherInfo:nil],
                   [ZGanActionModel modelWithType:2 title:@"政务要闻" thumbImageName:@"main5" url:nil otherInfo:nil],
                   [ZGanActionModel modelWithType:3 title:@"招工信息" thumbImageName:@"main7" url:zgxxURL otherInfo:nil],
                   [ZGanActionModel modelWithType:4 title:@"办事指南" thumbImageName:@"main6" url:nil otherInfo:nil],
                   [ZGanActionModel modelWithType:5 title:@"办公地点" thumbImageName:@"main3" url:nil otherInfo:nil],
                   [ZGanActionModel modelWithType:6 title:@"查询账单" thumbImageName:@"main9" url:nil otherInfo:nil],
                   [ZGanActionModel modelWithType:7 title:@"联系物业" thumbImageName:@"main8" url:nil otherInfo:nil]];
    
    UIImage * image = [UIImage imageNamed:@"drag_bg_yellow.png"];
    
    // 设置端盖的值
    CGFloat top = image.size.height * 0.02;
    CGFloat left = image.size.width * 0.5;
    CGFloat bottom = image.size.height * 0.98;
    CGFloat right = image.size.width * 0.5;
    
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(top, left, bottom, right);

    _topImageView.image = [image resizableImageWithCapInsets:edgeInsets];
    [_notiButton setEnlargeEdgeWithTop:0 right:_blueBar.width bottom:0 left:0];[_notiButton setEnlargeEdgeWithTop:0 right:_blueBar.width bottom:0 left:0];

    DDCollectionViewFlowLayout *layout = [[DDCollectionViewFlowLayout alloc] init];
    layout.delegate = self;
    layout.enableStickyHeaders = YES;
    _collectionView.collectionViewLayout = layout;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerClass:[ZGanCollectionViewCell class] forCellWithReuseIdentifier:@"ZGanCollectionViewCell"];
    [_collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UICollectionView DataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(DDCollectionViewFlowLayout *)layout numberOfColumnsInSection:(NSInteger)section{
    return 4;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZGanCollectionViewCell *cell = (ZGanCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ZGanCollectionViewCell" forIndexPath:indexPath];
    cell.actionInfo = _dataArray[indexPath.row];
    cell.delegate = self;
    return cell;
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
//    return nil;
//}

#pragma mark - UICollectionView Delegate Methods

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(CGRectGetWidth(self.view.frame)/4,CGRectGetWidth(self.view.frame)/4 * 114 / 90);
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
//    return CGSizeMake(self.view.bounds.size.width, 0);
//}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

#pragma mark --
#pragma mark -- ZGanCollectionViewCellDelegate --
- (void)cellClickWithInfo:(ZGanActionModel *)model
{
    BBRootViewController * viewController = nil;
    switch (model.type) {
        case 0:{
            viewController = [[ZGFWViewController alloc] initWithNibName:@"ZGBaseCollectionViewController" bundle:nil];
        }
            break;
        case 1:{
            viewController = [[ZGSQViewController alloc] initWithNibName:@"ZGBaseCollectionViewController" bundle:nil];
        }
            break;
        case 2: {
           viewController = [[ZGZWYWViewController alloc] initWithNibName:@"ZGZWYWViewController" bundle:nil];
        }
            break;
        case 3:{
            viewController = [[ZGZGViewController alloc] initWithNibName:@"ZGBaseCollectionViewController" bundle:nil];
        }
            break;
        case 4:{
            viewController = [[ZGZNViewController alloc] initWithNibName:@"ZGBaseCollectionViewController" bundle:nil];
        }
            break;
        default: {
            ZGWebViewController * vc = [[ZGWebViewController alloc] initWithNibName:@"ZGWebViewController" bundle:[NSBundle mainBundle]];
            vc.titleString = model.title;
            vc.urlString = @"https://www.baidu.com";
            viewController = vc;
        }
            break;
    }
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)noticeClick:(id)sender {
    
    
}

@end



