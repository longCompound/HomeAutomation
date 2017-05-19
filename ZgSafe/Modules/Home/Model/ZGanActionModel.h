//
//  ZGanActionModel.h
//  ZgSafe
//
//  Created by Mark on 2017/5/19.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZGanActionModel : NSObject

@property (nonatomic, copy) NSString * title;

@property (nonatomic, copy) NSString * thumbImageName;

@property (nonatomic, copy) NSString * url;

@property (nonatomic, strong) NSDictionary * otherInfo;

@end
