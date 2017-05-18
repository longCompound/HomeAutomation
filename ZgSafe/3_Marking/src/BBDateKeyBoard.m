//
//  BBDateKeyBoard.m
//  ZgSafe
//
//  Created by box on 13-11-1.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBDateKeyBoard.h"

@implementation BBDateKeyBoard

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _inputTarget = nil;
    }
  
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [_datePicker release];
    [super dealloc];
}


- (IBAction)onCancel:(UIButton *)sender {
    if ([_inputTarget respondsToSelector:@selector(resignFirstResponder)]) {
        [_inputTarget resignFirstResponder];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(dateKeyboardDidCanceled:)]) {
        [_delegate dateKeyboardDidCanceled:self];
    }
}

- (IBAction)onSelectDate:(UIButton *)sender {
    if ([_inputTarget respondsToSelector:@selector(setText:)]) {
        NSDateFormatter *fmt = [[NSDateFormatter alloc]init];
        [fmt setDateFormat:@"yyyy/MM/dd"];
        NSString *dateStr = [fmt stringFromDate:_datePicker.date];
        [_inputTarget setText:dateStr];
        [fmt release];
    }
    if ([_inputTarget respondsToSelector:@selector(resignFirstResponder)]) {
        [_inputTarget resignFirstResponder];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(dateKeyboardDidSelected:)]) {
        [_delegate dateKeyboardDidSelected:self];
    }
    
}
@end
