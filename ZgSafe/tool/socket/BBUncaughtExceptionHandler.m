//
//  BBUncaughtExceptionHandler.m
//  ZgSafe
//
//  Created by iXcoder on 14-1-13.
//  Copyright (c) 2014年 iXcoder. All rights reserved.
//

#import "BBUncaughtExceptionHandler.h"
#import <sys/signal.h>

static NSMutableArray *ignoredSigs ;

static void MySignalHandler(int signal)
{
    for (NSDictionary *item in ignoredSigs) {
        int sign = [[item objectForKey:@"signal"] intValue];
        if (sign == signal) {
            id<UncaughtExceptionDelegate> handler = [item objectForKey:@"handler"];
            if (handler != nil
                && [handler conformsToProtocol:@protocol(UncaughtExceptionDelegate)]) {
                [handler didIgnoredSignal:sign];
                break;
            }
        }
    }
}

@implementation BBUncaughtExceptionHandler

+ (void)regHandler:(id)handler forSignal:(int)sign
{
    if (ignoredSigs == nil) {
        ignoredSigs = [[NSMutableArray alloc] init];
    }
    NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys:handler,@"handler", @(sign), @"signal", nil];
    [ignoredSigs addObject:item];
    struct sigaction sa;
    sa.sa_handler = MySignalHandler;
    sigaction(SIGPIPE, &sa, 0);
//    signal(sign, MySignalHandler);
}

@end



