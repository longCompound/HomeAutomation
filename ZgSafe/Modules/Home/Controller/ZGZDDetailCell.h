//
//  ZGZDDetailCell.h
//  ZgSafe
//
//  Created by Mark on 2017/6/16.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZGZDDetailCell : UITableViewCell

@property (nonatomic, strong) NSDictionary * infoDic;

+ (CGFloat)caculateHeight:(NSDictionary *)infoDic;

@end
