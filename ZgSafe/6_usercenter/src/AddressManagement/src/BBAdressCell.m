//
//  BBAdressCell.m
//  ZgSafe
//
//  Created by box on 13-10-31.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBAdressCell.h"

@implementation BBAdressCell

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
    [_selectIndicateImage release];
    [_adressTf release];
    [_deviceTf release];
    [super dealloc];
}

- (IBAction)onDeleteCell:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didClickDeleteButton:)]) {
        [_delegate didClickDeleteButton:self];
    }
} 

@end
