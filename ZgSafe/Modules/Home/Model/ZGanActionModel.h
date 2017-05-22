//
//  ZGanActionModel.h
//  ZgSafe
//
//  Created by Mark on 2017/5/19.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZGanActionModel : NSObject

@property (nonatomic, assign) NSUInteger type;

@property (nonatomic, copy) NSString * thumbImageName;

@property (nonatomic, copy) NSString * url;

@property (nonatomic, strong) NSDictionary * otherInfo;

+ (instancetype)modelWithType:(NSUInteger)type
                thumbImageName:(NSString *)thumbImageName
                           url:(NSString *)url
                     otherInfo:(NSDictionary*)otherInfo;

@end
