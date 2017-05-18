//
//  BBRFIDCell.m
//  ZgSafe
//
//  Created by box on 13-10-30.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBRFIDCell.h"

@interface BBRFIDCell()

- (IBAction)onDeleteCell:(UIButton *)sender;

@end

@implementation BBRFIDCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_nameTf release];
    [_RFIDTf release];
    [_headImageView release];
    [super dealloc];
}

- (IBAction)onDeleteCell:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didClickDeleteButton:)]) {
        [_delegate didClickDeleteButton:self];
    }
}

@end
