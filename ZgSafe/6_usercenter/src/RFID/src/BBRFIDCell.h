//
//  BBRFIDCell.h
//  ZgSafe
//
//  Created by box on 13-10-30.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol BBRFIDCellDelegate;

@interface BBRFIDCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UITextField *nameTf;
@property (retain, nonatomic) IBOutlet UITextField *RFIDTf;
@property (retain, nonatomic) IBOutlet UIImageView *headImageView;
@property (nonatomic,assign)id<BBRFIDCellDelegate>delegate;

@end


@protocol BBRFIDCellDelegate <NSObject>

@optional
- (void)didClickDeleteButton:(BBRFIDCell *)cell;

@end