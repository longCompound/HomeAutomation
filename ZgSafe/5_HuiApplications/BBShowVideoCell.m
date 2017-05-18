//
//  BBShowVideoCell.m
//  ZgSafe
//
//  Created by YANGReal on 13-10-29.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBShowVideoCell.h"

@implementation BBShowVideoCell

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
    [_appName1 release];
    [_appName2 release];
    [super dealloc];
}
@end
