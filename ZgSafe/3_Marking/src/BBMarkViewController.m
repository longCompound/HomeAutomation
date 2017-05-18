//
//  BBMarkViewController.m
//  ZgSafe
//
//  Created by box on 13-10-28.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBMarkViewController.h"
#import "BBInOutAndSafeRecoredCell.h"
#import "BBWarningRecordCell.h"
#import "BBSideBarView.h"
#import "BBHighTemperatureViewController.h"
#import "BBInvadeViewController.h"
#import "BBDateKeyBoard.h"
#import "BBAlbumsViewController.h"
#import "BBHuiAplViewController.h"
#import "BBUserCenterViewController.h"


//三个标题按钮的背景色
#define BTN_BG_COLOR [UIColor getColorWithRed:244. andGreen:194. andBlue:109.]

@interface BBMarkViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,BBSideBarViewDelegate,UIActionSheetDelegate,BBDateKeyBoardDelegate,BBSocketClientDelegate,BBPullRefreshDelegate>
{
    BBSideBarView *_siderBar;//侧边栏
    BBDateKeyBoard *_dateKeyboard;
    BOOL isOpen;
    MBProgressHUD *_hud;
    NSInteger _typeIndex;//actionsheet上选择的类型的index
    NSUInteger pageIndex;
    BOOL isLoadMore;
    NSMutableArray *userArr;
    NSInteger pageSize;
    BOOL selectData;
}

@property (retain, nonatomic) IBOutlet UIButton *safeRecordBtn;
@property (retain, nonatomic) IBOutlet UIButton *warnRecordBtn;
@property (retain, nonatomic) IBOutlet UIButton *inOutBtn;
@property (retain, nonatomic) IBOutlet UIView *titleBtnView;
- (IBAction)goBack:(id)sender;
- (IBAction)onClickInOutBtn:(id)sender;
- (IBAction)onClickSafeRecordBtn:(id)sender;
- (IBAction)onClickWarningRecordBtn:(id)sender;
- (IBAction)onClickCAllBtn:(id)sender;

@property (retain, nonatomic) IBOutlet UITextField *currentSelectdate;
@property (retain, nonatomic) IBOutlet UIButton *typeBtn;


@end

@implementation BBMarkViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _currentPageType = BBMarkPageTypeInOutRecord;
    }    return self;
}

#pragma mark -
#pragma mark life cycle method
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    isOpen=YES;
    selectData = NO;
    userArr = [[NSMutableArray alloc] init];
    _inOutBtn.backgroundColor = [UIColor clearColor];
    _safeRecordBtn.backgroundColor = [UIColor clearColor];
    _warnRecordBtn.backgroundColor = [UIColor clearColor];
    if (BBMarkPageTypeInOutRecord == _currentPageType) {
        _lastClickBtn = _inOutBtn;
        _inOutBtn.backgroundColor = BTN_BG_COLOR;
    }else if(BBMarkPageTypeSafeRecord == _currentPageType){
        _lastClickBtn = _safeRecordBtn;
        _safeRecordBtn.backgroundColor = BTN_BG_COLOR;
    }else{
        _lastClickBtn = _warnRecordBtn;
        _warnRecordBtn.backgroundColor = BTN_BG_COLOR;
    }
    pageSize = 10;
    
    _recordTable.sDelegate = self;
    _recordTable.tableKey = @"makeView";
    _recordTable.bbStyle = UIActivityIndicatorViewStyleGray;
    _recordTable.refreshDirection = kBBTableRefreshDirectionDown | kBBTableRefreshDirectionUp;
    [_recordTable setUpRefreshers];
    [_recordTable performSelector:@selector(updateRefreshers) withObject:nil afterDelay:0.1];
    
    _members = appDelegate.homePageVC.members;
    
    _dateKeyboard = [[[[NSBundle mainBundle]loadNibNamed:@"BBDateKeyBoard" owner:self options:nil]lastObject]retain];
    [_dateKeyboard setFrame:CGRectMake(0,appDelegate.window.frame.size.height,_dateKeyboard.frame.size.width , _dateKeyboard.frame.size.height)];
    [self.view addSubview:_dateKeyboard];
    _dateKeyboard.delegate = self;
    
    _siderBar = [BBSideBarView siderBarWithBesideView:self.view];
    _siderBar.delegate=self;
    _titleBtnView.layer.cornerRadius = 5;
    _titleBtnView.clipsToBounds = YES;
    
    _dataArr = [[NSMutableArray alloc]init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    _currentSelectdate.text = dateStr;
    
    [self getDatasWhileSelectType:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_dataArr release];
    [_recordTable release];
    [_currentSelectdate release];
    [_dateKeyboard release];
    [_titleBtnView release];
    [_inOutBtn release];
    [_safeRecordBtn release];
    [_warnRecordBtn release];
    [_siderBar remove];
    [_typeBtn release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setRecordTable:nil];
    [self setCurrentSelectdate:nil];
    [self setTitleBtnView:nil];
    [self setInOutBtn:nil];
    [self setSafeRecordBtn:nil];
    [self setWarnRecordBtn:nil];
    [self setTypeBtn:nil];
    [super viewDidUnload];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_currentSelectdate resignFirstResponder];
}

#pragma mark -
#pragma mark self define method

/*!
 *@description  请求数据
 *@function     getDatasWhileSelectType:
 *@param        isSelectType    --YES：选择的类型  NO：选择的日期
 *@return       (void)
 */
- (void)getDatasWhileSelectType:(BOOL)isSelectType
{
    pageSize = 10;
    [_dataArr removeAllObjects];
    [userArr removeAllObjects];
    [_recordTable reloadData];

    BBMainClient *mainClient = [[[BBSocketManager getInstance] mainClient]retain];
    if (BBMarkPageTypeInOutRecord == _currentPageType) {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.labelFont = [UIFont systemFontOfSize:13.0f];
        _hud.removeFromSuperViewOnHide = YES;
        _hud.labelText = @"正在获取出入记录...";
        NSMutableString *param = [[NSMutableString alloc]initWithString:curUser.userid];
        if (isSelectType) {
//            默认模式查询【当前时间之内3天，以天为单位】
            if ([_typeBtn.titleLabel.text isEqualToString:@"全部"]) {
                [param appendString:@"\t0"];
            }else{
//                特定成员近3天归家离家查询【当前时间之内3天，以天为单位】
                NSString *rfid = [[_members[_typeIndex-1] valueForKey:@"id"] stringByTrimmingCharactersInSet:[NSCharacterSet  whitespaceAndNewlineCharacterSet]];
                [param appendFormat:@"\t1\t%@",rfid];
            }
        }else{
            if ([_typeBtn.titleLabel.text isEqualToString:@"全部"]) {
//                	特定时间家庭成员归家离家查询【以天为单位】
                [param appendFormat:@"\t2\t%@",[_currentSelectdate.text stringByReplacingOccurrencesOfString:@"/" withString:@"-"]];
            }else{
                //                	特定成员在特定时间归家离家查询
                NSString *rfid = [_members[_typeIndex-1] valueForKey:@"id"];
                [param appendFormat:@"\t3\t%@\t%@",rfid,[_currentSelectdate.text stringByReplacingOccurrencesOfString:@"/" withString:@"-"]];
            }
        }
        
        [mainClient queryInOutHistory:self param:param];
        [param autorelease];
        
    }else if (BBMarkPageTypeSafeRecord == _currentPageType){
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.labelFont = [UIFont systemFontOfSize:13.0f];
        _hud.removeFromSuperViewOnHide = YES;
        _hud.labelText = @"正在获取安防记录...";
        NSMutableString *param = [[NSMutableString alloc]initWithString:curUser.userid];
        
        if (isSelectType) {
            if ([_typeBtn.titleLabel.text isEqualToString:@"全部"]) {
//                	默认模式查询
                [param appendString:@"\t0"];
            }else if([_typeBtn.titleLabel.text isEqualToString:@"布防"]){
//                	布防查询
                [param appendString:@"\t2\t1"];
            }else{
//                	撤防查询
                [param appendString:@"\t3\t2"];
            }
        }else{
            if ([_typeBtn.titleLabel.text isEqualToString:@"全部"]) {
//                	特定日期布防/撤防查询
                [param appendFormat:@"\t1\t%@",[_currentSelectdate.text stringByReplacingOccurrencesOfString:@"/" withString:@"-"]];
            }else if([_typeBtn.titleLabel.text isEqualToString:@"布防"]){
//                	特定日期布防查询
                [param appendFormat:@"\t4\t%@",[_currentSelectdate.text stringByReplacingOccurrencesOfString:@"/" withString:@"-"]];
            }else{
//                	特定日期撤防查询
                [param appendFormat:@"\t5\t%@",[_currentSelectdate.text stringByReplacingOccurrencesOfString:@"/" withString:@"-"]];
            }
        }
        [mainClient queryAlarmOrCanncelHistory:self param:param];
        [param autorelease];
        
    }else if (BBMarkPageTypeWarningRecord == _currentPageType){
        
   
        NSMutableString *param = [[NSMutableString alloc]initWithString:curUser.userid];
        
        if (isSelectType) {
            _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            _hud.labelFont = [UIFont systemFontOfSize:13.0f];
            _hud.removeFromSuperViewOnHide = YES;
            _hud.labelText = @"正在获取报警记录...";
            if ([_typeBtn.titleLabel.text isEqualToString:@"全部"]) {
//                	默认查询
                [param appendString:@"\t0"];
            }else if ([_typeBtn.titleLabel.text isEqualToString:@"入侵"]){
//                	入侵报警查询
                [param appendString:@"\t2"];
            }else{
//                	温度报警查询
                [param appendString:@"\t1"];
            }
            [mainClient queryWarningHistory:self param:param];
            [param autorelease];
        }else{
            if ([_typeBtn.titleLabel.text isEqualToString:@"全部"]) {
                _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                _hud.labelFont = [UIFont systemFontOfSize:13.0f];
                _hud.removeFromSuperViewOnHide = YES;
                _hud.labelText = @"正在获取报警记录...";
                [param appendFormat:@"\t3\t%@",[_currentSelectdate.text stringByReplacingOccurrencesOfString:@"/" withString:@"-"]];
                [mainClient queryWarningHistory:self param:param];
                [param autorelease];
            }else if ([_typeBtn.titleLabel.text isEqualToString:@"入侵"]){
//                没有接口
            }else{
//                没有接口
            }
        }
    

    }
}

/*!
 *@description      返回主界面
 *@function         goBack:
 *@param            sender      --返回按钮
 *@return           (void)
 */
- (IBAction)goBack:(id)sender {
    [self retain];
    [self performSelector:@selector(release) withObject:nil afterDelay:300];
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
 *@description  添加过度动画
 *@function     addAnimition
 *@param        direction   --动画的方向
 *@return       (void)
 */
- (void)addAnimitionWithDirection:(NSString *)direction
{
    [_recordTable.layer removeAnimationForKey:@"anim"];
    CATransition *anim = [CATransition animation];
    anim.duration = 0.5f;
    anim.type = kCATransitionPush;
    anim.subtype = direction;
    [_recordTable.layer addAnimation:anim forKey:@"anim"];
}


/*!
 *@description      响应点击出入记录按钮事件
 *@function         onClickInOutBtn:
 *@param            sender      --出入记录按钮
 *@return           (void)
 */
- (IBAction)onClickInOutBtn:(id)sender {
    [self.view endEditing:YES];
    if (sender == _lastClickBtn) {
        return;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    _currentSelectdate.text = dateStr;
    selectData = NO;
    [_typeBtn setTitle:@"全部" forState:UIControlStateNormal];
    _inOutBtn.backgroundColor = BTN_BG_COLOR;
    _safeRecordBtn.backgroundColor = [UIColor clearColor];
    _warnRecordBtn.backgroundColor = [UIColor clearColor];
    
    _currentPageType = BBMarkPageTypeInOutRecord;
    
    
    if (_lastClickBtn.tag > _inOutBtn.tag) {
        [self addAnimitionWithDirection:@"fromLeft"];
    }
    _lastClickBtn = _inOutBtn;
    [self getDatasWhileSelectType:YES];
}

/*!
 *@description      响应点击安防记录按钮事件
 *@function         onClickSafeRecordBtn:
 *@param            sender      --安防记录按钮
 *@return           (void)
 */
- (IBAction)onClickSafeRecordBtn:(id)sender {
//     时间回收 
    if (isOpen==NO) {
        [self chickDate:_dateKeyboard.frame.size.height];
    }
    if (sender == _lastClickBtn) {
        return;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    _currentSelectdate.text = dateStr;
    isOpen = YES;
    selectData = NO;
    [_typeBtn setTitle:@"全部" forState:UIControlStateNormal];
    _safeRecordBtn.backgroundColor = BTN_BG_COLOR;
    _inOutBtn.backgroundColor = [UIColor clearColor];
    _warnRecordBtn.backgroundColor = [UIColor clearColor];
    _currentPageType = BBMarkPageTypeSafeRecord;
    
    
    if (_lastClickBtn.tag > _safeRecordBtn.tag) {
        [self addAnimitionWithDirection:@"fromLeft"];
    }else if (_lastClickBtn.tag < _safeRecordBtn.tag){
        [self addAnimitionWithDirection:@"fromRight"];
    }
    _lastClickBtn = _safeRecordBtn;
    [self getDatasWhileSelectType:YES];
}

/*!
 *@description      响应点击报警记录记录按钮事件
 *@function         onClickWarningRecordBtn:
 *@param            sender      --报警记录按钮
 *@return           (void)
 */
- (IBAction)onClickWarningRecordBtn:(id)sender {
    [self.view endEditing:YES];
    if (sender == _lastClickBtn) {
        return;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    _currentSelectdate.text = dateStr;
    isOpen = YES;
    selectData = NO;
    [_typeBtn setTitle:@"全部" forState:UIControlStateNormal];
    _warnRecordBtn.backgroundColor = BTN_BG_COLOR;
    _inOutBtn.backgroundColor = [UIColor clearColor];
    _safeRecordBtn.backgroundColor = [UIColor clearColor];
    _currentPageType = BBMarkPageTypeWarningRecord;
    
    
    if (_lastClickBtn.tag < _warnRecordBtn.tag){
        [self addAnimitionWithDirection:@"fromRight"];
    }
    _lastClickBtn = _warnRecordBtn;
    [self getDatasWhileSelectType:YES];
}


/*!
 *@description      响应点击全部按钮事件
 *@function         onClickCAllBtn:
 *@param            sender      --全部按钮
 *@return           (void)
 */
- (IBAction)onClickCAllBtn:(id)sender {
    //时间消失
    if (isOpen==NO) {
        [self chickDate:_dateKeyboard.frame.size.height];
    }
    isOpen = YES;
    UIActionSheet *ac;
    if (BBMarkPageTypeInOutRecord == _currentPageType) {
        ac = [[UIActionSheet alloc]initWithTitle:nil
                                        delegate:self
                               cancelButtonTitle:nil
                          destructiveButtonTitle:nil
                               otherButtonTitles:@"全部", nil];
        for (NSDictionary *dic in _members) {
            [ac addButtonWithTitle:[dic valueForKey:@"name"]];
           
        }
        [ac addButtonWithTitle:@"取消"];
    }else if (BBMarkPageTypeSafeRecord == _currentPageType){
        ac = [[UIActionSheet alloc]initWithTitle:nil
                                        delegate:self
                               cancelButtonTitle:@"取消"
                          destructiveButtonTitle:nil
                               otherButtonTitles:@"全部",@"布防",@"撤防", nil];
    }else {
        
        //入侵，温度异常分类
        ac = [[UIActionSheet alloc]initWithTitle:nil
                                        delegate:self
                               cancelButtonTitle:@"取消"
                          destructiveButtonTitle:nil
                               otherButtonTitles:@"全部", nil];
    }
    [ac showInView:self.view];
    [ac release];
}
/*!
 *@brief        点击弹出时间的button
 *@function     clickDateButton
 *@param        sender
 *@return       （void）
 */
- (IBAction)clickDateButton:(UIButton *)sender {
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
#pragma mark -
#pragma mark UITableViewDataSource method

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr ? _dataArr.count:0 ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if(BBMarkPageTypeWarningRecord == _currentPageType)
//    {
//        return 90.0f;
//    }else{
        return 75.0f;
//    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *inOutAndSafIdentifier = @"inOutAndSafeCell";
    static NSString *WarningRecordIdentifier = @"WarningRecordCell";
    UITableViewCell *cell;
    
    if (BBMarkPageTypeInOutRecord == _currentPageType) {
        cell = [tableView dequeueReusableCellWithIdentifier:inOutAndSafIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"BBInOutAndSafeRecoredCell"
                                                 owner:self
                                               options:nil]lastObject];
        }
        BBInOutAndSafeRecoredCell *inOutCell = ((BBInOutAndSafeRecoredCell
                                                 *)cell);
        inOutCell.stateName.hidden = NO;
        inOutCell.tel.hidden = YES;
        inOutCell.name.text = [_dataArr[indexPath.row] objectForKey:NAME_KEY];
        inOutCell.stateName.text = [_dataArr[indexPath.row] objectForKey:ACT_KEY];
        
        
        NSArray *arr = [[_dataArr[indexPath.row] objectForKey:TIME_KEY]  componentsSeparatedByString:@" "];
        inOutCell.date.text = arr[0];
        inOutCell.time.text = arr[1];
        
        if ([inOutCell.stateName.text isEqualToString:@"离家"]) {
            inOutCell.stateImage.image = [UIImage imageNamed:@"out_home"];
        }else{
            inOutCell.stateImage.image = [UIImage imageNamed:@"back_home"];
        }
        
    }else if(BBMarkPageTypeSafeRecord == _currentPageType){
        cell = [tableView dequeueReusableCellWithIdentifier:inOutAndSafIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"BBInOutAndSafeRecoredCell"
                                                 owner:self
                                               options:nil]lastObject];
        }
        BBInOutAndSafeRecoredCell *safeCell = ((BBInOutAndSafeRecoredCell*)cell);
        
        safeCell.stateName.hidden = YES;
        safeCell.tel.hidden = YES;
        safeCell.name.text = [_dataArr[indexPath.row] objectForKey:NAME_KEY];
        NSArray *arr = [[_dataArr[indexPath.row] objectForKey:TIME_KEY]  componentsSeparatedByString:@" "];
        safeCell.date.text = arr[0];
        safeCell.time.text = arr[1];
        
        NSString *actStr = [_dataArr[indexPath.row] objectForKey:ACT_KEY];
        if ([actStr isEqualToString:@"布防"] ) {
            safeCell.stateImage.image = [UIImage imageNamed:@"set_regard"];
        }else{
            safeCell.stateImage.image = [UIImage imageNamed:@"cancel_regard"];
        }
        
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:WarningRecordIdentifier];
        BBWarningRecordCell *warnCell = ((BBWarningRecordCell *)cell);
        if (!cell) {
            cell = [[[NSBundle mainBundle]loadNibNamed:@"BBWarningRecordCell"
                                                 owner:self
                                               options:nil]lastObject];
            warnCell = ((BBWarningRecordCell *)cell);
            warnCell.infoLable.layer.cornerRadius = 5;
            warnCell.clipsToBounds = YES;
        }
        
        warnCell.infoLable.text = [_dataArr[indexPath.row] objectForKey:WARN_TYPE_KEY];
        warnCell.timeLable.text = [_dataArr[indexPath.row] objectForKey:TIME_KEY];
        
        if ([warnCell.infoLable.text isEqualToString:@"温度异常"]) {
            warnCell.temperatureLable.hidden = NO;
            warnCell.infoLable.text = @"温度异常";
            warnCell.infoLable.backgroundColor = BTN_BG_COLOR;
            warnCell.backGroundImage.image = [UIImage imageNamed:@"temperature_warning_bg.png"];
            warnCell.temperatureLable.text = [NSString stringWithFormat:@"%@℃",[_dataArr[indexPath.row] objectForKey:TEMPERATURE_KEY]];
            warnCell.infoLable.frame = CGRectMake(warnCell.infoLable.frame.origin.x,
                                                  warnCell.infoLable.frame.origin.y
                                                  ,78.
                                                  , warnCell.infoLable.frame.size.height);
        }else{
            warnCell.temperatureLable.hidden = YES;
            warnCell.infoLable.text = @"入侵";
            warnCell.infoLable.backgroundColor = [UIColor redColor];
            warnCell.backGroundImage.image = [UIImage imageNamed:@"temperature_warning_bg.png"];
            warnCell.infoLable.frame = CGRectMake(warnCell.infoLable.frame.origin.x,
                                                  warnCell.infoLable.frame.origin.y
                                                  ,50.
                                                  , warnCell.infoLable.frame.size.height);
        }
        
    }
    //!在日期键盘上点击了取消
    if (isOpen==NO) {
        [self chickDate:_dateKeyboard.frame.size.height];
    }
    isOpen = YES;
    return cell;
}

#pragma mark -
#pragma mark UITableView delegate method
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *vc = nil;
    if (BBMarkPageTypeWarningRecord == _currentPageType) {
        
        BBWarningRecordCell *cell = (BBWarningRecordCell *)[tableView cellForRowAtIndexPath:indexPath];
        if ([cell.infoLable.text isEqualToString:@"入侵"]) {
            
            BBInvadeViewController *invadeVC = [[BBInvadeViewController alloc]init];
            BBWarningRecordCell *cell = (BBWarningRecordCell *)[tableView cellForRowAtIndexPath:indexPath];
            invadeVC.time = [cell.timeLable.text componentsSeparatedByString:@" "][0];
            invadeVC.ID = [_dataArr[indexPath.row] valueForKey:INVADE_ID_KEY];
            vc = invadeVC;
        }else{
            
            BBHighTemperatureViewController *hVC = [[BBHighTemperatureViewController alloc]init];
            hVC.dateStr = cell.timeLable.text;
            vc = hVC;
        }
        
    }
    
    //!在日期键盘上点击了取消
    if (isOpen==NO) {
        [self chickDate:_dateKeyboard.frame.size.height];
    }
    isOpen = YES;
    [self.view endEditing:YES];
    [_siderBar hide];
    if (vc) {
        if (self.navigationController) {
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            [self presentModalViewController:vc animated:YES];
        }
        [vc release];
    }
}


- (void)tableView:tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    CATransition *anim = [CATransition animation];
//    anim.duration = 0.5f;
//    anim.type = @"cube";
//    anim.subtype = kCATransitionFromRight;
//    [cell.layer addAnimation:anim forKey:nil];
}

#pragma mark -
#pragma mark BBSideBarViewDelegate method
- (void)didSelectedButtonAtIndex:(NSInteger)index
{ 
    [_siderBar hide];
    UIViewController *vc = nil;
    if (index==0) { 
        //[BBCloudEyesViewController verifyThenPushWithVC:self];
    }else if(index==1){
//        vc=[[BBMarkViewController alloc]init];
    }else if(index==2){
        
        vc=[[BBAlbumsViewController alloc]init];
    }else if (index==3)
    {
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

#pragma mark -
#pragma mark UIActionSheetDelegate method
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _typeIndex = buttonIndex;
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
    if (![title isEqualToString:@"取消"]) {
//        _typeBtn.titleLabel.text = title;
        [_typeBtn setTitle:title forState:UIControlStateNormal];
        if (selectData) {
          [self getDatasWhileSelectType:NO];
        }else{
            [self getDatasWhileSelectType:YES];
        }
       
    }
    
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
    [_currentSelectdate setText:str];
    [fmt release];
    if (isOpen==NO) {
        [self chickDate:_dateKeyboard.frame.size.height];
    }
    isOpen = YES;
    selectData = YES;
    
    if (BBMarkPageTypeWarningRecord == _currentPageType) {
//        由于没有特定日期特定类型的报警查询，所以设置为全部，有接口之后删除
        _typeBtn.titleLabel.text=@"全部";
    }
    [self getDatasWhileSelectType:NO];
}


//!在日期键盘上点击了取消
- (void)dateKeyboardDidCanceled:(BBDateKeyBoard *)keboard{
    
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
#pragma mark BBSocketClientDelegate method

-(int)onRecevie:(BBDataFrame *)src received:(BBDataFrame *)data
{
    if(src.MainCmd == 0x0E && src.SubCmd == 68) {
        //出入记录查询
        dispatch_async(dispatch_get_main_queue(), ^{
            [_recordTable refreshTableDidFinishLoad];
            NSString *result = [[NSString alloc] initWithString:[data dataString]];
            NSString *strTxt=@"暂无出入记录";
            
            if (result) {
                NSArray *arr = [result componentsSeparatedByString:@"\t"];
                [result release];
                //判断总记录数
                if([arr[0] intValue]>0){
                    for (int i=3; i<arr.count-1; i++) {
                        NSArray *sigleArr = [arr[i] componentsSeparatedByString:@","];
                        
                        [userArr addObject:@{NAME_KEY:sigleArr[0],
                                             TIME_KEY:sigleArr[1],
                                             ACT_KEY:[sigleArr[2] integerValue]==1?@"回家":@"离家"}];
                    }
                    
                    if ([userArr count]>10) {
                        for (int i =0; i<10; i++) {
                            [_dataArr addObject:[userArr objectAtIndex:i]];;
                        }
                    }else{
                        [_dataArr addObjectsFromArray:userArr];
                    }
                    
                    if ([arr[0] integerValue] == userArr.count) {
                        strTxt = @"出入记录查询成功";
                        [_recordTable reloadData];
                    }
                }
            }
            
             _hud.labelText = strTxt;
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5f];
        });
    }else if (src.MainCmd == 0x0E && src.SubCmd == 69) {
        //布防记录查询
        dispatch_async(dispatch_get_main_queue(), ^{
            [_recordTable refreshTableDidFinishLoad];
            NSString *result = [[ NSString alloc] initWithString:[data dataString]];
            NSString *strTxt=@"暂无布防记录";
            
            if (result) {
                NSArray *arr = [result componentsSeparatedByString:@"\t"];
                [result release];
                
                if([arr[0] intValue]>0){
                    for (int i=3; i<arr.count-1; i++) {
                        NSArray *sigleArr = [arr[i] componentsSeparatedByString:@","];
                        [userArr addObject:@{NAME_KEY:sigleArr[0],
                                             TIME_KEY:sigleArr[1],
                                             ACT_KEY:[sigleArr[2] integerValue]==1?@"布防":@"撤防"}];
                        
                    }

                    if ([userArr count]>10) {
                        for (int i =0;i<10; i++) {
                            [_dataArr addObject:[userArr objectAtIndex:i]];
                        }
        
                    }else{
                        [_dataArr addObjectsFromArray:userArr];
                    }
                    
                    if ([arr[0] integerValue] == userArr.count) {
                        strTxt = @"布防记录查询成功";
                        [_recordTable reloadData];
                    }
                }
            }
            
            _hud.labelText = strTxt;
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5f];
            
        });
    }else if (src.MainCmd == 0x0E && src.SubCmd == 70) {
        //报警记录查询
        dispatch_async(dispatch_get_main_queue(), ^{
            [_recordTable refreshTableDidFinishLoad];
            NSString *result = [[NSString alloc] initWithData:data.data encoding:NSUTF8StringEncoding];
            NSString *strTxt=@"暂无布防记录";
            
            if(result){
                NSArray *arr = [result componentsSeparatedByString:@"\t"];
                
                if([arr[0] intValue]>0){
                    for (int i=3;i<arr.count-1;i++) {
                        NSArray *singleArr = [arr[i] componentsSeparatedByString:@","];
                        
                        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{WARN_TYPE_KEY:[singleArr[1] integerValue]==3?@"入侵":@"温度异常",
                                                                                                   TIME_KEY:singleArr[2]}];
                        
                        if ([singleArr[1] integerValue]==16) {
                            [dic setValue:[NSString stringWithFormat:@"%@",singleArr[3]] forKey:TEMPERATURE_KEY];
                        }else{
                            [dic setValue:[NSString stringWithFormat:@"%@",singleArr[0]] forKey:INVADE_ID_KEY];
                        }
                        [userArr addObject:dic];
                    }
                    
                    if ([userArr count]>10) {
                        for (int i =0; i<10; i++) {
                            [_dataArr addObject:[userArr objectAtIndex:i]];;
                        }
                    }else{
                        [_dataArr addObjectsFromArray:userArr];
                    }
                    if ([arr[0] integerValue] == userArr.count) {
                        strTxt = @"获取报警记录成功";
                        [_recordTable reloadData];
                    }
                }
            }
            
            _hud.labelText = strTxt;
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.5f];
            
        });
    }
    
    return 0;
}

-(void)onTimeout:(BBDataFrame *)src
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Timeout src = %d",src.SubCmd);
        if (_hud) {
            _hud.labelText = @"获取超时";
            [_recordTable refreshTableDidFinishLoad];
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        }
        _hud = nil;
    });
}


-(void)onRecevieError:(BBDataFrame*)src received:(BBDataFrame*)data
{
   
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"RecevieError src = %d",src.SubCmd);
        _hud.labelText = @"获取出错";
          [_recordTable refreshTableDidFinishLoad];
        [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
    });
}

#pragma mark -
#pragma mark BBPullRefreshDelegate method

- (BOOL)refreshTable:(BBPullRefreshTable *)prt shouldInteractiveForDirection:(BBTableRefreshDirection)direction{
    return YES;
}

- (void)refreshTable:(BBPullRefreshTable *)prt willTriggerForDirection:(BBTableRefreshDirection)direction{
    
}


- (void)refreshTable:(BBPullRefreshTable *)prt didTriggerForDirection:(BBTableRefreshDirection)direction
{
    
      if (kBBTableRefreshDirectionDown == direction) {
          if (selectData) {
             [self getDatasWhileSelectType:NO];
          }else{
               [self getDatasWhileSelectType:YES];
          }
          
      }else{
          [_dataArr removeAllObjects];
          pageSize +=10;
          if (pageSize >[userArr count]) {
                [_dataArr addObjectsFromArray:userArr];
          }else{
              for (int i=0; i<pageSize; i++) {
                  [_dataArr addObject:[userArr objectAtIndex:i]];
              }
          }
          [_recordTable reloadData];
          [_recordTable performSelector:@selector(refreshTableDidFinishLoad) withObject:nil afterDelay:1.0];
      }
    

}


#pragma mark -
#pragma mark UIScrollViewDelegate method
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_recordTable refreshTableDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_recordTable refreshTableDidEndDraging];
}

@end
