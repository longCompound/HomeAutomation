//
//  ZGWebViewController.m
//  ZgSafe
//
//  Created by Mark on 2017/5/22.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGWebViewController.h"

@interface ZGWebViewController () <UIWebViewDelegate> {
    __weak IBOutlet UIWebView *_web;
}

@end

@implementation ZGWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topBar.hidesLeftBtn = NO;
    [self.topBar setupBackTrace:@"返回" title:_titleString rightActionTitle:nil];
    [_web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlString]]];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _web.frame = CGRectMake(0, self.topBar.bottom, self.view.width, self.view.height - self.topBar.bottom);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark --
#pragma mark -- UIWebViewDelegate --
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

- (void)touchTopBarLeftButton:(ZGanTopBar *)bar
{
    if ([_web canGoBack]) {
        [_web goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
