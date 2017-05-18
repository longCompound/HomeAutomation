//
//  BBWarningRecordCell.h
//  ZgSafe
//
//  Created by box on 13-10-29.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBWarningRecordCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *backGroundImage;
@property (retain, nonatomic) IBOutlet UILabel *infoLable;//“温度异常”的lable
@property (retain, nonatomic) IBOutlet UILabel *temperatureLable;
@property (retain, nonatomic) IBOutlet UILabel *timeLable;

@end
