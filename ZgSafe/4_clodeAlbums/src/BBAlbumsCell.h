//
//  BBAlbumsCell.h
//  ZgSafe
//
//  Created by YANGReal on 13-10-28.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BBAlbumsCellDelegate;

@interface BBAlbumsCell : UITableViewCell
{
    
}
@property (retain, nonatomic) IBOutlet UILabel *time;
@property (retain, nonatomic) IBOutlet UILabel *totalShe; 
@property (retain, nonatomic) IBOutlet UIView *ImgView;
@property (retain, nonatomic) IBOutlet UILabel *invadeLbl;
@property (retain, nonatomic) IBOutlet UILabel *snapLbl;
@property (nonatomic,retain)NSIndexPath *indexPath;
@property (nonatomic,assign)id<BBAlbumsCellDelegate> delegate;
@end


@protocol BBAlbumsCellDelegate <NSObject>

@optional
- (void)didClickImageInCell:(BBAlbumsCell *)cell;

@end
