//
//  BBAdressManageViewController.m
//  ZgSafe
//
//  Created by box on 13-10-31.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBAdressManageViewController.h"
#import "BBAdressCell.h"
#import "BBAddAdressViewController.h"

@interface BBAdressManageViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate,BBSocketClientDelegate,BBAdressCellDelegate>
{
    NSInteger _clickedIndexPathRow;
    MBProgressHUD *_hud;
    NSInteger _indexPathRow;
    BBAdressCell *_willDeletedCell;
    BOOL _isDeleteAddress;//是否是删除地址（输入验证码的时候区分删地址和切换地址）
}

- (IBAction)goBack:(id)sender;
- (IBAction)onClickAddBtn:(UIButton *)sender;

@end

@implementation BBAdressManageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark -
#pragma mark life cycle method
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _currentSelectedDevice = [[NSString alloc]init];
    _dataArr = [[NSMutableArray alloc]init];
    [self getDatas];
    
}


/*!
 *@description  请求地址列表数据
 *@function     getDatas
 *@param        (void)
 *@return       (void)
 */
- (void)getDatas
{
    [_dataArr removeAllObjects];
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
    [_hud setLabelText:@"正在获取地址列表..."];
    [_hud setRemoveFromSuperViewOnHide:YES];
    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
    NSString *userId = curUser.userid;
    [mainClient queryUserDevices:self param:userId];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_currentSelectedDevice release];
    [_adressTeble release];
    [_dataArr release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setAdressTeble:nil];
    [super viewDidUnload];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


#pragma mark -
#pragma mark self define method

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
    BBAddAdressViewController *vc = [[BBAddAdressViewController alloc]init];
    if (self.navigationController) {
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self presentModalViewController:vc animated:YES];
    }
    [vc release];
}




#pragma mark -
#pragma mark UITableViewDataSource method

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}


- (BBAdressCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentifier = @"BBAdressCell";
    BBAdressCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"BBAdressCell" owner:self options:nil]lastObject];
    }
    
    NSString *deviceID = [_dataArr[indexPath.row] objectForKey:DEVICE_KEY];
    NSString *shortDeviceID = [deviceID stringByReplacingCharactersInRange:NSMakeRange(7, 5) withString:@"..."];
    cell.adressTf.text = [_dataArr[indexPath.row] objectForKey:ADRESS_KEY];
    cell.deviceTf.text =  shortDeviceID;
    if ([deviceID isEqualToString:_currentSelectedDevice]) {
        cell.selectIndicateImage.hidden = NO;
    }else{
        cell.selectIndicateImage.hidden = YES;;
    }
    
    cell.delegate = self;
    
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate method

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 111.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _indexPathRow = indexPath.row;
    BBAdressCell *cell;
    cell = (BBAdressCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    NSString *curDeviceID = [_dataArr[indexPath.row] objectForKey:DEVICE_KEY];
    if (![curDeviceID isEqualToString:_currentSelectedDevice])
    {
        
        _isDeleteAddress = NO;
        _clickedIndexPathRow = indexPath.row;
        
        _willDeletedCell = cell;
        _isDeleteAddress = YES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NOTICE_TITLE
                                                        message:@"确定切换吗？"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
        //        alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
        alert.tag = 10001;
        [alert show];
        [alert release];
    }
    
}


#pragma mark -
#pragma mark BBAdressCellDelegate method
- (void)didClickDeleteButton:(BBAdressCell *)cell
{
    _willDeletedCell = cell;
    _isDeleteAddress = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NOTICE_TITLE
                                                    message:@"请输入验证码"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    alert.alertViewStyle = UIAlertViewStyleSecureTextInput;
    alert.tag = 10000;
    [alert show];
    [alert release];
}

#pragma mark -
#pragma mark UIAlertView delegate method
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (alertView.tag == 10000) {//删除地址
            
            UITextField *pswdTf = [alertView textFieldAtIndex:0];
            _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
            [_hud setLabelText:@"正在删除..."];
            [_hud setRemoveFromSuperViewOnHide:YES];
            
            BBMainClient *mainClient = [[BBSocketManager getInstance]mainClient];
            NSIndexPath *indexPath = [_adressTeble indexPathForCell:_willDeletedCell];
            NSString *deviceID = [_dataArr[indexPath.row] objectForKey:DEVICE_KEY];
            NSString *param = [NSString stringWithFormat:@"%@\t%@\t%@",curUser.userid,deviceID,pswdTf.text];
            [mainClient deleteDevice:self param:param];
        }else{//切换地址
            _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            _hud.labelFont = [UIFont systemFontOfSize:13.0f];
            _hud.labelText = @"正在切换...";
            _hud.removeFromSuperViewOnHide = YES;
            
            BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
            NSString *userId = curUser.userid;
            
            NSString *deviceID = [_dataArr[_clickedIndexPathRow] valueForKey:DEVICE_KEY];
            
            NSString *param = [NSString stringWithFormat:@"%@\t%@\t%@",userId,deviceID,@"1"];//地址切换 切换设备不需要输入验证码 所以随便填了个1
            [mainClient changeTerminal:self param:param];
            
        }
    }
}


#pragma mark -
#pragma mark UITextFieldDelegate method
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark -
#pragma mark BBSocketClientDelegate method

-(int)onRecevie:(BBDataFrame *)src received:(BBDataFrame *)data
{
    if(src.MainCmd == 0x0E && src.SubCmd == 71) {
        //切换终端
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc]initWithString:[data dataString]];
            NSString *strTxt=@"切换失败";
            
            if(result && [result isEqualToString:@"0"]){
                [appDelegate.homePageVC getAllDatas];
                [appDelegate.homePageVC genMemberView:[NSArray array]];//删除首页成员列表
                NSString *deviceID = [_dataArr[_clickedIndexPathRow] valueForKey:DEVICE_KEY];
                [_currentSelectedDevice release];
                _currentSelectedDevice = [[NSString alloc]initWithString:deviceID];
                [_adressTeble reloadData];
                strTxt=@"切换成功";
            }
            _hud.labelText=strTxt;
            [result release];
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5f];
        });
        
    }else if(src.MainCmd == 0x0E && src.SubCmd == 82) {
        //获取当前用户设备信息
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc] initWithString:[data dataString]];
            NSString *strTxt=@"获取地址列表失败";
            
            if(result){
                NSArray *arr = [result componentsSeparatedByString:@"\t"];
                [result release];
                
                if([arr[0] isEqualToString:@"0"]){
                    strTxt=@"获取地址列表成功";
                    
                    for (int i=2; i<arr.count; i++) {
                        NSArray *sigleArr = [arr[i] componentsSeparatedByString:@"\n"];
                        NSDictionary *dic = @{ADRESS_KEY:sigleArr[1],
                                              DEVICE_KEY:sigleArr[0]};
                        [_dataArr addObject:dic];
                    }
                    
                    [_adressTeble reloadData];
                    
                    _currentSelectedDevice = curUser.deviceid;
                }
            }
            
            [_hud setLabelText:strTxt];
            
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5f];
        });
    }else if(src.MainCmd == 0x0E && src.SubCmd == 87) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc]initWithString:[data dataString]];
            NSString *strTxt=@"删除失败";
            
            if(result){
                if ([result isEqualToString:@"0"]) {
                    NSIndexPath *indexPath = [_adressTeble indexPathForCell:_willDeletedCell];
                    [_dataArr removeObjectAtIndex:indexPath.row];
                    [_adressTeble deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationLeft];
                    
                    strTxt = @"删除成功";
                    
                    
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
    
    if(src.MainCmd == 0x0E && src.SubCmd == 71) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _hud.labelText = @"切换超时";
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }else if(src.MainCmd == 0x0E && src.SubCmd == 80) {
        //获取当前绑定的终端
        dispatch_async(dispatch_get_main_queue(), ^{
            _hud.labelText = @"获取当前选择地址超时";
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }else if(src.MainCmd == 0x0E && src.SubCmd == 82) {
        //获取当前用户设备信息
        dispatch_async(dispatch_get_main_queue(), ^{
            _hud.labelText = @"获取地址列表超时";
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }else if(src.MainCmd == 0x0E && src.SubCmd == 87) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _hud.labelText = @"删除超时";
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }
    
}


-(void)onRecevieError:(BBDataFrame*)src received:(BBDataFrame*)data
{
    if(src.MainCmd == 0x0E && src.SubCmd == 71) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _hud.labelText = @"切换出现错误";
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }else if(src.MainCmd == 0x0E && src.SubCmd == 80) {
        //获取当前绑定的终端
        dispatch_async(dispatch_get_main_queue(), ^{
            _hud.labelText = @"获取当前选择地址出现错误";
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }else if(src.MainCmd == 0x0E && src.SubCmd == 82) {
        //获取当前用户设备信息
        dispatch_async(dispatch_get_main_queue(), ^{
            _hud.labelText = @"获取地址列表出现错误";
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }else if(src.MainCmd == 0x0E && src.SubCmd == 87) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _hud.labelText = @"删除出错";
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }
}

@end
