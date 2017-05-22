//
//  ZGDeviceModel.h
//  ZgSafe
//
//  Created by Mark on 2017/5/23.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZGDeviceModel : NSObject

@property (nonatomic, copy) NSString * title;

@property (nonatomic, copy) NSString * imagePath;

@property (nonatomic, copy) NSString * highLightImagePath;

@property (nonatomic, assign) BOOL state;

@property (nonatomic, assign) NSUInteger deviceType;

+ (instancetype)modelWithType:(NSUInteger)deviceType
                        title:(NSString *)title
                    imagePath:(NSString *)imagePath
           highLightImagePath:(NSString *)highLightImagePath
                        state:(BOOL)state;

@end
