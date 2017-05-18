//
//  BBSetNetingViewController.h
//  ZgSafe
//
//  Created by iXcoder on 13-10-29.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BBAPModeType){
    kBBAPModeTypeHttp = 0,//通过网页请求的方式设置AP模式
    kBBAPModeTypeCamera//通过IOTCamera提供的SDK设置AP模式
};

@interface BBSetNetingViewController : BBRootViewController <UITextFieldDelegate,UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic,assign)BBAPModeType apModeType;

@end
