//
//  BBDateKeyBoard.h
//  ZgSafe
//
//  Created by box on 13-11-1.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBDateKeyBoard;
@protocol BBDateKeyBoardDelegate <NSObject>

@optional
//!在日期键盘上点击了确定
- (void)dateKeyboardDidSelected:(BBDateKeyBoard *)keboard;
//!在日期键盘上点击了取消
- (void)dateKeyboardDidCanceled:(BBDateKeyBoard *)keboard;

@end


@interface BBDateKeyBoard : UIView

@property (nonatomic,assign)id<BBDateKeyBoardDelegate>delegate;
@property (nonatomic,assign)id inputTarget;//输入目标（如textfield、textView）
@property (retain, nonatomic) IBOutlet UIDatePicker *datePicker;

- (IBAction)onCancel:(UIButton *)sender;
- (IBAction)onSelectDate:(UIButton *)sender;

@end