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

@interface ZGanHomeViewController () <UICollectionViewDataSource,UICollectionViewDelegate,DDCollectionViewDelegateFlowLayout>{
    NSMutableArray                       * _dataArray;
    UICollectionView                     *_collectionView;
}

@end

@implementation ZGanHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topBar.hiddenLeftBtn = YES;
    [self.topBar setupBackTrace:nil title:@"首页" rightActionTitle:nil];
    [self initData];
    [self createUI];
}

- (void)initData
{
    _dataArray = [NSMutableArray array];
}

- (void)createUI
{
    [self.view addSubview:({
        DDCollectionViewFlowLayout *layout = [[DDCollectionViewFlowLayout alloc] init];
        layout.delegate = self;
        layout.enableStickyHeaders = YES;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.topBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-CGRectGetMaxY(self.topBar.frame)) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[ZGanCollectionViewCell class] forCellWithReuseIdentifier:@"MeetingPicCell"];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        //        _collectionView.header = self.refreshHeader;
        //		_collectionView.footer = self.refreshFooter;
        _collectionView;
    })];
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
    ZGanCollectionViewCell *cell = (ZGanCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"MeetingPicCell" forIndexPath:indexPath];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    return nil;
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
    return CGSizeMake(CGRectGetWidth(self.view.frame)/4,CGRectGetWidth(self.view.frame)/4);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(self.view.bounds.size.width, 30);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

@end



