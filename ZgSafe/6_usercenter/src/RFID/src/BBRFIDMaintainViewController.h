//
//  BBRFIDMaintainViewController.h
//  ZgSafe
//
//  Created by box on 13-10-30.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBRootViewController.h"

#define NICKNAME_KEY @"name"
#define RFID_KEY @"rfid"
#define HEAD_IMAGE_KEY @"headImage"
@class BBRFIDCell;
@interface BBRFIDMaintainViewController : BBRootViewController
{
    BBRFIDCell *_willDeletedCell;
}

@property (retain, nonatomic) IBOutlet UITableView *rfidTable;
@property(nonatomic,retain)NSMutableArray *dataArr;
- (void)getDatas;

@end
