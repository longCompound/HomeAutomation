//
//  BBSideBarView.h
//  ZgSafe
//
//  Created by box on 13-10-29.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BBSideBarViewDelegate <NSObject>

@optional
- (void)didSelectedButtonAtIndex:(NSInteger)index;

@end

@interface BBSideBarView : UIView<UIGestureRecognizerDelegate>
{
}


@property (nonatomic,assign)UIView
*besideView;//侧边栏旁边的view
@property (nonatomic,assign)id<BBSideBarViewDelegate> delegate;

+ (id)siderBarWithBesideView:(UIView *)view;
- (void)show;
- (void)hide;
- (void)remove;

@end
