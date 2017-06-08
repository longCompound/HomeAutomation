//
//  ZGHeaderCell.m
//  ZgSafe
//
//  Created by Mark on 2017/5/25.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGHeaderCell.h"

@interface ZGHeaderCell () {
    
    __weak IBOutlet UIImageView *_bgImageView;
    __weak IBOutlet UILabel     *_titleLabel;
    
}

@end

@implementation ZGHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [ColorUtil getColor:@"#efefef" alpha:1];
    self.clipsToBounds = YES;
}

- (void)layoutSubviews
{
    _bgImageView.frame = CGRectMake(10, -2, self.width - 10 * 2, self.height + 3);
    _titleLabel.frame  = CGRectMake(20, 0, self.width - 20 * 2, self.height);
}

- (void)setModel:(ZGRowModel *)model
{
    _titleLabel.text = model.title;
    UIImage * image = [UIImage imageNamed:model.bgImageName];
    _bgImageView.image =  [image stretchableImageWithLeftCapWidth:0.5 * image.size.width  topCapHeight:0.9 * image.size.height];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
