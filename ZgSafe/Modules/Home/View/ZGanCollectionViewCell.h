//
//  ZGanCollectionViewCell.h
//  ZgSafe
//
//  Created by Mark on 2017/5/19.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZGanActionModel.h"

@protocol ZGanCollectionViewCellDelegate;
@interface ZGanCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) ZGanActionModel  * actionInfo;

@property (nonatomic,weak) id<ZGanCollectionViewCellDelegate>delegate;

@end


@protocol ZGanCollectionViewCellDelegate <NSObject>

- (void)cellClickWithInfo:(ZGanActionModel *)model;

@end
