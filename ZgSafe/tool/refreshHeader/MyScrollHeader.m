//
//  MyScrollHeader.m
//  TestScroll
//
//  Created by iXcoder on 13-8-17.
//  Copyright (c) 2013年 BB. All rights reserved.
//

#import "MyScrollHeader.h"

@interface MyScrollHeader ()
{
    UIActivityIndicatorView *_indicator;
    UILabel *_statusLabel;
    BOOL isLoading;
}

@end

@implementation MyScrollHeader

- (void)dealloc
{
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

///*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
    isLoading = NO;
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:self.style];
    _indicator.frame = CGRectMake(75, self.frame.size.height - 30, 30, 30);
    
    _indicator.hidesWhenStopped = NO;
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2 - 30
                                                             , self.frame.size.height - 30
                                                             , self.frame.size.width - 100
                                                             , 30)];
    _statusLabel.backgroundColor = [UIColor clearColor];
    _statusLabel.textColor = [UIColor whiteColor];
    if (self.style == UIActivityIndicatorViewStyleGray) {
        _statusLabel.textColor = [UIColor grayColor];
    }
    _statusLabel.font = [UIFont systemFontOfSize:13];
    _statusLabel.text = @"下拉即可刷新...";
    if (self.descs != nil && [self.descs count] > 0) {
        _statusLabel.text = [self.descs objectAtIndex:0];
    }
    [self addSubview:_indicator];
    [self addSubview:_statusLabel];
    
}
//*/

- (void)didScrollViewScrolled
{
    
    if (_scroll.contentOffset.y < -70 && _scroll.isDragging) {
        _statusLabel.text = @"释放立刻刷新...";
        if (self.descs != nil && [self.descs count] > 1) {
            _statusLabel.text = [self.descs objectAtIndex:1];
        }
        [_indicator stopAnimating];
    } else if (_scroll.contentOffset.y > -70 && _scroll.contentOffset.y < 0 && _scroll.isDragging) {
        _statusLabel.text = @"下拉即可刷新...";
        if (self.descs != nil && [self.descs count] > 0) {
            _statusLabel.text = [self.descs objectAtIndex:0];
        }
        [_indicator stopAnimating];
    }
}

- (void)didEndDragOnScrollView
{
    if (_scroll.contentOffset.y < -70 && !isLoading) {
        self.scroll.userInteractionEnabled = NO;
        _statusLabel.text = @"正在刷新...";
        if (self.descs != nil && [self.descs count] > 2) {
            _statusLabel.text = [self.descs objectAtIndex:2];
        }
        [_indicator startAnimating];
        [UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		self.scroll.contentInset = UIEdgeInsetsMake(50.0f, self.scroll.contentInset.left, self.scroll.contentInset.bottom, self.scroll.contentInset.right);
		[UIView commitAnimations];
        if (self.delegate && [self.delegate respondsToSelector:@selector(needsDataSourceRefresh)]) {
            isLoading = YES;
            [self.delegate performSelector:@selector(needsDataSourceRefresh)];
            
        }
    } else {
        [UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		self.scroll.contentInset = UIEdgeInsetsMake(0.0f, self.scroll.contentInset.left, self.scroll.contentInset.bottom, self.scroll.contentInset.right);
		[UIView commitAnimations];
    }
}

- (void)didEndDataSourceRefresh
{
    self.scroll.userInteractionEnabled = YES;
    _statusLabel.text = @"下拉即可刷新...";
    if (self.descs != nil && [self.descs count] > 0) {
        _statusLabel.text = [self.descs objectAtIndex:0];
    }
    [_indicator stopAnimating];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    self.scroll.contentInset = UIEdgeInsetsMake(0.0, self.scroll.contentInset.left, self.scroll.contentInset.bottom, self.scroll.contentInset.right);
    [UIView commitAnimations];
    isLoading = NO;
}

@end
