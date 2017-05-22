//
//  ZGanSecurityViewController.m
//  ZgSafe
//
//  Created by Mark on 2017/5/18.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGanSecurityViewController.h"

@interface ZGanSecurityViewController ()

@end

@implementation ZGanSecurityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topBar.hidesLeftBtn = YES;
    [self.topBar setupBackTrace:nil title:@"家庭卫士" rightActionTitle:nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
