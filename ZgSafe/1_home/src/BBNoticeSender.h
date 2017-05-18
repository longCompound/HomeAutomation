//
//  BBNoticeSender.h
//  ZgSafe
//
//  Created by box on 14-1-11.
//  Copyright (c) 2014年 iXcoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBNoticeSender : UIWindow

@property (nonatomic,assign)BOOL showFullLine;//多行时显示所有行  为NO时显示1行  然后滚动显示其他行

+ (void)showNotice:(NSString *)notice;

@end