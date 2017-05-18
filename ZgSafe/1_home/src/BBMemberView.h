//
//  BBMemberView.h
//  ZgSafe
//
//  Created by iXcoder on 13-10-24.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBMemberView : UIView

// 性别
@property (nonatomic, assign) BOOL isMale;
// 称谓
@property (nonatomic, retain) NSString *name;
// 是否在线
@property (nonatomic, assign) BOOL isOnline;
@property (nonatomic, retain) IBOutlet UIImageView *photo;

@end
