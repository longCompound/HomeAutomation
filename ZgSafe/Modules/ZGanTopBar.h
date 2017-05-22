//
//  ZGanTopBar.h
//  ZgSafe
//
//  Created by Mark on 2017/5/19.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZGanTopBarDelegate;
@interface ZGanTopBar : UIView

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property (weak, nonatomic) IBOutlet UIButton *leftButton;

@property (weak, nonatomic) IBOutlet UILabel *traceTitleLabel;


@property (nonatomic, weak) id <ZGanTopBarDelegate>delegate;

@property (nonatomic, assign) BOOL hidesLeftBtn;

- (void)setupBackTrace:(NSString *)trace
                 title:(NSString *)title
      rightActionTitle:(NSString *)actionTitle;


@end


@protocol ZGanTopBarDelegate <NSObject>

- (void)touchTopBarLeftButton:(ZGanTopBar *)bar;

- (void)touchTopBarRightButton:(ZGanTopBar *)bar;

@end
