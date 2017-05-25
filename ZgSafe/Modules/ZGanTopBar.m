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
    self.backgroundColor = [ColorUtil getColor:@"3C394B" alpha:1.0];
    self.userInteractionEnabled = YES;
}

- (void)setHidesLeftBtn:(BOOL)hidesLeftBtn
{
    _hidesLeftBtn = hidesLeftBtn;
    _leftButton.hidden = hidesLeftBtn;
    _traceTitleLabel.hidden = hidesLeftBtn;
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
    [self resetRightBtnFrame];
}

- (void)setupBackTrace:(NSString *)trace
                 title:(NSString *)title
      rightActionImage:(NSString *)rightActionImage
{
    _titleLabel.text = title;
    _traceTitleLabel.text = trace;
    [_rightButton setImage:[UIImage imageNamed:rightActionImage] forState:UIControlStateNormal];
    [_leftButton setEnlargeEdgeWithTop:0 right:60 bottom:0 left:0];
    _rightButton.hidden = !(rightActionImage.length > 0);
    [self resetRightBtnFrame];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    _bgImageView.frame = self.bounds;
    _titleLabel.frame = CGRectMake((width-200)/2, height-44, 200, 44);
    [self resetRightBtnFrame];
    _leftButton.frame = CGRectMake(0, height-44, 44, 44);
    _traceTitleLabel.frame = CGRectMake(35,height-44, 60, 44);
}

- (void)resetRightBtnFrame
{
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    UIImage *image = _rightButton.imageView.image;
    if (!image) {
        _rightButton.frame = CGRectMake(width-44, height-44, 44, 44);
    } else {
        CGFloat h = 36;
        CGFloat w = image.size.height != 0 ? h * image.size.width / MAX(image.size.height, 1) : h;
        _rightButton.frame = CGRectMake(width-w-5, height-(44-h)/2-h, w, h);
    }
}

@end
