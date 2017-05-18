//
//  BBScrollMenu.m
//  JiangbeiEPA
//
//  Created by iXcoder on 13-9-25.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#ifdef MENU_ITEM_COUNT
#undef MENU_ITEM_COUNT
#endif

#define MENU_ITEM_COUNT 6   // 可滑动菜单数量

#import "BBScrollMenu.h"

@interface BBScrollMenu ()

// 带尖角图形
@property (nonatomic, retain) IBOutlet UIImageView *indicatorView;

/*!
 *@brief        菜单按钮响应事件
 *@function     utilActionHandler:
 *@param        sender          -- 事件触发按钮
 *@return       (void)
 */
- (IBAction)utilActionHandler:(id)sender;

@end

@implementation BBScrollMenu

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _currentIndex = 0;
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
//*/

- (void)awakeFromNib
{
    [super awakeFromNib];
    NSArray *geses = self.gestureRecognizers;
    for (UIGestureRecognizer *ges in geses) {
        [self removeGestureRecognizer:ges];
    }
//    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureHandler:)];
//    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
//    [self addGestureRecognizer:swipeRight];
//    BB_SAFE_RELEASE(swipeRight);
//    
//    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureHandler:)];
//    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
//    [self addGestureRecognizer:swipeLeft];
//    BB_SAFE_RELEASE(swipeLeft);
}

#pragma mark -
#pragma mark self defined method

/*!
 *@brief        根据滑动手势来判断应展示的位置
 *@function     movationWithDirection:
 *@param        direction          -- 滑动方向
 *@return       (void)
 */
- (void)movationWithDirection:(UISwipeGestureRecognizerDirection)direction
{
    if (direction & (UISwipeGestureRecognizerDirectionDown | UISwipeGestureRecognizerDirectionUp)) {
        return ;
    }
    BOOL moveRight = (direction == UISwipeGestureRecognizerDirectionLeft)
                        && _currentIndex < MENU_ITEM_COUNT;
    BOOL moveLeft = (direction == UISwipeGestureRecognizerDirectionRight)
                        && _currentIndex > 0;
    NSInteger flag = 0;
    if (moveRight) {
        flag = 1;
    } else if (moveLeft) {
        flag = -1;
    }
    if (flag == 0) {
        return ;
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = self.currentIndex + flag + 120;
    [self utilActionHandler:button];
}

/*!
 *@brief        滑动手势处理
 *@function     swipeGestureHandler:
 *@param        sender
 *@return       (void)
 */
- (void)swipeGestureHandler:(id)sender
{
    UISwipeGestureRecognizer *swipe = (UISwipeGestureRecognizer *)sender;
    NSUInteger targetIndex = -1;
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        if ( _currentIndex > 0) {
            targetIndex = _currentIndex - 1;
        }
    } else {
        if (_currentIndex < MENU_ITEM_COUNT) {
            targetIndex = _currentIndex + 1;
        }
    }
    if (targetIndex == -1) {
        return ;
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = targetIndex + 120;
    [self utilActionHandler:button];
}

/*!
 *@brief        菜单按钮响应事件
 *@function     utilActionHandler:
 *@param        sender          -- 事件触发按钮
 *@return       (void)
 */
- (IBAction)utilActionHandler:(id)sender
{
    UIButton *button = (UIButton *)sender;
    NSInteger index = button.tag - 120;
    if (index == _currentIndex || index > 5 || index < 0) {
        return ;
    }
    
    BOOL shouldSelect = YES;
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(shouldScrollMenu:selectItemAtIndex:)]) {
        shouldSelect = [self.delegate shouldScrollMenu:self selectItemAtIndex:index];
    }
    if (!shouldSelect) {
        return ;
    }
    [self adjustSelectedIndicatorForType:button.tag];
}

/*!
 *@brief        调整选中指标位置
 *@function     adjustSelectedIndicatorForType:
 *@param        mbt
 *@return       (void)
 */
- (void)adjustSelectedIndicatorForType:(MenuButtonType)mbt
{
    if (self.delegate
        && [self.delegate respondsToSelector:@selector(willScrollMenu:selectItemAtIndex:)]) {
        [self.delegate willScrollMenu:self selectItemAtIndex:mbt - 120];
    }
    BBLog(@"mbt = %d",mbt);
    CGPoint start = [self calculatePositionForMenuButtonType:mbt];
    
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.indicatorView.frame = CGRectMake(start.x
                                                               , start.y
                                                               , self.indicatorView.frame.size.width
                                                               , self.indicatorView.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             _currentIndex = mbt - 120;
                             if (self.delegate
                                 && [self.delegate respondsToSelector:@selector(didScrollMenu:selectItemAtIndex:)]) {
                                 [self.delegate didScrollMenu:self selectItemAtIndex:_currentIndex];
                             }
                         }
                         
                     }];
    
    
}

/*!
 *@brief        计算不同位置处底部指示栏的位置
 *@function     calculatePositionForMenuButtonType:
 *@param        mbt         -- 选中状态
 *@return       (CGPoint)   -- 位置
 */
- (CGPoint)calculatePositionForMenuButtonType:(MenuButtonType)mbt
{
    CGPoint targetPositon = CGPointZero;
    switch (mbt) {
        case kMenuButtonTypeHome:
            targetPositon = CGPointMake(-433, 37);
            break;
        case kMenuButtonTypeAdvise:
            targetPositon = CGPointMake(-393, 37);
            break;
        case kMenuButtonTypeEnterprise:
            targetPositon = CGPointMake(-353, 37);
            break;
        case kMenuButtonTypePublic:
            targetPositon = CGPointMake(-313, 37);
            break;
        case kMenuButtonTypeMore:
            targetPositon = CGPointMake(-273, 37);
            break;
        case kMenuButtonTypeUserCenter:
            targetPositon = CGPointMake(-170, 37);
            break;
        default:
            break;
    }
    return targetPositon;
}

@end
