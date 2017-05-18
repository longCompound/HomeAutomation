//
//  BBAddRFIDViewController.m
//  ZgSafe
//
//  Created by box on 13-11-4.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBAddRFIDViewController.h"
#import "BBRFIDMaintainViewController.h"
@interface BBAddRFIDViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate,BBSocketClientDelegate>
{
    BOOL isopen;
    MBProgressHUD *_hud;
    BOOL _selectedHeadImage;//选择了头像
}

- (IBAction)onSelectRFID:(UIButton *)sender;
- (IBAction)goBack:(UIButton *)sender;
- (IBAction)onCommit:(UIButton *)sender;
- (IBAction)onTakePhoto:(UIButton *)sender;
- (IBAction)onLocalUpLoad:(UIButton *)sender;
- (IBAction)onCancel:(UIButton *)sender;

@property (retain, nonatomic) IBOutlet UIView *RFIDView;
@property (retain, nonatomic) IBOutlet UITextField *RFIDTf;
@property (retain, nonatomic) IBOutlet UITextField *nameTf;
@property (retain, nonatomic) IBOutlet UITableView *RFIDTable;
@property (retain, nonatomic) IBOutlet UIButton *RFIDBtn;
@property (retain, nonatomic) IBOutlet UIImageView *headImage;
@property (retain, nonatomic) IBOutlet UIView *actionSheet;

@end

@implementation BBAddRFIDViewController


#pragma mark -
#pragma mark - system  method
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _tableArray =[[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setModalPresentationStyle:UIModalPresentationFullScreen];
    
    _RFIDTf.enabled=NO;
    
    isopen =YES;
    _selectedHeadImage = NO;
    _RFIDBtn.hidden = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onChooseImage:)];
    [_headImage addGestureRecognizer:tap];
    [tap release];
    
    
    _actionSheet.center = CGPointMake(_actionSheet.center.x
                                      , self.view.frame.size.height
                                      +_actionSheet.frame.size.height/2.);
    [self.view addSubview:_actionSheet];

    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _RFIDTf.text = _tableArray[0];
    });
}


- (void)dealloc {
    [_RFIDView release];
    [_RFIDTable release];
    [_RFIDBtn release];
    [_headImage release];
    [_actionSheet release];
    [_RFIDTf release];
    [_nameTf release];
    [_tableArray release];
    [super dealloc];
}


- (void)viewDidUnload {
    [self setRFIDView:nil];
    [self setRFIDTable:nil];
    [self setRFIDBtn:nil];
    [self setHeadImage:nil];
    [self setActionSheet:nil];
    [self setRFIDTf:nil];
    [self setNameTf:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    [self hideRFIDTable];
    if(_actionSheet.center.y < self.view.frame.size.height){
        [self hideActionSheet];
    }
    if (isopen==NO) {
        CGFloat sysVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (sysVersion >= 7.0) {
            [UIView animateWithDuration:0.25 animations:^{
                NSLog(@"%f",self.view.frame.origin.y);
                [self.view setCenter:CGPointMake(self.view.frame.size.width/2,self.view.frame.origin.y+370)];
            }];

        }else{
        
        [UIView animateWithDuration:0.25 animations:^{
            NSLog(@"%f",self.view.frame.origin.y);
            [self.view setCenter:CGPointMake(self.view.frame.size.width/2,self.view.frame.origin.y+350)];
        }];
        }
        isopen=YES;

    }
  }

#pragma mark -
#pragma mark - self define method

/*!
 *@description      隐藏RFIDTable
 *@function         hideRFIDTable
 *@param            (void)
 *@return           (void)
 */
- (void)hideRFIDTable
{
    if (!_RFIDView.hidden) {
        [UIView animateWithDuration:0.5f animations:^{
            _RFIDView.alpha = 0.;
        }completion:^(BOOL finished) {
            _RFIDView.hidden = YES;
        }];
    }
}

/*!
 *@description      隐藏自定义的actionsheet
 *@function         hideActionSheet
 *@param            (void)
 *@return           (void)
 */
- (void)hideActionSheet
{
    [UIView animateWithDuration:0.25f animations:^{
        _actionSheet.center = CGPointMake(_actionSheet.center.x
                                          , self.view.frame.size.height
                                          +_actionSheet.frame.size.height/2.);
    }];
}

/*!
 *@description      响应点击返回按钮事件
 *@function         goback:
 *@param            sender     --返回按钮
 *@return           (void)
 */
- (IBAction)goBack:(UIButton *)sender {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.presentingViewController dismissModalViewControllerAnimated:YES];
    }
}


/*!
 *@description      响应点击选择RFID卡按钮事件
 *@function         onSelectRFID:
 *@param            sender     --返回按钮
 *@return           (void)
 */
- (IBAction)onSelectRFID:(UIButton *)sender {
    if (_RFIDView.hidden) {
        _RFIDView.alpha = 0.;
        _RFIDView.hidden = NO;
        [UIView animateWithDuration:0.5f animations:^{
            _RFIDView.alpha = 1.0f;
        }];
    }else
    {
        [self hideRFIDTable];
    }
}


/*!
 *@description      响应点击提交按钮事件
 *@function         onCommit:
 *@param            sender     --返回按钮
 *@return           (void)
 */
- (IBAction)onCommit:(UIButton *)sender {
    
    if (!_nameTf.text.length) {
        UtilAlert(@"请填写名称", nil);
        return;
    }
    if (!_RFIDTf.text.length) {
        UtilAlert(@"请填写随身保", nil);
        return;
    }
    
    [self toSaveRFIDInfo];
    
//    UIAlertView *dialAlert = [[UIAlertView alloc] initWithTitle:NOTICE_TITLE
//                                                        message:@"确定要添加这个随身保吗？"
//                                                       delegate:self
//                                              cancelButtonTitle:@"取消"
//                                              otherButtonTitles:@"确定", nil];
//    [dialAlert show];
//    [dialAlert release];

}

/*!
 *@description      响应点击拍照按钮事件
 *@function         onTakePhoto:
 *@param            sender     --拍照按钮
 *@return           (void)
 */
- (IBAction)onTakePhoto:(UIButton *)sender {
    
    [self hideActionSheet];
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UtilAlert(@"当前设备不支持摄像头", nil);
        return;
    }
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self presentModalViewController:imagePicker animated:YES];
    [imagePicker release];
}

/*!
 *@description      响应点击本地上传按钮事件
 *@function         onTakePhoto:
 *@param            sender     --本地上传按钮
 *@return           (void)
 */
- (IBAction)onLocalUpLoad:(UIButton *)sender {
    [self hideActionSheet];
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentModalViewController:imagePicker animated:YES];
    [imagePicker release];
}

/*!
 *@description      响应点击取消按钮事件
 *@function         onChooseImage:
 *@param            sender     --取消按钮
 *@return           (void)
 */
- (IBAction)onCancel:(UIButton *)sender {
    [self hideActionSheet];
}


/*!
 *@description      响应点击头像事件
 *@function         onChooseImage:
 *@param            gesture     --手势
 *@return           (void)
 */
- (void)onChooseImage:(UITapGestureRecognizer *)gesture
{
    [UIView animateWithDuration:0.25f animations:^{
        _actionSheet.center = CGPointMake(_actionSheet.center.x
                                          , self.view.frame.size.height
                                          -_actionSheet.frame.size.height/2.);
    }];
}

#pragma mark -
#pragma mark UITableViewDataSource method

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _tableArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indentifier = @"RFIDCardCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier]autorelease];
        [cell.textLabel setFont:[UIFont systemFontOfSize:12]];
        [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.textLabel.text=[_tableArray objectAtIndex:indexPath.row];

    }

   
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate method

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    _RFIDTf.text = cell.textLabel.text;

    [self hideRFIDTable];
}

#pragma mark -
#pragma mark - UIImagePickerControllerDelegate method
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    if (IOS_VERSION>=7.0) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    
    UIImage *img = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    _headImage.image = img;
    _selectedHeadImage = YES;
    CATransition *anim = [CATransition animation];
    anim.duration = 0.5f;
    anim.type = @"cube";
    anim.subtype = @"fromLeft";
    [_headImage.layer addAnimation:anim forKey:nil];
    
    [self dismissModalViewControllerAnimated:YES];


}
#pragma mark-
#pragma mark UITextFieldDelegate method
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (self.view.frame.size.height<=480) {
        if (isopen == YES) {
                [UIView animateWithDuration:0.25 animations:^{
                NSLog(@"%f",self.view.frame.origin.y);
                [self.view setCenter:CGPointMake(self.view.frame.size.width/2,self.view.frame.origin.x+110)];
            }];
            isopen=NO;
        }else{
           
        }
            }else{
        NSLog(@"我的高是580");
        
    }
    
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (isopen==NO) {
        [UIView animateWithDuration:0.25 animations:^{
                       [self.view setCenter:CGPointMake(self.view.frame.size.width/2,self.view.frame.origin.y+350)];
        }];
        isopen=YES;
    }
       return YES;
}

//请求上传文件
-(void)toRequestUpFile{
    if(_selectedHeadImage){

        UIImage *selctedImage = _headImage.image;
        
        CGSize size = CGSizeMake(20, 20);
        UIGraphicsBeginImageContext(size);
        [selctedImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *compressImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *compressData = UIImageJPEGRepresentation(compressImage, 1.0f);
        
        NSDateFormatter *fmt = [[NSDateFormatter alloc]init];
        [fmt setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *dateStr = [fmt stringFromDate:[NSDate date]];
        [fmt release];
        
        NSString *param =[[[NSString alloc]initWithFormat:@"%@\t%@\t%@\t1\t0",curUser.userid,@"255",dateStr]autorelease];
        BBFileClient *fileClient = [[BBSocketManager getInstance] fileClient];
        [fileClient requestForWriteFile:self param:param];
    }
}

//上传文件
-(void)toUPFile{

}

//保存RFID卡信息
-(void)toSaveRFIDInfo
{
   
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
    [_hud setLabelText:@"正在保存随身保信息"];
    [_hud setRemoveFromSuperViewOnHide:YES];
    
    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
    
    // 发送注册信息
    NSMutableData *data = [NSMutableData data];
    //      模式:1
    [data appendData:[@"1" dataUsingEncoding:GBK_ENCODEING]];
    //      用户ID
    NSString *userID = [NSString stringWithFormat:@"\t%@",curUser.userid];
    [data appendData:[userID dataUsingEncoding:GBK_ENCODEING]];
    //      卡片ID
    NSString *cardID = [NSString stringWithFormat:@"\t%@\t", _RFIDTf.text];
    [data appendData:[cardID dataUsingEncoding:GBK_ENCODEING]];
    //      昵称
    [data appendData:[_nameTf.text dataUsingEncoding:GBK_ENCODEING]];
    [data appendData:[@"\t" dataUsingEncoding:GBK_ENCODEING]];
    
    UIImage *selctedImage = nil;
    if (!_selectedHeadImage) {
        selctedImage = [UIImage imageNamed:@"male_on.png"];
        _selectedHeadImage = YES;
    }else{
        selctedImage = _headImage.image;
    }
    
    if (_selectedHeadImage) {
        //      头像数据
        //            CGFloat limit = 40.0f * 1024.0f;//服务器限制头像大小
        //            NSData *imgData = UIImageJPEGRepresentation([UIImage imageNamed:@"male_on.png"], 1.0f);
        ////            NSData *imgData = UIImageJPEGRepresentation(_headImage.image, 1.0f);
        //            CGFloat k = (CGFloat)(limit/imgData.length);
        //            if (k > 1.0f) {
        //                k = 1.0f;
        //            }
        //            NSData *compressData = UIImageJPEGRepresentation([UIImage imageNamed:@"male_on.png"], k);
        
        CGSize size = CGSizeMake(20, 20);
        UIGraphicsBeginImageContext(size);
        [selctedImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *compressImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSData *compressData = UIImageJPEGRepresentation(compressImage, 1.0f);
        
        BBLog(@"加图片前 headImage data.length = %d",data.length);
        [data appendData:compressData];
    }
    BBLog(@"headImage data.length = %d",data.length);
    
    [mainClient registCard:self param:data];
    
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.presentingViewController dismissModalViewControllerAnimated:YES];
    }
    
    
    
}

#pragma mark -
#pragma mark BBSocketClientDelegate method


-(int)onRecevie:(BBDataFrame *)src received:(BBDataFrame *)data
{   
    if(src.MainCmd == 0x0E && src.SubCmd == 5) {
        //注册RFID卡
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc]initWithString:[data dataString]];
            NSString *strMsg=@"随身保保存失败";
            
            if (result) {
                NSArray *arr = [result componentsSeparatedByString:@"\t"];
                if ([arr[0] isEqualToString:@"0"]) {
                    
                    _nameTf.text = @"";
                    _RFIDTf.text = @"";
                    _headImage.image = [UIImage imageNamed:@"add_btn_pic.png"];
                    
//                    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
//                    [dic setValue:_nameTf.text forKey:NICKNAME_KEY];
//                    [dic setValue:_RFIDTf.text forKey:RFID_KEY];
//                    [dic setValue:_headImage.image forKey:HEAD_IMAGE_KEY];
                    
                    BBRFIDMaintainViewController *vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count-2];
                    [vc getDatas];
//                    [vc.dataArr addObject:dic];
//                    [dic release];
//                    [vc.rfidTable reloadData];
                    
                    strMsg=@"随身保保存成功";
                    
                }else{
                    if (arr.count > 1) {
                        strMsg=arr[1];
                    }
                }
                [result release];
            }
            
            [_hud setLabelText:strMsg];
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5f];
        });
    }else if(src.MainCmd == 0x0f && src.SubCmd == 18){
        NSLog(@"请求上传文件");
    }
    
    return 0;
}

-(void)onTimeout:(BBDataFrame *)src
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_hud setLabelText:@"随身保添加超时"];
        [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5f];
    });
}


-(void)onRecevieError:(BBDataFrame*)src received:(BBDataFrame*)data
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_hud setLabelText:@"随身保添加失败"];
        [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5f];
    });
}




@end
