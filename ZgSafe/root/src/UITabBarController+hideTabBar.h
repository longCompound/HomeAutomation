//
//  UITabBarController+hideTabBar.h
//  JiangbeiEPA
//
//  Created by iXcoder on 13-7-24.
//  Copyright (c) 2013年 Blue Box. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBarController (hideTabBar)

@property (nonatomic, getter=isTabBarHidden) BOOL tabBarHidden;

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;

@end
