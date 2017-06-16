//
//  ZGDatePicker.m
//  ZgSafe
//
//  Created by Mark on 2017/6/16.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGDatePicker.h"

@interface ZGDatePicker () <UIPickerViewDelegate,UIPickerViewDataSource> {
    UIPickerView  *_picker;
    NSMutableArray * _yearArray;
    NSArray        * _monthArray;
}

@property (nonatomic, assign) NSUInteger minYear;
@property (nonatomic, assign) NSUInteger maxYear;
@property (nonatomic, strong) NSDate * date;


@end

@implementation ZGDatePicker

- (instancetype)initWithFrame:(CGRect)frame
                      minYear:(NSUInteger)minYear
                      maxYear:(NSUInteger)maxYear
                         date:(NSDate *)date
{
    if (self = [self initWithFrame:frame]) {
        self.date = date;
        self.minYear = minYear;
        self.maxYear = maxYear;
        _yearArray = [NSMutableArray array];
        for (NSUInteger i = minYear; i<=maxYear ;i++) {
            [_yearArray addObject:@(i).stringValue];
        }
        _monthArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12"];
        [_picker reloadAllComponents];
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale currentLocale];
        formatter.dateFormat = @"yyyy-M";
        NSString * str = [formatter stringFromDate:date];
        NSArray * temp = [str componentsSeparatedByString:@"-"];
        NSString * year = [temp firstObject];
        NSString * month = [temp lastObject];
        [_picker selectRow:[_yearArray indexOfObject:year] inComponent:0 animated:NO];
        [_picker selectRow:[_monthArray indexOfObject:month] inComponent:1 animated:NO];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _picker = [[UIPickerView alloc] initWithFrame:self.bounds];
        _picker.dataSource = self;
        _picker.delegate = self;
        [self addSubview:_picker];
    }
    return self;
}

- (NSString *)selectedYearMonthString
{
    NSString * year = _yearArray[[_picker selectedRowInComponent:0]];
    NSString * month = _monthArray[[_picker selectedRowInComponent:1]];
    return [year stringByAppendingFormat:@"%@%@",(month.integerValue > 9 ? @"" : @"0"),month];
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return _yearArray.count;
    } else if (component == 1) {
        return _monthArray.count;
    }
    return 0;
}

// returns width of column and height of row for each component.
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return self.width/2;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 44;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        return [_yearArray[row] stringByAppendingString:@"年"];
    } else if (component == 1) {
        return [_monthArray[row] stringByAppendingString:@"月"];
    }
    return @"";
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width/2, 44)];
    label.backgroundColor = [UIColor whiteColor];
    label.textColor = [UIColor darkGrayColor];
    label.textAlignment = NSTextAlignmentCenter;
    if (component == 0) {
        label.text = [_yearArray[row] stringByAppendingString:@"年"];
    } else if (component == 1) {
        label.text = [_monthArray[row] stringByAppendingString:@"月"];
    }
    return label;
}

@end
