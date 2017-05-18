//
//  BBshowADcorl.h
//  ZgSafe
//
//  Created by iXcoder on 13-11-11.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBshowADcorl : UIView<SDWebImageManagerDelegate,UIScrollViewDelegate,UITableViewDataSource>
@property (retain, nonatomic) IBOutlet UIScrollView *scollView;//广告业面

- (IBAction)pullButton:(UIButton *)sender;//向上拖动的button

- (IBAction)checkButton:(UIButton *)sender;//查看详情

@property (retain, nonatomic) IBOutlet UIPageControl *pageCorl;//页数page
@property(nonatomic ,retain)NSMutableArray *imageArray;
@property(nonatomic,retain)NSArray *imagUrls;
/*!
 *@brief        下拉展示启动页广告视图
 *@function     showADView
 *@param        (void)
 *@return       (void)
 */
-(void)showAdView;
@end
