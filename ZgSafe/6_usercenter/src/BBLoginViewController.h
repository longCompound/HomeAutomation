//
//  BBLoginViewController.h
//  ZgSafe
//
//  Created by box on 13-10-29.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBRootViewController.h"

@interface BBLoginViewController : BBRootViewController <UITextFieldDelegate>{
    
    MBProgressHUD *_hud;
}

@property (retain, nonatomic) IBOutlet UIImageView *backG;

@end
