//
//  BBTabbarController.m
//  JiangbeiEPA
//
//  Created by iXcoder on 13-9-24.
//  Copyright (c) 2013年 bulebox. All rights reserved.
//

#import "BBTabbarController.h"

@interface BBTabbarController ()

@end

@implementation BBTabbarController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark UIView rotate method
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    UIViewController *selectedViewController = self.selectedViewController;
    if ([selectedViewController isKindOfClass:[UINavigationController class]]) {
        UIViewController *topViewController = [(UINavigationController *)selectedViewController topViewController];
        return [topViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    } else {
        return [selectedViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
    }
}

- (BOOL)shouldAutorotate
{
    UIViewController *selectedViewController = self.selectedViewController;
    if ([selectedViewController isKindOfClass:[UINavigationController class]]) {
        UIViewController *topViewController = [(UINavigationController *)selectedViewController topViewController];
        return [topViewController shouldAutorotate];
    } else {
        return [selectedViewController shouldAutorotate];
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    UIViewController *selectedViewController = self.selectedViewController;
    if ([selectedViewController isKindOfClass:[UINavigationController class]]) {
        UIViewController *topViewController = [(UINavigationController *)selectedViewController topViewController];
        return [topViewController supportedInterfaceOrientations];
    } else {
        return [selectedViewController supportedInterfaceOrientations];
    }
}


@end
