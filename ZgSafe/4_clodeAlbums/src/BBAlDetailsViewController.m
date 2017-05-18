//
//  BBAlDetailsViewController.m
//  ZgSafe
//
//  Created by YANGReal on 13-10-28.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBAlDetailsViewController.h"
#import "WXApi.h"
#import "BBAlbumsViewController.h"
#import "BBScrollImageView.h"

@interface BBAlDetailsViewController ()<BBSocketClientDelegate,UIImageViewWebCacheDelegate,BBScrollImageViewDelegate>
{
    NSInteger inter;
    MBProgressHUD *_hud;
    BBScrollImageView *_scrollImageView;
}

- (IBAction)onShare:(id)sender;
- (IBAction)onDelete:(id)sender;
- (IBAction)goback:(id)sender;
- (IBAction)onSina:(id)sender;
- (IBAction)onTencent:(id)sender;
- (IBAction)onCancel:(id)sender;
- (IBAction)onFriends:(id)sender;

- (IBAction)PreviousClick:(id)sender;
- (IBAction)NextClick:(id)sender;
@property (retain, nonatomic) IBOutlet UIScrollView *bg_scro;
@property (retain, nonatomic) IBOutlet UIView *actionSheet;
@property (nonatomic,retain)NSMutableArray *urlsArr;
@property (nonatomic,retain)NSArray *imgArr;
@property (nonatomic,assign)NSDictionary *dataDic;
@end

@implementation BBAlDetailsViewController

#pragma mark -
#pragma mark system method
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)dealloc {
    [_urlsArr release];
    [_bg_scro release];
    [_actionSheet release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBg_scro:nil];
    [self setActionSheet:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    inter = 0;
    
    _actionSheet.center = CGPointMake(_actionSheet.center.x
                                      , self.view.frame.size.height
                                      +_actionSheet.frame.size.height/2.);
    [self.view addSubview:_actionSheet];
    
    _dataDic = _dataArr[_index];
    NSArray *imageArr = [_dataDic valueForKey:IMAGES_KEY];
    _urlsArr = [[NSMutableArray alloc]init];
    for (int i=0; i<imageArr.count; i++) {
        [_urlsArr addObject:[imageArr[i] valueForKey:IMAGE_KEY]];
    }
    
    
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _scrollImageView = [[[[NSBundle mainBundle]loadNibNamed:@"BBScrollImageView" owner:self options:nil]lastObject]retain];
        _scrollImageView.frame = _bg_scro.bounds;
        _scrollImageView.delegate = self;
        _scrollImageView.autoPlay = NO;
        _scrollImageView.showIndicator = NO;
        [_scrollImageView loadWithUrls:_urlsArr aryImg:imageArr];
        _scrollImageView.pageControlLimit = 100;
        _scrollImageView.showFullImageWhenClick = NO;
        _scrollImageView.pageControl.hidden = YES;
        [_bg_scro addSubview:_scrollImageView];
        //[self updateScroll];
    });
    
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
 *@description      响应点击分享按钮事件
 *@function         onShare:
 *@param            sender     --按钮
 *@return           (void)
 */
- (IBAction)onShare:(id)sender {
    [UIView animateWithDuration:0.25f animations:^{
        _actionSheet.center = CGPointMake(_actionSheet.center.x
                                          , self.view.frame.size.height
                                          -_actionSheet.frame.size.height/2.);
    }];
}


/*!
 *@description      响应点击删除按钮事件
 *@function         onDelete:
 *@param            sender     --按钮
 *@return           (void)
 */
- (IBAction)onDelete:(id)sender {
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NOTICE_TITLE
                                                    message:@"确定这张图片删除吗？"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    alert.tag = 10001;
    [alert show];
    [alert release];
}


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
 *@description
 *@function 新浪微博发送
 *@param (void)
 *@return (void)
 */
- (void)sendSinaShare
{
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_hud setLabelText:@"正在发送..."];
    NSMutableString *path = [NSMutableString stringWithFormat:@"https://upload.api.weibo.com/2/statuses/upload.json"];
    //        [path appendFormat:@"?status=jfkldajfkjfklafkldasjfklda"];
    NSURL *url = [NSURL URLWithString:path];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    NSDictionary *sinaInfo = [[NSUserDefaults standardUserDefaults] objectForKey:EPA_SINA_INFO];
    [request setPostValue:kSinaAppKey forKey:@"source"];
    [request setPostValue:[sinaInfo objectForKey:SN_TOKEN_KEY] forKey:@"access_token"];
    [request setPostValue:@"\"柚保.云智能卫士\",你的生活好帮手。快来看一下吧！" forKey:@"status"];
    
    
    //    NSInteger index = (NSInteger)(_bg_scro.contentOffset.x/_bg_scro.frame.size.width);
    UIImageView *imgView = _scrollImageView.visibleImageView;
    
     
    NSData *imgData  = UIImageJPEGRepresentation(imgView.image, 0.5);
    [request setData:imgData withFileName:@"upload.png" andContentType:@"image/png" forKey:@"pic"];
    
    [request setDelegate:self];
    request.tag = 166;
    [request setTimeOutSeconds:NETWORK_TIMEOUT];
    [request startAsynchronous];
}

/*
 新浪微博：
 App key：2714247321
 App secret：f29008c06a9f7c465e0178d1bbf80f23
 授权回调页： http://www.zgantech.com
 
 
 腾讯微博：APP ID：100551593
 APP KEY：5ac1877cba3cb93946c4f95e7808aaa4
*/


/*!
 *@description      响应点击新浪微博按钮事件
 *@function         onSina:
 *@param            sender     --按钮
 *@return           (void)
 */
- (IBAction)onSina:(id)sender {
    [self hideActionSheet];
    
//    BBAppDelegate *appdelegate = (BBAppDelegate *)[UIApplication sharedApplication].delegate;
//    appdelegate.flag = @"NewDetails";
    NSDictionary *sinaInfo = [[NSUserDefaults standardUserDefaults] objectForKey:EPA_SINA_INFO];
    NSDate *date = nil;
    if (sinaInfo != nil) {
        date = [sinaInfo objectForKey:SN_EXPIRE_KEY];
    }
    if (sinaInfo == nil || date == nil
        || [date compare:[NSDate dateWithTimeIntervalSinceNow:60*6]] == NSOrderedAscending) {
        BBAppDelegate *delegate = (BBAppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate sinaSSOAuthrize:nil];
    } else { // 发送新浪微博
        [self sendSinaShare];
    }
}

/*!
 *@description      响应点击腾讯微博按钮事件
 *@function         onTencent:
 *@param            sender     --按钮
 *@return           (void)
 */
- (IBAction)onTencent:(id)sender {
//    [self hideActionSheet];
//     
//    NSDictionary *qqInfo = [[NSUserDefaults standardUserDefaults] objectForKey:EPA_QQ_INFO];
//    NSDate *date = nil;
//    if (qqInfo != nil ) {
//        date = [qqInfo objectForKey:QQ_EXPIRE_KEY];
//    }
//    if (1 || qqInfo == nil || date == nil
//        || [date compare:[NSDate date]] == NSOrderedAscending) {
//        BBAppDelegate *delegate = (BBAppDelegate *)[UIApplication sharedApplication].delegate;
//        delegate.tencentOAuth.sessionDelegate = self;
//        delegate.at = kAuthorizeTypeQQ;
//        NSArray *permission = [NSArray arrayWithObjects:@"get_user_info", @"add_share",@"add_t",@"add_pic_t", nil];
//        [delegate.tencentOAuth authorize:permission inSafari:NO];
//    } else { // 发送腾讯微博
//        [self sendTencentWeibo];
//    }
}

/*!
 *@description      响应点击朋友圈按钮事件
 *@function         onFriends:
 *@param            sender     --按钮
 *@return           (void)
 */
- (IBAction)onFriends:(id)sender {
    [self hideActionSheet];
    
    
    appDelegate.at = KAuthorizeTypeWeixin;
    if (![WXApi openWXApp]) {
        UIAlertView *alt = [[UIAlertView alloc] initWithTitle:NOTICE_TITLE message:@"您尚未安装微信,是否立即进入下载页面?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alt.tag = 10000;
        [alt show];
        [alt release];
    }else{
        [self sendImageContent];
    }
}

/*!
 *@description      响应点击取消按钮事件
 *@function         onCancel:
 *@param            sender     --按钮
 *@return           (void)
 */
- (IBAction)onCancel:(id)sender {
    [self hideActionSheet];
}

- (IBAction)PreviousClick:(id)sender {
    
    if (![_scrollImageView skipToLastImage]) {
        [BBNoticeSender showNotice:@"已经是第一张图片了。"];
    }

//    if (_bg_scro.contentOffset.x>0) {
//        inter --;
//        [UIView animateWithDuration:0.25 animations:^{
//            [_bg_scro setContentOffset:CGPointMake(_bg_scro.contentOffset.x-_bg_scro.frame.size.width, 0)];
//        }];
//    }
}

- (IBAction)NextClick:(id)sender {
    
    if (![_scrollImageView skipToNextImage]) {
        [BBNoticeSender showNotice:@"已经是最后一张图片了。"];
    }

//    if (_bg_scro.contentOffset.x +_bg_scro.frame.size.width<_bg_scro.contentSize.width) {
//        [UIView animateWithDuration:0.25 animations:^{
//            inter ++;
//            [_bg_scro setContentOffset:CGPointMake(_bg_scro.contentOffset.x+_bg_scro.frame.size.width, 0)];
//        }];
//    }
   
  
}

- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this newcontext, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

/*!
 *@description  向朋友圈发送图片
 *@function     sendImageContent
 *@param        (void)
 *@return       (void)
 */
- (void) sendImageContent
{
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_hud setLabelText:@"正在发送..."];
    
//    WXMediaMessage *message = [WXMediaMessage message];
//    [message setThumbImage:[UIImage imageNamed:@"img1.png"]];
//    
//    WXImageObject *ext = [WXImageObject object];
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"img1" ofType:@"png"];
//    NSLog(@"filepath :%@",filePath);
//    ext.imageData = [NSData dataWithContentsOfFile:filePath];
//    
//    //UIImage* image = [UIImage imageWithContentsOfFile:filePath];
//    UIImage* image = [UIImage imageWithData:ext.imageData];
//    ext.imageData = UIImagePNGRepresentation(image);
//    
//    //    UIImage* image = [UIImage imageNamed:@"res5thumb.png"];
//    //    ext.imageData = UIImagePNGRepresentation(image);
//    
//    message.mediaObject = ext;
//    
//    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
//    req.bText = NO;
//    req.message = message;
//    req.scene = WXSceneTimeline;
//    
//    [WXApi sendReq:req];
    
    
    
//    NSInteger index = (NSInteger)(_bg_scro.contentOffset.x/_bg_scro.frame.size.width);
//    UIImageView *imgView = (UIImageView *)[_bg_scro viewWithTag:11100+index];
    UIImageView *imgView = _scrollImageView.visibleImageView;
    
    CGFloat k = imgView.image.size.width/imgView.image.size.height;
    UIImage *compressImage = [self imageWithImageSimple:imgView.image scaledToSize:CGSizeMake(k*100, 100)];
#if DEBUG
    NSData *data = UIImageJPEGRepresentation(compressImage, 1.);
    BBLog(@"压缩后大小%.2fkb",(CGFloat)data.length/1024.);
#endif
    WXMediaMessage *message = [WXMediaMessage message];
    [message setThumbImage:compressImage];

    WXImageObject *ext = [WXImageObject object];
    ext.imageData = UIImageJPEGRepresentation(imgView.image, 1.0);
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneTimeline;
    
    [WXApi sendReq:req];
}


/*!
 *@description  更新scrollview
 *@function     updateScroll
 *@param        (void)
 *@return       (void)
 */
- (void)updateScroll
{
    [_scrollImageView loadWithUrls:_urlsArr aryImg:_imgArr];
    
//    for (UIImageView *imageView in _bg_scro.subviews) {
//        if ([imageView isKindOfClass:[UIImageView class]]) {
//            [imageView removeFromSuperview];
//        }
//    }
//    
//    for (int i=0; i<_urlsArr.count; i++) {
//        UIImageView *img = [[UIImageView alloc]initWithFrame:_bg_scro.bounds];
//        
//        UIActivityIndicatorView *ac = [[UIActivityIndicatorView alloc]init];
//        ac.center = CGPointMake(_bg_scro.frame.size.width/2.0f, _bg_scro.frame.size.height/2.0f);
//        ac.tag = 12306;
//        [img addSubview:ac];
//        [ac startAnimating];
//        [ac release];
//        
//        img.delegateCache = self;
//        img.contentMode = UIViewContentModeScaleAspectFit;
//        [img setImageWithURL:[NSURL URLWithString:_urlsArr[i]]];
//        img.tag = 11100+i;
//        [_bg_scro addSubview:img];
////        img.center = CGPointMake(img.center.x+i*img.frame.size.width, img.center.y);
//        img.frame = CGRectMake(_bg_scro.frame.size.width*i,
//                               0,
//                               img.frame.size.width,
//                               img.frame.size.height);
//        [img release];
//    }
//    
//    CGSize newSzie = CGSizeMake(_urlsArr.count*_bg_scro.frame.size.width, _bg_scro.frame.size.height);
//    _bg_scro.contentSize = newSzie;
//    _bg_scro.contentOffset = CGPointMake(0, 0);
}

#pragma mark -
#pragma mark tencentOAuth delegate method
- (void)tencentDidLogin
{
//    BBAppDelegate *delegate = (BBAppDelegate *)[UIApplication sharedApplication].delegate;
//    TencentOAuth *to = [delegate tencentOAuth];
//    if (to.accessToken && 0 != [to.accessToken length]) {
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        [dic setObject:to.openId            forKey:QQ_ID_KEY];
//        [dic setObject:to.accessToken       forKey:QQ_TOKEN_KEY];
//        [dic setObject:to.expirationDate    forKey:QQ_EXPIRE_KEY];
//        [dic setObject:kQQAppKey            forKey:QQ_APP_ID];
//        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:EPA_QQ_INFO];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        [self sendTencentWeibo];
//    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled
{
    if (!cancelled) {
        UtilAlert(@"登陆发生异常， 请重试",nil);
        return;
    }
}

- (void)tencentDidNotNetWork
{
    UtilAlert(@"当前网络异常或不稳定，请稍后重试",nil);
}

/*!
 *@description 发送微博
 *@function sendTencentWeibo
 *@return void
 */
- (void)sendTencentWeibo
{
//    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [_hud setLabelText:@"正在发送..."];
//    
//    WeiBo_add_pic_t_POST *request = [[WeiBo_add_pic_t_POST alloc] init];
//    
////    NSInteger index = (NSInteger)(_bg_scro.contentOffset.x/_bg_scro.frame.size.width);
////    UIImageView *imgView = (UIImageView *)[_bg_scro viewWithTag:11100+index];
//    UIImageView *imgView = _scrollImageView.visibleImageView;
//    request.param_pic = imgView.image;
//    
//    [request setParam_content:@"\"柚保.云智能卫士\",你的生活好帮手。快来看一下吧！"];
//    BBAppDelegate *appdelegate = (BBAppDelegate *)[UIApplication sharedApplication].delegate;
//    [appdelegate.tencentOAuth sendAPIRequest:request callback:self];
//    [request release];
}

#pragma mark -
#pragma mark ASIHTTPRequestDelegate method
-(void)requestFinished:(ASIHTTPRequest *)request
{
    JSONDecoder *coder = [[JSONDecoder alloc] init];
    NSString *dataStr = [request.responseString stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    NSDictionary *result = [dataStr objectFromJSONString];
    [coder release];
    if (request.tag == 165) {
        [_hud setLabelText:@"发送成功..."];
        //腾讯微博
    }else if (request.tag == 166)
        
    {  [_hud setLabelText:@"发送成功..."];
        //新浪微博
    }else{
        
        
        NSNumber *status = [result objectForKey:@"status"];
        if (!status || [status isEqual:[NSNumber numberWithInt:0]]) {
            [_hud setLabelText:@"请求数据失败"];
            [_hud performSelector:@selector(hide:)
                      withObject:[NSNumber numberWithBool:YES]
                      afterDelay:1.0];
            return;
        }else{
            [_hud setLabelText:@"请求数据成功"];
        }
        NSDictionary *dict = [result objectForKey:@"data"];
//        _titleLab.text = [dict objectForKey:@"title"];
        
        
        NSString *timeStr = [dict objectForKey:@"time"];
        timeStr = [timeStr stringByReplacingOccurrencesOfString:@"-" withString:@" "];
        timeStr = [timeStr stringByReplacingOccurrencesOfString:@":" withString:@" "];
        
        NSDate *curDate = [NSDate date];
        NSDateFormatter *fmt = [[NSDateFormatter alloc]init];
        [fmt setDateFormat:@"yyyy MM dd HH mm ss"];
        NSDate *date = [fmt dateFromString:timeStr];
        [fmt release];
        
        NSTimeInterval timeGap = [curDate timeIntervalSinceDate:date];
        if (timeGap > 24*60*60) {
//            _time.text = [dict objectForKey:@"time"];
        }else{
            NSInteger sec  = (NSInteger)timeGap%60;
            NSInteger min = ((NSInteger)timeGap/60)%60;
            NSInteger hour = ((NSInteger)timeGap/3600)%24;
            NSMutableString *str = [[NSMutableString alloc]init];
            if (hour) {
                [str appendFormat:@"%d小时",hour];
            }
            if (min) {
                [str appendFormat:@"%d分",min];
            }
            if (!hour && !min) {
                [str appendFormat:@"%d秒",sec];
            }
            [str appendString:@"前"];
//            _time.text = str;
            [str release];
        }
    }
    [_hud performSelector:@selector(hide:)
              withObject:[NSNumber numberWithBool:YES]
              afterDelay:1.0];
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    [_hud setLabelText:@"请求数据失败"];
    [_hud performSelector:@selector(hide:)
              withObject:[NSNumber numberWithBool:YES]
              afterDelay:1.0];
    return;
}


#pragma mark -
#pragma mark UIAlertViewDelegate method
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if (alertView.tag == 10000) {
            NSURL *url =[NSURL URLWithString:WeiXinUrl];
            UIApplication *application = [UIApplication sharedApplication];
            if (url!=nil && [application canOpenURL:url] ) {
                [application openURL:url];
            }
        }else{
            
            _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [_hud setLabelFont:[UIFont systemFontOfSize:13.0f]];
            [_hud setLabelText:@"正在删除..."];
            [_hud setRemoveFromSuperViewOnHide:YES];
            BBFileClient *fileClient = [[BBSocketManager getInstance] fileClient];
//            NSInteger index = (NSInteger)(_bg_scro.contentOffset.x/_bg_scro.frame.size.width);
            BBLog(@"index = %d\n%@",_scrollImageView.urlIndex,_dataDic);
            NSString *imageId = [[_dataDic valueForKey:IMAGES_KEY][_scrollImageView.urlIndex] valueForKey:IMAGE_ID_KEY];
            NSString *param = [NSString stringWithFormat:@"%@\t%@",curUser.userid,imageId];
            [fileClient requestForDeleteFile: self param:param];
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView*)scrollView{
    
}

#pragma mark -
#pragma mark BBSocketClient delegate method
-(int)onRecevie:(BBDataFrame *)src received:(BBDataFrame *)data
{
    if (src.MainCmd == 0x0F && src.SubCmd == 41) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *result = [[NSString alloc]initWithString:[data dataString]];
            NSString *strTxt=@"删除失败";
            
            if(result && [result isEqualToString:@"0" ]){
                NSMutableArray *imageArr = [_dataDic valueForKey:IMAGES_KEY];
                [imageArr removeObjectAtIndex:_scrollImageView.urlIndex];
                [_urlsArr removeAllObjects];
                if (imageArr.count == 0) {
                    [_dataArr removeObject:_dataDic];
                    
                    if (self.navigationController) {
                        [self.navigationController popViewControllerAnimated:YES];
                    }else{
                        [self.presentingViewController dismissModalViewControllerAnimated:YES];
                    }
                    
                }else{
                    [_dataDic setValue:imageArr forKey:IMAGES_KEY];
                    [_dataDic setValue:[NSString stringWithFormat:@"%d",imageArr.count] forKey:IMAGES_COUNT_KEY];
                    for (int i=0; i<imageArr.count; i++) {
                        [_urlsArr addObject:[imageArr[i] valueForKey:IMAGE_KEY]];
                    }
                    
                    [_scrollImageView loadWithUrls:_urlsArr aryImg:imageArr];
                }
                
                //[self updateScroll];
                strTxt=@"删除成功";
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
    if (src.MainCmd == 0x0F && src.SubCmd == 41) {
        dispatch_async(dispatch_get_main_queue(), ^{
   
            [_hud setLabelText:@"删除图片超时"];
            [_hud performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }
}

-(void)onClose
{
    NSLog(@"Socketet closed");
}

-(void)onRecevieError:(BBDataFrame*)src received:(BBDataFrame*)data
{
    if (src.MainCmd == 0x0F && src.SubCmd == 41) {
        dispatch_async(dispatch_get_main_queue(), ^{
        [_hud setLabelText:@"删除图片出错"];
        [_hud performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        });
    }
}


#pragma mark -
#pragma mark UIImageViewWebCacheDelegate method
- (void)imageView:(UIImageView *)imageView didSetWithImage:(UIImage *)image
{
    UIView *ac = [imageView viewWithTag:12306];
    [ac removeFromSuperview];
}

@end
