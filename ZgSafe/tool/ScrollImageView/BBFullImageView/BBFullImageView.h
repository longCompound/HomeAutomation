//
//  BBFullImageView.h
//  VankeClub
//
//  Created by box on 13-10-26.
//  Copyright (c) 2013年 Blue Box. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBAppDelegate.h"
#import "UIImageView+WebCache.h"

@interface BBFullImageView : UIView
{
    NSInteger _imageCount;
}
@property (retain,nonatomic)UIScrollView *scrollView;
@property (retain,nonatomic)UIScrollView *target;
@property (nonatomic,assign)NSInteger curIndex;//当前展示的图片index
@property (nonatomic,assign)BOOL openSaveImage;//开启保存图片到相册的功能
@property (nonatomic,retain,readonly)UIImageView *visibleImageView;//当前可见的imageView


- (void)reloadImagesFromTargetScroll;
- (void)removeFullImageView;
- (id)initWithTarget:(UIScrollView *)aScrollView;
- (void)loadImagesFromUrls:(NSArray *)urlArr;

@end
