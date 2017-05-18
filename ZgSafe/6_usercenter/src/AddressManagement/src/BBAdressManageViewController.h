//
//  BBAdressManageViewController.h
//  ZgSafe
//
//  Created by box on 13-10-31.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBRootViewController.h"
#define ADRESS_KEY @"adress"
#define DEVICE_KEY @"device"

@interface BBAdressManageViewController : BBRootViewController
{
    NSString *_currentSelectedDevice;
}

@property (nonatomic,retain)
NSMutableArray *dataArr;

@property (retain, nonatomic) IBOutlet UITableView *adressTeble;
- (void)getDatas;

@end
