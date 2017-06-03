//
//  ZGRowModel.h
//  ZgSafe
//
//  Created by Mark on 2017/5/25.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

typedef NS_ENUM(NSUInteger, ZGCellType) {
    ZGCellType_TitleCell = 1,
    ZGCellType_TextCell  = 2,
    ZGCellType_ContentCell = 3,
};

#import <Foundation/Foundation.h>

@interface ZGRowModel : NSObject

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * bgImageName;
@property (nonatomic, assign) ZGCellType cellType;
@property (nonatomic, copy) NSString * content;
@property (nonatomic, assign) BOOL  editable;

+ (instancetype)modelWithTitle:(NSString *)title
                   bgImageName:(NSString *)bgImageName
                       content:(NSString *)content
                      cellType:(ZGCellType)cellType
                      editable:(BOOL)editable;

@end
