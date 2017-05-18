//
//  BBPopupView.h
//  VankeClub
//
//  Created by iXcoder on 13-7-31.
//  Copyright (c) 2013年 Blue Box. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol BBPopupDelegate ;

@interface BBPopupView : UIView


/*!
 *@brief        模态展示一个视图
 *@function     showWithView:
 *@param        customView      -- 要展示的视图
 *@return       (void)
 */
+ (void)popupWithView:(UIView *)customView  withDelegate:(id<BBPopupDelegate>)delegate animation:(CAAnimation *)animation;

/*!
 *@brief        消失模态视图
 *@function     dismiss
 *@return       (void)
 */
+ (void)dismiss;

@end


@protocol BBPopupDelegate <NSObject>

@optional
- (void)popupWillShowWithCustomView:(UIView *)customView;

- (void)popupDidShowWithCustomView:(UIView *)customView;

- (void)popupWillDismissWithCustomView:(UIView *)customView;

- (void)popupDidDismissWithCustomView:(UIView *)customView;

@end