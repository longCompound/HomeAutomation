//
//  BBScrollImageView.h
//  ImageScrollView
//
//  Created by box on 13-12-17.
//  Copyright (c) 2013年 box. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBPageControl.h"

@protocol BBScrollImageViewDelegate ;
@interface BBScrollImageView : UIView

@property (retain, nonatomic) BBPageControl *pageControl;
@property(nonatomic,assign)CGFloat pageControlLimit;//图片数量超过这个值不用pageControl 而用“1/10”类型表示 默认:5
@property(nonatomic,assign)CGFloat animateDuration;//动画时间 默认：0.5
@property(nonatomic,assign)BOOL autoPlay;//自动滚动播放 默认：NO
@property(nonatomic,assign)CGFloat autoPlayDuration;//自动播放时间间隔 默认：3.0
@property(nonatomic,assign)id<BBScrollImageViewDelegate>delegate;

- (void)loadWithUrls:(NSArray *)urlArr;

@end


@protocol BBScrollImageViewDelegate <NSObject>

@optional
- (void)scrollImageView:(BBScrollImageView *)scrollImageView didSeletedImageView:(UIImageView *)imageView atIndex:(NSInteger)index;

@end