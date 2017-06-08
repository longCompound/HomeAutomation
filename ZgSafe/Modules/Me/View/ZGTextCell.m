//
//  ZGTextCell.m
//  ZgSafe
//
//  Created by Mark on 2017/5/25.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGTextCell.h"

@interface ZGTextCell () {

    __weak IBOutlet UIImageView *_bgImageView;
    __weak IBOutlet UILabel     *_titleLabel;
    __weak IBOutlet UIImageView *_markIMageView;
    
}

@end

@implementation ZGTextCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [ColorUtil getColor:@"#efefef" alpha:1];
    self.clipsToBounds = YES;
}

- (void)layoutSubviews
{
    _bgImageView.frame = CGRectMake(10, -2, self.width - 10 * 2, self.height + 3);
     _markIMageView.frame = CGRectMake(_bgImageView.right - 24 - 5, (self.height - 24) / 2, 24, 24);
    _titleLabel.frame  = CGRectMake(20, 0, _markIMageView.left - 20  - 10, self.height);
}

- (void)setModel:(ZGRowModel *)model
{
    NSString * text = model.content.length > 0 ? model.content : @"";
    _titleLabel.text = [model.title stringByAppendingFormat:@" %@",text];
    UIImage * image = [UIImage imageNamed:model.bgImageName];
    _bgImageView.image =  [image stretchableImageWithLeftCapWidth:0.5 * image.size.width  topCapHeight:0.5 * image.size.height];
    _markIMageView.hidden = !model.editable;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
