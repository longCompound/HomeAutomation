//
//  ZGanCollectionViewCell.m
//  ZgSafe
//
//  Created by Mark on 2017/5/19.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGanCollectionViewCell.h"

@implementation ZGanCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.imageView];
    }
    return self;
}

- (void)layoutSubviews
{
    self.imageView.frame = CGRectMake(0.25, 0.25, CGRectGetWidth(self.frame)-0.5, CGRectGetHeight(self.frame)-0.5);
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.25, 0.25, CGRectGetWidth(self.frame)-0.5, CGRectGetHeight(self.frame)-0.5)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

@end
