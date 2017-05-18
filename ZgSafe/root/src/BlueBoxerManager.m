//
//  BlueBoxer.m
//  JiangbeiEPA
//
//  Created by iXcoder on 13-9-6.
//  Copyright (c) 2013年 bulebox. All rights reserved.
//

#import "BlueBoxerManager.h"
#import <objc/runtime.h>

static BlueBoxer *sysUser = nil;

@implementation BlueBoxer

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    Class cls = [self class];
    uint count = 0;
    objc_property_t *properties = class_copyPropertyList(cls, &count);
    for (int i = 0; i < count; i++) {
        const char *key = property_getName(properties[i]);
        NSString *keyName = [NSString stringWithUTF8String:key];
        NSString *value = [self valueForKeyPath:keyName];
        [aCoder encodeObject:value forKey:keyName];
        keyName = nil;
        value = nil;
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        Class cls = [self class];
        uint proCount = 0;
        objc_property_t *properties = class_copyPropertyList(cls, &proCount);
        for (int i = 0; i < proCount; i++) {
            const char *key = property_getName(properties[i]);
            NSString *keyName = [NSString stringWithUTF8String:key];
            if ([aDecoder containsValueForKey:keyName]) {
                id value = [aDecoder decodeObjectForKey:keyName];
                [self setValue:value forKeyPath:keyName];
            }
        }
    }
    return self;
}

@end


@implementation BlueBoxerManager

/*!
 *@brief        储存当前用户信息
 *@function     archiveCurrentUser:
 *@param        currentUser
 *@return       (void)
 */
+ (void)archiveCurrentUser:(BlueBoxer *)currentUser
{
    sysUser = currentUser;
    NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:sysUser];
    [[NSUserDefaults standardUserDefaults] setObject:userData forKey:USER_KEY];
    [[NSUserDefaults standardUserDefaults]synchronize];
    return;
}

/*!
 *@brief        获取当前用户信息
 *@function     getCurrentUser
 *@param        (void)
 *@return       (void)
 */
+ (BlueBoxer *)getCurrentUser
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:USER_KEY];
    if (data != nil) {
        sysUser = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        sysUser.firstLogOnDevice = NO;
    } else {
        sysUser = [[[BlueBoxer alloc] init] autorelease];
        sysUser.firstLogOnDevice = YES;
    }
    return sysUser;
}

@end