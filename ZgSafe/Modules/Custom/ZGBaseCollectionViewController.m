//
//  ZGBaseCollectionViewController.m
//  ZgSafe
//
//  Created by Mark on 2017/5/22.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGBaseCollectionViewController.h"
#import "DDCollectionViewFlowLayout.h"
#import "ZGanCollectionViewCell.h"


@interface ZGBaseCollectionViewController () <UICollectionViewDataSource,UICollectionViewDelegate,DDCollectionViewDelegateFlowLayout,ZGanCollectionViewCellDelegate> {
    __weak IBOutlet UICollectionView *_collectionView;
}

@end

@implementation ZGBaseCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _numbersInRow = 3;
    // Do any additional setup after loading the view from its nib.
}

- (void)setNumbersInRow:(NSUInteger)numbersInRow
{
    if (numbersInRow == 0) {
        numbersInRow = 3;
    }
    _numbersInRow = numbersInRow;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _collectionView.frame = CGRectMake(0, self.topBar.bottom, self.view.width, self.view.height - self.topBar.bottom);
}

- (void)createUI
{
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
    // Dispose of any resources that can be recreated.
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
    return CGSizeMake(CGRectGetWidth(self.view.frame)/_numbersInRow,CGRectGetWidth(self.view.frame)/_numbersInRow * 114 / 90);
}

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
