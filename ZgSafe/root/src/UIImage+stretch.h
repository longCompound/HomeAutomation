//
//  UIImage+stretch.h
//  JiangbeiEPA
//
//  Created by iXcoder on 13-7-31.
//  Copyright (c) 2013年 Blue Box. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (stretch)

/*!
 *@brief        图片拉升重复
 *@function     stretchImage:withLeftCapWidth:topCapHeight:capInsets:resizingMode:
 *@param        image               -- 要拉升的图片
 *@param        capInsets           -- 四周边距
 *@param        resizingMode        -- 改变方式
 *@return       (UIImage)
 */
+ (UIImage *)stretchImage:(UIImage *)image
         withCapInsets:(UIEdgeInsets)capInsets
             resizingMode:(UIImageResizingMode)resizingMode;

- (UIImage*)imageRotatedByDegrees:(CGFloat)degrees;

@end
