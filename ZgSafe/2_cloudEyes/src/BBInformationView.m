//
//  BBInformationView.m
//  ZgSafe
//
//  Created by box on 13-10-25.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBInformationView.h"

@implementation BBInformationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
