//
//  BBSwipeRefreshTable.m
//  Accumulation
//
//  Created by iXcoder on 14-3-10.
//  Copyright (c) 2014年 iXcoder. All rights reserved.
//

#import "BBPullRefreshTable.h"

#define TRIGER_OFFSET 50.f

#define ACT_INDI_TAG 500
#define SHW_LBEL_TAG 501
#define LST_LBEL_TAG 502
#define SCL_IMAG_TAG 503

@interface BBPullRefreshTable ()
{
    // 下拉
    BOOL hasLoadDown;
    BOOL loadingDown;
    UIView *pullDown;
    NSArray *downTxts;
    
    // 上拉
    BOOL hasLoadUp;
    BOOL loadingUp;
    UIView *pullUp;
    NSArray *upTxts;
    BOOL bottomHiden;
}

- (UIView *)createIndicatorViewWithType:(BBTableRefreshDirection)direction;

@end

@implementation BBPullRefreshTable

#if !__has_feature(objc_arc)
- (void)dealloc
{
    if (hasLoadDown) {
        [pullDown release];
        [downTxts release];
    }
    if (hasLoadUp) {
        [pullUp release];
        [upTxts release];
    }
    [super dealloc];
}
#endif

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        NSString *tblKey = @"Default_Table_Key";
        self.tableKey = tblKey;
        self.bounces = YES;
        
        hasLoadDown = NO;
        pullDown = nil;
        loadingDown = NO;
        
        hasLoadUp = NO;
        pullUp = nil;
        loadingUp = NO;
        
        self.bbStyle = UIActivityIndicatorViewStyleGray;
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSString *tblKey = @"Default_Table_Key";
        self.tableKey = tblKey;
        self.bounces = YES;
        
        hasLoadDown = NO;
        pullDown = nil;
        loadingDown = NO;
        
        hasLoadUp = NO;
        pullUp = nil;
        loadingUp = NO;
        
        self.bbStyle = UIActivityIndicatorViewStyleGray;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:style]) {
        NSString *tblKey = @"Default_Table_Key";
        self.tableKey = tblKey;
        self.bounces = YES;
        
        hasLoadDown = NO;
        pullDown = nil;
        loadingDown = NO;
        
        hasLoadUp = NO;
        pullUp = nil;
        loadingUp = NO;
        
        self.bbStyle = UIActivityIndicatorViewStyleGray;
    }
    return self;
}

- (void)reloadData
{
    [super reloadData];
    [self updateRefreshers];
}

#pragma mark -
#pragma mark self defined method

- (UIView *)createIndicatorViewWithType:(BBTableRefreshDirection)direction
{
    CGRect frame = CGRectZero;
    NSString *indiStr = @"";
    NSString *key = @"";
    
    if (direction == kBBTableRefreshDirectionDown) {
        frame = CGRectMake(0, -TRIGER_OFFSET, 200, TRIGER_OFFSET);
        indiStr = [downTxts objectAtIndex:0];
        key = [self.tableKey stringByAppendingString:@"_Down"];
    } else if (direction == kBBTableRefreshDirectionUp) {
        frame = CGRectMake(0, MAX(self.contentSize.height, self.frame.size.height), 200, TRIGER_OFFSET);
        indiStr = [upTxts objectAtIndex:0];
        key = [self.tableKey stringByAppendingString:@"_Up"];
    }
    UIView *indiView = [[UIView alloc] initWithFrame:frame];
    indiView.backgroundColor = [UIColor clearColor];
    
    UIActivityIndicatorView *indi = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:self.bbStyle];
    indi.center = CGPointMake(10, TRIGER_OFFSET / 2.0f);
    indi.hidesWhenStopped = YES;
    indi.tag = ACT_INDI_TAG;
    [indiView addSubview:indi];
#if !__has_feature(objc_arc)
    [indi release];
#endif
    NSString *imgName = self.bbStyle == UIActivityIndicatorViewStyleGray ? @"grayArrow.png" : @"whiteArrow.png";
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(4, 10, 12, 30)];
    iv.image = [UIImage imageNamed:imgName];
    iv.tag = SCL_IMAG_TAG;
    if (direction == kBBTableRefreshDirectionUp) {
        iv.transform = CGAffineTransformMakeRotation(M_PI);
    }
    [indiView addSubview:iv];
#if !__has_feature(objc_arc)
    [iv release];
#endif
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20
                                                               , TRIGER_OFFSET / 2. - 16
                                                               , 180
                                                               , 16)];
    label.text = indiStr;
    label.tag = SHW_LBEL_TAG;
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = self.bbStyle == UIActivityIndicatorViewStyleGray ? [UIColor blackColor] : [UIColor whiteColor];
    [indiView addSubview:label];
#if !__has_feature(objc_arc)
    [label release];
#endif
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *v = [ud objectForKey:key];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20
                                                             , TRIGER_OFFSET / 2.0
                                                             , 180
                                                             , 16)];
    lbl.text = v == nil ? @"上次更新：从未" : [@"上次更新：" stringByAppendingString:v];
    lbl.backgroundColor = [UIColor clearColor];
    lbl.font = [UIFont systemFontOfSize:12];
    lbl.textAlignment = NSTextAlignmentCenter;
    lbl.tag = LST_LBEL_TAG;
    lbl.textColor = self.bbStyle == UIActivityIndicatorViewStyleGray ? [UIColor blackColor] : [UIColor whiteColor];
    [indiView addSubview:lbl];
#if !__has_feature(objc_arc)
    [lbl release];
#endif
    return indiView;
}

- (void)setUpRefreshers
{
    if (self.refreshDirection == kBBTableRefreshDirectionNone) {
        return ;
    }
    
    if (hasLoadDown) {
        NSMutableArray *indi = [NSMutableArray array];
        [indi addObject:@"下拉可以刷新"];
        [indi addObject:@"释放立即刷新"];
        [indi addObject:@"正在刷新..."];
        [indi addObject:@"刷新结束"];
        downTxts = [indi retain];
        pullDown = [self createIndicatorViewWithType:kBBTableRefreshDirectionDown];
//        pullDown.alpha = 0.0f;
        [self addSubview:pullDown];
    }
    
    if (hasLoadUp) {
        NSMutableArray *indi = [NSMutableArray array];
        [indi addObject:@"上拉加载更多"];
        [indi addObject:@"释放立即加载"];
        [indi addObject:@"正在加载..."];
        [indi addObject:@"加载完成"];
        upTxts = [indi retain];
        pullUp = [self createIndicatorViewWithType:kBBTableRefreshDirectionUp];
//        pullUp.alpha = 0.0f;
        [self addSubview:pullUp];
    }
}

- (void)setRefreshDirection:(NSUInteger)refreshDirection
{
    _refreshDirection = refreshDirection;
    if (refreshDirection & kBBTableRefreshDirectionDown) {
        hasLoadDown = YES;
    }
    if (refreshDirection & kBBTableRefreshDirectionUp) {
        hasLoadUp = YES;
    }
}

- (void)updateRefreshers
{
    if (self.refreshDirection == kBBTableRefreshDirectionNone) {
        return;
    }
    if (pullDown != nil) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            CGPoint p = CGPointMake(self.frame.size.width / 2., -TRIGER_OFFSET / 2.0);
            [pullDown setCenter:p];
        });
    }
    if (pullUp != nil) {
        [pullUp setCenter:CGPointMake(self.frame.size.width / 2.
                                      , MAX(self.contentSize.height, self.bounds.size.height) + TRIGER_OFFSET / 2.)];
    }
}

- (void)refreshTableDidScroll
{
    BOOL canLoad = YES;
    if (hasLoadDown && self.contentOffset.y  < 0) {
        if (_sDelegate != nil
            && [_sDelegate respondsToSelector:@selector(refreshTable:shouldInteractiveForDirection:)]) {
            canLoad = [_sDelegate refreshTable:self shouldInteractiveForDirection:kBBTableRefreshDirectionDown];
        }
        if (loadingDown || !canLoad) {
            return ;
        }
//        pullDown.alpha = - self.contentOffset.y / TRIGER_OFFSET;
        UILabel *showLbl = (UILabel *)[pullDown viewWithTag:SHW_LBEL_TAG];
        UIView *iv = [pullDown viewWithTag:SCL_IMAG_TAG];
        if (self.contentOffset.y <= -TRIGER_OFFSET) {
            showLbl.text = [downTxts objectAtIndex:1];
            if (CGAffineTransformEqualToTransform(iv.transform, CGAffineTransformIdentity)) {
                [UIView animateWithDuration:0.1
                                 animations:^{
                                     iv.transform = CGAffineTransformMakeRotation(M_PI);
                                 }];
            }
        } else {
            showLbl.text = [downTxts objectAtIndex:0];
            if (CGAffineTransformEqualToTransform(iv.transform, CGAffineTransformMakeRotation(M_PI))) {
                [UIView animateWithDuration:0.1
                                 animations:^{
                                     iv.transform = CGAffineTransformIdentity;
                                 }];
            }
        }
    } else if (hasLoadUp && self.contentOffset.y > MAX(self.contentSize.height, self.frame.size.height) - self.frame.size.height) {
        if (bottomHiden) {
            return;
        }
        if (_sDelegate != nil
            && [_sDelegate respondsToSelector:@selector(refreshTable:shouldInteractiveForDirection:)]) {
            canLoad = [_sDelegate refreshTable:self shouldInteractiveForDirection:kBBTableRefreshDirectionDown];
        }
        if (loadingUp || !canLoad) {
            return ;
        }
//        pullUp.alpha = (self.contentOffset.y + self.frame.size.height - self.contentSize.height) / TRIGER_OFFSET;
        UILabel *showLbl = (UILabel *)[pullUp viewWithTag:SHW_LBEL_TAG];
        UIView *iv = [pullUp viewWithTag:SCL_IMAG_TAG];
        if (self.contentOffset.y > MAX(self.contentSize.height, self.frame.size.height) - self.frame.size.height + TRIGER_OFFSET) {
            showLbl.text = [upTxts objectAtIndex:1];
            if (CGAffineTransformEqualToTransform(iv.transform, CGAffineTransformMakeRotation(M_PI))) {
                [UIView animateWithDuration:0.1
                                 animations:^{
                                     iv.transform = CGAffineTransformIdentity;
                                 }];
            }
        } else {
            showLbl.text = [upTxts objectAtIndex:0];
            if (CGAffineTransformEqualToTransform(iv.transform, CGAffineTransformIdentity)) {
                [UIView animateWithDuration:0.1
                                 animations:^{
                                     iv.transform = CGAffineTransformMakeRotation(M_PI);
                                 }];
            }
        }
    }
}

- (void)refreshTableDidEndDraging
{
    if (hasLoadUp && self.contentOffset.y > MAX(self.contentSize.height, self.frame.size.height) - self.bounds.size.height + TRIGER_OFFSET) {
        if (!loadingUp) {
            BOOL shouldLoad = YES;
            if (_sDelegate != nil
                && [_sDelegate respondsToSelector:@selector(refreshTable:shouldInteractiveForDirection:)]) {
                shouldLoad = [_sDelegate refreshTable:self shouldInteractiveForDirection:kBBTableRefreshDirectionUp];
            }
            
            if (shouldLoad) {
                if (_sDelegate != nil
                    && [_sDelegate respondsToSelector:@selector(refreshTable:willTriggerForDirection:)]) {
                    [_sDelegate refreshTable:self willTriggerForDirection:kBBTableRefreshDirectionUp];
                }
                loadingUp = YES;
                [UIView animateWithDuration:.2
                                 animations:^{
                                     UIEdgeInsets contentInset = self.contentInset;
                                     contentInset.bottom += TRIGER_OFFSET;
                                     self.contentInset = contentInset;
                                 }];
                UIView *iv = [pullUp viewWithTag:SCL_IMAG_TAG];
                iv.hidden = YES;
                UIActivityIndicatorView *ac = (UIActivityIndicatorView *)[pullUp viewWithTag:ACT_INDI_TAG];
                [ac startAnimating];
                UILabel *showLbl = (UILabel *)[pullUp viewWithTag:SHW_LBEL_TAG];
                showLbl.text = [upTxts objectAtIndex:2];
                if (_sDelegate != nil
                    && [_sDelegate respondsToSelector:@selector(refreshTable:didTriggerForDirection:)]) {
                    [_sDelegate refreshTable:self didTriggerForDirection:kBBTableRefreshDirectionUp];
                }
            }
        }
    } else if (hasLoadDown && self.contentOffset.y < -TRIGER_OFFSET) {
        if (!loadingDown) {
            BOOL shouldLoad = YES;
            if (_sDelegate != nil
                && [self.sDelegate respondsToSelector:@selector(refreshTable:shouldInteractiveForDirection:)]) {
                shouldLoad = [self.sDelegate refreshTable:self shouldInteractiveForDirection:kBBTableRefreshDirectionDown];
            }
            if (shouldLoad) {
                if (_sDelegate != nil
                    && [_sDelegate respondsToSelector:@selector(refreshTable:willTriggerForDirection:)]) {
                    [_sDelegate refreshTable:self willTriggerForDirection:kBBTableRefreshDirectionDown];
                }
                loadingDown = YES;
                [UIView animateWithDuration:.2
                                 animations:^{
                                     UIEdgeInsets contentInset = self.contentInset;
                                     contentInset.top += TRIGER_OFFSET;
                                     self.contentInset = contentInset;
                                 }];
                UIView *iv = [pullDown viewWithTag:SCL_IMAG_TAG];
                iv.hidden = YES;
                UIActivityIndicatorView *ac = (UIActivityIndicatorView *)[pullDown viewWithTag:ACT_INDI_TAG];
                [ac startAnimating];
                UILabel *showLbl = (UILabel *)[pullDown viewWithTag:SHW_LBEL_TAG];
                showLbl.text = [downTxts objectAtIndex:2];
                if (_sDelegate != nil
                    && [_sDelegate respondsToSelector:@selector(refreshTable:didTriggerForDirection:)]) {
                    [_sDelegate refreshTable:self didTriggerForDirection:kBBTableRefreshDirectionDown];
                }
            }
        }
    }
}

- (void)refreshTableDidFinishLoad
{
    if (loadingDown) {
        [self refreshTableDidFinishLoad:kBBTableRefreshDirectionDown];
    }else if (loadingUp) {
        [self refreshTableDidFinishLoad:kBBTableRefreshDirectionUp];
        
    }
}

- (void)refreshTableDidFinishLoad:(BBTableRefreshDirection)direction
{
    if (direction == kBBTableRefreshDirectionDown && loadingDown) {
        [UIView animateWithDuration:.2
                         animations:^{
                             
                         }];
        loadingDown = NO;
        UIView *iv = [pullDown viewWithTag:SCL_IMAG_TAG];
        iv.hidden = NO;
        iv.transform = CGAffineTransformIdentity;
        UIActivityIndicatorView *ac = (UIActivityIndicatorView *)[pullDown viewWithTag:ACT_INDI_TAG];
        UILabel *showLbl = (UILabel *)[pullDown viewWithTag:SHW_LBEL_TAG];
        ac.hidesWhenStopped = YES;
        [ac stopAnimating];
        showLbl.text = [downTxts objectAtIndex:3];
        [showLbl performSelector:@selector(setText:) withObject:[downTxts objectAtIndex:0] afterDelay:0.5];
        [UIView animateWithDuration:0.5
                              delay:0.3
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             UIEdgeInsets contentInset = self.contentInset;
                             contentInset.top -= TRIGER_OFFSET;
                             self.contentInset = contentInset;
                         } completion:nil];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *ds = [df stringFromDate:[NSDate date]];
        [df release];
        UILabel *lstLbl = (UILabel *)[pullDown viewWithTag:LST_LBEL_TAG];
        lstLbl.text = [@"上次更新：" stringByAppendingString:ds];
        NSString *key = [self.tableKey stringByAppendingString:@"_Down"];
        [[NSUserDefaults standardUserDefaults] setObject:ds forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else if (direction == kBBTableRefreshDirectionUp && loadingUp) {
        
        loadingUp = NO;
        UIView *iv = [pullUp viewWithTag:SCL_IMAG_TAG];
        iv.hidden = NO;
        iv.transform = CGAffineTransformMakeRotation(M_PI);
        UIActivityIndicatorView *ac = (UIActivityIndicatorView *)[pullUp viewWithTag:ACT_INDI_TAG];
        UILabel *showLbl = (UILabel *)[pullUp viewWithTag:SHW_LBEL_TAG];
        ac.hidesWhenStopped = YES;
        [ac stopAnimating];
        showLbl.text = [upTxts objectAtIndex:3];
        [showLbl performSelector:@selector(setText:) withObject:[upTxts objectAtIndex:0] afterDelay:0.5];
        [UIView animateWithDuration:0.5
                              delay:0.3
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             UIEdgeInsets contentInset = self.contentInset;
                             contentInset.bottom -= TRIGER_OFFSET;
                             self.contentInset = contentInset;
                         } completion:nil];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *ds = [df stringFromDate:[NSDate date]];
        [df release];
        UILabel *lstLbl = (UILabel *)[pullUp viewWithTag:LST_LBEL_TAG];
        lstLbl.text = [@"上次更新：" stringByAppendingString:ds];
        NSString *key = [self.tableKey stringByAppendingString:@"_Up"];
        [[NSUserDefaults standardUserDefaults] setObject:ds forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self updateRefreshers];
}

#pragma mark -
#pragma mark CAAnimation method
- (CAAnimation *)showAnimation
{
    CAKeyframeAnimation *kf = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    kf.removedOnCompletion = YES;
    kf.keyTimes = [NSArray arrayWithObjects:@0.0, @0.75, @1.0, nil];
    kf.values = [NSArray arrayWithObjects:@0.0, @1.2, @1.0, nil];
    kf.timingFunction = [CAMediaTimingFunction functionWithName:@"easeIn"];
    kf.duration = 0.1;
    return kf;
}

- (CAAnimation *)hideAnimation
{
    CAKeyframeAnimation *kf = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    kf.removedOnCompletion = YES;
    kf.keyTimes = [NSArray arrayWithObjects:@0.0, @0.25, @1.0, nil];
    kf.values = [NSArray arrayWithObjects:@1.0, @1.2,@0.0, nil];
    kf.timingFunction = [CAMediaTimingFunction functionWithName:@"easeOut"];
    kf.duration = 0.1;
    return kf;
}

- (void)hideBottomRefresher
{
    if (!hasLoadDown) {
        return;
    }
    
    pullUp.hidden = YES;
    bottomHiden = YES;
}

- (void)showBottomRefresher
{ 
    if (!hasLoadDown) {
        return;
    }
    
    pullUp.hidden = NO;
    bottomHiden = NO;
}


@end
