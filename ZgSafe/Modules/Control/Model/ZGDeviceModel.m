//
//  ZGDeviceModel.m
//  ZgSafe
//
//  Created by Mark on 2017/5/23.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGDeviceModel.h"

@implementation ZGDeviceModel

+ (instancetype)modelWithType:(NSUInteger)deviceType
                        title:(NSString *)title
                    imagePath:(NSString *)imagePath
           highLightImagePath:(NSString *)highLightImagePath
                        state:(BOOL)state;
{
    ZGDeviceModel * model = [[ZGDeviceModel alloc] init];
    model.deviceType = deviceType;
    model.title = title;
    model.imagePath = imagePath;
    model.state = state;
    model.highLightImagePath = highLightImagePath;
    return model;
}

@end
