//
//  BBMarkViewController.h
//  ZgSafe
//
//  Created by box on 13-10-28.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import <UIKit/UIKit.h> 

#define NAME_KEY @"name"
#define TIME_KEY @"time"
#define ACT_KEY @"act"
#define TEL_KEY @"tel"
#define WARN_TYPE_KEY @"type"
#define TEMPERATURE_KEY @"TEMPERATURE_KEY"
#define INVADE_ID_KEY @"INVADE_ID_KEY"
//当前页面类型
NS_ENUM(NSInteger,MarkPageType)
{
    BBMarkPageTypeInOutRecord = 0,//出入记录页面
    BBMarkPageTypeSafeRecord,//安防页面
    BBMarkPageTypeWarningRecord//报警记录页面
};

typedef enum MarkPageType BBMarkPageType;

@interface BBMarkViewController : BBRootViewController
{
    //上一次点击的button（顶部的3个btn之一）
    UIButton *_lastClickBtn;
}

@property(nonatomic,retain)NSMutableArray *dataArr;
@property (retain, nonatomic) IBOutlet BBPullRefreshTable *recordTable;
@property (nonatomic,assign) BBMarkPageType currentPageType;//当前的页面类型
@property(nonatomic,retain)NSArray *members;//家庭成员
- (void)getDatasWhileSelectType:(BOOL)isSelectType;


@end
