//
//  BBHuiAplViewController.m
//  ZgSafe
//
//  Created by YANGReal on 13-10-29.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBHuiAplViewController.h"
#import "BBShowVideoCell.h"
#import "BBSideBarView.h"
#import "BBUserCenterViewController.h"
#import "BBAlbumsViewController.h"
#import "BBMarkViewController.h"

@interface BBHuiAplViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,BBSideBarViewDelegate,BBSocketClientDelegate>
{
    BBSideBarView *_siderBar;
//    MBProgressHUD *_hud;
}

@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet UITableView *showtab;

- (IBAction)goback:(id)sender;

@end

@implementation BBHuiAplViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


#pragma mark - 
#pragma mark system method
- (void)viewDidLoad
{
    [super viewDidLoad];
    _siderBar = [BBSideBarView siderBarWithBesideView:self.view];
    _siderBar.delegate=self;
    
    _webView.scalesPageToFit = NO;
     
    [self getDatas];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    if (!ISIP5) {
        _showtab.center = CGPointMake(_showtab.center.x, _showtab.center.y-18);
    }
}

- (void)dealloc {
    [_showtab release];
    [_siderBar remove];
    [_webView release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setShowtab:nil];
    [self setWebView:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark -
#pragma mark self define method

/*!
 *@description  请求数据
 *@function     getDatas
 *@param        (void)
 *@return       (void)
 */
- (void)getDatas
{
//    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
//    [_hud setLabelText:@"正在请求数据..."];
//    [_hud setRemoveFromSuperViewOnHide:YES];
    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
    NSString *userId = curUser.userid;
    [mainClient queryHuiAppUrls:self param:userId];
    
}

- (IBAction)goback:(id)sender {
    [_siderBar hide];
    if (self.navigationController) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        UIViewController *vc = self;
        while (![vc isKindOfClass:[UINavigationController class]]) {
            UIViewController *tempVC = vc.presentingViewController;
            if ([tempVC isKindOfClass:[UINavigationController class]]) {
                [vc dismissModalViewControllerAnimated:YES];
            }else{
                [vc dismissModalViewControllerAnimated:NO];
            }
            vc = tempVC;
        }
    }
}



#pragma mark -
#pragma mark UITableViewDataSource method
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 83.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentifer = @"BBShowVideoCell";
    BBShowVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifer];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"BBShowVideoCell"
                                            owner:self
                                          options:nil]lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.row == 1) {
        cell.appName1.text = @"商业服务";
        cell.appName2.text = @"阳光政务";
    }
    
    return cell;
}
#pragma mark -
#pragma mark - BBSideBarViewDelegate method-

- (void)didSelectedButtonAtIndex:(NSInteger)index{
    
    
    [_siderBar hide];
    UIViewController *vc = nil;
    if (index==0) {
        //[BBCloudEyesViewController verifyThenPushWithVC:self];
    }else if(index==1){
        vc=[[BBMarkViewController alloc]init];
    }else if(index==2){
        
        vc=[[BBAlbumsViewController alloc]init];
    }else if (index==3)
    {
//        vc=[[BBHuiAplViewController alloc]init];
    }else if (index==4)
    {
        vc=[[BBUserCenterViewController alloc]init];
    }
    
    if (vc) {
        if (self.navigationController) {
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            [self presentModalViewController:vc animated:YES];
        }
        [vc release];
    }
}


#pragma mark -
#pragma mark BBSocketClientDelegate method

-(int)onRecevie:(BBDataFrame *)src received:(BBDataFrame *)data
{
    if(src.MainCmd == 0x0E && src.SubCmd == 83) {
        //慧应用广告URL
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc]initWithString:[data dataString]];
            NSArray *arr = [result componentsSeparatedByString:@"\t"];
            if ([arr[0] boolValue]) {
//                [_hud setLabelText:@"获取url失败"];
            }else{
//                [_hud setLabelText:@"获取url成功"];
//                UtilAlert(arr[1], arr[1]);
                [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:arr[1]]]];
            }
            [result release];
            
            
            BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
            NSString *userId = curUser.userid;
            [mainClient huiAppDownLoad:self param:[NSString stringWithFormat:@"%@\t4\t1",userId]];
        });
    }else if(src.MainCmd == 0x0E && src.SubCmd == 86) {
        //慧应用下载
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc]initWithString:[data dataString]];
            NSArray *arr = [result componentsSeparatedByString:@"\t"];
            if ([arr[0] boolValue]) {
//                [_hud setLabelText:@"获取app下载链接失败"];
            }else{
//                [_hud setLabelText:@"获取app下载链接成功"];
            }
//            UtilAlert(result, nil);
//            [_hud performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
            [result release];
        });
    }
    
    return 0;
}

-(void)onTimeout:(BBDataFrame *)src
{
//    [_hud setLabelText:@"请求超时"];
//    [_hud performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
}


-(void)onRecevieError:(BBDataFrame*)src received:(BBDataFrame*)data
{
    NSLog(@"RecevieError src.SubCmd=%d",src.SubCmd);
}
- (BOOL) isFileExist:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingFormat:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:filePath];
    return result;
}
@end
