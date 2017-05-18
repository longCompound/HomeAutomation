//
//  BBPageControl.m
//  BackgroundOperation
//
//  Created by iXcoder on 13-12-18.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#define POINT_RADIUS    3.
#define POINT_GAP       6.

#import "BBPageControl.h"

@interface BBPageControl ()
{
    CGPoint startPoint;
}

@end

@implementation BBPageControl

- (id)initWithFrame:(CGRect)frame
{
    CGRect rect = frame;
    if (rect.size.height < POINT_RADIUS * 2. + 4.) {
        rect.size.height = POINT_RADIUS * 2. + 4.;
    }
    self = [super initWithFrame:rect];
    if (self) {
        // Initialization code
        _alignment = kBBIndicatorAlignmentCenter;
    }
    return self;
}

//*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, self.bounds);
    
    [[UIColor whiteColor] set];
    for (int i = 0; i < self.numberOfPages; i++) {
        CGPoint center0 = [self centerAtIndex:i withAlignment:_alignment];;
        CGRect frame = CGRectMake(center0.x - POINT_RADIUS
                                  , center0.y - POINT_RADIUS
                                  , POINT_RADIUS * 2
                                  , POINT_RADIUS * 2);
        UIColor *color = nil;
        if (i == self.currentPage) {
            color = self.selectedColor != nil ? self.selectedColor : [UIColor lightGrayColor];
        } else {
            color = self.otherColor != nil ? self.otherColor : [UIColor redColor];
        }
        context = UIGraphicsGetCurrentContext();
        CGContextAddEllipseInRect(context, frame);
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillEllipseInRect(context, frame);
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextStrokePath(context);
    }
}
//*/

- (void)setCurrentPage:(NSUInteger)currentPage
{
    if (currentPage == _currentPage) {
        return;
    }
    _currentPage = currentPage;
    [self setNeedsDisplay];
}

- (void)setAlignment:(BBIndicatorAlignment)alignment
{
    _alignment = alignment;
    CGPoint center = CGPointMake(self.frame.size.width / 2., self.frame.size.height / 2.);
    switch (_alignment) {
        case kBBIndicatorAlignmentCenter:
        {
            CGFloat xOffsetCenter = (self.numberOfPages - 1) * POINT_RADIUS + (self.numberOfPages - 1) / 2.0 * POINT_GAP;
            startPoint = CGPointMake(center.x - xOffsetCenter, center.y);
            break;
        }
        case kBBIndicatorAlignmentLeft:
        {
            startPoint = CGPointMake(POINT_GAP*2, center.y);
            break;
        }
        case kBBIndicatorAlignmentRight:
        {
            startPoint = CGPointMake(self.frame.size.width - self.numberOfPages * (POINT_GAP + POINT_RADIUS * 2)
                                     , self.frame.size.height / 2.0);
        }
        default:
            break;
    }
}

- (CGPoint)centerAtIndex:(NSUInteger)index withAlignment:(BBIndicatorAlignment)alignment
{
    CGPoint point = CGPointZero;
    point = CGPointMake(startPoint.x + index * (POINT_RADIUS * 2 + POINT_GAP)
                        , startPoint.y);
//    if (alignment == kBBIndicatorAlignmentCenter) {
//        point = CGPointMake(startPoint.x + index * (POINT_RADIUS * 2 + POINT_GAP)
//                            , startPoint.y);
//    } else if (alignment == kBBIndicatorAlignmentLeft) {
//        point = CGPointMake((index + 1) * POINT_GAP + (index + 0.5) * POINT_RADIUS
//                            , self.frame.size.height / 2.);
//    } else if (alignment == kBBIndicatorAlignmentRight) {
//        point = CGPointMake(self.frame.size.width - (index + 1) * POINT_GAP - (index + 0.5) * POINT_RADIUS
//                            , self.frame.size.height / 2.);
//    }
    return point;
}
 

- (void)setNumberOfPages:(NSUInteger)numberOfPages
{
    if (numberOfPages != _numberOfPages) {
        _numberOfPages = numberOfPages;
        [self setAlignment:self.alignment];
        [self setNeedsDisplay];
    }
}

#pragma mark -
#pragma mark UITouch method
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self];
    CGFloat currentPointX = startPoint.x + self.currentPage * (POINT_RADIUS + POINT_RADIUS * 2);
    NSInteger flag = 0;
    if (point.x > currentPointX) {
        flag = self.currentPage == self.numberOfPages - 1 ? 0 : 1;
    } else if (point.x < currentPointX){
        flag = self.currentPage == 0 ? 0 : -1;
    }
    NSLog(@"flag:%d", flag);
    if (flag == 0) {
        return ;
    }
    NSUInteger oldPage = self.currentPage;
    self.currentPage += flag;
    [self setNeedsDisplay];
    if (_delegate != nil
        && [_delegate respondsToSelector:@selector(pageControl:didChangeIndexTo:from:)]) {
        [_delegate pageControl:self didChangeIndexTo:self.currentPage from:oldPage];
    }
}


@end
