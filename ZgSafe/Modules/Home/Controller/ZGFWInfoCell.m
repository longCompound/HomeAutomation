//
//  ZGFWInfoCell.m
//  ZgSafe
//
//  Created by Mark on 2017/6/13.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGFWInfoCell.h"
#import "ZGStarView.h"

@interface ZGFWInfoCell () {
    __weak IBOutlet UIImageView *_bgImgView;
    __weak IBOutlet UIImageView *_nameImgView;
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UIImageView *_phoneImgView;
    __weak IBOutlet UILabel *_phoneLabel;
    __weak IBOutlet UIImageView *_addressImgView;
    __weak IBOutlet UILabel *_addressLabel;
    __weak IBOutlet UIImageView *_priseImgView;
     ZGStarView                 *_starView;
    __weak IBOutlet UIView *_sep1;
    __weak IBOutlet UIView *_sep2;
    __weak IBOutlet UIView *_sep3;
}

@end

@implementation ZGFWInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _starView = [[[NSBundle mainBundle] loadNibNamed:@"ZGStarView" owner:nil options:nil] lastObject];
    [self.contentView addSubview:_starView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self refreshDisplay];
}

- (void)refreshDisplay
{
    CGFloat bgTop = 10;
    CGFloat bgStart = 10;
    CGFloat startX = 20;
    CGFloat imgSize = 36;
    _bgImgView.frame = CGRectMake(bgStart, bgTop, self.width - 2 * bgStart, self.height - 2 * 10);
    CGFloat edge = (_bgImgView.height - 4 * imgSize) / 8;
    _sep1.frame = CGRectMake(bgStart + 4,bgTop + 1 * _bgImgView.height / 4, _bgImgView.width - 8, 0.5);
    _sep2.frame = CGRectMake(_sep1.left,bgTop + 2 * _bgImgView.height / 4, _sep1.width, 0.5);
    _sep3.frame = CGRectMake(_sep1.left,bgTop + 3 * _bgImgView.height / 4, _sep1.width, 0.5);
    
    _nameImgView.frame = CGRectMake(startX,bgTop + edge + 0 * (2 * edge + imgSize), imgSize, imgSize);
    _nameLabel.frame = CGRectMake(_nameImgView.right + 5,_nameImgView.top, self.width  - bgStart - _nameImgView.right - 20 , imgSize);
    _phoneImgView.frame = CGRectMake(startX,bgTop + edge + 1 * (2 * edge + imgSize), imgSize, imgSize);
    _phoneLabel.frame = CGRectMake(_phoneImgView.right + 5,_phoneImgView.top, self.width  - bgStart - _phoneImgView.right - 20 , imgSize);;
    _addressImgView.frame = CGRectMake(startX,bgTop + edge + 2 * (2 * edge + imgSize), imgSize, imgSize);
    _addressLabel.frame = CGRectMake(_addressImgView.right + 5,_addressImgView.top, self.width  - bgStart - _addressImgView.right - 20 , imgSize);;
    _priseImgView.frame = CGRectMake(startX,bgTop + edge + 3 * (2 * edge + imgSize), imgSize, imgSize);
    _starView.frame = CGRectMake(_priseImgView.right + 5,_priseImgView.top + 8, (imgSize - 16) * 5, imgSize - 16);
}

- (void)setInfoDic:(NSDictionary *)infoDic
{
    _infoDic = infoDic;
    _nameLabel.text = _infoDic[@"name"];
    _phoneLabel.text = _infoDic[@"addr"];
    _addressLabel.text = _infoDic[@"tel"];
    _starView.star = 4;
    [self refreshDisplay];
}

@end
