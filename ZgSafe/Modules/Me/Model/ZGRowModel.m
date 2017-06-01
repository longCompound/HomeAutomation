//
//  ZGRowModel.m
//  ZgSafe
//
//  Created by Mark on 2017/5/25.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGRowModel.h"

@implementation ZGRowModel

+ (instancetype)modelWithTitle:(NSString *)title
                   bgImageName:(NSString *)bgImageName
                       content:(NSString *)content
                      cellType:(ZGCellType)cellType
                      editable:(BOOL)editable
{
    ZGRowModel *model = [[ZGRowModel alloc] init];
    model.title = title;
    model.bgImageName = bgImageName;
    model.content = content;
    model.cellType = cellType;
    model.editable = editable;
    return model;
}

@end
