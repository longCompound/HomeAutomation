//
//  MyScrollHeader.h
//  TestScroll
//
//  Created by iXcoder on 13-8-17.
//  Copyright (c) 2013年 BB. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyScrollHeaderDelegate <NSObject>

//刷新数据操作
- (void)needsDataSourceRefresh;

@end

@interface MyScrollHeader : UIView

@property (nonatomic, retain) UIScrollView *scroll;
@property (nonatomic, assign) UIActivityIndicatorViewStyle style;
@property (nonatomic, assign) id<MyScrollHeaderDelegate> delegate;
@property (nonatomic, retain) NSArray *descs;

//滑动改变状态操作
- (void)didScrollViewScrolled;

//停止滑动操作
- (void)didEndDragOnScrollView;

//结束数据刷新操作
- (void)didEndDataSourceRefresh;

@end
