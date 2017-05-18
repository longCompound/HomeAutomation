//
//  BBTemperatureLineView.h
//  ZgSafe
//
//  Created by box on 13-11-6.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#define START_X 20.
#define WIDTH 12.
#define GAP 15.

#import <UIKit/UIKit.h>

@interface BBTemperatureLineView : UIView

// 数据数组
@property (nonatomic, retain) NSArray *temperatureArr;
// 日期
@property (nonatomic, copy) NSString *dateStr;
// 开始时间
@property (nonatomic, copy) NSString *fromTime;
// 结束时间
@property (nonatomic, copy) NSString *toTime;
// 当前温度
@property (nonatomic, copy) NSString *curTemp; 

@end
