//
//  BBAdressCell.h
//  ZgSafe
//
//  Created by box on 13-10-31.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BBAdressCellDelegate;

@interface BBAdressCell : UITableViewCell
{
}
@property (retain, nonatomic) IBOutlet UIImageView *selectIndicateImage;//地址选中时“勾”
@property (retain, nonatomic) IBOutlet UITextField *adressTf;
@property (retain, nonatomic) IBOutlet UITextField *deviceTf;
@property (nonatomic,assign) id<BBAdressCellDelegate> delegate;

@end

@protocol BBAdressCellDelegate <NSObject>

@optional
- (void)didClickDeleteButton:(BBAdressCell *)cell;

@end