//
//  ZGPoiPoint.m
//  ZgSafe
//
//  Created by Mark on 2017/6/15.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGPoiPoint.h"

@implementation ZGPoiPoint

- (instancetype)initWith:(BMKPoiInfo *)infoModel;
{
    if (self = [self init]) {
        _infoModel = infoModel;
        _title = _infoModel.name;
        _subtitle = _infoModel.address;
        _coordinate = _infoModel.pt;
    }
    return self;
}

@end
