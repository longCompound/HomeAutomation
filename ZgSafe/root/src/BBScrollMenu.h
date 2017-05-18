//
//  BBScrollMenu.h
//  JiangbeiEPA
//
//  Created by iXcoder on 13-9-25.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MenuButtonType) {
    kMenuButtonTypeHome = 120,      // 首页
    kMenuButtonTypeAdvise,          // 建议与投诉
    kMenuButtonTypeEnterprise,      // 企业申报
    kMenuButtonTypePublic,          // 环保宣传
    kMenuButtonTypeMore,            // 更多
    kMenuButtonTypeUserCenter       // 用户中心
};

@class BBScrollMenu;

@protocol BBScrollMenuDelegate <NSObject>

- (BOOL)shouldScrollMenu:(BBScrollMenu *)menu selectItemAtIndex:(NSUInteger)index;

- (void)willScrollMenu:(BBScrollMenu *)menu selectItemAtIndex:(NSUInteger)index;

- (void)didScrollMenu:(BBScrollMenu *)menu selectItemAtIndex:(NSUInteger)index;

@end

@interface BBScrollMenu : UIView

@property (nonatomic, assign) NSUInteger currentIndex;

@property (nonatomic, assign) id<BBScrollMenuDelegate> delegate;

// 根据滑动手势来判断应展示的位置
- (void)movationWithDirection:(UISwipeGestureRecognizerDirection)direction;

@end
