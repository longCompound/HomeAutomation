//
//  BBNewsEyesViewController.m
//  ZgSafe
//
//  Created by apple on 14-7-11.
//  Copyright (c) 2014年 iXcoder. All rights reserved.
//

#import "BBNewsEyesViewController.h"
#import "iToast.h"
#import <IOTCamera/AVFRAMEINFO.h>
#import <IOTCamera/ImageBuffInfo.h>
#import <sys/time.h>
#import <AVFoundation/AVFoundation.h>
#import "BBVideoCameraViewController.h"
#import "BBAlbumsViewController.h"

#ifndef P2PCAMLIVE
#define SHOW_SESSION_MODE
#endif
#define DEF_WAIT4STOPSHOW_TIME	250
extern unsigned int _getTickCount() {
    
	struct timeval tv;
    
	if (gettimeofday(&tv, NULL) != 0)
        return 0;
    
	return (tv.tv_sec * 1000 + tv.tv_usec / 1000);
}


@implementation BBNewsEyesViewController

@synthesize bStopShowCompletedLock;
@synthesize mCodecId;
@synthesize glView;
@synthesize mPixelBufferPool;
@synthesize mPixelBuffer;
@synthesize mSizePixelBuffer;
@synthesize portraitView, landscapeView;
@synthesize monitorPortrait, monitorLandscape;
@synthesize loadingViewPortrait, loadingViewLandscape;
@synthesize scrollViewPortrait, scrollViewLandscape;
@synthesize selectedChannel;
@synthesize selectedAudioMode;
@synthesize camera;
@synthesize directoryPath;

#pragma mark
//启动视频
-(void)toStartVideo{
    [MyCamera initIOTC];
    
    //设置UID
    NSString *strUid=curUser.deviceid;
    
    camera = [[MyCamera alloc] initWithName:strUid];
    
    selectedChannel=0;
    
    camera.delegate2 = self;
    [camera connect:strUid];
    [camera start:selectedChannel viewAccount:@"admin" viewPassword:@"admin" is_playback:FALSE];
    [camera startShow:selectedChannel ScreenObject:self];
    
    SMsgAVIoctrlGetAudioOutFormatReq *s = (SMsgAVIoctrlGetAudioOutFormatReq *)malloc(sizeof(SMsgAVIoctrlGetAudioOutFormatReq));
    s->channel = 0;
    [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETAUDIOOUTFORMAT_REQ Data:(char *)s DataSize:sizeof(SMsgAVIoctrlGetAudioOutFormatReq)];
    free(s);
    
    SMsgAVIoctrlGetSupportStreamReq *s2 = (SMsgAVIoctrlGetSupportStreamReq *)malloc(sizeof(SMsgAVIoctrlGetSupportStreamReq));
    [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETSUPPORTSTREAM_REQ Data:(char *)s2 DataSize:sizeof(SMsgAVIoctrlGetSupportStreamReq)];
    free(s2);
    
    SMsgAVIoctrlTimeZone s3={0};
    s3.cbSize = sizeof(s3);
    [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GET_TIMEZONE_REQ Data:(char *)&s3 DataSize:sizeof(s3)];
    
    [loadingViewLandscape setHidden:NO];
    [loadingViewPortrait setHidden:NO];
    [loadingViewPortrait startAnimating];
    [loadingViewLandscape startAnimating];
    
    [monitorPortrait setImage:nil];
    [monitorLandscape setImage:nil];
    
    
    [self activeAudioSession];
    
    [self toStartSoundToPhone];

}

//关闭视频
-(void)toCloseVideo{

    if (camera != nil) {
        [camera stopShow:selectedChannel];
        [self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
        [camera stopSoundToDevice:selectedChannel];
        [camera stopSoundToPhone:selectedChannel];
        [camera disconnect];
        [self unactiveAudioSession];
    }
    
    [MyCamera uninitIOTC];
    
    appDelegate.EyesVCShowwing=NO;
}

//开启通话
-(void)toStartSoundToDevice{
    if (camera != nil) {
        selectedAudioMode = AUDIO_MODE_MICROPHONE;
        
        [camera stopSoundToPhone:selectedChannel];
        
        [self unactiveAudioSession];
        [self activeAudioSession];
        
        [camera startSoundToDevice:selectedChannel];
 
        _btnSelectedAudioMode.selected=YES;
        _btnSelectedAudioMode1.selected=YES;

    }
}


//开启监听
-(void)toStartSoundToPhone{
    if (camera != nil) {
        selectedAudioMode = AUDIO_MODE_SPEAKER;
        [camera stopSoundToDevice:selectedChannel];
        
        [self unactiveAudioSession];
        [self activeAudioSession];
        
        [camera startSoundToPhone:selectedChannel];
        
        _btnSelectedAudioMode.selected=NO;
        _btnSelectedAudioMode1.selected=NO;
    }
}

//判断监听与通话模式
-(void)toSelectdAudioMode{
    //监听
    if (selectedAudioMode == AUDIO_MODE_SPEAKER) {
        [self toStartSoundToPhone];
    }else{
        [self toStartSoundToDevice];
    }
}

//竖屏
-(void)toVerticalScreen{
    [monitorLandscape deattachCamera];
    [monitorPortrait attachCamera:camera];
    
    [self removeGLView:TRUE];
    self.view = self.portraitView;
    NSLog( @"video frame {%d,%d}%dx%d", (int)self.monitorPortrait.frame.origin.x, (int)self.monitorPortrait.frame.origin.y, (int)self.monitorPortrait.frame.size.width, (int)self.monitorPortrait.frame.size.height);
    if( glView == nil ) {
        glView = [[CameraShowGLView alloc] initWithFrame:self.monitorPortrait.frame];
        self.glView.parentFrame = self.monitorPortrait.frame;
        [glView setMinimumGestureLength:100 MaximumVariance:50];
        glView.delegate = self;
        [glView attachCamera:camera];
    }
    else {
        [self.glView destroyFramebuffer];
        self.glView.initFrame = self.monitorPortrait.frame;
        self.glView.parentFrame = self.monitorPortrait.frame;
        self.glView.frame = self.monitorPortrait.frame;
    }
    [self.scrollViewPortrait addSubview:glView];
    self.scrollViewPortrait.zoomScale = 1.0;
    
    if( mCodecId == MEDIA_CODEC_VIDEO_MJPEG ) {
        [self.scrollViewPortrait bringSubviewToFront:monitorPortrait/*self.glView*/];
    }
    else {
        [self.scrollViewPortrait bringSubviewToFront:/*monitorPortrait*/self.glView];
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    //        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
    //            [self setNeedsStatusBarAppearanceUpdate];
    //        }

}

//横屏
-(void)toHorizontalScreen{
    [monitorPortrait deattachCamera];
    [monitorLandscape attachCamera:camera];
    
    [self removeGLView:FALSE];
    self.view = self.landscapeView;
    NSLog( @"video frame {%d,%d}%dx%d", (int)self.monitorLandscape.frame.origin.x, (int)self.monitorLandscape.frame.origin.y, (int)self.monitorLandscape.frame.size.width, (int)self.monitorLandscape.frame.size.height);
    if( glView == nil ) {
        glView = [[CameraShowGLView alloc] initWithFrame:self.monitorLandscape.frame];
        self.glView.parentFrame = self.monitorLandscape.frame;
        [glView setMinimumGestureLength:100 MaximumVariance:50];
        glView.delegate = self;
        [glView attachCamera:camera];
    }
    else {
        [self.glView destroyFramebuffer];
        self.glView.initFrame = self.monitorLandscape.frame;
        self.glView.parentFrame = self.monitorLandscape.frame;
        self.glView.frame = self.monitorLandscape.frame;
        
    }
    [self.scrollViewLandscape addSubview:glView];
    self.scrollViewLandscape.zoomScale = 1.0;
    
    if( mCodecId == MEDIA_CODEC_VIDEO_MJPEG ) {
        [self.scrollViewLandscape bringSubviewToFront:monitorLandscape/*self.glView*/];
    }
    else {
        [self.scrollViewLandscape bringSubviewToFront:/*monitorLandscape*/self.glView];
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    //        if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
    //            [self setNeedsStatusBarAppearanceUpdate];
    //        }
}

- (void)verifyConnectionStatus
{
    if (camera.sessionState == CONNECTION_STATE_CONNECTING) {
        NSLog(@"%@ 视频连接中....", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_DISCONNECTED) {
        NSLog(@"%@ 视频离线", camera.uid);
		
    }
    else if (camera.sessionState == CONNECTION_STATE_UNKNOWN_DEVICE) {

        NSLog(@"%@ 未知设备", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_TIMEOUT) {

        NSLog(@"%@ 连接超时", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_UNSUPPORTED) {

        NSLog(@"%@ 不支持设备", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECT_FAILED) {
        NSLog(@"%@ 设备未找到", camera.uid);
    }
    
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTED) {
        NSLog(@"%@ online", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_CONNECTING) {
		NSLog(@"%@ connecting", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_DISCONNECTED) {
        NSLog(@"%@ off line", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_UNKNOWN_DEVICE) {
        NSLog(@"%@ unknown device", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_WRONG_PASSWORD) {
        NSLog(@"%@ wrong password", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_TIMEOUT) {
        NSLog(@"%@ timeout", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_UNSUPPORTED) {
        NSLog(@"%@ unsupported", camera.uid);
    }
    else if (camera.sessionState == CONNECTION_STATE_CONNECTED && [camera getConnectionStateOfChannel:0] == CONNECTION_STATE_NONE) {
        NSLog(@"%@ wait for connecting", camera.uid);
    }
}

- (CGRect)zoomRectForScrollView:(UIScrollView *)_scrollView withScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // The zoom rect is in the content view's coordinates.
    // At a zoom scale of 1.0, it would be the size of the
    // imageScrollView's bounds.
    // As the zoom scale decreases, so more content is visible,
    // the size of the rect grows.
    zoomRect.size.height = _scrollView.frame.size.height / scale;
    zoomRect.size.width  = _scrollView.frame.size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

- (UIImage *) getUIImage:(char *)buff Width:(NSInteger)width Height:(NSInteger)height {
    
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
    
    return [[img copy] autorelease];
}

- (NSString *) pathForDocumentsResource:(NSString *) relativePath {
    
    static NSString* documentsPath = nil;
    
    if (nil == documentsPath) {
        
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsPath = [[dirs objectAtIndex:0] retain];
    }
    
    return [documentsPath stringByAppendingPathComponent:relativePath];
}

- (void)saveImageToFile:(UIImage *)image :(NSString *)fileName {
    
    NSData *imgData = UIImageJPEGRepresentation(image, 1.0f);
    NSString *imgFullName = [self pathForDocumentsResource:fileName];
    
    [imgData writeToFile:imgFullName atomically:YES];
}

- (NSString *)directoryPath {
    
	if (!directoryPath) {
        
		//directoryPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Library"];
        NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        directoryPath = [[dirs objectAtIndex:0] retain];
    }
    
	return directoryPath;
}


- (IBAction)selectAudio:(id)sender {
    //监听
    if (selectedAudioMode == AUDIO_MODE_SPEAKER) {
        [self toStartSoundToDevice];
    }else{
        [self toStartSoundToPhone];
    }

}

- (IBAction)reload:(id)sender
{
    if (camera != nil) {
        
        // NSString *acc = [camera getViewAccountOfChannel:selectedChannel];
        // NSString *pwd = [camera getViewPasswordOfChannel:selectedChannel];
        
        [camera stopShow:selectedChannel];
		[self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
        [camera stop:selectedChannel];
        [camera disconnect];
        [camera connect:camera.uid];
        [camera start:selectedChannel];
        [camera startShow:selectedChannel ScreenObject:self];
        
        if (selectedChannel == 0) {
            SMsgAVIoctrlGetAudioOutFormatReq *s = (SMsgAVIoctrlGetAudioOutFormatReq *)malloc(sizeof(SMsgAVIoctrlGetAudioOutFormatReq));
            s->channel = 0;
            [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETAUDIOOUTFORMAT_REQ Data:(char *)s DataSize:sizeof(SMsgAVIoctrlGetAudioOutFormatReq)];
            free(s);
            
            SMsgAVIoctrlGetSupportStreamReq *s2 = (SMsgAVIoctrlGetSupportStreamReq *)malloc(sizeof(SMsgAVIoctrlGetSupportStreamReq));
            [camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GETSUPPORTSTREAM_REQ Data:(char *)s2 DataSize:sizeof(SMsgAVIoctrlGetSupportStreamReq)];
            free(s2);
			
			SMsgAVIoctrlTimeZone s3={0};
			s3.cbSize = sizeof(s3);
			[camera sendIOCtrlToChannel:0 Type:IOTYPE_USER_IPCAM_GET_TIMEZONE_REQ Data:(char *)&s3 DataSize:sizeof(s3)];
			
        }
        
        [monitorPortrait setImage:nil];
        [monitorLandscape setImage:nil];
        
        [loadingViewLandscape setHidden:NO];
        [loadingViewPortrait setHidden:NO];
        [loadingViewPortrait startAnimating];
        [loadingViewLandscape startAnimating];

        [self toSelectdAudioMode];
    }
}

- (IBAction)back:(id)sender
{
    [self.monitorLandscape deattachCamera];
    [self.monitorPortrait deattachCamera];
    
    if ([self.camera isKindOfClass:[MyCamera class]]) {
        MyCamera *cam = (MyCamera *)camera;
        cam.lastChannel = selectedChannel;
    }
    
    if (camera != nil) {
        [camera stopShow:selectedChannel];
        [self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
        [camera stopSoundToDevice:selectedChannel];
        [camera stopSoundToPhone:selectedChannel];
        [camera disconnect];
        [self unactiveAudioSession];
		
		camera = nil;
    }
	
    [self.navigationController popViewControllerAnimated:YES];
}

//保存图片
- (IBAction)savePhoto:(id)sender{
    char *imageFrame = (char *) malloc(MAX_IMG_BUFFER_SIZE);
    unsigned int w = 0, h = 0;
    unsigned int codec_id = mCodecId;
    int size = 0;
    size = [camera getChannel:selectedChannel Snapshot:imageFrame DataSize:MAX_IMG_BUFFER_SIZE ImageType:&codec_id   WithImageWidth:&w ImageHeight:&h];
    if (size > 0) {

        UIImage *img = NULL;
        
        if (codec_id == MEDIA_CODEC_VIDEO_H264 || codec_id == MEDIA_CODEC_VIDEO_MPEG4) {
            img = [self getUIImage:imageFrame Width:w Height:h];
            
            NSData *imgData = UIImagePNGRepresentation(img);
            UIImage *zpimg=[[UIImage alloc] initWithData:imgData];
            UIImageWriteToSavedPhotosAlbum(zpimg, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);

         }
        else if (codec_id == MEDIA_CODEC_VIDEO_MJPEG) {
            NSData *data = [[NSData alloc] initWithBytes:imageFrame length:size];
            img = [[UIImage alloc] initWithData:data];
            
            NSData *imgData = UIImagePNGRepresentation(img);
            UIImage *zpimg=[[UIImage alloc] initWithData:imgData];
            UIImageWriteToSavedPhotosAlbum(zpimg, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            
            [imgData release];
            [zpimg release];
            [data release];
			[img release];
        }

    }
    
    free(imageFrame);
}

/*!
 *@description  保存图片完成回调方法
 *@function     image:didFinishSavingWithError:contextInfo:
 *@param        image           --需要保存的图片
 *@param        error           --错误信息
 *@param        contextInfo     --上下文信息
 *@return       (void)
 */
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error
   contextInfo:(void *)contextInfo
{
    if (error) {
        UtilAlert(@"图片保存失败", nil);
    }else{
        UtilAlert(@"图片已保存到相册", nil);
    }
}

//跳转云相册
- (IBAction)goAlbum:(id)sender{
    BBAlbumsViewController *vc = [[BBAlbumsViewController alloc]init];
    appDelegate.EyesVCBtn=YES;
    [self presentModalViewController:vc animated:YES];
    [vc release];
}

//跳转设置
- (IBAction)goSetup:(id)sender{
    BBVideoCameraViewController *vc = [[BBVideoCameraViewController alloc]init];

    [self presentModalViewController:vc animated:YES];
    [vc release];
}

//横/竖屏切换
- (IBAction)goChange:(id)sender{
    
    if (CGAffineTransformIsIdentity(self.view.transform)) {
        [[UIApplication sharedApplication]setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
        [self toHorizontalScreen];
        
        self.view.transform = CGAffineTransformMakeRotation(M_PI*0.5);
        
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        self.view.bounds = CGRectMake(0, 0, frame.size.height, frame.size.width);
    }else{
        [[UIApplication sharedApplication]setStatusBarOrientation:UIInterfaceOrientationPortrait];
        [self toVerticalScreen];
        self.view.transform = CGAffineTransformIdentity;
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        self.view.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
    }
}

- (void)removeGLView :(BOOL)toPortrait
{
	if( glView ) {
		BOOL bRemoved = FALSE;
		if(toPortrait) {
			for (UIView *subView in self.scrollViewLandscape.subviews) {
				
				if ([subView isKindOfClass:[CameraShowGLView class]]) {
					
					[subView removeFromSuperview];
					NSLog( @"glView has been removed from scrollViewLandscape <OK>" );
					bRemoved = TRUE;
					break;
				}
			}
			if( !bRemoved ) {
				for (UIView *subView in self.scrollViewPortrait.subviews) {
					
					if ([subView isKindOfClass:[CameraShowGLView class]]) {
						
						[subView removeFromSuperview];
						NSLog( @"glView has been removed from scrollViewPortrait <OK>" );
                        //						bRemoved = TRUE;
						break;
					}
				}
			}
		}
		else {
			for (UIView *subView in self.scrollViewPortrait.subviews) {
				
				if ([subView isKindOfClass:[CameraShowGLView class]]) {
					
					[subView removeFromSuperview];
					NSLog( @"glView has been removed from scrollViewPortrait <OK>" );
					bRemoved = TRUE;
					break;
				}
			}
			if( !bRemoved ) {
				for (UIView *subView in self.scrollViewLandscape.subviews) {
					
					if ([subView isKindOfClass:[CameraShowGLView class]]) {
						
						[subView removeFromSuperview];
						NSLog( @"glView has been removed from scrollViewLandscape <OK>" );
                        //						bRemoved = TRUE;
						break;
					}
				}
			}
		}
	}
}


//判读横坚屏
- (void)changeOrientation:(UIInterfaceOrientation)orientation {
    
    if (orientation == UIInterfaceOrientationLandscapeLeft ||
        orientation == UIInterfaceOrientationLandscapeRight) {
        [self toHorizontalScreen];
    }
    else {
        [self toVerticalScreen];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return self.navigationController.navigationBarHidden;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self changeOrientation:toInterfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

#pragma mark - View lifecycle

- (void)dealloc
{
    [monitorPortrait release];
    [monitorLandscape release];
    [scrollViewPortrait release];
    [scrollViewLandscape release];
    [portraitView release];
    [landscapeView release];
    [loadingViewPortrait release];
    [loadingViewLandscape release];
    [camera release];
    [directoryPath release];
    [_btnSelectedAudioMode release];
    [_btnSelectedAudioMode1 release];

    [super dealloc];
}

//初始化界面
- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(cameraStopShowCompleted:) name: @"CameraStopShowCompleted" object: nil];
	
    appDelegate.EyesVCShowwing=YES;
   
    //[self.monitorPortrait setMinimumGestureLength:100 MaximumVariance:50];
    //[self.monitorPortrait setUserInteractionEnabled:YES];
    //self.monitorPortrait.contentMode = UIViewContentModeScaleToFill;
    //self.monitorPortrait.backgroundColor = [UIColor blackColor];
    self.monitorPortrait.delegate = self;
    
    //[self.monitorLandscape setMinimumGestureLength:100 MaximumVariance:50];
    //[self.monitorLandscape setUserInteractionEnabled:YES];
    //self.monitorLandscape.contentMode = UIViewContentModeScaleAspectFit;
    //self.monitorLandscape.backgroundColor = [UIColor blackColor];
    self.monitorLandscape.delegate = self;
    
    //self.scrollViewPortrait.minimumZoomScale = ZOOM_MIN_SCALE;
    //self.scrollViewPortrait.maximumZoomScale = ZOOM_MAX_SCALE;
   // self.scrollViewPortrait.contentMode = UIViewContentModeScaleAspectFit;
    self.scrollViewPortrait.contentSize = self.scrollViewPortrait.frame.size;
    
    //self.scrollViewLandscape.minimumZoomScale = ZOOM_MIN_SCALE;
    //self.scrollViewLandscape.maximumZoomScale = ZOOM_MAX_SCALE;
    //self.scrollViewLandscape.contentMode = UIViewContentModeScaleAspectFit;
    self.scrollViewLandscape.contentSize = self.scrollViewLandscape.frame.size;
    
    self.loadingViewLandscape.hidesWhenStopped = YES;
    self.loadingViewPortrait.hidesWhenStopped = YES;

    wrongPwdRetryTime = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    self.monitorPortrait = nil;
    self.monitorLandscape = nil;
    self.scrollViewPortrait = nil;
    self.scrollViewLandscape = nil;
    self.portraitView = nil;
    self.landscapeView = nil;
    self.loadingViewLandscape = nil;
    self.loadingViewPortrait = nil;
    self.camera = nil;
    self.btnSelectedAudioMode = nil;
    self.directoryPath = nil;
    
    appDelegate.EyesVCShowwing=NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:UIApplicationWillResignActiveNotification];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:UIApplicationDidBecomeActiveNotification];

	if(glView) {
    	[self.glView tearDownGL];
		self.glView = nil;
	}
	CVPixelBufferRelease(mPixelBuffer);
	CVPixelBufferPoolRelease(mPixelBufferPool);
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self changeOrientation:self.interfaceOrientation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationItem setPrompt:nil];
}

//首次连接视频
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self toStartVideo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self toCloseVideo];
}

#pragma mark -
#pragma mark Application status change notification handler
- (void)appDidEnterBackground:(id)sender
{
    
    NSLog(@"appDidEnterBackground................");
    
    //[MyCamera uninitIOTC];
    //[self toCloseVideo];

}

- (void)appWillEnterForeground:(id)sender
{
    
    NSLog(@"appWillEnterForeground................");
    
    [MyCamera initIOTC];
    //[self toStartVideo];
}

#pragma mark - MyCamera Delegate Methods

- (void)camera:(MyCamera *)camera_ _didChangeSessionStatus:(NSInteger)status
{
    if (camera_ == camera) {
        
        [self verifyConnectionStatus];
        
        if (status == CONNECTION_STATE_TIMEOUT) {
            [self toCloseVideo];
            [self toStartVideo];
        }        
    }
}

- (void)camera:(MyCamera *)camera_ _didChangeChannelStatus:(NSInteger)channel ChannelStatus:(NSInteger)status
{
    if (camera_ == camera) {
        
        if (channel == selectedChannel) {
            
#ifndef MacGulp
            if ([camera getMultiStreamSupportOfChannel:0] &&
                [[camera getSupportedStreams] count] > 1) {
                
                if (self.navigationItem.rightBarButtonItem == nil) {
                    UIBarButtonItem *streamButton = [[UIBarButtonItem alloc]
                                                     initWithTitle:NSLocalizedString(@"Channel", @"")
                                                     style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(selectChannel:)];
                    self.navigationItem.rightBarButtonItem = streamButton;
                    [streamButton release];
                }
                
                self.navigationItem.prompt = [NSString stringWithFormat:@"%@ - CH%d", camera.name, selectedChannel + 1];
            }
            else {
                self.navigationItem.prompt = camera.name;
                self.navigationItem.rightBarButtonItem = nil;
            }
#endif
        }
        
        if (channel == selectedChannel) {
            
            [self verifyConnectionStatus];
            
            if (status == CONNECTION_STATE_WRONG_PASSWORD) {
                [self toCloseVideo];
                
            } else if (status == CONNECTION_STATE_CONNECTED) {
                
                // self.statusLabel.text = NSLocalizedString(@"Connected", nil);
                
            } else if (status == CONNECTION_STATE_CONNECTING) {
                
                // self.statusLabel.text = NSLocalizedString(@"Connecting...", nil);
                
            } else if (status == CONNECTION_STATE_TIMEOUT) {
                
                // self.statusLabel.text = NSLocalizedString(@"Timeout", @"");
                
                [self toCloseVideo];                
                [self toStartVideo];
                
            } else {
                
                // self.statusLabel.text = NSLocalizedString(@"Off line", nil);
                
                [self.loadingViewPortrait stopAnimating];
                [self.loadingViewLandscape stopAnimating];
            }
        }
    }
}

- (void)camera:(MyCamera *)camera _didReceiveJPEGDataFrame:(const char *)imgData DataSize:(NSInteger)size
{
    [loadingViewPortrait stopAnimating];
    [loadingViewLandscape stopAnimating];
}

- (void)camera:(MyCamera *)camera _didReceiveRawDataFrame:(const char *)imgData VideoWidth:(NSInteger)width VideoHeight:(NSInteger)height
{
    [loadingViewPortrait stopAnimating];
    [loadingViewLandscape stopAnimating];
}

int _vdoH = -1;
int _vdoW = -1;

- (void)camera:(MyCamera *)camera_ _didReceiveFrameInfoWithVideoWidth:(NSInteger)videoWidth VideoHeight:(NSInteger)videoHeight VideoFPS:(NSInteger)fps VideoBPS:(NSInteger)videoBps AudioBPS:(NSInteger)audioBps OnlineNm:(NSInteger)onlineNm FrameCount:(unsigned long)frameCount IncompleteFrameCount:(unsigned long)incompleteFrameCount {
    
    if (camera_ == camera) {
		if( videoWidth > 1280 || videoHeight > 720 ) {
			NSLog( @"!!!!!!!! ERROR !!!!!!!!" );
			return;
		}
		
		CGSize maxZoom = CGSizeMake((videoWidth*2.0 > 1280)?1280:videoWidth*2.0, (videoHeight*2.0 > 720)?720:videoHeight*2.0);
        
        if ( -1 == _vdoH || -1 == _vdoW || _vdoH != videoHeight || _vdoW !=  videoWidth){
            _vdoH = videoHeight;
            _vdoW = videoWidth ;
            
            if ( glView && videoWidth > 0 && videoHeight > 0 ) {
                //[self recalcMonitorRect:CGSizeMake(videoWidth, videoHeight)];
                self.glView.videoSize = CGSizeMake(videoWidth, videoHeight) ;
                self.glView.frame = self.glView.frame;
                self.glView.maxZoom = maxZoom;
            }
        }
        
		if( maxZoom.width / self.scrollViewPortrait.frame.size.width > 1.0 ) {
			self.scrollViewPortrait.maximumZoomScale = maxZoom.width / self.scrollViewPortrait.frame.size.width;
		}
		else {
			self.scrollViewPortrait.maximumZoomScale = 1;
		}
		if( maxZoom.width / self.scrollViewLandscape.frame.size.width > 1.0 ) {
			self.scrollViewLandscape.maximumZoomScale = maxZoom.width / self.scrollViewLandscape.frame.size.width;
		}
		else {
			self.scrollViewLandscape.maximumZoomScale = 1;
		}
		
#ifndef MacGulp
//		if( g_bDiagnostic ) {
//			self.videoInfoLabel.text = [NSString stringWithFormat:@"%dx%d / FPS: %d / BPS: %d Kbps", videoWidth, videoHeight, fps, (videoBps + audioBps) / 1024];
//			self.frameInfoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Online Nm: %d / Frame ratio: %d / %d", @"Used for display channel information"), onlineNm, incompleteFrameCount, frameCount];
//		}
//		else {
//			self.videoInfoLabel.text = [NSString stringWithFormat:@"%dx%d", videoWidth, videoHeight ];
//			self.frameInfoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Online Nm: %d", @""), onlineNm];
//		}
#else
        
        if (onlineNm >= 5) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CAM P" message:NSLocalizedString(@"Exceed multiple viewer limitation", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
            [alert release];
            
            [camera stopShow:selectedChannel];
			[self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
            [camera stopSoundToDevice:selectedChannel];
            [camera stopSoundToPhone:selectedChannel];
            
            monitorPortrait.image = nil;
            monitorLandscape.image = nil;
            
            self.videoInfoLabel.text = [NSString stringWithFormat:@"%dx%d @ %d fps", videoWidth, videoHeight, 0];
            self.frameInfoLabel.text = [NSString stringWithFormat:@"x%d", onlineNm];
        }
        else {
            self.videoInfoLabel.text = [NSString stringWithFormat:@"%dx%d @ %d fps", videoWidth, videoHeight, fps];
            self.frameInfoLabel.text = [NSString stringWithFormat:@"x%d", onlineNm];
        }
#endif

    }
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory {
    
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSDocumentDirectory
             inDomains:NSUserDomainMask] lastObject];
}


- (void)monitor:(Monitor *)monitor gesturePinched:(CGFloat)scale
{
    
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        
#if 0
        [monitorLandscape deattachCamera];
        [monitorLandscape attachCamera:camera];
        
        //[self removeGLView:FALSE];
        //self.view = self.landscapeView;
        //NSLog( @"video frame {%d,%d}%dx%d", (int)self.monitorLandscape.frame.origin.x, (int)self.monitorLandscape.frame.origin.y, (int)self.monitorLandscape.frame.size.width, (int)self.monitorLandscape.frame.size.height);
        //        if( glView == nil ) {
        //            glView = [[CameraShowGLView alloc] initWithFrame:self.monitorLandscape.frame];
        //            [glView setMinimumGestureLength:100 MaximumVariance:50];
        //            glView.delegate = self;
        //            [glView attachCamera:camera];
        //        }
        //        else {
        [self.glView destroyFramebuffer];
        
        [self.glView createFramebuffers];
        //            self.glView.frame = self.monitorLandscape.frame;
        //            self.glView.fScale = scale;
        //}
        //[self.scrollViewLandscape addSubview:glView];
        //self.scrollViewLandscape.zoomScale = 1.0;
        
        
        if( mCodecId == MEDIA_CODEC_VIDEO_MJPEG ) {
            [self.scrollViewLandscape bringSubviewToFront:monitorLandscape/*self.glView*/];
        }
        else {
            [self.scrollViewLandscape bringSubviewToFront:/*monitorLandscape*/self.glView];
        }
        
        //        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        //        [self.navigationController setNavigationBarHidden:YES animated:NO];
#endif
        
		NSLog( @"CameraLiveViewController - Pinched [Landscape] scale:%f/%f", scale, self.scrollViewLandscape.maximumZoomScale );
        
        if( mCodecId == MEDIA_CODEC_VIDEO_MJPEG ) {
            //if( scale <= self.scrollViewLandscape.maximumZoomScale )
            [self.scrollViewLandscape setZoomScale:scale animated:YES];
            
        }
        else {
            [self.scrollViewLandscape setContentSize:self.glView.frame.size];
            NSLog( @"glView.frame width:%f height:%f" ,self.glView.frame.size.width, self.glView.frame.size.height );
        }
        
        
    }
    else {
		NSLog( @"CameraLiveViewController - Pinched scale:%f/%f", scale, self.scrollViewPortrait.maximumZoomScale );
        if( mCodecId == MEDIA_CODEC_VIDEO_MJPEG ) {
            //if( scale <= self.scrollViewPortrait.maximumZoomScale )
            [self.scrollViewPortrait setZoomScale:scale animated:YES];
        }
        else {
            [self.scrollViewPortrait setContentSize:self.glView.frame.size];
        }
    }
    
}

#pragma mark - ScrollView Delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
        return self.monitorPortrait;
    }
    else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
             self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        return self.monitorLandscape;
    }
    else return nil;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView
                       withView:(UIView *)view
                        atScale:(float)scale
{
	if( glView ) {
		glView.frame = CGRectMake( 0, 0, scrollView.frame.size.width*scale, scrollView.frame.size.height*scale );
		NSLog( @"{0,0,%d,%d}", (int)(scrollView.frame.size.width*scale), (int)(scrollView.frame.size.height*scale) );
	}
}

#pragma mark - UIActionSheetDelegate implementation
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    int mode = -1;
    
    if ([camera getAudioInSupportOfChannel:selectedChannel] && [camera getAudioOutSupportOfChannel:selectedChannel]) {
        
        if (buttonIndex == 0) {
            
            mode = 0;
            
        } else if (buttonIndex == 1) { // Device to Phone
            
            mode = 1;
            
        } else if (buttonIndex == 2) { // Phone to Device
            
            mode = 2;
            
        }
        
    } else if ([camera getAudioInSupportOfChannel:selectedChannel] && ![camera getAudioOutSupportOfChannel:selectedChannel]) {
        
        if (buttonIndex == 0) {
            
            mode = 0;
            
        } else if (buttonIndex == 1) { // Device to Phone
            
            mode = 1;
            
        }
        
    } else if (![camera getAudioInSupportOfChannel:selectedChannel] && [camera getAudioOutSupportOfChannel:selectedChannel]) {
        
        if (buttonIndex == 0) {
            
            mode = 0;
            
        } else if (buttonIndex == 1) { // Phone to Device
            
            mode = 2;
            
        }
        
    } else {
        
        mode = 0;
        
    }
    
    
    if (mode == 0) {
        
        if (camera != nil) {
      
            selectedAudioMode = AUDIO_MODE_OFF;
            
            [camera stopSoundToDevice:selectedChannel];
            [camera stopSoundToPhone:selectedChannel];
            
            [self unactiveAudioSession];
        }
        
    } else if (mode == 1) { // Device to Phone
        
        if (camera != nil) {
            
            selectedAudioMode = AUDIO_MODE_SPEAKER;
            [camera stopSoundToDevice:selectedChannel];
            
            [self unactiveAudioSession];
            [self activeAudioSession];
            
            [camera startSoundToPhone:selectedChannel];
            
        }
        
    } else if (mode == 2) { // Phone to Device
        
        if (camera != nil) {
            
            selectedAudioMode = AUDIO_MODE_MICROPHONE;
            
            [camera stopSoundToPhone:selectedChannel];
            
            [self unactiveAudioSession];
            [self activeAudioSession];
            
            [camera startSoundToDevice:selectedChannel];
        }
    }
}

#pragma mark - AudioSession implementations
- (void)activeAudioSession
{
    
#if 0
    OSStatus error;
    
    UInt32 category = kAudioSessionCategory_LiveAudio;
    
    if (selectedAudioMode == AUDIO_MODE_SPEAKER) {
        category = kAudioSessionCategory_LiveAudio;
        NSLog(@"kAudioSessionCategory_LiveAudio");
    }
    
    if (selectedAudioMode == AUDIO_MODE_MICROPHONE) {
        category = kAudioSessionCategory_PlayAndRecord;
        NSLog(@"kAudioSessionCategory_PlayAndRecord");
    }
    
    error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
    if (error) printf("couldn't set audio category!");
    
    error = AudioSessionSetActive(true);
    if (error) printf("AudioSessionSetActive (true) failed");
#else
    
    NSString *audioMode = nil;
    if (selectedAudioMode == AUDIO_MODE_SPEAKER) {
        NSLog(@"kAudioSessionCategory_LiveAudio");
        audioMode = AVAudioSessionCategoryPlayback;
    }
    
    else if (selectedAudioMode == AUDIO_MODE_MICROPHONE) {;
        NSLog(@"kAudioSessionCategory_PlayAndRecord");
        audioMode = AVAudioSessionCategoryPlayAndRecord;
    }
    
    if ( nil == audioMode){
        return ;
    }
    
    //get your app's audioSession singleton object
    AVAudioSession* session = [AVAudioSession sharedInstance];
    
    //error handling
    BOOL success;
    NSError* error;
    
    //set the audioSession category.
    //Needs to be Record or PlayAndRecord to use audioRouteOverride:
    
    success = [session setCategory:audioMode error:&error];
    
    if (!success)  NSLog(@"AVAudioSession error setting category:%@",error);
    
    //set the audioSession override
    success = [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
                                         error:&error];
    if (!success)  NSLog(@"AVAudioSession error overrideOutputAudioPort:%@",error);
    
    //activate the audio session
    success = [session setActive:YES error:&error];
    if (!success) NSLog(@"AVAudioSession error activating: %@",error);
    else NSLog(@"audioSession active");
    
    
#endif
}

- (void)unactiveAudioSession {
    
#if 0
    AudioSessionSetActive(false);
#else
    BOOL success;
    NSError* error;
    
    //get your app's audioSession singleton object
    AVAudioSession* session = [AVAudioSession sharedInstance];
    
    //activate the audio session
    success = [session setActive:NO error:&error];
    if (!success) NSLog(@"AVAudioSession error deactivating: %@",error);
    else NSLog(@"audioSession deactive");
    
#endif
    
}

#pragma mark - UIApplication Delegate
- (void)applicationWillResignActive:(NSNotification *)notification
{
    [camera stopShow:selectedChannel];
	[self waitStopShowCompleted:DEF_WAIT4STOPSHOW_TIME];
    [camera stopSoundToDevice:selectedChannel];
    [camera stopSoundToPhone:selectedChannel];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [camera startShow:selectedChannel ScreenObject:self];
    
    [self toSelectdAudioMode];
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
	CVPixelBufferLockBaseAddress(mPixelBuffer,0);
	
	UInt8* baseAddress = (UInt8*)CVPixelBufferGetBaseAddress(mPixelBuffer);
	
	memcpy(baseAddress, pScreenBmpStore->pData_buff, pScreenBmpStore->nBytes_per_Row * pScreenBmpStore->nHeight );
	
	CVPixelBufferUnlockBaseAddress(mPixelBuffer,0);
	
	[glView renderVideo:mPixelBuffer];
}

- (void)recalcMonitorRect:(CGSize)videoframe
{
	CGFloat fRatioFrame = videoframe.width / videoframe.height;
	CGFloat fRatioMonitor;
	UIScrollView* viewMonitor;
	UIView* viewCanvas;
	
    if( self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
	   self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		viewMonitor = self.scrollViewLandscape;
		viewCanvas = self.monitorLandscape;
	}
	else {
		viewMonitor = self.scrollViewPortrait;
		viewCanvas = self.monitorPortrait;
	}
	fRatioMonitor = viewMonitor.frame.size.width/viewMonitor.frame.size.height;
    
	if( fRatioMonitor < fRatioFrame ) {
		CGFloat canvas_height = (viewMonitor.frame.size.width * viewMonitor.zoomScale) / fRatioFrame;
		
        viewCanvas.frame = CGRectMake(0, 0, (viewMonitor.frame.size.width * viewMonitor.zoomScale), canvas_height);
        
//		if( canvas_height < viewMonitor.frame.size.height ) {
//			viewCanvas.frame = CGRectMake(0, ((viewMonitor.frame.size.height) - canvas_height)/2.0, (viewMonitor.frame.size.width * viewMonitor.zoomScale), canvas_height);
//		}
//		else {
//			viewCanvas.frame = CGRectMake(0, 0, (viewMonitor.frame.size.width * viewMonitor.zoomScale), canvas_height);
//		}
	}
	else {
		CGFloat canvas_width = (viewMonitor.frame.size.height * viewMonitor.zoomScale) * fRatioFrame;
		
        viewCanvas.frame = CGRectMake(0, 0, canvas_width, (viewMonitor.frame.size.height * viewMonitor.zoomScale));
        
//		if( canvas_width < viewMonitor.frame.size.width ) {
//			viewCanvas.frame = CGRectMake(((viewMonitor.frame.size.width) - canvas_width)/2.0, 0, canvas_width, (viewMonitor.frame.size.height * viewMonitor.zoomScale));
//		}
//		else {
//			viewCanvas.frame = CGRectMake(0, 0, canvas_width, (viewMonitor.frame.size.height * viewMonitor.zoomScale));
//		}
	}
    
    //self.glView.parentFrame = viewCanvas.frame;
}

// If you want to set the final frame size, just implement this delegation to given the wish frame size
//
- (void)glFrameSize:(NSArray*)param
{
    NSLog( @"glview:%@", self.glView);
    
	CGSize* pglFrameSize_Original = (CGSize*)[(NSValue*)[param objectAtIndex:0] pointerValue];
	CGSize* pglFrameSize_Scaling = (CGSize*)[(NSValue*)[param objectAtIndex:1] pointerValue];
	
	//[self recalcMonitorRect:*pglFrameSize_Original];
    
	self.glView.maxZoom = CGSizeMake( (pglFrameSize_Original->width*2.0 > 1280)?1280:pglFrameSize_Original->width*2.0, (pglFrameSize_Original->height*2.0 > 720)?720:pglFrameSize_Original->height*2.0 );
    
    CGSize size = self.glView.frame.size;
    float fScale  = [[UIScreen mainScreen] scale];
    size.height *= fScale;
    size.width *= fScale;
    *pglFrameSize_Scaling = size ;
    
    
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
        self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        [self.scrollViewLandscape setContentSize:self.glView.frame.size];
    }
    else {
        [self.scrollViewPortrait setContentSize:self.glView.frame.size];
    }
}

- (void)reportCodecId:(NSValue*)pointer
{
	unsigned short *pnCodecId = (unsigned short *)[pointer pointerValue];
	
	mCodecId = *pnCodecId;
	
	if( mCodecId == MEDIA_CODEC_VIDEO_MJPEG ) {
        if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            
			[self.scrollViewLandscape bringSubviewToFront:monitorLandscape/*self.glView*/];
        }
        else {
			[self.scrollViewPortrait bringSubviewToFront:monitorLandscape/*self.glView*/];
        }
	}
	else {
        if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            
			[self.scrollViewLandscape bringSubviewToFront:/*monitorLandscape*/self.glView];
        }
        else {
			[self.scrollViewPortrait bringSubviewToFront:/*monitorLandscape*/self.glView];
        }
	}
}

- (void)waitStopShowCompleted:(unsigned int)uTimeOutInMs
{
	unsigned int uStart = _getTickCount();
	while( self.bStopShowCompletedLock == FALSE ) {
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

- (void)cameraStartShow:(NSTimer*)theTimer
{
	[camera startShow:selectedChannel ScreenObject:self];
	
	[loadingViewLandscape setHidden:NO];
	[loadingViewPortrait setHidden:NO];
	[loadingViewPortrait startAnimating];
	[loadingViewLandscape startAnimating];
	
	[self activeAudioSession];
	
    [self toSelectdAudioMode];
}

@end
