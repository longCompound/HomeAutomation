//
//  BBAutoLoginViewController.m
//  ZgSafe
//
//  Created by apple on 14-5-31.
//  Copyright (c) 2014年 iXcoder. All rights reserved.
//

#import "BBAutoLoginViewController.h"

@interface BBAutoLoginViewController ()

@end

@implementation BBAutoLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"进入自动登录页");
    NSString *username=[[NSUserDefaults standardUserDefaults]objectForKey:@"userName"];
    NSString *pwd=[[NSUserDefaults standardUserDefaults]objectForKey:@"passWord"];

    NSString *user;
    if (username!=nil) {
        user=username;
    }else{
        user=[[NSUserDefaults standardUserDefaults]objectForKey:@"moblePhone"];
    }
    
    
    if (user!=nil&&pwd!=nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [[BBSocketManager getInstance] login:user password:pwd delegate:self];
        });

    }
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark BBLoginClientDelegate method
-(void)loginReceiveData:(BBDataFrame *)data{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *result = [[NSString alloc]initWithBytes:[data.data bytes] length:data.data.length encoding:GBK_ENCODEING];
        NSArray *arr = [result componentsSeparatedByString:@"\t"];
        if (![arr[0] boolValue]) {
            BlueBoxer *sysUser = [BlueBoxerManager getCurrentUser];
            sysUser.loged = YES;
            sysUser.deviceid=nil;
            [BlueBoxerManager archiveCurrentUser:sysUser];
            
            double delayInSeconds = 0.2;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [appDelegate.homePageVC registNotices];
            });
        }
        [result release];
    });
    
}
@end
