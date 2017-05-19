//
//  UIButton+EnlargeEdge.h
//  FaciShare
//
//  Created by mark on 15/4/23.
//  Copyright (c) 2015年 facishare. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (EnlargeEdge)

- (void)setEnlargeEdge:(CGFloat) size;
- (void)setEnlargeEdgeWithTop:(CGFloat) top right:(CGFloat) right bottom:(CGFloat) bottom left:(CGFloat) left;

@end
