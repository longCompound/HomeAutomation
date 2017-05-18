//
//  BBWarningRecordCell.m
//  ZgSafe
//
//  Created by box on 13-10-29.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBWarningRecordCell.h"

@implementation BBWarningRecordCell

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
    [_backGroundImage release];
    [_infoLable release];
    [_temperatureLable release];
    [_timeLable release];
    [super dealloc];
}
@end
