//
//  ZGWebViewCell.m
//  ZgSafe
//
//  Created by Mark on 2017/6/14.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGWebViewCell.h"

@interface ZGWebViewCell () <UIWebViewDelegate> {
    
}

@end

@implementation ZGWebViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _webView.scalesPageToFit = NO;
    _webView.scrollView.scrollEnabled = NO;
    // Initialization code
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _webView.frame = CGRectMake(5, 0, self.width-10, self.height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
