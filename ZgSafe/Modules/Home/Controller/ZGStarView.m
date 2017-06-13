//
//  ZGStarView.m
//  ZgSafe
//
//  Created by Mark on 2017/6/14.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGStarView.h"

@interface ZGStarView () {
    IBOutletCollection(UIImageView) NSArray *_starImageArray;
}

@end

@implementation ZGStarView

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_starImageArray enumerateObjectsUsingBlock:^(UIImageView * obj, NSUInteger idx, BOOL * stop) {
        obj.frame = CGRectMake(self.height * idx, 0, self.height, self.height);
    }];
}

- (void)setStar:(NSUInteger)star
{
    _star = star;
    [_starImageArray enumerateObjectsUsingBlock:^(UIImageView * obj, NSUInteger idx, BOOL * stop) {
            obj.highlighted = (idx <= _star-1);
    }];
}

@end
