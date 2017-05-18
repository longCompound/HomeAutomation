//
//  BBsigle.m
//  ZgSafe
//
//  Created by apple on 14-5-21.
//  Copyright (c) 2014年 iXcoder. All rights reserved.
//

#import "BBsigle.h"
static BBsigle *sigleInfoManager=nil;
@implementation BBsigle
+(BBsigle *)sigleManager{
@synchronized(self){
    if (sigleInfoManager==nil) {
        sigleInfoManager=[[BBsigle alloc]init];
        }

    }
    return sigleInfoManager;
}
@end
