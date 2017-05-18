//
//  BBInOutAndSafeRecoredCell.h
//  ZgSafe
//
//  Created by box on 13-10-28.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBInOutAndSafeRecoredCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *headImage;//头像
@property (retain, nonatomic) IBOutlet UIImageView *stateImage;//状态（布防、撤防等）
@property (retain, nonatomic) IBOutlet UILabel *stateName;//状态名
@property (retain, nonatomic) IBOutlet UILabel *name;
@property (retain, nonatomic) IBOutlet UILabel *tel;
@property (retain, nonatomic) IBOutlet UILabel *time;
@property (retain, nonatomic) IBOutlet UILabel *date;


@end
