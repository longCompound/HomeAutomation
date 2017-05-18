//
//  BBRootViewController.h
//  JiangbeiEPA
//
//  Created by iXcoder on 13-9-16.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBRootViewController : UIViewController

// 是否允许自动旋转(默认为NO)
@property (nonatomic, assign, getter=isAutoRotate) BOOL autoRotate;

// 默认界面方向(默认为UIInterfaceOrientationPortrait)
@property (nonatomic, assign) UIInterfaceOrientation defaultOrientation;

@end
