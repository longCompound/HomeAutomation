//
//  BBAlDetailsViewController.h
//  ZgSafe
//
//  Created by YANGReal on 13-10-28.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBAlDetailsViewController : BBRootViewController
{
}

@property (retain, nonatomic)MBProgressHUD *hud;
@property (nonatomic,assign)NSMutableArray *dataArr;
@property (nonatomic,assign)NSInteger index;
@property (nonatomic,copy)NSString *timeStr;


- (void)sendSinaShare;

@end
