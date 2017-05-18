//
//  BBExchangeScoreViewController.m
//  ZgSafe
//   积分兑换
//  Created by box on 13-11-1.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBExchangeScoreViewController.h"
#define INT_NUMBER 400
@interface BBExchangeScoreViewController ()
{
    
}
@property (retain, nonatomic) IBOutlet UIScrollView *longScollView;//长的scollView
@property (retain, nonatomic) IBOutlet UIView *tanchuView;//弹出的view
@property (retain, nonatomic) IBOutlet UIView *backergroundView;//背景的view
@property (retain, nonatomic) IBOutlet UILabel *fenshuLable;//弹出框多少分数的lable


- (IBAction)goback:(id)sender;//返回上一个页面
- (IBAction)cancelButton:(UIButton *)sender;//取消兑换
- (IBAction)setUpButton:(UIButton *)sender;//确定兑换

- (IBAction)jifenButton:(UIButton *)sender;//积分的button；
@end

@implementation BBExchangeScoreViewController

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
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        if (self.view.frame.size.height<=480) {
             [_longScollView setContentSize:CGSizeMake(_longScollView.frame.size.width, _longScollView.frame.size.height+960)];
        }else{
         [_longScollView setContentSize:CGSizeMake(_longScollView.frame.size.width, _longScollView.frame.size.height+880)];
        }
    });
//     设置弹出的view为圆角的
    _tanchuView.layer.cornerRadius=6;
    _tanchuView.layer.masksToBounds=YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark - self define method -
/*!
 *@description      响应点击返回按钮事件
 *@function         goback:
 *@param            sender     --返回按钮
 *@return           (void)
 */
- (IBAction)goback:(id)sender {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.presentingViewController dismissModalViewControllerAnimated:YES];
    }
}
/*!
 *@brief        取消兑换积分
 *@function     cancelButton
 *@param        sender
 *@return       （void）
 */
- (IBAction)cancelButton:(UIButton *)sender {
    [_backergroundView setHidden:YES];
    [self moderlongs:INT_NUMBER];
}
/*!
 *@brief        确定兑换积分
 *@function     setUpButton
 *@param        sender
 *@return       （void）
 */
- (IBAction)setUpButton:(UIButton *)sender {
    [_backergroundView setHidden:YES];
    [self moderlongs:INT_NUMBER];
}
/*!
 *@brief        点击兑换积分
 *@function     jifenButton
 *@param        sender
 *@return       （void）
 */
- (IBAction)jifenButton:(UIButton *)sender {
    [_backergroundView setHidden:NO];
    [self moderlongs:-INT_NUMBER];
}
/*!
 *@brief        弹出框的多少
 *@function     moderlongs
 *@param        sender
 *@return       （void）
 */
-(void)moderlongs:(NSInteger)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        [_tanchuView setFrame:CGRectMake(_tanchuView.frame.origin.x, _tanchuView.frame.origin.y+sender, _tanchuView.frame.size.width, _tanchuView.frame.size.height)];
    }];

}
- (void)dealloc {
    [_longScollView release];
    [_tanchuView release];
    [_fenshuLable release];
    [_backergroundView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setLongScollView:nil];
    [self setTanchuView:nil];
    [self setFenshuLable:nil];
    [self setBackergroundView:nil];
    [super viewDidUnload];
}

@end
