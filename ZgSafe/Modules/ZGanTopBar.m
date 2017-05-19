//
//  ZGanTopBar.m
//  ZgSafe
//
//  Created by Mark on 2017/5/19.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGanTopBar.h"
#import "ColorUtil.h"
#import "UIButton+EnlargeEdge.h"


@interface ZGanTopBar ()


@end

@implementation ZGanTopBar

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = [ColorUtil getColor:@"3C394B"alpha:1.0];
    self.userInteractionEnabled = YES;
}

- (void)setHiddenLeftBtn:(BOOL)hiddenLeftBtn
{
    _leftButton.hidden = hiddenLeftBtn;
    _traceTitleLabel.hidden = hiddenLeftBtn;
}

- (IBAction)leftButtonClick:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(touchTopBarLeftButton:)]) {
        [_delegate touchTopBarLeftButton:self];
    }
}

- (IBAction)rightButtonClick:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(touchTopBarRightButton:)]) {
        [_delegate touchTopBarRightButton:self];
    }
}

- (void)setupBackTrace:(NSString *)trace
                 title:(NSString *)title
      rightActionTitle:(NSString *)actionTitle
{
    _titleLabel.text = title;
    _traceTitleLabel.text = trace;
    [_rightButton setTitle:actionTitle forState:UIControlStateNormal];
    [_leftButton setEnlargeEdgeWithTop:0 right:60 bottom:0 left:0];
    _rightButton.hidden = !(actionTitle.length > 0);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    _bgImageView.frame = self.bounds;
    _titleLabel.frame = CGRectMake((width-200)/2, height-44, 200, 44);
    _rightButton.frame = CGRectMake(width-60, height-44, 60, 44);
    _leftButton.frame = CGRectMake(0, height-44, 44, 44);
    _traceTitleLabel.frame = CGRectMake(44,height-44, 60, 44);
}

@end
