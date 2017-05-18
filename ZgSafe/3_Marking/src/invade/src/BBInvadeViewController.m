//
//  BBInvadeViewController.m
//  ZgSafe
//
//  Created by box on 13-10-31.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBInvadeViewController.h"
#import "BBInvadeCell.h"
#import "BBFullImageView.h"

#define INVADE_TIME @"INVADE_TIME"
#define INVADE_IMAGE @"INVADE_IMAGE"

@interface BBInvadeViewController ()<BBSocketClientDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_dataArr;
    MBProgressHUD *_hud;
    NSString *_emergenceTel;//紧急电话
}

- (IBAction)goBack:(id)sender;
- (IBAction)dialNumber:(id)sender;
- (IBAction)onHorn:(UIButton *)sender;

@property (retain, nonatomic) IBOutlet UIButton *hornBrn;
@property (retain, nonatomic) IBOutlet UIImageView *forbidImage;
@property (retain, nonatomic) IBOutlet UITableView *invadeTable;

@end

@implementation BBInvadeViewController

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
    // Do any additional setup after loading the view from its nib.
    
    _emergenceTel = [[NSString alloc]initWithString:@"110"];
    
    _dataArr = [[NSMutableArray alloc]init];
    _forbidImage.hidden = NO;
    [self getDatas];
    
    _hornBrn.hidden=YES;
    _forbidImage.hidden=YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
 
- (void)dealloc {
    [_emergenceTel release];
    [_invadeTable release];
    [_forbidImage release];
    [_dataArr release];
    [_hornBrn release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setInvadeTable:nil];
    [self setForbidImage:nil];
    [self setHornBrn:nil];
    [super viewDidUnload];
}


#pragma mark - self define method -

/*!
 *@description      返回主界面
 *@function         goBack:
 *@param            sender      --返回按钮
 *@return           (void)
 */
- (IBAction)goBack:(id)sender {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.presentingViewController dismissModalViewControllerAnimated:YES];
    }
}



/*!
 *@description  请求数据
 *@function     getDatas
 *@param        (void)
 *@return       (void)
 */
- (void)getDatas
{
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
    [_hud setLabelText:@"正在请求数据..."];
    [_hud setRemoveFromSuperViewOnHide:YES];
    
    [_dataArr removeAllObjects];
    
    NSString *userId = curUser.userid;
    NSMutableString *param = [[NSMutableString alloc]initWithString:userId];
    [param appendFormat:@"\t%@\t6",_ID];
    
    BBFileClient *fileClient = [[BBSocketManager getInstance] fileClient];
    [fileClient getFileRequest:self param:param];
    [param release];
    
    
//    
//    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
//    NSString *param1 = [NSString stringWithFormat:@"%@\t2",userId];
//    [mainClient queryWarningHistory:self param:param1];

}

/*!
 *@description  获取紧急电话
 *@function     getTel
 *@param        (void)
 *@return       (void)
 */
- (void)getTel
{
//    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
//    [_hud setLabelText:@"正在获取紧急联系电话..."];
//    [_hud setRemoveFromSuperViewOnHide:YES];
    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
    [mainClient queryEmergencyNumber:self param:curUser.userid];
}

/*!
 *@description  响应点击拨打电话按钮事件
 *@function     dialNumber:
 *@param        sender     --按钮
 *@return       (void)
 */
- (IBAction)dialNumber:(id)sender {
    
    [appDelegate dialNumber:_emergenceTel];
}





/*!
 *@description  响应点击蜂鸣按钮事件
 *@function     onHorn:
 *@param        sender     --按钮
 *@return       (void)
 */
- (IBAction)onHorn:(UIButton *)sender {
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
    [_hud setRemoveFromSuperViewOnHide:YES];
    
    if (_forbidImage.hidden) {
        [_hud setLabelText:@"正在关闭蜂鸣..."];
        BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
        [mainClient stopBeep:self];
    }else{
        [_hud setLabelText:@"正在开启蜂鸣..."];
        BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
        [mainClient startBeep:self];
    }
    
}




#pragma mark -
#pragma mark UITableViewDataSource method

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"BBInvadeCell";
    BBInvadeCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"BBInvadeCell" owner:self options:nil]lastObject];
    }
    NSArray *timeArr = [[_dataArr[indexPath.row] valueForKey:INVADE_TIME] componentsSeparatedByString:@" "];
    cell.dateLbl.text = timeArr[0];
    cell.timeLbl.text = timeArr[1];
    [cell.imgView setImageWithURL:[NSURL URLWithString:[_dataArr[indexPath.row] valueForKey:INVADE_IMAGE]]];
    
    return cell;
}

#pragma mark -
#pragma mark UITableView delegate method

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 185.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *urlArr = [NSMutableArray array];
    for (NSDictionary *dic in _dataArr) {
        NSURL *url = [NSURL URLWithString:[dic valueForKey:INVADE_IMAGE]];
        [urlArr addObject:url];
    }
    
    BBFullImageView *_fullImageView = [[BBFullImageView alloc]init];
    _fullImageView.curIndex = 0;
    [_fullImageView loadImagesFromUrls:urlArr];
    UIWindow *window = [[[UIApplication sharedApplication]delegate]window];
    _fullImageView.frame = window.bounds;
    [window addSubview:_fullImageView];
    [_fullImageView release];

}

#pragma mark -
#pragma mark BBSocketClient delegate method
-(int)onRecevie:(BBDataFrame *)src received:(BBDataFrame *)data
{
    if (src.MainCmd == 0x0F && src.SubCmd == 39) {
//        客户端文件读取请求
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *result = [[NSString alloc] initWithData:data.data encoding:NSUTF8StringEncoding];
            if (!result) {
                [_hud setLabelText:@"请求数据失败"];
            }else{
                
                NSArray *arr = [result componentsSeparatedByString:@"\t"];
                [result release];
                if ([arr[1] integerValue]==0) {
                    [_hud setLabelText:@"暂无数据"];
                }else{
                    
                    for (int i=3; i<arr.count-1; i++) {
                        NSArray *sigleArr = [arr[i] componentsSeparatedByString:@"\n"];
                        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                        [dic setValue:sigleArr[1] forKey:INVADE_TIME];
                        [dic setValue:sigleArr[3] forKey:INVADE_IMAGE];
                        [_dataArr addObject:dic];
                        [dic release];
                    }
                    
                    [_invadeTable reloadData];
                    
                    [_hud setLabelText:@"请求数据成功"];
                    
                }
            }
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
            
            [self performSelector:@selector(getTel) withObject:nil afterDelay:1.1f];
        });
    }else if (src.MainCmd == 0x0E && src.SubCmd == 13) {
        //蜂鸣
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSString *result = [[NSString alloc] initWithString:data.dataString];
            _forbidImage.hidden = _forbidImage.hidden?NO:YES;
            if (_forbidImage.hidden) {
                [_hud setLabelText:@"蜂鸣已开"];
            }else{
                [_hud setLabelText:@"蜂鸣已关"];
            }
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
            [_hornBrn performSelector:@selector(setEnabled:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.];
            [result release];
        });
    }else if (src.MainCmd == 0x0E && src.SubCmd == 79) {
        //获取紧急电话
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc] initWithString:data.dataString];
            if (result) {
                NSArray *arr = [result componentsSeparatedByString:@"\t\t"];
                [result release];
                if ([arr[0] isEqualToString:@"0"]) {
                    [_emergenceTel release];
                    _emergenceTel = [[NSString alloc]initWithString:arr[1]];
//                    [_hud setLabelText:@"获取紧急联系电话成功"];
                }else{
//                    [_hud setLabelText:@"获取紧急联系电话失败"];
                }
            }else{
//                [_hud setLabelText:@"获取紧急联系电话失败"];
            }
//            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }

    return 0;
}

-(void)onTimeout:(BBDataFrame *)src
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Timeout");
        if (src.MainCmd == 0x0F && src.SubCmd == 39) {
            //        客户端文件读取请求
            [_hud setLabelText:@"请求数据超时"];
            [self performSelector:@selector(getTel) withObject:nil afterDelay:1.1f];
        }else if (src.MainCmd == 0x0E && src.SubCmd == 13) {
            //蜂鸣
            [_hud setLabelText:@"开关蜂鸣超时"];
        }
        [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
    });
}

-(void)onClose
{
    NSLog(@"Socketet closed");
}

-(void)onRecevieError:(BBDataFrame*)src received:(BBDataFrame*)data
{
    NSLog(@"Recevie Error , src.SubCmd = %d",src.SubCmd);
    if (src.MainCmd == 0x0F && src.SubCmd == 39) {
        //        客户端文件读取请求
        dispatch_async(dispatch_get_main_queue(), ^{
            [_hud setLabelText:@"请求数据出错"];
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
            [self performSelector:@selector(getTel) withObject:nil afterDelay:1.1f];
        });
    }else if (src.MainCmd == 0x0E && src.SubCmd == 13) {
        //蜂鸣
        dispatch_async(dispatch_get_main_queue(), ^{
            [_hud setLabelText:@"开关蜂鸣出错"];
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }
}



@end
