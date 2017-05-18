 //
//  BBCloudEyesViewController.m
//  ZgSafe
//
//  Created by box on 13-10-25.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "BBCloudEyesViewController2.h"
#import "BBAlbumsViewController.h"
#import "BBUnlockView.h"
#import "BBVideoCameraViewController.h"
#import <IOTCamera/Camera.h>
//#import <IOTCamera/AVFRAMEINFO.h>
#import <IOTCamera/ImageBuffInfo.h>
#import <sys/time.h>

unsigned int _getTickCount() {
    
	struct timeval tv;
    
	if (gettimeofday(&tv, NULL) != 0)
        return 0;
    
	return (tv.tv_sec * 1000 + tv.tv_usec / 1000);
}

@interface BBCloudEyesViewController ()<BBUnlockViewDelegate, CameraDelegate,BBSocketClientDelegate,MonitorTouchDelegate,AVAudioPlayerDelegate,MyCameraDelegate>
{
    NSUInteger selectedChannel;
    MBProgressHUD *progress;
    
    
//    AVAudioRecorder *recorder;
//    AVAudioPlayer *player;
//    NSURL *recordedFile;
    
    
    MBProgressHUD *_uploadHud;
    MBProgressHUD *_getDeviceHud;
	CameraShowGLView *glView;
	CVPixelBufferRef mPixelBuffer;
	CGSize mSizePixelBuffer;
	unsigned short mCodecId;
	CVPixelBufferPoolRef mPixelBufferPool;
	BOOL bStopShowCompletedLock;
}

@property (nonatomic, retain) IBOutlet Monitor *monitor;// 摄像头展示区域

- (IBAction)onToCloudAlbums:(UIButton *)sender;
- (IBAction)onTakePhoto:(UIButton *)sender;
- (IBAction)onRecord:(UIButton *)sender;
- (IBAction)onClickEarBtn:(UIButton *)sender;
- (IBAction)onChangeScreen:(UIButton *)sender;
- (IBAction)onSetting:(UIButton *)sender;
- (IBAction)onClickCloseBtn:(UIButton *)sender;

@property (strong,nonatomic) UIImage *Myimg;

@end

@implementation BBCloudEyesViewController


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
    // Do any additional setup after loading the view from its nib.
    [super viewDidLoad];
    appDelegate.EyesVCBtn=NO;
    appDelegate.EyesIsOpen=NO;
    self.view.clipsToBounds = YES;

}


- (void)dealloc {
    if (glView) {
        [glView destroyFramebuffer];
        [glView release];
    }
    [camera release];
    [_monitor release];
    [_closeBtn release];
    [_toolBar release];
    [_cloudAlbumBtn release];
    [_takePhotoBtn release];
    [_recordBtn release];
    [_earBtn release];
    [_screenTypeBtn release];
    [_settingBtn release];
    [_closeBtn release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setMonitor:nil];
    [self setCloseBtn:nil];
    [self setToolBar:nil];
    [self setCloudAlbumBtn:nil];
    [self setTakePhotoBtn:nil];
    [self setRecordBtn:nil];
    [self setEarBtn:nil];
    [self setScreenTypeBtn:nil];
    [self setSettingBtn:nil];
    [self setMyimg:nil];
    
    if(mPixelBuffer!=nil){
        CVPixelBufferRelease(mPixelBuffer);
    }
    
    if(mPixelBufferPool!=nil){
        CVPixelBufferPoolRelease(mPixelBufferPool);
    }
    
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    if (IOS_VERSION >= 7.0f) {
        [UIView animateWithDuration:0.75 animations:^{
            appDelegate.statusBg.alpha = 0;
        }completion:^(BOOL finished) {
            
            appDelegate.statusBg.hidden = YES;
        }];
    }
    
    UIDeviceOrientation statusBarOrientation = [[UIDevice currentDevice]orientation];
//    UIInterfaceOrientation statusBarOrientation = appDelegate.window.rootViewController.interfaceOrientation;
    switch (statusBarOrientation) {
        case UIInterfaceOrientationPortrait:
            NSLog(@"UIInterfaceOrientationPortrait");
            [self fitPotrait];
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            NSLog(@"UIInterfaceOrientationPortraitUpsideDown");
            [self fitPotrait];
            break;
        case UIInterfaceOrientationLandscapeRight:
            NSLog(@"UIInterfaceOrientationLandscapeRight");
            [self fitLandscape];
            break;
        case UIInterfaceOrientationLandscapeLeft:
            NSLog(@"UIInterfaceOrientationLandscapeLeft");
            [self fitLandscape];
            break;
        default:
            [self fitPotrait];
            break;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
    appDelegate.EyesVCBtn=NO;
    
    appDelegate.EyesIsOpen=NO;
    
    if(appDelegate.EyesVCShowwing){
        if (camera != nil) {
            [camera startShow:selectedChannel ScreenObject:self];
            
            if(_recordBtn.selected){
                //开始说话
                [self startTalkToDevice];
            }else{
                //开始监听
                [self startListenToDevice];
            }
        }
    }else{
        [self getDatas];
    }    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
    if (IOS_VERSION >= 7.0f) {
        appDelegate.statusBg.frame = [[UIApplication sharedApplication]statusBarFrame];
        appDelegate.statusBg.alpha = 0;
        appDelegate.statusBg.hidden = NO;
        
        [UIView animateWithDuration:0.8 animations:^{
            appDelegate.statusBg.alpha = 1;
        }completion:^(BOOL finished) {
            appDelegate.statusBg.hidden = NO;
        }];
    }
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    if(appDelegate.EyesVCBtn){
        if (camera != nil) {
            [camera stopShow:selectedChannel];
            [camera stopSoundToDevice:selectedChannel];
            [camera stopSoundToPhone:selectedChannel];
            [self unactiveAudioSession];
        }
    }else{
        [camera stopShow:selectedChannel];
        [camera stopSoundToDevice:selectedChannel];
        [camera stopSoundToPhone:selectedChannel];
        [self stopCamera:camera];
        [camera disconnect];
        

        appDelegate.statusBg.hidden = NO;
        
        appDelegate.EyesVCShowwing = NO;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationWillResignActiveNotification
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationWillEnterForegroundNotification
                                                      object:nil];
        BB_SAFE_RELEASE(camera);
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)waitStopShowCompleted:(unsigned int)uTimeOutInMs
{
	unsigned int uStart = _getTickCount();
	while( bStopShowCompletedLock == FALSE ) {
		usleep(1000);
		unsigned int now = _getTickCount();
		if( now - uStart >= uTimeOutInMs ) {
			NSLog( @"CameraLiveViewController - waitStopShowCompleted !!!TIMEOUT!!!" );
			break;
		}
	}
	
}

- (void)cameraStopShowCompleted:(NSNotification *)notification
{
	bStopShowCompletedLock = TRUE;
}

#pragma mark -
#pragma mark rotate method
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
//    UIInterfaceOrientation orientation = toInterfaceOrientation;
//    //    UIInterfaceOrientation orientation = appDelegate.window.rootViewController.interfaceOrientation;
//    //竖屏
//    if (UIInterfaceOrientationPortrait == orientation) {
//        appDelegate.statusBg.frame = CGRectMake(0, 0,  appDelegate.window.frame.size.height,20);
//        [self fitPotrait];
//    }
//    //横屏
//    else if (UIInterfaceOrientationPortraitUpsideDown != orientation){
//        if (UIInterfaceOrientationLandscapeLeft == orientation) {
//            appDelegate.statusBg.frame = CGRectMake(0, 0, 20, appDelegate.window.frame.size.height);
//        }else{
//            appDelegate.statusBg.frame = CGRectMake( 300,0, 20, appDelegate.window.frame.size.height);
//        }
//        [self fitLandscape];
    
//    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    UIInterfaceOrientation orientation = [[UIDevice currentDevice]orientation];
//    UIInterfaceOrientation orientation = appDelegate.window.rootViewController.interfaceOrientation;
    //竖屏
    if (UIInterfaceOrientationPortrait == orientation) {
//        appDelegate.statusBg.frame = CGRectMake(0, 0,  appDelegate.window.frame.size.height,20);
        [self fitPotrait];
    }
    //横屏
    else if (UIInterfaceOrientationPortraitUpsideDown != orientation){
        if (UIInterfaceOrientationLandscapeLeft == orientation) {
//            appDelegate.statusBg.frame = CGRectMake(0, 0, 20, appDelegate.window.frame.size.height);
        }else{
//            appDelegate.statusBg.frame = CGRectMake( 300,0, 20, appDelegate.window.frame.size.height);
        }
        [self fitLandscape];
    }
}

#pragma mark -
#pragma mark Application status change notification handler
- (void)appDidEnterBackground:(id)sender
{
    
    NSLog(@"appDidEnterBackground................");
    
    if(camera!=nil){
        [self stopCamera:camera];
        [camera disconnect];
        
        appDelegate.statusBg.hidden = NO;
        
        appDelegate.EyesVCShowwing = NO;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationWillResignActiveNotification
                                                      object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationWillEnterForegroundNotification
                                                      object:nil];
        BB_SAFE_RELEASE(camera);
    }
    
//    if (progress) {
//        [progress hide:YES];
//        progress = nil;
//    }
    
    
   // [self stopCamera:camera];
//    [self onClickCloseBtn:nil];
}

- (void)appWillEnterForeground:(id)sender
{
//    [self connectDevice:self.deviceID];
    
    NSLog(@"appWillEnterForeground................");

    [self getDatas];
    //[self restartCamera];
}

- (void)appDidBecomeActive:(id)sender
{
//    [self connectDevice:self.deviceID];
    
    NSLog(@"appDidBecomeActive................");
    
    [self getDatas];
    //[self restartCamera];
}

#pragma mark -
#pragma mark self define method

/*!
 *@description  获取当前绑定设备
 *@function     getDatas
 *@param        (void)
 *@return       (void)
 */
- (void)getDatas
{
//    _getDeviceHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [_getDeviceHud setLabelFont:[UIFont systemFontOfSize:13.0f]];
//    [_getDeviceHud setLabelText:@"连接视频中..."];
//    [_getDeviceHud setRemoveFromSuperViewOnHide:YES];
//    BBMainClient *mainClient = [[BBSocketManager getInstance] mainClient];
//    NSString *userId = curUser.userid;
//    [mainClient queryCurrentTerminal:self param:userId];
//
    NSString *strDeivceID=curUser.deviceid;
    
    if(strDeivceID==nil){
         UtilAlert(@"视频连接失败", nil);
    }else{
        _deviceID=strDeivceID;
        
        selectedChannel = 0;
        
        NSString *nameStr = [NSString stringWithFormat:@"视频(%@)",_deviceID];
        camera = [[MyCamera alloc] initWithName:nameStr viewAccount:@"admin" viewPassword:@"admin"];
        //                [camera setDelegate:self];
        camera.delegate2 = self;
        camera.lastChannel = 0;
        
        appDelegate.EyesVCShowwing = YES;
           
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDidEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillEnterForeground:)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
        
        [self connectDevice:self.deviceID];
        
    }
}

/*!
 *@description  经过安全手势验证之后push云眼页面
 *@function     verifyThenPushWithVC:
 *@param        viewControllor      --云眼的前一个页面
 *@return       (void)
 */
+ (void)verifyThenPushWithVC:(UIViewController *)viewControllor
{
    BBCloudEyesViewController *eyesVC = [[BBCloudEyesViewController alloc]initWithNibName:@"BBCloudEyesViewController2" bundle:nil];
    eyesVC.lastViewController = viewControllor;
    
//屏蔽解锁功能
//    BlueBoxer *user = curUser;
//    if (user.gestureUnlock && user.safeGestureOpened) {
//        BBUnlockView *unlockView = [[BBUnlockView alloc]initWithFrame:appDelegate.window.frame];
//        [unlockView setBackgroundColor:[UIColor colorWithRed:0. green:0. blue:0. alpha:0.7]];
//        unlockView.isModifyPswd = NO;
//        unlockView.delegate = eyesVC;
//        //eyesVC将在手势解锁成功或者取消解锁之后释放
//        UINavigationController *nav = (UINavigationController *)appDelegate.window.rootViewController;
//        [nav.visibleViewController.view addSubview:unlockView];
//        [unlockView release];
//        
//        CATransition *anim = [CATransition animation];
//        anim.duration = 0.5f;
//        anim.removedOnCompletion = YES;
//        anim.type = kCATransitionPush;
//        anim.subtype = kCATransitionFromTop;
//        [unlockView.layer addAnimation:anim forKey:nil];
//    }else{
//        
//        [viewControllor presentModalViewController:eyesVC animated:YES];
////        [viewControllor.navigationController pushViewController:eyesVC animated:YES];
//        [eyesVC release];
//    }
    
    [viewControllor presentModalViewController:eyesVC animated:YES];
    //        [viewControllor.navigationController pushViewController:eyesVC animated:YES];
    [eyesVC release];
    
}


/*!
 *@description      适配横屏
 *@function         fitLandscape
 *@param            (void)
 *@return           (void)
 */
- (void)fitLandscape
{
    NSLog(@"适配横屏 ： %@",self.view);
    NSLog(@"适配横屏  _closeBtn  == %@",_closeBtn);
    [_closeBtn setCenter:CGPointMake(_closeBtn.center.x, 10+_closeBtn.frame.size.height/2.)];
    [UIView animateWithDuration:0.25f animations:^{
        _toolBar.center = CGPointMake(_toolBar.center.x,self.view.bounds.size.height-_toolBar.frame.size.height/2.-13.);
        
        CGFloat k = self.view.bounds.size.width/568.;
        _cloudAlbumBtn.center = CGPointMake(25./2.*k
                                            +_cloudAlbumBtn.frame.size.width/2.
                                            , _cloudAlbumBtn.center.y);
        
        _takePhotoBtn.center = CGPointMake((25.+286.)/2.*k
                                           +_cloudAlbumBtn.frame.size.width
                                           +_takePhotoBtn.frame.size.width/2.
                                           , _takePhotoBtn.center.y);
        
        _recordBtn.center = CGPointMake((25.+286.+31.)/2.*k
                                        +_cloudAlbumBtn.frame.size.width
                                        +_takePhotoBtn.frame.size.width
                                        +_recordBtn.frame.size.width/2.
                                        +20
                                        , _recordBtn.center.y);
        
        _earBtn.center = CGPointMake(self.view.bounds.size.width-(12.+282.+31.)/2.*k
                                     -_settingBtn.frame.size.width
                                     -_screenTypeBtn.frame.size.width
                                     -_earBtn.frame.size.width/2.                                     , _earBtn.center.y);
        
        
        _screenTypeBtn.center =  CGPointMake(self.view.bounds.size.width-(12.+282.)/2.*k
                                             -_settingBtn.frame.size.width
                                             -_screenTypeBtn.frame.size.width/2.
                                             , _screenTypeBtn.center.y);
        
        _settingBtn.center = CGPointMake(self.view.bounds.size.width-(12.)/2.*k
                                         -_settingBtn.frame.size.width/2.
                                         , _settingBtn.center.y);
        
        
        CGFloat delta = 0.;
        if (IOS_VERSION >= 7.0) {
            delta = 20.;
        }
        
        _monitor.frame = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
        NSLog(@"%@",self.view);
//        glView.frame = CGRectMake(0, delta, self.view.frame.size.height, self.view.frame.size.width);

    }completion:^(BOOL finished) {
        if (finished) {
            if (!glView) {
                glView = [[CameraShowGLView alloc] initWithFrame:self.monitor.frame];
                [glView setDelegate: self];
                [glView attachCamera:camera];
                [self.view addSubview:glView];
                //                [self.view sendSubviewToBack:glView];
            }
            [UIView animateWithDuration:0.25 animations:^{
                glView.frame = self.monitor.frame;
            }];
            [self.view bringSubviewToFront:_toolBar];
            [self.view bringSubviewToFront:_closeBtn];
        }
    }];
}

/*!
 *@description      适配竖屏
 *@function         fitPotrait
 *@param            (void)
 *@return           (void)
 */
- (void)fitPotrait
{
    CGFloat delta = 0.;
    if (0&&IOS_VERSION >= 7.0) {
        delta = 20.;
    }
//  关闭按钮不需要位置调整2013-11-18 10:06 zgf
    _closeBtn.center = CGPointMake(self.view.frame.size.width-5-_closeBtn.frame.size.width/2.
                                        , delta+17./2.+_closeBtn.frame.size.height/2.);
    
    NSLog(@"fitPotrait _closeBtn  == %@",_closeBtn);
    
    [UIView animateWithDuration:0.25f animations:^{
        
        _toolBar.frame = CGRectMake(0, self.view.frame.size.height-44, 320, 44);
        
        
        _cloudAlbumBtn.center = CGPointMake(11+_cloudAlbumBtn.frame.size.width/2.
                                            , _cloudAlbumBtn.center.y);
        _takePhotoBtn.center = CGPointMake((23.+73.)/2.
                                           +_cloudAlbumBtn.frame.size.width
                                           +_takePhotoBtn.frame.size.width/2.
                                           , _takePhotoBtn.center.y);
        
        _recordBtn.center = CGPointMake((23.+73.+22.)/2.
                                        +_cloudAlbumBtn.frame.size.width
                                        +_takePhotoBtn.frame.size.width
                                        +_recordBtn.frame.size.width/2.
                                        +20
                                        , _recordBtn.center.y);
        
        _earBtn.center = CGPointMake((23.+73.+22.+22.)/2.
                                     +_cloudAlbumBtn.frame.size.width
                                     +_takePhotoBtn.frame.size.width
                                     +_recordBtn.frame.size.width
                                     +_earBtn.frame.size.width/2.
                                     , _earBtn.center.y);
        
        _screenTypeBtn.center = CGPointMake((23.+73.+22.+22.+22.)/2.
                                            +_cloudAlbumBtn.frame.size.width
                                            +_takePhotoBtn.frame.size.width
                                            +_recordBtn.frame.size.width
                                            +_earBtn.frame.size.width
                                            +_screenTypeBtn.frame.size.width/2.
                                            , _screenTypeBtn.center.y);
        
        _settingBtn.center =  CGPointMake((23.+73.+22.+22.+22.+70.)/2.
                                          +_cloudAlbumBtn.frame.size.width
                                          +_takePhotoBtn.frame.size.width
                                          +_recordBtn.frame.size.width
                                          +_earBtn.frame.size.width
                                          +_screenTypeBtn.frame.size.width
                                          +_settingBtn.frame.size.width/2.
                                          , _settingBtn.center.y);
        CGFloat y = 0.;
        if (0 && IOS_VERSION >= 7.0) {
            y = ISIP5 ? 170+20 : 130+20;
        }else{
            y = ISIP5 ? 170 : 130;
        }
        _monitor.frame = CGRectMake(0, y, 320, 200);
//        glView.frame = CGRectMake(0, y, 320, 200);
    }completion:^(BOOL finished) {
        if (finished) {
            if (!glView) {
                glView = [[CameraShowGLView alloc] initWithFrame:self.monitor.frame];
                [glView setDelegate: self];
                [glView attachCamera:camera];
                [self.view addSubview:glView];
//                [self.view sendSubviewToBack:glView];
            }
            [UIView animateWithDuration:0.25 animations:^{
                glView.frame = self.monitor.frame;
            }];
            [self.view bringSubviewToFront:_toolBar];
            [self.view bringSubviewToFront:_closeBtn];
        }
    }];
}



/*!
 *@description      响应点击关闭按钮
 *@function         onClickCloseBtn:
 *@param            sender     --关闭按钮
 *@return           (void)
 */
- (IBAction)onClickCloseBtn:(UIButton *)sender {
    //[self retain];
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.presentingViewController dismissModalViewControllerAnimated:YES];
    }
    //[self performSelector:@selector(release) withObject:nil afterDelay:30];
    
//    appDelegate.EyesVCBtn=YES;
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [self stopCamera:camera];
//        
//        [camera disconnect];
//
//        //    [Camera uninitIOTC];
//        appDelegate.statusBg.hidden = NO;
//        
//        CVPixelBufferRelease(mPixelBuffer);
//        CVPixelBufferPoolRelease(mPixelBufferPool);
//        
//        appDelegate.EyesVCShowwing = NO;
//        
//        [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                        name:UIApplicationWillResignActiveNotification
//                                                      object:nil];
//        [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                        name:UIApplicationWillEnterForegroundNotification
//                                                      object:nil];
//        BB_SAFE_RELEASE(camera);
//    });

}

/*!
 *@description  响应点击云相册按钮事件
 *@function     onToCloudAlbums:
 *@param        sender     --按钮
 *@return       (void)
 */
- (IBAction)onToCloudAlbums:(UIButton *)sender {
    BBAlbumsViewController *vc = [[BBAlbumsViewController alloc]init];
    appDelegate.EyesVCBtn=YES;
    [self presentModalViewController:vc animated:YES];
    [vc release];
}


/*!
 *@description  响应点击抓拍按钮事件
 *@function     onTakePhoto:
 *@param        sender     --按钮
 *@return       (void)
 */
- (IBAction)onTakePhoto:(UIButton *)sender
{
    if(self.Myimg!=nil){
        UIImageWriteToSavedPhotosAlbum(self.Myimg, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }
    
//    char *imageFrame = (char *) malloc(MAX_IMG_BUFFER_SIZE);
//    unsigned int w = 0, h = 0;
//    unsigned int codec_id=1234;
//    unsigned int size = 0;
//    size = [camera getChannel:selectedChannel Snapshot:imageFrame DataSize:MAX_IMG_BUFFER_SIZE ImageType:&codec_id   WithImageWidth:&w ImageHeight:&h];
    //if (size > 0) {
//        UIImage *img = NULL;
//        img = [self getUIImage:imageFrame Width:w Height:h];
        
//        UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
//        UIImage *img = NULL;
//        
//        if (codec_id == MEDIA_CODEC_VIDEO_H264 || codec_id == MEDIA_CODEC_VIDEO_MPEG4) {
//            img = [self getUIImage:imageFrame Width:w Height:h];
//            [img retain];
//            
//            UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
//        
//        } else if (codec_id == MEDIA_CODEC_VIDEO_MJPEG) {
//            NSData *data = [[NSData alloc] initWithBytes:imageFrame length:size];
//            img = [[UIImage alloc] initWithData:data];
//            UIImageWriteToSavedPhotosAlbum(img, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
//            
//        }
//    }
//    
//    free(imageFrame);
}

/*!
 *@brief        从传回的帧上获取图片
 *@function     getUIImage:Width:Height:
 *@param        buff            -- 数据缓冲区
 *@param        width           -- 图片宽度
 *@param        height          -- 图片高度
 *@return       (UIImage)       -- 获取的图片
 */
- (UIImage *)getUIImage:(char *)buff Width:(NSInteger)width Height:(NSInteger)height {
    
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buff, width * height * 3, NULL);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imgRef = CGImageCreate(width, height, 8, 24, width * 3, colorSpace, kCGBitmapByteOrderDefault, provider, NULL, true,  kCGRenderingIntentDefault);
    UIImage *img = [UIImage imageWithCGImage:imgRef];
    
    if (imgRef != nil) {
        CGImageRelease(imgRef);
        imgRef = nil;
    }
    
    if (colorSpace != nil) {
        CGColorSpaceRelease(colorSpace);
        colorSpace = nil;
    }
    
    if (provider != nil) {
        CGDataProviderRelease(provider);
        provider = nil;
    }
    
    //img格式可能有误 重新画一个image  解决截图崩的问题 2014-3-3 赵文双
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [img drawInRect:CGRectMake(0, 0, width, height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [[newImage copy] autorelease];
    
}

/*!
 *@description  上传图片至服务器
 *@function     uploadImage:
 *@param        image
 *@return       (void)
 */
- (void)uploadImage:(UIImage *)image
{
    _uploadHud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_uploadHud setLabelFont:[UIFont systemFontOfSize:13.0f]];
    [_uploadHud setLabelText:@"正在上传至服务器..."];
    [_uploadHud setRemoveFromSuperViewOnHide:YES];
    
    BBFileClient *fileClient = [[BBSocketManager getInstance] fileClient];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter release];
    //    NSTimeInterval time = [[NSDate date]timeIntervalSince1970];
//    NSString *param = [NSString stringWithFormat:@"%@\t1\t%.3lf",dateStr,time];
    NSString *param = [NSString stringWithFormat:@"%@\t1\t0",dateStr];
    NSData *fileData = UIImagePNGRepresentation(image);
    [fileClient writeFile:fileData withParam:param callbackHandler:self];
    BB_SAFE_RELEASE(image);
}

/*!
 *@brief        保存图片的回调函数
 *@function     image:didFinishSavingWithError:contextInfo:
 *@param        context             -- 设备上下文
 *@return       (void)
 */
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *msg = @"图片已保存到相册";
    
    if (error) {
        msg=[error description];
    }
    
    UtilAlert(msg, nil);
    
//    NSLog(@"saveImageCompletionHandler");
//
//    if (error != nil) {
//        msg = [error localizedDescription];
//    }
//    [[iToast makeText:msg] show]; 
////    [self uploadImage:image];
//    [self performSelector:@selector(uploadImage:) withObject:image afterDelay:1.0f];
}

- (BOOL)getAudioInSupportOfChannel:(NSInteger)channel
{
    return ([camera getServiceTypeOfChannel:channel] & 1) == 0;
}
/*!
 *@description  开始对设备说话
 *@function     startTalkToDevice
 *@param        (void)
 *@return       (void)
 */
- (void)startTalkToDevice
{
//    BBLog(@"[camera getAudioInSupportOfChannel:selectedChannel] == %d",[self getAudioInSupportOfChannel:selectedChannel]);
//    BBLog(@"[camera getAudioOutSupportOfChannel:selectedChannel] == %d",[self getAudioOutSupportOfChannel:selectedChannel]);
 
    
    if ([camera getAudioInSupportOfChannel:selectedChannel]) {
//    if ([self getAudioOutSupportOfChannel:selectedChannel]) {
        
        selectedAudioMode = kAudioModeMicrophone;
        
        _earBtn.selected = NO;
        _recordBtn.selected = YES;
        [camera stopSoundToPhone:selectedChannel];
        
        [self unactiveAudioSession];
        [self activeAudioSession];
        
        [camera startSoundToDevice:selectedChannel];
        BBLog(@"通话开启");
        
    } else {
        UtilAlert(@"开启语音通话失败", nil);
    }
}

/*!
 *@description  结束对设备说话
 *@function     endTalkToDevice
 *@param        (void)
 *@return       (void)
 */
- (void)endTalkToDevice
{
    [self unactiveAudioSession];
    _recordBtn.selected = NO;
    selectedAudioMode = kAudioModeOff;
    [camera stopSoundToDevice:selectedChannel];
}

/*!
 *@description  响应点击通话按钮事件  手机 --> 设备
 *@function     onRecord:
 *@param        sender     --按钮
 *@return       (void)
 */
- (IBAction)onRecord:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender.selected) {
        //开启通话
        if (IOS_VERSION >= 7.0) {
            void (^requestHandler)(BOOL) = ^(BOOL granted) {
                if (!granted) {
                    UtilAlert(@"柚保未获得麦克风使用权限，请在\"设置\"-\"隐私\"-\"麦克风\"中开启",nil);
                    return ;
                }
                dispatch_queue_t queue = dispatch_get_main_queue();
                dispatch_async(queue, ^{
                    [self startTalkToDevice];
                });
            };
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio
                                     completionHandler:requestHandler];
        } else {
        
            [self startTalkToDevice];
        }
        
    }else{
        //开启监听
        [self startListenToDevice];
    }
}

- (BOOL)getAudioOutSupportOfChannel:(NSInteger)channel
{
    return ([camera getServiceTypeOfChannel:channel] & 2) == 0;
}
/*!
 *@description  开始监听设备声音
 *@function     startListenToDevice
 *@param        (void)
 *@return       (void)
 */
- (void)startListenToDevice
{
//    BBLog(@"[camera getAudioOutSupportOfChannel:selectedChannel] == %d",[self getAudioOutSupportOfChannel:selectedChannel]);
    
 
    
//    if ([self getAudioOutSupportOfChannel:selectedChannel]) {
    if ([camera getAudioInSupportOfChannel:selectedChannel]) {
        
        selectedAudioMode = kAudioModeSpeaker;
        
        _recordBtn.selected = NO;
        _earBtn.selected = YES;
        [camera stopSoundToDevice:selectedChannel];
        
        [self unactiveAudioSession];
        [self activeAudioSession];
        
        [camera startSoundToPhone:selectedChannel];
        BBLog(@"监听开启");
    } else {
        UtilAlert(@"开启监听失败", nil);
    }
}

/*!
 *@description  结束监听设备声音
 *@function     endListenToDevice
 *@param        (void)
 *@return       (void)
 */
- (void)endListenToDevice
{
    [self unactiveAudioSession];
    _earBtn.selected = NO;
    selectedAudioMode = kAudioModeOff;
    [camera stopSoundToPhone:selectedChannel];
}

/*!
 *@description  响应点击监听按钮事件  设备 --> 手机
 *@function     onClickEarBtn:
 *@param        sender     --按钮
 *@return       (void)
 */
- (IBAction)onClickEarBtn:(UIButton *)sender {
    if (!sender.selected) {
        //开启监听
        [self startListenToDevice];
    }else{
        //结束监听
        [self endListenToDevice];
    }
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}

/*!
 *@description  响应点击横竖屏按钮事件
 *@function     onChangeScreen:
 *@param        sender     --按钮
 *@return       (void)
 */
- (IBAction)onChangeScreen:(UIButton *)sender {
    if (CGAffineTransformIsIdentity(self.view.transform)) {
//        NSLog(@"%@",self.view);
        [UIView animateWithDuration:0.25f animations:^{
            
            self.view.transform = CGAffineTransformMakeRotation(M_PI*0.5);
        }completion:^(BOOL finished) {
            [[UIApplication sharedApplication]setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
//            NSLog(@"%@",self.view);
            self.view.bounds = CGRectMake(0
                                          , 0
                                          , self.view.bounds.size.height
                                          , self.view.bounds.size.width);
//            NSLog(@"%@",self.view);
            [self performSelector:@selector(fitLandscape) withObject:nil afterDelay:0.1f];
//            NSLog(@"%@",self.view);
        }];
    }else{
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
        [UIView animateWithDuration:0.25f animations:^{
            self.view.transform = CGAffineTransformIdentity;
        }completion:^(BOOL finished) {
            self.view.bounds = CGRectMake(0
                                          , 0
                                          , self.view.bounds.size.height
                                          , self.view.bounds.size.width);
            
            [self performSelector:@selector(fitPotrait) withObject:nil afterDelay:0.1f];
        }];
        
        
    }
}


/*!
 *@description  响应点击设置按钮事件
 *@function     onSetting:
 *@param        sender     --按钮
 *@return       (void)
 */
- (IBAction)onSetting:(UIButton *)sender {
    
    BBVideoCameraViewController *vc = [[BBVideoCameraViewController alloc]init];
    appDelegate.EyesVCBtn=YES;
    [self presentModalViewController:vc animated:YES];
    [vc release];
}

- (void)connectDevice:(NSString *)deviceId
{
    if (_deviceID == nil || [_deviceID isEqual:@""]) {
        UtilAlert(@"设备id为空,不能连接设备", nil);
        return ;
    }
    
    progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [progress setLabelText:@"视频连接中..."];
    [progress setRemoveFromSuperViewOnHide:YES];
    
    [camera connect:deviceId];
    
    [self startCamera:nil];
}

/*!
 *@brief        停止视频传输
 *@function     stopCamera:
 *@param        camera
 *@return       (void)
 */
- (void)stopCamera:(MyCamera *)camera1
{
    [_monitor deattachCamera];
    [glView deattachCamera];
    [self unactiveAudioSession];
    [camera1 stopShow:selectedChannel];
    [camera1 stop:selectedChannel];
//    [camera1 disconnect];
//    [camera disconnect];
}

/*!
 *@brief        启动视频传输
 *@function     startCamera:
 *@param        sender
 *@return       (void)
 */
- (void)startCamera:(id)sender
{
//    [Camera start:camera.lastChannel];
    if ([camera getConnectionStateOfChannel:0] != kCameraSessionStateConnected) {
        //            [camera start:0];
        SMsgAVIoctrlGetAudioOutFormatReq *s = (SMsgAVIoctrlGetAudioOutFormatReq *)malloc(sizeof(SMsgAVIoctrlGetAudioOutFormatReq));
        s->channel = 0;
        [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETAUDIOOUTFORMAT_REQ Data:(char *)s DataSize:sizeof(SMsgAVIoctrlGetAudioOutFormatReq)];
        free(s);
        
        SMsgAVIoctrlGetSupportStreamReq *s2 = (SMsgAVIoctrlGetSupportStreamReq *)malloc(sizeof(SMsgAVIoctrlGetSupportStreamReq));
        [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETSUPPORTSTREAM_REQ Data:(char *)s2 DataSize:sizeof(SMsgAVIoctrlGetSupportStreamReq)];
        free(s2);
    }
    
    
//    [camera start:0 viewAccount:@"admin" viewPassword:@"admin" is_playback:FALSE];
//	[camera startShow:0 ScreenObject:self];
    
    [camera start:selectedChannel];
    
    
    
//!     2014.3.6添加  解决通话没声音问题
/////////////////////////////////////////////////////////////////////////////
    
    SMsgAVIoctrlGetAudioOutFormatReq *s = (SMsgAVIoctrlGetAudioOutFormatReq *)malloc(sizeof(SMsgAVIoctrlGetAudioOutFormatReq));
    s->channel = 0;
    [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETAUDIOOUTFORMAT_REQ Data:(char *)s DataSize:sizeof(SMsgAVIoctrlGetAudioOutFormatReq)];
    free(s);
    
    SMsgAVIoctrlGetSupportStreamReq *s2 = (SMsgAVIoctrlGetSupportStreamReq *)malloc(sizeof(SMsgAVIoctrlGetSupportStreamReq));
    [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETSUPPORTSTREAM_REQ Data:(char *)s2 DataSize:sizeof(SMsgAVIoctrlGetSupportStreamReq)];
    free(s2);
/////////////////////////////////////////////////////////////////////////////
    
    [camera startShow:selectedChannel ScreenObject:self];
    [self.monitor attachCamera:camera];
    
    
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(cameraStopShowCompleted:) name: @"CameraStopShowCompleted" object: nil];
    
    if (!glView) {
        
        UIInterfaceOrientation currOrientation = [[UIDevice currentDevice] orientation];
        CGSize glSize = CGSizeZero;
        if (UIInterfaceOrientationIsPortrait(currOrientation)) {
            glSize = CGSizeMake(320, 240);
        } else {
            glSize = CGSizeMake(480, 320);
        }
        CGRect glFrame = CGRectMake((self.view.bounds.size.width - glSize.width) / 2.
                                    , (self.view.bounds.size.height - glSize.height) / 2.
                                    , glSize.width, glSize.height);
        glView = [[CameraShowGLView alloc] initWithFrame:glFrame];
        [glView setDelegate: self];
        [glView attachCamera:camera];
        [self.view insertSubview:glView atIndex:1];
        
        [UIView animateWithDuration:0.25 animations:^{
            glView.frame = self.monitor.frame;
        }];
    }
}

/*!
 *@brief        检测摄像头状态
 *@function     verifyCameraStatus
 *@param        camera
 *@return       (void)
 */
- (void)verifyCameraStatus:(MyCamera *)camera1
{
    NSString *cameraName = camera.name;
    CameraSessionState state = (CameraSessionState)camera.sessionState;
    switch (state) {
        case kCameraSessionStateNone:
        {
            NSLog(@"%@ 正在连接", cameraName);
            break;
        }
        case kCameraSessionStateConnecting:
        {
            NSLog(@"%@ 正在连接", cameraName);
            break;
        }
        case kCameraSessionStateConnected:
        {
            NSLog(@"%@ 已连接", cameraName);
            break;
        }
        case kCameraSessionStateDisconnected:
        {
            NSLog(@"%@ 已断开连接", cameraName);
            break;
        }
        case kCameraSessionStateUnknownDevice:
        {
            NSLog(@"%@ 发现未知设备", cameraName);
            break;
        }
        case kCameraSessionStateWrongPassword:
        {
            NSLog(@"%@ 密码错误", cameraName);
            break;
        }
        case kCameraSessionStateTimeOut:
        {
            NSLog(@"%@ 连接超时", cameraName);
            break;
        }
            
        case kCameraSessionStateUnsupported:
        {
            NSLog(@"%@ 不支持此功能", cameraName);
            break;
        }
        case kCameraSessionStateConnectFailed:
        {
            NSLog(@"%@ 连接失败", cameraName);
            break;
        }
        default:
            NSLog(@"%@ 发生未知错误", cameraName);
            break;
    }
}

- (void)activeAudioSession
{
    
    if (IOS_VERSION >= 7.0) {
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        void (^captureHandler)(BOOL) = ^(BOOL granted) {
            if (granted) {
                dispatch_semaphore_signal(sem);
            } else {
                UtilAlert(@"未获取麦克风使用权限", nil);
                return ;
            }
        };
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:captureHandler];
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        dispatch_release(sem);
    }
    
    OSStatus error;
    
    UInt32 category = kAudioSessionCategory_LiveAudio;
    
    if (selectedAudioMode == kAudioModeSpeaker) {
        category = kAudioSessionCategory_LiveAudio;
        NSLog(@"kAudioSessionCategory_LiveAudio");
    }
    
    if (selectedAudioMode == kAudioModeMicrophone) {
        category = kAudioSessionCategory_PlayAndRecord; 
        NSLog(@"kAudioSessionCategory_PlayAndRecord");
    }
    
    error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
    if (error)
        printf("couldn't set audio category!");
    
    error = AudioSessionSetActive(true);
    if (error)
        printf("AudioSessionSetActive (true) failed");
}

- (void)unactiveAudioSession
{
    OSStatus error;
    error = AudioSessionSetActive(false);
    if (error) {
        printf("AudioSessionSetActive error = %ld\n",error);
    }
}


#pragma mark -
#pragma mark - BBUnlockViewDelegate method
- (void)didUnlockSuccessed:(BBUnlockView *)unlockView
{
    //    UtilAlert(@"解锁成功",nil);
    
    [unlockView removeFromSuperview];
    
//    UINavigationController *nav = (UINavigationController *)appDelegate.window.rootViewController;
//    [nav.topViewController.navigationController pushViewController:self animated:YES];
    [_lastViewController presentModalViewController:self animated:YES];
    
    //这里的release是抵消创建本页面的alloc
    [self release];
    
}

- (void)didUnlockFailed:(BBUnlockView *)unlockView
{
    UtilAlert(@"解锁失败",nil);
}

- (void)didTouchBackgroundBegan:(BBUnlockView *)unlockView
{
    [UIView animateWithDuration:0.5f animations:^{
        unlockView.alpha = 0.;
    }completion:^(BOOL finished) {
        [unlockView removeFromSuperview];
        //这里的release是抵消创建本页面的alloc
        [self release];
    }];
}
#pragma mark - MonitorTouchDelegate Methods
/*
 - (void)monitor:(Monitor *)monitor gestureSwiped:(Direction)direction
 {
 }
 */

- (void)monitor:(Monitor *)monitor gesturePinched:(CGFloat)scale
{
	NSLog( @"CameraLiveViewController - Pinched scale:%f", scale );
    
}


#pragma mark -
#pragma mark Camera delegate method

//
//- (void)camera:(MyCamera *)camera didReceiveRawDataFrame:(const char *)imgData VideoWidth:(NSInteger)width VideoHeight:(NSInteger)height{
//    
//}
//
//
//- (void)camera:(MyCamera *)camera didReceiveJPEGDataFrame:(const char *)imgData DataSize:(NSInteger)size;
//- (void)camera:(MyCamera *)camera didReceiveJPEGDataFrame2:(NSData *)imgData;
//- (void)camera:(MyCamera *)camera didReceiveFrameInfoWithVideoWidth:(NSInteger)videoWidth VideoHeight:(NSInteger)videoHeight VideoFPS:(NSInteger)fps VideoBPS:(NSInteger)videoBps AudioBPS:(NSInteger)audioBps OnlineNm:(NSInteger)onlineNm FrameCount:(unsigned long)frameCount IncompleteFrameCount:(unsigned long)incompleteFrameCount;
//- (void)camera:(MyCamera *)camera didChangeSessionStatus:(NSInteger)status;
//- (void)camera:(MyCamera *)camera didChangeChannelStatus:(NSInteger)channel ChannelStatus:(NSInteger)status;
//- (void)camera:(MyCamera *)camera didReceiveIOCtrlWithType:(NSInteger)type Data:(const char*)data DataSize:(NSInteger)size;
//
- (void)camera:(MyCamera *)camera1 _didChangeChannelStatus:(NSInteger)channel ChannelStatus:(NSInteger)status
{
    [self verifyCameraStatus:camera];
}

- (void)startCameraFailed
{
    if (progress) {
        
        [progress setLabelText:@"视频启动失败"];
        [progress performSelector:@selector(hide:)
                       withObject:[NSNumber numberWithBool:YES]
                       afterDelay:1.0];
        progress = nil;
    }
}

- (void)restartCamera
{
    [camera stopShow:selectedChannel];
    [self endListenToDevice];
    [self endTalkToDevice];
    [camera disconnect];
    [self unactiveAudioSession];
    
    [camera connect:camera.uid];
    [camera start:0];
    [camera startShow:selectedChannel ScreenObject:self];
    
    SMsgAVIoctrlGetAudioOutFormatReq *s = (SMsgAVIoctrlGetAudioOutFormatReq *)malloc(sizeof(SMsgAVIoctrlGetAudioOutFormatReq));
    s->channel = 0;
    [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETAUDIOOUTFORMAT_REQ Data:(char *)s DataSize:sizeof(SMsgAVIoctrlGetAudioOutFormatReq)];
    free(s);
    
    SMsgAVIoctrlGetSupportStreamReq *s2 = (SMsgAVIoctrlGetSupportStreamReq *)malloc(sizeof(SMsgAVIoctrlGetSupportStreamReq));
    [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETSUPPORTSTREAM_REQ Data:(char *)s2 DataSize:sizeof(SMsgAVIoctrlGetSupportStreamReq)];
    free(s2);
    
    
    [self activeAudioSession];
    
    if (selectedAudioMode == kAudioModeSpeaker)
        [self startListenToDevice];
    if (selectedAudioMode == kAudioModeMicrophone)
        [self startTalkToDevice ];

}

- (void)camera:(MyCamera *)camera1 _didChangeSessionStatus:(NSInteger)status
{
//    [self verifyCameraStatus:camera];
//    if (status == kCameraSessionStateConnected) {
//        if (progress) {
//            [progress setLabelText:@"视频连接中..."];
//        }
//        [self startCamera:nil];
//        [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(startCameraFailed) userInfo:nil repeats:NO];
//        
//    }else if(status == kCameraSessionStateConnecting){
//        [progress setLabelText:@"视频连接中..."];
//    }else if(status == kCameraSessionStateTimeOut){
//        [self restartCamera];
//    }else if(status == kCameraSessionStateDisconnected){
//        if (progress) {
//            BBLog(@"连接断开，正在重新连接...");
//            [self restartCamera];
//        }
//    }else{
//        BBLog(@"连接失败,status = %d",status);
//        if (progress) {
//            [progress setLabelText:@"连接失败"];
//            [progress performSelector:@selector(hide:)
//                           withObject:[NSNumber numberWithBool:YES]
//                           afterDelay:1.0];
//            progress = nil;
//        }
//    }
}

- (void)camera:(MyCamera *)camera _didReceiveFrameInfoWithVideoWidth:(NSInteger)videoWidth VideoHeight:(NSInteger)videoHeight VideoFPS:(NSInteger)fps VideoBPS:(NSInteger)videoBps AudioBPS:(NSInteger)audioBps OnlineNm:(NSInteger)onlineNm FrameCount:(unsigned long)frameCount IncompleteFrameCount:(unsigned long)incompleteFrameCount
{
    if (progress) {
        [progress setLabelText:@"视频连接成功"];
        [progress performSelector:@selector(hide:)
                       withObject:[NSNumber numberWithBool:YES]
                       afterDelay:2.0];
        progress = nil;
//        [self performSelector:@selector(startListenToDevice) withObject:nil afterDelay:4.0f];
        [self startListenToDevice];
    }
}

- (void)camera:(MyCamera *)camera _didReceiveIOCtrlWithType:(NSInteger)type Data:(const char *)data DataSize:(NSInteger)size
{
}

- (void)camera:(MyCamera *)camera _didReceiveJPEGDataFrame:(const char *)imgData DataSize:(NSInteger)size
{
//    BBLog(@"size%uld", sizeof(imgData));
    BBLog(@"收到图片");
}


- (void)camera:(MyCamera *)camera _didReceiveRawDataFrame:(const char *)imgData VideoWidth:(NSInteger)width VideoHeight:(NSInteger)height
{
    /* You may use the code snippet as below to get an image. */
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, imgData, width * height * 3, NULL);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imgRef = CGImageCreate(width, height, 8, 24, width * 3, colorSpace, kCGBitmapByteOrderDefault, provider, NULL, true,  kCGRenderingIntentDefault);
    
    UIImage *img = [[UIImage alloc] initWithCGImage:imgRef];
    
    /* Set "img" to your own image object. */
    // self.image = img;
    self.Myimg=img;
    
    [img release];
    
    if (imgRef != nil) {
        CGImageRelease(imgRef);
        imgRef = nil;
    }
    
    if (colorSpace != nil) {
        CGColorSpaceRelease(colorSpace);
        colorSpace = nil;
    }
    
    if (provider != nil) {
        CGDataProviderRelease(provider);
        provider = nil;
    }
}


- (void)camera:(MyCamera *)camera _didReceiveRemoteNotification:(NSInteger)eventType EventTime:(long)eventTime
{

}


#pragma mark -
#pragma mark BBSocketClient delegate method
-(int)onRecevie:(BBDataFrame *)src received:(BBDataFrame *)data
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(src.MainCmd == 0x0F && src.SubCmd == 19) {
            //上传图片
            NSString *result = [[NSString alloc]initWithString:[data dataString]];
            NSArray *arr = [result componentsSeparatedByString:@"\t"];
            if ([arr[0] boolValue]) {
                [_uploadHud setLabelText:@"上传至服务器失败"];
            }else{
                [_uploadHud setLabelText:@"上传至服务器成功"];
            }
            [_uploadHud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
            
            [result release];
        }
    });
    
    return 0;
}

-(void)onTimeout:(BBDataFrame *)src
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_uploadHud setLabelText:@"上传至服务器超时"];
        [_uploadHud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        NSLog(@"Timeout src.subCmd = %d",src.SubCmd);
    });
}

-(void)onClose
{
    NSLog(@"Socketet closed");
}

-(void)onRecevieError:(BBDataFrame*)src received:(BBDataFrame*)data
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_uploadHud setLabelText:@"上传至服务器出错"];
        [_uploadHud performSelector:@selector(hide:) withObject:[NSNumber numberWithBool:YES] afterDelay:1.0f];
        NSLog(@"Timeout src.subCmd = %d",src.SubCmd);
    });
}

#pragma mark - openGL view method
- (void)removeGLView
{
    if (glView != nil) {
        [glView removeFromSuperview];
    } else {
        BBLog(@"glView has been removed from scrollViewPortrait <OK>");
    }
}

- (void)updateToScreen:(NSValue*)pointer
{
	LPSIMAGEBUFFINFO pScreenBmpStore = (LPSIMAGEBUFFINFO)[pointer pointerValue];
	if( mPixelBuffer == nil ||
       mSizePixelBuffer.width != pScreenBmpStore->nWidth ||
       mSizePixelBuffer.height != pScreenBmpStore->nHeight ) {
		
		if(mPixelBuffer) {
			CVPixelBufferRelease(mPixelBuffer);
			CVPixelBufferPoolRelease(mPixelBufferPool);
		}
		
		NSMutableDictionary* attributes;
		attributes = [NSMutableDictionary dictionary];
		[attributes setObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
		[attributes setObject:[NSNumber numberWithInt:pScreenBmpStore->nWidth] forKey: (NSString*)kCVPixelBufferWidthKey];
		[attributes setObject:[NSNumber numberWithInt:pScreenBmpStore->nHeight] forKey: (NSString*)kCVPixelBufferHeightKey];
		
		CVReturn err = CVPixelBufferPoolCreate(kCFAllocatorDefault, NULL, (CFDictionaryRef) attributes, &mPixelBufferPool);
		if( err != kCVReturnSuccess ) {
			NSLog( @"mPixelBufferPool create failed!" );
		}
		err = CVPixelBufferPoolCreatePixelBuffer (NULL, mPixelBufferPool, &mPixelBuffer);
		if( err != kCVReturnSuccess ) {
			NSLog( @"mPixelBuffer create failed!" );
		}
		mSizePixelBuffer = CGSizeMake(pScreenBmpStore->nWidth, pScreenBmpStore->nHeight);
		NSLog( @"CameraLiveViewController - mPixelBuffer created %dx%d nBytes_per_Row:%d", pScreenBmpStore->nWidth, pScreenBmpStore->nHeight, pScreenBmpStore->nBytes_per_Row );
	}
    
    try {        
        if(mPixelBuffer!=nil){
            CVPixelBufferLockBaseAddress(mPixelBuffer,0);
            UInt8* baseAddress = (UInt8*)CVPixelBufferGetBaseAddress(mPixelBuffer);
            memcpy(baseAddress, pScreenBmpStore->pData_buff, pScreenBmpStore->nBytes_per_Row * pScreenBmpStore->nHeight );
            CVPixelBufferUnlockBaseAddress(mPixelBuffer,0);
        }
        
    } catch (NSException * e) {
        NSLog(@"%@",e);
    }
	
	[glView renderVideo:mPixelBuffer];
}

@end
