//
//  UIImage+stretch.m
//  JiangbeiEPA
//
//  Created by iXcoder on 13-7-31.
//  Copyright (c) 2013年 Blue Box. All rights reserved.
//

#import "UIImage+stretch.h"

@implementation UIImage (stretch)

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
             resizingMode:(UIImageResizingMode)resizingMode
{
    UIImage *resultImage = nil;
    double systemVersion = [[UIDevice currentDevice].systemVersion doubleValue];
    if (systemVersion >= 6.0)
    {
        resultImage = [image resizableImageWithCapInsets:capInsets resizingMode:resizingMode];
    }
    else if (systemVersion >= 5.0)
    {
        resultImage = [image resizableImageWithCapInsets:capInsets];
    }
    else
    {
        CGFloat leftCapWidth = capInsets.left;
        CGFloat topCapHeight = capInsets.top;
        resultImage = [image stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
    }
    return resultImage;
}

- (UIImage*)imageRotatedByDegrees:(CGFloat)degrees
{
    
    CGFloat width = CGImageGetWidth(self.CGImage);
    CGFloat height = CGImageGetHeight(self.CGImage);
    
	CGSize rotatedSize;
    
    rotatedSize.width = width;
    rotatedSize.height = height;
    
	UIGraphicsBeginImageContext(rotatedSize);
	CGContextRef bitmap = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
	CGContextRotateCTM(bitmap, degrees * M_PI / 180);
	CGContextRotateCTM(bitmap, M_PI);
	CGContextScaleCTM(bitmap, -1.0, 1.0);
	CGContextDrawImage(bitmap, CGRectMake(-rotatedSize.width/2, -rotatedSize.height/2, rotatedSize.width, rotatedSize.height), self.CGImage);
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

@end
