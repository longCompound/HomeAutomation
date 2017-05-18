    //
//  BBAlbumsViewController.m
//  ZgSafe
//  云相册
//  Created by YANGReal on 13-10-28.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBAlbumsViewController.h"
#import "BBAlbumsCell.h"
#import "BBAlDetailsViewController.h"
#import "BBSideBarView.h"
#import "BBDateKeyBoard.h"
#import "MJRefresh.h"
#import "BBUserCenterViewController.h"
#import "BBHuiAplViewController.h"
#import "BBMarkViewController.h"

@interface BBAlbumsViewController ()<UITableViewDataSource,UITableViewDelegate,BBDateKeyBoardDelegate,MJRefreshBaseViewDelegate,BBSideBarViewDelegate,UIScrollViewDelegate,BBDateKeyBoardDelegate,BBSocketClientDelegate,BBAlbumsCellDelegate
>
{
    NSInteger _row;
    BBSideBarView *_siderBar;
    BBDateKeyBoard *_dateKeyboard;
//    MJRefreshFooterView *_footterView;
//    MJRefreshHeaderView *_headerViw;
    NSMutableArray *_dataArr;
    BOOL isOpen;
    MBProgressHUD *_hud;
    BOOL _defaultSearch;//是默认查询
    
}
- (IBAction)goback:(id)sender;
@property (retain, nonatomic) IBOutlet UITextField *currentSelectDate;

@property (retain, nonatomic) IBOutlet UIButton *typeBrn;       //选择类型

@property (retain, nonatomic) IBOutlet UIView *typeView;        //类型弹出框

@property (retain, nonatomic) IBOutlet UIView *backgroundView;//大的button

- (IBAction)style_click:(id)sender;

- (IBAction)checkButtons:(UIButton *)sender;//点击消失全部；

- (IBAction)checkButton:(UIButton *)sender;

- (IBAction)chooseType:(id)sender;
@property (retain, nonatomic) IBOutlet UITableView *showTab;

@end

@implementation BBAlbumsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

#pragma mark -
#pragma mark sysetem method
- (void)viewDidLoad
{
    [super viewDidLoad];
    isOpen=YES;
    _row=5;
    _siderBar = [BBSideBarView siderBarWithBesideView:self.view];
    _siderBar.delegate=self;
    _dateKeyboard = [[[[NSBundle mainBundle]loadNibNamed:@"BBDateKeyBoard" owner:self options:nil]lastObject]retain];
    [_dateKeyboard setFrame:CGRectMake(0,appDelegate.window.frame.size.height,_dateKeyboard.frame.size.width , _dateKeyboard.frame.size.height)];
    [self.view addSubview:_dateKeyboard];
    _dateKeyboard.delegate = self;
    [_dateKeyboard release];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    _currentSelectDate.text = dateStr;
    
    //_footterView = [[MJRefreshFooterView alloc]init];
    //_footterView.delegate=self;
    //_footterView.scrollView=_showTab;
    //_headerViw = [[MJRefreshHeaderView alloc]init];
    //_headerViw.delegate=self;
    //_headerViw.scrollView=_showTab;
    //_headerViw.backgroundColor = [UIColor clearColor];
    //_footterView.backgroundColor = [UIColor clearColor];
    _dataArr = [[NSMutableArray alloc]init];
    
    _defaultSearch = YES;
    
    [self getDatasWhileSelectedType:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_showTab reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void)dealloc {
    [_showTab release];
    [_typeBrn release];
    [_typeView release];
    [_siderBar remove];
    [_currentSelectDate release];
//    [_footterView free];
//    [_headerViw free];
    [_backgroundView release];
    [_dataArr release];
    
    [super dealloc];
}
- (void)viewDidUnload {
    [self setShowTab:nil];
    [self setTypeBrn:nil];
    [self setTypeView:nil];
    [self setCurrentSelectDate:nil];
    [self setBackgroundView:nil];
    [super viewDidUnload];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

/*!
 *@description  请求数据
 *@function     getDatasWhileSelectedType：
 *@param        selectedType    --是否是选择类型 YES：选择的类型  NO：选择的日期
 *@return       (void)
 */
- (void)getDatasWhileSelectedType:(BOOL)selectedType
{
    [_dataArr removeAllObjects];
    
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
    [_hud setLabelText:@"正在请求数据..."];
    [_hud setRemoveFromSuperViewOnHide:YES];
    
    NSString *userId = curUser.userid;
    NSMutableString *param = [[NSMutableString alloc]initWithString:userId];
    
    if ([_typeBrn.titleLabel.text isEqualToString:@"全部"]) {
        [param appendFormat:@"\t%@\t1",[_currentSelectDate.text stringByReplacingOccurrencesOfString:@"/" withString:@"-"]];
    }
    else if ([_typeBrn.titleLabel.text isEqualToString:@"入侵"]) {
        [param appendFormat:@"\t%@\t4",[_currentSelectDate.text stringByReplacingOccurrencesOfString:@"/" withString:@"-"]];
    }
    else{
        [param appendFormat:@"\t%@\t5",[_currentSelectDate.text stringByReplacingOccurrencesOfString:@"/" withString:@"-"]];
    }

    
    
   /* if (selectedType) {
        
        if ([_typeBrn.titleLabel.text isEqualToString:@"全部"]) {
            [param appendFormat:@"\t%@\t0",[_currentSelectDate.text stringByReplacingOccurrencesOfString:@"/" withString:@"-"]];
        }else if ([_typeBrn.titleLabel.text isEqualToString:@"入侵"]) {
            [param appendFormat:@"\t%@\t2",[_currentSelectDate.text stringByReplacingOccurrencesOfString:@"/" withString:@"-"]];
        }else{
            [param appendFormat:@"\t%@\t3",[_currentSelectDate.text stringByReplacingOccurrencesOfString:@"/" withString:@"-"]];
        }
    }else{

        
    }*/
    
    
    /**
     请求类型,
     0: 默认查询(抓拍,入侵,三天内记录),
     1: 按时间查询
     2: 全部入侵图片(三天内记录)
     3: 全部抓拍图片(三天内记录)
     4: 按时间入侵图片
     5: 按时间抓拍图片
     */
    
    BBFileClient *fileClient = [[BBSocketManager getInstance] fileClient];
    [fileClient getFileRequest:self param:param];
    [param release];
    
}

#pragma mark -
#pragma mark UITableViewDataSource and UITableViewDelegate method
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    [_footterView endRefreshing];
//    [_headerViw endRefreshing];
    if (_dataArr) {
        return _dataArr.count;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *showCell = @"showCell";
    BBAlbumsCell *cell = [tableView dequeueReusableCellWithIdentifier:showCell];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"BBAlbumsCell" owner:nil options:nil] lastObject];
    }
    cell.delegate = self;
    cell.indexPath = indexPath;
    NSDictionary *dic = _dataArr[indexPath.row];

    BOOL haveInvadeImage = [[dic valueForKey:HAVE_INVADE_IMAGE]boolValue];
    BOOL haveSnapImage = [[dic valueForKey:HAVE_SNAP_IMAGE]boolValue];
    if (haveInvadeImage && !haveSnapImage) {
        cell.invadeLbl.frame = CGRectMake(22, 14, 50, 21);
        cell.invadeLbl.hidden = NO;
        cell.snapLbl.hidden = YES;
    }else if (!haveInvadeImage && haveSnapImage) {
        cell.snapLbl.frame = CGRectMake(22, 14, 50, 21);
        cell.snapLbl.hidden = NO;
        cell.invadeLbl.hidden = YES;
    }else{
        cell.invadeLbl.frame = CGRectMake(22, 14, 50, 21);
        cell.invadeLbl.hidden = NO;
        cell.snapLbl.frame = CGRectMake(73, 14, 50, 21);
        cell.snapLbl.hidden = NO;
    }
    
    NSInteger cellCount = [[dic objectForKey:IMAGES_COUNT_KEY] integerValue];
    
    //显示有图片的imageview
    NSArray *imageArr = [dic valueForKey:IMAGES_KEY];
    int i;
    for (i = 0; i<cellCount && i<4; i++) {
        UIImageView *imageView = (UIImageView *)[cell.ImgView viewWithTag:1400+i];
        imageView.hidden = NO;
        [imageView setImageWithURL:[NSURL URLWithString:[imageArr[i] valueForKey:IMAGE_KEY]]];
    }
    //隐藏无图片的imageview
    for (; i<4; i++) {
        [cell.ImgView viewWithTag:1400+i].hidden = YES;
    }
    
    for (UIGestureRecognizer *ges in cell.ImgView.gestureRecognizers) {
        [cell.ImgView removeGestureRecognizer:ges];
    }
    
    cell.totalShe.text = [NSString stringWithFormat:@"%@张",[dic objectForKey:IMAGES_COUNT_KEY]];
    cell.time.text = [[dic objectForKey:IMAGES_TIME_KEY] componentsSeparatedByString:@" "][0];
    
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onShowDetailImages:)];
//    [cell.ImgView addGestureRecognizer:tap];
//    [tap release];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger imageCount = [[_dataArr[indexPath.row] objectForKey:IMAGES_COUNT_KEY] integerValue];
    if (imageCount>2) {
        return 190.0f;
    }else{
        return 190.0f - 70.0f;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [_siderBar hide];
    //!在日期键盘上点击了取消
    if (isOpen==NO) {
        [self chickDate:_dateKeyboard.frame.size.height];
    }
    isOpen = YES;
}


#pragma mark -
#pragma mark self define  method

/*!
 *@description      响应点击cell上的图片事件
 *@function         onShowDetailImages:
 *@param            gesture    --手势
 *@return           IBAction
 */
- (void)onShowDetailImages:(UITapGestureRecognizer *)gesture
{
    [_siderBar setHidden:YES];
    BBAlbumsCell *selectedCell = nil;
    for (BBAlbumsCell *cell in _showTab.visibleCells) {
        if ( CGRectContainsPoint(cell.ImgView.bounds, [gesture locationInView:cell.ImgView]) ) {
            selectedCell = cell;
            break;
        }
    }
    BBAlDetailsViewController *vc = [[BBAlDetailsViewController alloc]init];
    if (selectedCell) {
        vc.timeStr = selectedCell.time.text;
        NSIndexPath *indexPath = [_showTab indexPathForCell:selectedCell];
        vc.index = indexPath.row;
        vc.dataArr = _dataArr;
    }
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
    //在日期键盘上点击了取消
    if (isOpen==NO) {
        [self chickDate:_dateKeyboard.frame.size.height];
    }

}

- (void)hideActionSheet
{
    [UIView animateWithDuration:0.25 animations:^{
        [_backgroundView setHidden:YES];
        _typeView.frame = CGRectMake(0,
                                     self.view.frame.size.height,
                                     _typeView.frame.size.width,
                                     _typeView.frame.size.height);
    }];
}

/*!
 *@description 选择类型   全部,入侵...
 *@function style_click:
 *@param sender
 *@return IBAction
 */
- (IBAction)style_click:(id)sender {
    //在日期键盘上点击了取消
    if (isOpen==NO) {
        [self chickDate:_dateKeyboard.frame.size.height];
    }
    isOpen = YES;
    [self hideActionSheet];
    UIButton *btn = (UIButton*)sender;
    
    if (![btn.titleLabel.text isEqualToString:@"取消"]) {
        [_typeBrn setTitle:btn.titleLabel.text forState:UIControlStateNormal];
        _defaultSearch = NO;
        [self getDatasWhileSelectedType:YES];
    }
}
/*!
 *@brief        点击button全部消失
 *@function     checkButtons
 *@param        sender
 *@return       （void）
 */
- (IBAction)checkButtons:(UIButton *)sender {
    [_backgroundView setHidden:YES];
    [UIView animateWithDuration:0.25 animations:^{
        _typeView.frame = CGRectMake(0,
                                     self.view.frame.size.height+_typeView.frame.size.height,
                                     _typeView.frame.size.width,
                                     _typeView.frame.size.height);
    }];

}




/*!
 *@description 选择时间
 *@function chooseTime:
 *@param sender
 *@return IBAction
 */
- (IBAction)chooseTime:(id)sender {
    
}

/*!
 *@description 选择类型
 *@function chooseType:
 *@param sender
 *@return IBAction
 */
- (IBAction)chooseType:(id)sender {
    //在日期键盘上点击了取消
    if (isOpen==NO) {
        [self chickDate:_dateKeyboard.frame.size.height];
    }
    isOpen = YES;
    
    [_backgroundView setHidden:NO];
    [UIView animateWithDuration:0.25 animations:^{
        _typeView.frame = CGRectMake(0,
                                     self.view.frame.size.height-_typeView.frame.size.height,
                                     _typeView.frame.size.width,
                                     _typeView.frame.size.height);
    }];
    
}
/*!
 *@description 返回上级页面
 *@function goback
 *@return IBAction
 */
- (IBAction)goback:(id)sender {
    [_siderBar hide];
    
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.presentingViewController dismissModalViewControllerAnimated:YES];
    }
    
//    if (self.navigationController) {
//        [self.navigationController popToRootViewControllerAnimated:YES];
//    }else{
//        UIViewController *vc = self;
//        while (![vc isKindOfClass:[UINavigationController class]]) {
//            UIViewController *tempVC = vc.presentingViewController;
//            if ([tempVC isKindOfClass:[UINavigationController class]]) {
//                [vc dismissModalViewControllerAnimated:YES];
//            }else{
//                [vc dismissModalViewControllerAnimated:NO];
//            }
//            vc = tempVC;
//        }
//    }
}
/*!
 *@brief        点击弹出时间的button
 *@function     clickDateButton
 *@param        sender
 *@return       （void）
 */
- (IBAction)checkButton:(UIButton *)sender {
    if (isOpen==YES) {
        [self chickDate:-_dateKeyboard.frame.size.height];
    }
    isOpen = NO;
}

/*!
 *@brief        键盘from的高度
 *@function     chickDate
 *@param        sender
 *@return       （void）
 */
-(void)chickDate:(NSInteger)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        [_dateKeyboard setFrame:CGRectMake(0,self.view.frame.size.height+sender, _dateKeyboard.frame.size.width, _dateKeyboard.frame.size.height)];
    }];
    
}


/*!
 *@description  处理获取到云相册图片结果
 *@function     handleReceiveFiles :data:
 *@param        src     --
 *@return       data    --返回数据
 */
- (void)handleReceiveFiles:(BBDataFrame *)src received:(BBDataFrame *)data
{
    NSString *result = [[NSString alloc] initWithString:[data dataString]];
    NSString *strTxt=@"暂无数据";
    
    if(result){
        NSArray *arr = [result componentsSeparatedByString:@"\t"];
        [result release];
        
        if(arr.count>3 && [arr[0] isEqualToString:@"0" ] && [arr[1] intValue]>0){
            BOOL haveInvadeImage = NO;
            BOOL haveSnapImage = NO;
            for (int i=3; i<arr.count-1; i++) {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                
                NSArray *sigleArr = [arr[i] componentsSeparatedByString:@"\n"];
                
                [dic setValue:sigleArr[0] forKey:IMAGE_TYPE_KEY];
                if ([sigleArr[0] isEqualToString:@"3"] ) {
                    haveInvadeImage = YES;
                }else{
                    haveSnapImage = YES;
                }
                [dic setValue:sigleArr[2] forKey:IMAGE_ID_KEY];
                [dic setValue:sigleArr[3] forKey:IMAGE_KEY];
                [dic setValue:sigleArr[1] forKey:IMAGES_TIME_KEY];
                
                NSArray *dateArr = [sigleArr[1] componentsSeparatedByString:@" "];
                
                NSMutableDictionary *aimDic = nil;
                //查找这一天是否已有图片
                for (NSMutableDictionary *dict in _dataArr) {
                    NSString *timeStr = [dict valueForKey:IMAGES_TIME_KEY];
                    NSArray *timeArr = [timeStr componentsSeparatedByString:@" "];
                    if ([timeArr[0] isEqualToString:dateArr[0]]) {
                        aimDic = dict;//找到了
                        break;
                    }
                }
                if (aimDic) {
                    NSMutableArray *imageArr = [aimDic valueForKey:IMAGES_KEY];
                    [imageArr addObject:dic];
                }else{
                    aimDic = [[NSMutableDictionary alloc]init];
                    NSMutableArray *imageArr = [[NSMutableArray alloc]init];
                    
                    [imageArr addObject:dic];
                    
                    [aimDic setValue:dateArr[0] forKey:IMAGES_TIME_KEY];
                    [aimDic setValue:imageArr forKey:IMAGES_KEY];
                    
                    [_dataArr addObject:aimDic];
                    
                    [aimDic release];
                    [imageArr release];
                }
                [aimDic setValue:[NSNumber numberWithBool:haveInvadeImage] forKey:HAVE_INVADE_IMAGE];
                [aimDic setValue:[NSNumber numberWithBool:haveSnapImage] forKey:HAVE_SNAP_IMAGE];
                
                [dic release];
            }
            
            NSInteger sum = 0;
            for (NSMutableDictionary *dict in _dataArr) {
                NSArray *imageArr = [dict valueForKey:IMAGES_KEY];
                [dict setValue:[NSString stringWithFormat:@"%d",imageArr.count] forKey:IMAGES_COUNT_KEY];
                sum += imageArr.count;
            }
            //所有数据全部接收完
            if ([arr[1] integerValue] == sum) {
                strTxt=@"请求成功";
            }

        }
        
        appDelegate.homePageVC.cloudAlbumBadge.value = 0;
        appDelegate.homePageVC.cloudAlbumBadge.frame = CGRectMake(80, 5, 40, 20);
        [_showTab reloadData];
    }
    
    [_hud setLabelText:strTxt];
    [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5f];
    
    
    
//    if (!result) {
//        [_hud setLabelText:@"请求失败"];
//    }else
//    {
//        NSArray *arr = [result componentsSeparatedByString:@"\t"];
//        
//        
//        if (![arr[0] isEqualToString:@"0"]) {
//
//            [_showTab reloadData];
//        }else{
//            if ([arr[1] isEqualToString:@"0"]) {
//                [_hud setLabelText:@"暂无数据"];
//    
//            }else{
//                            }
//            
//        }
//    }
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
//        vc=[[BBAlbumsViewController alloc]init];
    }else if (index==3){
        vc=[[BBHuiAplViewController alloc]init];
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}
#pragma mark -
#pragma mark -BBDateKeyBoardDelegate-
//!在日期键盘上点击了确定
- (void)dateKeyboardDidSelected:(BBDateKeyBoard *)keboard
{
    NSDate *date=[keboard.datePicker date];
    NSDateFormatter *fmt=[[NSDateFormatter alloc]init];
    [fmt setDateFormat:@"yyyy/MM/dd"];
    NSString *str=[fmt stringFromDate:date];
    [_currentSelectDate setText:str];
    [fmt release];
    if (isOpen==NO) {
    [self chickDate:_dateKeyboard.frame.size.height];
    }
    isOpen = YES;
    _defaultSearch = NO;
    [self getDatasWhileSelectedType:NO];
}
//!在日期键盘上点击了取消
- (void)dateKeyboardDidCanceled:(BBDateKeyBoard *)keboard{
  //在日期键盘上点击了取消
    if (isOpen==NO) {
        [self chickDate:_dateKeyboard.frame.size.height];
    }
    isOpen = YES;
    
    
}
#pragma mark-
#pragma mark UIScrollViewDelegate method

//!在日期键盘上点击了取消
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{

    if (isOpen==NO) {
        [self chickDate:_dateKeyboard.frame.size.height];
    }
    isOpen = YES;
    
}
#pragma mark -
#pragma mark UITableViewDataSource and MJRefreshBaseViewDelegate method
- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView{
//    if (_headerViw==refreshView) {
//        _row=1;
//    }else{
//        _row+=0;
//    }
//    [self getDatas];
}

#pragma mark -
#pragma mark BBSocketClient delegate method
-(int)onRecevie:(BBDataFrame *)src received:(BBDataFrame *)data
{
    if (src) {
        //不是通知消息
        if (src.MainCmd == 0x0F && src.SubCmd == 39) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleReceiveFiles:src received:data];
            });
        }
    }
    
    
    
    return 0;
}

-(void)onTimeout:(BBDataFrame *)src
{
    NSLog(@"Timeout src.subCmd = %d",src.SubCmd);
    dispatch_async(dispatch_get_main_queue(), ^{
        [_hud setLabelText:@"请求超时"];
        [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
    });
}

-(void)onClose
{
    NSLog(@"Socketet closed");
}

-(void)onRecevieError:(BBDataFrame*)src received:(BBDataFrame*)data
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_hud setLabelText:@"请求出错"];
        [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
    });
    NSLog(@"RecevieError ");
}


#pragma mark -
#pragma mark BBAlbumsCellDelegate method
- (void)didClickImageInCell:(BBAlbumsCell *)cell
{
    
    BBAlDetailsViewController *vc = [[BBAlDetailsViewController alloc]init];
    if (cell) {
        vc.timeStr = cell.time.text;
        NSIndexPath *indexPath = cell.indexPath;
        vc.index = indexPath.row;
        vc.dataArr = _dataArr;
    }
    if (self.navigationController) {
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self presentModalViewController:vc animated:YES];
    }
    [vc release];
    //在日期键盘上点击了取消
    if (isOpen==NO) {
        [self chickDate:_dateKeyboard.frame.size.height];
    }
}
@end
