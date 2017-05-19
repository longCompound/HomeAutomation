//
//  ColorUtil.m
//  aqgj_dial
//
//  Created by chenq on 11-12-21.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ColorUtil.h"

@implementation ColorUtil


+ (UIColor *)color:(NSInteger)color alpha:(CGFloat)alpha
{
    NSInteger red = (color & 0xFF0000) >> 16;
    NSInteger green = (color & 0xFF00) >> 8;
    NSInteger blue = (color & 0xFF);
    
    return [UIColor colorWithRed:red/255.0f
                           green:green/255.0f
                            blue:blue/255.0f
                           alpha:alpha];
}

+ (UIColor *)getColor:(NSString *)hexColor alpha:(CGFloat)alpha
{
    //防止crash
    if (hexColor.length < 6 ||
        ([hexColor hasPrefix:@"#"] && hexColor.length < 7)) {
      return [UIColor clearColor];
    }
    
    BOOL tf = [hexColor hasPrefix:@"#"];
    int offset = tf? 1:0;
    
	unsigned int red, green, blue;
	NSRange range;
	range.length = 2;
	
	range.location = 0+offset;
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
	range.location = 2+offset;
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
	range.location = 4+offset;
	[[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];	
	
	return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green/255.0f) blue:(float)(blue/255.0f) alpha:alpha];
}

UIColor *navigationColor = nil;
+ (void)setNavigationColor:(UIColor *)color
{

    navigationColor = color;
}

+ (UIColor *)getNavigationColor
{
    return navigationColor;
}

UIColor *backgroundColor = nil;
+ (void)setBackgroundColor:(UIColor *)color
{

    backgroundColor = color;
}

+ (UIColor *)getBackgroundColor
{
    return backgroundColor;
}

NSInteger  colorRow = 0;
+ (NSInteger)getColorRow
{
    return colorRow;
}

+ (void)setColorRow:(NSInteger)cRow
{
    NSString   *tempRow = [@(cRow) stringValue];
    [[NSUserDefaults standardUserDefaults] setObject:tempRow forKey:@"navigationColorRow"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    colorRow = cRow;
}

@end
