//
//  BBAlbumsCell.m
//  ZgSafe
//
//  Created by YANGReal on 13-10-28.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBAlbumsCell.h"

@implementation BBAlbumsCell

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
    [_time release];
    [_totalShe release]; 
    [_ImgView release]; 
    [_invadeLbl release]; 
    [_snapLbl release];
    [super dealloc];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject]locationInView:_ImgView];
    if (CGRectContainsPoint(_ImgView.bounds, point)) {
        if (_delegate && [_delegate respondsToSelector:@selector(didClickImageInCell:)]) {
            [_delegate didClickImageInCell:self];
        }
    }
}


@end
