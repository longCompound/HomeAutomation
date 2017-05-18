//
//  BBHighTemperatureViewController.m
//  ZgSafe
//
//  Created by box on 13-10-30.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBHighTemperatureViewController.h"
#import "BBTemperatureLineView.h"

@interface BBHighTemperatureViewController ()<BBSocketClientDelegate>{
    MBProgressHUD *_hud;
    BBTemperatureLineView *_temperatureLineView;
    NSString *_emergenceTel;
}
- (IBAction)goBack:(id)sender;
- (IBAction)dialNum:(id)sender;
@property (retain, nonatomic) IBOutlet UIView *lineView;

@end

@implementation BBHighTemperatureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - life cycle method -

- (void)dealloc
{
    [_emergenceTel release];
    [_lineView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _temperatureLineView = [[[NSBundle mainBundle]loadNibNamed:@"BBTemperatureLineView" owner:self options:nil]lastObject];
    [_lineView addSubview:_temperatureLineView];
    
    _emergenceTel = [[NSString alloc]initWithString:@"110"];
    
    [self getDatas];
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
    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
    NSString *userId = curUser.userid;
     
    NSString *param = [NSString stringWithFormat:@"%@\t%@",userId,_dateStr];
    
    [mainClient queryTemperatureLine:self param:param]; 
    [mainClient queryEmergencyNumber:self param:userId];
    [mainClient queryCurrentTemp:self param:userId];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
 *@description  响应点击打电话按钮事件
 *@function     dialNum:
 *@param        sender     --按钮
 *@return       (void)
 */
- (IBAction)dialNum:(id)sender {
    
    [appDelegate dialNumber:_emergenceTel];
}





- (void)viewDidUnload {
    [self setLineView:nil];
    [super viewDidUnload];
}


#pragma mark -
#pragma mark BBSocketClientDelegate method
-(int)onRecevie:(BBDataFrame *)src received:(BBDataFrame *)data
{
    if(src.MainCmd == 0x0E && src.SubCmd == 84) {
        //获取温度曲线表
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc] initWithString:[data dataString]];
            NSArray *arr = [result componentsSeparatedByString:@"\t"];
            if ([arr[0] boolValue]) {
                [_hud setLabelText:@"获取温度曲线失败"];
            }else{
                NSMutableArray *temperatureArr = [NSMutableArray array];
                for (int i=arr.count-1; i>=1; i--) {
                    [temperatureArr addObject:arr[i]];
                }
                
                
                
                NSArray *dateArr = [_dateStr componentsSeparatedByString:@" "];
                [_temperatureLineView setDateStr:dateArr[0]];
                [_temperatureLineView setToTime:[dateArr[1] substringToIndex:5]];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                NSDate *date = [dateFormatter dateFromString:_dateStr];
                NSDate *halfDate = [date dateByAddingTimeInterval:-1800];
                [dateFormatter setDateFormat:@"HH:mm"];
                [_temperatureLineView setFromTime:[dateFormatter stringFromDate:halfDate]];
                
                [dateFormatter release];
            
                
                
                _temperatureLineView.temperatureArr = temperatureArr;
                [_temperatureLineView setNeedsDisplay];
                [_hud setLabelText:@"获取温度曲线成功"];
            }
            [_hud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
            [result release];
        });
    }else if (src.MainCmd == 0x0E && src.SubCmd == 79) {
        //获取紧急电话
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc] initWithString:data.dataString];
            if (result) {
                NSArray *arr = [result componentsSeparatedByString:@"\t\t"];
                if (![arr[0] boolValue]) {
                    [_emergenceTel release];
                    _emergenceTel = [[NSString alloc]initWithString:arr[1]];
                }
            }
            [result release];
        });
    }else if (src.MainCmd == 0x0E && src.SubCmd == 74) {
        //获取温度
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc] initWithData:data.data encoding:NSUTF8StringEncoding];
            NSArray *arr = [result componentsSeparatedByString:@"\t"];
            [result release];
            if ([arr[0] integerValue]) {
                UtilAlert(@"获取当前温度失败", nil);
            }else{
                NSString *temperatureStr = [NSString stringWithFormat:@"%d℃",(NSInteger)([arr[1] floatValue]+0.5f)];
                [_temperatureLineView setCurTemp:temperatureStr];
            }
        });
        
    }
    
    return 0;
}

-(void)onTimeout:(BBDataFrame *)src
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_hud setLabelText:@"请求超时"];
        [_hud performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
    });
}


-(void)onRecevieError:(BBDataFrame*)src received:(BBDataFrame*)data
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"RecevieError src.SubCmd=%d",src.SubCmd);
        [_hud setLabelText:@"请求出错"];
        [_hud performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
    });
}


@end
