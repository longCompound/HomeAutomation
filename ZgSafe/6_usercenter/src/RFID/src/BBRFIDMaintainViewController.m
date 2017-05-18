//
//  BBRFIDMaintainViewController.m
//  ZgSafe
//
//  Created by box on 13-10-30.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBRFIDMaintainViewController.h"
#import "BBRFIDCell.h"
#import "BBAddRFIDViewController.h"

@interface BBRFIDMaintainViewController ()<UITableViewDataSource,UITableViewDelegate,BBRFIDCellDelegate,BBSocketClientDelegate>
{
    MBProgressHUD *_hud;
    NSMutableArray *_dataArr;
}

- (IBAction)goBack:(id)sender;
- (IBAction)onClickAddBtn:(UIButton *)sender;

@end

@implementation BBRFIDMaintainViewController

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
    
    //    _dataArr = [[NSMutableArray alloc]init];
    //    [self getDatas];
    //    [_rfidTable reloadData];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    _dataArr = [[NSMutableArray alloc]init];
    [self getDatas];
    [_rfidTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_dataArr release];
    [_rfidTable release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setRfidTable:nil];
    [super viewDidUnload];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark self define method

/*!
 *@description  请求RFID数据
 *@function     getDatas
 *@param        (void)
 *@return       (void)
 */
- (void)getDatas
{
    [_dataArr removeAllObjects];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
    [_hud setLabelText:@"正在获取随身保数据..."];
    [_hud setRemoveFromSuperViewOnHide:YES];
    
    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
    NSString *userId = curUser.userid;
    [mainClient scanCard2:self param:userId];
}

/*!
 *@description      响应点击返回按钮事件
 *@function         goback:
 *@param            sender     --返回按钮
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
 *@description      响应点击添加按钮事件
 *@function         onClickAddBtn:
 *@param            sender     --添加按钮
 *@return           (void)
 */
- (IBAction)onClickAddBtn:(UIButton *)sender {
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
    [_hud setLabelText:@"正在请求注册随身保..."];
    [_hud setRemoveFromSuperViewOnHide:YES];
    
    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
    NSString *userId = curUser.userid;
    NSString *param = [NSString stringWithFormat:@"0\t%@\t\t\t",userId];
    [mainClient applyForRegistCard:self param:param];
    
}


/*!
 *@description  处理获取RFID结果
 *@function     handleReceiveRFID:data:
 *@param        src     --
 *@return       data    --返回数据
 */
- (void)handleReceiveRFID:(BBDataFrame *)src data:(BBDataFrame *)data{
    NSString *result = [[NSString alloc] initWithString:[data dataString]];
    NSString *strTxt=@"暂无随身保数据";
    
    [_dataArr removeAllObjects];
    
    if(result){
        NSArray *aryData=[result componentsSeparatedByString:@"\t"];
        if(aryData.count>2){
            if([aryData[0] intValue]>0){
                int i=2;
                while (i<(aryData.count-1)) {
                    NSDictionary *dic = @{
                                          RFID_KEY:aryData[i],
                                          NICKNAME_KEY:[aryData[i+1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
                                          HEAD_IMAGE_KEY:[UIImage imageNamed:@"male_on.png"]
                                          };
                    [_dataArr addObject:dic];
                    i=i+4;
                }
                
                [_rfidTable reloadData];
                
                strTxt=@"获取成功";
            }
        }
    }
    
//    NSArray *dataArr =nil;
//    
//    dataArr = [BBHomePageController parseData:data];
//    
//    if (dataArr && dataArr.count>0) {
//        result = [[NSString alloc]initWithString:dataArr[0]];
//        
//        if (result) {
//            NSArray *arr = [result componentsSeparatedByString:@"\t"];
//            
//            if(arr.count>3 && [arr[0] isEqualToString:@"0" ]){
//                
//                if([arr[1] integerValue]==0){
//                    [_dataArr removeAllObjects];
//                }else{
//                    NSDictionary *dic = @{
//                                          RFID_KEY:arr[3],
//                                          NICKNAME_KEY:[arr[4] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],
//                                          HEAD_IMAGE_KEY:[UIImage imageNamed:@"male_on.png"]
//                                          };
//                    [_dataArr addObject:dic];
//                    
//                    [_rfidTable reloadData];
//                    
//                    strTxt=@"获取成功";
//                    
//                }
//            }
//        }
//    }

    [result release];
    [_hud setLabelText:strTxt];
    [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5f];
}

#pragma mark -
#pragma mark UITableViewDataSource method

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentifier = @"BBRFIDCell";
    BBRFIDCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"BBRFIDCell" owner:self options:nil]lastObject];
        cell.delegate = self;
    }
    
    cell.nameTf.text = [_dataArr[indexPath.row] objectForKey:NICKNAME_KEY];
    cell.RFIDTf.text = [_dataArr[indexPath.row] objectForKey:RFID_KEY];
    cell.headImageView.image = [_dataArr[indexPath.row] objectForKey:HEAD_IMAGE_KEY];
    
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate method

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 125.0f;
}



#pragma mark -
#pragma mark BBRFIDCellDelegate method
- (void)didClickDeleteButton:(BBRFIDCell *)cell
{
    _willDeletedCell = cell;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NOTICE_TITLE
                                                    message:@"确定删除这个随身保吗？"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    [alert show];
    [alert release];
    
}



#pragma mark -
#pragma mark UIAlertView delegate method
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSIndexPath *indexPath = [_rfidTable indexPathForCell:_willDeletedCell];
        
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
        [_hud setLabelText:@"正在删除随身保..."];
        [_hud setRemoveFromSuperViewOnHide:YES];
        
        BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
        NSString *userId = curUser.userid;
        NSString *param = [NSString stringWithFormat:@"%@\t%@",userId,[_dataArr[indexPath.row] valueForKey:RFID_KEY]];
        [mainClient withdrawCard:self param:param];
        
    }
}

#pragma mark -
#pragma mark BBSocketClientDelegate method

-(int)onRecevie:(BBDataFrame *)src received:(BBDataFrame *)data
{
    if(src.MainCmd == 0x0E && src.SubCmd == 4) {
        //获取随身保列表
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleReceiveRFID:src data:data];
        });
    }else if(src.MainCmd == 0x0E && src.SubCmd == 6) {
        //删除随身保
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc]initWithString:[data dataString]];
            NSString *strTxt=@"删除随身保失败";
            
            if (result && [result isEqualToString:@"0"]) {
                NSIndexPath *indexPath = [_rfidTable indexPathForCell:_willDeletedCell];
                [_dataArr removeObjectAtIndex:indexPath.row];
                [_rfidTable deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationLeft];
                strTxt=@"删除随身保成功";
            }
            
            [result release];
            [_hud setLabelText:strTxt];
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5f];
        });
    }else if(src.MainCmd == 0x0E && src.SubCmd == 5) {
        //请求注册随身保
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc]initWithString:[data dataString]];
            NSString *strTxt=@"请求注册随身保失败";
            
            if(result){
                NSArray *arr = [result componentsSeparatedByString:@"\t"];
                
                if([arr[0] isEqualToString:@"0"]){
                    strTxt=@"请求注册随身保成功";
                    
                    BBAddRFIDViewController *vc = [[BBAddRFIDViewController alloc]init];
                    [vc.tableArray addObject:arr[1]];
                    if (self.navigationController) {
                        [self.navigationController pushViewController:vc animated:YES];
                    }else{
                        [self presentModalViewController:vc animated:YES];
                    }
                    [vc release];
                }
            }
            
            [result release];
            [_hud setLabelText:strTxt];
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5f];
        });
    }
    
    return 0;
}

-(void)onTimeout:(BBDataFrame *)src
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_hud setLabelText:@"请求超时"];
        [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
    });
}


-(void)onRecevieError:(BBDataFrame*)src received:(BBDataFrame*)data
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_hud setLabelText:@"请求出错"];
        [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
    });
}



@end
