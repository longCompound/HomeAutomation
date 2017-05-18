//
//  BBUncaughtExceptionHandler.h
//  ZgSafe
//
//  Created by iXcoder on 14-1-13.
//  Copyright (c) 2014年 iXcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UncaughtExceptionDelegate <NSObject>

@required
- (void)didIgnoredSignal:(int)sig;

@end

@interface BBUncaughtExceptionHandler : NSObject

+ (void)regHandler:(id<UncaughtExceptionDelegate>)handler forSignal:(int)signal;

@end
