//
//  BBInOutAndSafeRecoredCell.m
//  ZgSafe
//
//  Created by box on 13-10-28.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBInOutAndSafeRecoredCell.h"

@implementation BBInOutAndSafeRecoredCell

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
    [_headImage release];
    [_stateImage release];
    [_stateName release];
    [_name release];
    [_tel release];
    [_time release];
    [_date release];
    [super dealloc];
}
@end
