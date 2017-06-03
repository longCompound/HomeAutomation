//
//  UIAlertView+Block.h
//  UBoxOnline
//
//  Created by whoslie on 13-5-5.
//  Copyright (c) 2013年 ubox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView(Block)

// 用Block的方式回调，这时候会默认用self作为Delegate
- (void)showWithCompleteBlock:(void(^)(NSInteger btnIndex))block;

@end
