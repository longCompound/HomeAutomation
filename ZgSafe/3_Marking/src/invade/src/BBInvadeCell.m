//
//  BBInvadeCell.m
//  ZgSafe
//
//  Created by box on 13-10-31.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBInvadeCell.h"

@implementation BBInvadeCell

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
    [_dateLbl release];
    [_timeLbl release];
    [_imgView release];
    [super dealloc];
}
@end
