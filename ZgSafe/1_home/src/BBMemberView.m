//
//  BBMemberView.m
//  ZgSafe
//
//  Created by iXcoder on 13-10-24.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBMemberView.h"

@interface BBMemberView()
 

@property (nonatomic, retain) IBOutlet UIImageView *online;

@property (nonatomic, retain) IBOutlet UILabel *nameLbl;

@end

@implementation BBMemberView

- (void)dealloc
{
    [_photo release];
    [_online release];
    [_nameLbl release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.nameLbl.text = self.name;
    if (self.isOnline) {
        self.photo.image = [UIImage imageNamed:@"male_on.png"];
    } else {
        self.photo.image = [UIImage imageNamed:@"male_off.png"];
    }
    
    
}

@end
