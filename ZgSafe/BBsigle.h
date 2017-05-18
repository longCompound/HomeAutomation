//
//  BBsigle.h
//  ZgSafe
//
//  Created by apple on 14-5-21.
//  Copyright (c) 2014年 iXcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBsigle : NSObject
+(BBsigle *)sigleManager;
@property(nonatomic,retain) UINavigationController *lNavigation;

@end
