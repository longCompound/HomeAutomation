//
//  BBPageControl.h
//  BackgroundOperation
//
//  Created by iXcoder on 13-12-18.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BBIndicatorAlignment) {
    kBBIndicatorAlignmentCenter = 0,
    kBBIndicatorAlignmentLeft,
    kBBIndicatorAlignmentRight
};

@protocol BBPageControlDelegate;


#pragma mark -
#pragma mark BBPageControl define method
@interface BBPageControl : UIView
// 总页数
@property (nonatomic, assign) NSUInteger numberOfPages;
// 当前页
@property (nonatomic, assign) NSUInteger currentPage;
// 回调代理
@property (nonatomic, assign) id<BBPageControlDelegate> delegate;
// 当前颜色
@property (nonatomic, retain) UIColor *selectedColor;
// 其他颜色
@property (nonatomic, retain) UIColor *otherColor;
// 对齐方式
@property (nonatomic, assign) BBIndicatorAlignment alignment;

@end

#pragma mark -
#pragma mark BBPageControl delegate define
@protocol BBPageControlDelegate <NSObject>

- (void)pageControl:(BBPageControl *)pc didChangeIndexTo:(NSUInteger)toIndex from:(NSUInteger)fromIndex;

@end

