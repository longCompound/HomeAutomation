//
//  BBViewController.h
//  ZgSafe
//
//  Created by iXcoder on 13-10-24.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBRootViewController.h"
#import "MyCamera.h"
#import "MKNumberBadgeView.h"

@class BBDataFrame;
@class MKNumberBadgeView;

@interface BBHomePageController : BBRootViewController
{
    //已布防
    BOOL _isRegard;
    BOOL _canMove;
    UIView *_temperatureLineView;
}

@property (nonatomic,retain)NSMutableArray *members;           // 成员列表

//4个按钮上的数字
@property(nonatomic,retain)MKNumberBadgeView *cloudAlbumBadge;

- (IBAction)onclickCloudEyes:(UIButton *)sender;

- (void)getAllDatas;
- (void)registNotices;
- (void)genMemberView:(NSArray *)mems;
+ (NSArray *)parseData:(BBDataFrame *)data;
-(void)toRecevieMsg:(NSString *)strJson;

@end
