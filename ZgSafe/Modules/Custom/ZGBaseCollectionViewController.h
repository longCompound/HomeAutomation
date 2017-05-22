//
//  ZGBaseCollectionViewController.h
//  ZgSafe
//
//  Created by Mark on 2017/5/22.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "BBRootViewController.h"
#import "ZGanActionModel.h"

@interface ZGBaseCollectionViewController : BBRootViewController

@property (nonatomic,copy) NSArray  *dataArray;

@property (nonatomic, assign) NSUInteger numbersInRow;

@property (nonatomic, assign) CGFloat topEdge;

@property (nonatomic, assign) CGFloat bottomEdge;

- (void)initData;

@end
