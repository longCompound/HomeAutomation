//
//  ColorUtil.h
//
//  Created by chenq on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorUtil : NSObject

+ (UIColor *)getColor:(NSString *)hexColor alpha:(CGFloat)alpha;

+ (void)setNavigationColor:(UIColor *)color;
+ (UIColor *)getNavigationColor;

+ (void)setBackgroundColor:(UIColor *)color;
+ (UIColor *)getBackgroundColor;
+ (NSInteger)getColorRow;
+ (void)setColorRow:(NSInteger)cRow;
+ (UIColor *)color:(NSInteger)color alpha:(CGFloat)alpha;

@end
