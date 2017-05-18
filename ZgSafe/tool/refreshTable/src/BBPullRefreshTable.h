//
//  BBSwipeRefreshTable.h
//  Accumulation
//
//  Created by iXcoder on 14-3-10.
//  Copyright (c) 2014年 iXcoder. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BBTableRefreshDirection) {
    kBBTableRefreshDirectionNone = 0,
    kBBTableRefreshDirectionDown = 1 << 0,
    kBBTableRefreshDirectionUp = 1 << 1,
//    kBBTableRefreshDirectionLeft = 1 << 2,
//    kBBTableRefreshDirectionRight = 1 << 3
};

@class BBPullRefreshTable;

@protocol BBPullRefreshDelegate <NSObject>

@required
- (BOOL)refreshTable:(BBPullRefreshTable *)prt shouldInteractiveForDirection:(BBTableRefreshDirection)direction;

- (void)refreshTable:(BBPullRefreshTable *)prt willTriggerForDirection:(BBTableRefreshDirection)direction;

- (void)refreshTable:(BBPullRefreshTable *)prt didTriggerForDirection:(BBTableRefreshDirection)direction;

@end

@interface BBPullRefreshTable : UITableView

@property (nonatomic, retain) NSString *tableKey;

@property (nonatomic, assign) UIActivityIndicatorViewStyle bbStyle;

@property (nonatomic, assign) id<BBPullRefreshDelegate> sDelegate;

@property (nonatomic, assign) NSUInteger refreshDirection;

- (void)setUpRefreshers;

- (void)updateRefreshers;

- (void)refreshTableDidScroll;

- (void)refreshTableDidEndDraging;

- (void)refreshTableDidFinishLoad:(BBTableRefreshDirection)direction;

- (void)refreshTableDidFinishLoad;

- (void)showBottomRefresher;
- (void)hideBottomRefresher;


@end


