//
//  ZGanCollectionViewCell.m
//  ZgSafe
//
//  Created by Mark on 2017/5/19.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGanCollectionViewCell.h"

@interface ZGanCollectionViewCell () {
    UIButton              *_actionButton;
}

@property (nonatomic, assign) CGFloat topEdge;

@property (nonatomic, assign) CGFloat bottomEdge;

@end

@implementation ZGanCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createUI];
    }
    return self;
}

- (void)createUI
{
    _topEdge = 5;
    _bottomEdge = 5;
    [self addSubview:({
        _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _actionButton.frame = CGRectMake(5, _topEdge, self.bounds.size.width - 10, self.bounds.size.height - _topEdge - _bottomEdge);
        [_actionButton addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
        _actionButton;
    })];
}

- (void)setActionInfo:(ZGanActionModel *)actionInfo
{
    _actionInfo = actionInfo;
    [_actionButton setImage:[[UIImage imageNamed:actionInfo.thumbImageName] imageByScalingToSize:CGSizeMake(70, 89)] forState:UIControlStateNormal];
}

- (void)setBottomEdge:(CGFloat)bottomEdge topEdge:(CGFloat)topEdge
{
    _topEdge = topEdge;
    _bottomEdge = bottomEdge;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    _actionButton.frame = CGRectMake(5, _topEdge, self.bounds.size.width - 10, self.bounds.size.height - _topEdge - _bottomEdge);
}

-(void)click
{
    if (_delegate && [_delegate respondsToSelector:@selector(cellClickWithInfo:)]) {
        [_delegate cellClickWithInfo:_actionInfo];
    }
}

//- (void)setButtonImageAndTitleWithSpace:(CGFloat)spacing WithButton:(UIButton *)btn{
//    CGSize imageSize = btn.imageView.frame.size;
//    CGSize titleSize = btn.titleLabel.frame.size;
//    CGSize textSize = [btn.titleLabel.text sizeWithFont:btn.titleLabel.font];
//    CGSize frameSize = CGSizeMake(ceilf(textSize.width), ceilf(textSize.height));
//    if (titleSize.width + 0.5 < frameSize.width) {
//        titleSize.width = frameSize.width;
//    }
//    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
//    btn.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
//    btn.titleEdgeInsets = UIEdgeInsetsMake(0, - imageSize.width, - (totalHeight - titleSize.height), 0);
//    
//}

@end
