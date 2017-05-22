//
//  ZGanActionModel.m
//  ZgSafe
//
//  Created by Mark on 2017/5/19.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGanActionModel.h"

@implementation ZGanActionModel

+ (instancetype)modelWithType:(NSUInteger)type
               thumbImageName:(NSString *)thumbImageName
                          url:(NSString *)url
                    otherInfo:(NSDictionary*)otherInfo
{
    ZGanActionModel * model = [[ZGanActionModel alloc] init];
    model.type = type;
    model.thumbImageName = thumbImageName;
    model.url = url;
    model.otherInfo = otherInfo;
    return model;
}

@end
