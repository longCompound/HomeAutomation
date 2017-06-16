//
//  ZGDatePicker.h
//  ZgSafe
//
//  Created by Mark on 2017/6/16.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZGDatePicker : UIView

- (instancetype)initWithFrame:(CGRect)frame
                      minYear:(NSUInteger)minYear
                      maxYear:(NSUInteger)maxYear
                         date:(NSDate *)date;

- (NSString *)selectedYearMonthString;

@end
