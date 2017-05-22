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
#define kPickPerLine  4

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
    _topImageView.frame = CGRectMake(0, 0, self.view.width, 95);
    _blueBar.frame = CGRectMake(0, _topImageView.bottom, self.view.width, 37);
    _adImageView.frame = CGRectMake(0, _blueBar.bottom, self.view.width, 130);
    _collectionView.frame = CGRectMake(0, _adImageView.bottom, self.view.width, self.view.height - _adImageView.bottom - 60);
    _notiButton.frame = CGRectMake(0, 0, _blueBar.height, _blueBar.height);
}

- (void)createUI
{
    _dataArray = @[[ZGanActionModel modelWithType:0 thumbImageName:@"main1" url:nil otherInfo:nil],
                   [ZGanActionModel modelWithType:1 thumbImageName:@"main4" url:nil otherInfo:nil],
                   [ZGanActionModel modelWithType:2 thumbImageName:@"main5" url:nil otherInfo:nil],
                   [ZGanActionModel modelWithType:3 thumbImageName:@"main7" url:nil otherInfo:nil],
                   [ZGanActionModel modelWithType:4 thumbImageName:@"main6" url:nil otherInfo:nil],
                   [ZGanActionModel modelWithType:5 thumbImageName:@"main3" url:nil otherInfo:nil],
                   [ZGanActionModel modelWithType:6 thumbImageName:@"main9" url:nil otherInfo:nil],
                   [ZGanActionModel modelWithType:7 thumbImageName:@"main8" url:nil otherInfo:nil]];
    
    UIImage * image = [UIImage imageNamed:@"drag_bg_yellow.png"];
    
    // 设置端盖的值
    CGFloat top = image.size.height * 0.02;
    CGFloat left = image.size.width * 0.5;
    CGFloat bottom = image.size.height * 0.98;
    CGFloat right = image.size.width * 0.5;
    
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(top, left, bottom, right);

    _topImageView.image = [image resizableImageWithCapInsets:edgeInsets];

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
    ZGWebViewController * vc = [[ZGWebViewController alloc] initWithNibName:@"ZGWebViewController" bundle:[NSBundle mainBundle]];
    vc.titleString = @"";
    vc.urlString = @"https://www.baidu.com";
    [self.navigationController pushViewController:vc animated:YES];
}

@end



