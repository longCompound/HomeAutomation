//
//  UIAlertView+Block.m
//  UBoxOnline
//
//  Created by whoslie on 13-5-5.
//  Copyright (c) 2013年 ubox. All rights reserved.
//

#import "UIAlertView+Block.h"
#import <objc/runtime.h>

@implementation UIAlertView(Block)

static char key;

// 用Block的方式回调，这时候会默认用self作为Delegate
- (void)showWithCompleteBlock:(void(^)(NSInteger btnIndex))block {
    if (block) {
        objc_removeAssociatedObjects(self);
        objc_setAssociatedObject(self, &key, block, OBJC_ASSOCIATION_COPY);
        self.delegate = self;
    }
    [self show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    void(^completeBlock)(NSInteger btnIndex) = objc_getAssociatedObject(self, &key);
    if (completeBlock) {
        completeBlock(buttonIndex);
    }
}

@end
