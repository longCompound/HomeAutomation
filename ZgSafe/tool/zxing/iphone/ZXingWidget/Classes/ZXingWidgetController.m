/**
 * Copyright 2009 Jeff Verkoeyen
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZXingWidgetController.h"
#import "Decoder.h"
#import "NSString+HTML.h"
#import "ResultParser.h"
#import "ParsedResult.h"
#import "ResultAction.h"
#import "TwoDDecoderResult.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import "OverlayView.h"
#import <AVFoundation/AVFoundation.h>

#define CAMERA_SCALAR 1.12412 // scalar = (480 / (2048 / 480))
#define FIRST_TAKE_DELAY 1.0
#define ONE_D_BAND_HEIGHT 10.0

static const CGFloat kPadding = 50;

@interface ZXingWidgetController ()

@property BOOL showCancel;
@property BOOL oneDMode;
@property BOOL isStatusBarHidden;

- (BOOL)initCapture;
- (void)stopCapture;

@end

@implementation ZXingWidgetController

#if HAS_AVFF
@synthesize captureSession;
@synthesize prevLayer;
#endif
@synthesize result, delegate, soundToPlay;
@synthesize overlayView;
@synthesize oneDMode, showCancel, isStatusBarHidden;
@synthesize readers;
@synthesize decodeImage;

- (id)initWithDelegate:(id<ZXingDelegate>)scanDelegate showCancel:(BOOL)shouldShowCancel OneDMode:(BOOL)shouldUseoOneDMode {
    self = [super init];
    if (self) {
        self.navigationItem.title = @"扫一扫";
        [self setDelegate:scanDelegate];
        self.oneDMode = shouldUseoOneDMode;
        self.showCancel = shouldShowCancel;
        self.wantsFullScreenLayout = YES;
        beepSound = -1;
        decoding = NO;
        CGRect screenRect = self.view.bounds;//[UIScreen mainScreen].bounds ;
        CGFloat rectSize = screenRect.size.width - kPadding * 2;
        overlay_frame = CGRectMake(kPadding, (screenRect.size.height - 44 - 20 - rectSize) / 2, rectSize, rectSize);
        //      overlay_frame = CGRectMake(100, 100, 200, 200);
        OverlayView *theOverLayView = [[OverlayView alloc] initWithFrame:screenRect
                                                           cancelEnabled:NO
                                                                oneDMode:oneDMode];
        //    OverlayView *theOverLayView = [[OverlayView alloc] initWithFrame:overlay_frame
        //                                                       cancelEnabled:showCancel
        //                                                            oneDMode:oneDMode];
        
        [theOverLayView setDelegate:self];
        self.overlayView = theOverLayView;
        [theOverLayView release];
    }
    
    return self;
}

- (void)dealloc {
    if (beepSound != (SystemSoundID)-1) {
        AudioServicesDisposeSystemSoundID(beepSound);
    }
    
    [self stopCapture];
    
    [soundToPlay release];
    [overlayView release];
    [readers release];
    [decodeImage release];
    [super dealloc];
}

- (void)cancelled {
    [self stopCapture];
    if (!self.isStatusBarHidden) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    
    wasCancelled = YES;
    if (delegate != nil) {
        [delegate zxingControllerDidCancel:self];
    }
}

- (NSString *)getPlatform {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    return platform;
}

- (BOOL)fixedFocus {
    NSString *platform = [self getPlatform];
    if ([platform isEqualToString:@"iPhone1,1"] ||
        [platform isEqualToString:@"iPhone1,2"]) return YES;
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.wantsFullScreenLayout = YES;
    if ([self soundToPlay] != nil) {
        OSStatus error = AudioServicesCreateSystemSoundID((CFURLRef)[self soundToPlay], &beepSound);
        if (error != kAudioServicesNoError) {
            NSLog(@"Problem loading nearSound.caf");
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    self.isStatusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
    if (!isStatusBarHidden)
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    decoding = YES;
    //1----------3-4
    //2           |
    //|           |
    //|           |
    //           6-5
    //
    BOOL flag = [self initCapture];
    if (!flag) {
        NSString *msg = @"请在设置-隐私-相机中允许万客会使用相机";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"无法使用相机"
                                                            message:msg
                                                           delegate:self
                                                  cancelButtonTitle:@"好"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
        return ;
    }
    [self.view addSubview:overlayView];
    
    
    CGFloat rColor = 1.0f/255.0f;
    CGFloat alpa = 1.0f;
    UIColor* bgColor = [UIColor colorWithRed:rColor green:rColor blue:rColor alpha:0.6];
    CGRect topView_frame = CGRectMake(0, 0, 320, overlay_frame.origin.y);
    UIView* topView = [[UIView alloc]initWithFrame:topView_frame];
    [topView setBackgroundColor:bgColor];
    [topView setAlpha:alpa];
    [self.view addSubview:topView];
    
    CGFloat label_note_width = 200.0f;
    CGRect label_note_frame = CGRectMake((topView.frame.size.width-label_note_width)/2
                                         , topView.frame.size.height - 40, 200, 40);
    UILabel* label_note = [[UILabel alloc]initWithFrame:label_note_frame];
    [label_note setText:@"请扫描二维码"];
    [label_note setTextColor:[UIColor whiteColor]];
    [label_note setFont:[UIFont systemFontOfSize:13]];
    [label_note setTextAlignment:UITextAlignmentCenter];
    [label_note setBackgroundColor:[UIColor clearColor]];
    [topView addSubview:label_note];
    [label_note release];
    
    [topView release];
    CGFloat lab_height = 6.0f;
    CGFloat sp = 0.0f;
    CGFloat line_width = 17.0f;
    CGRect lab1_frame = CGRectMake(overlay_frame.origin.x - lab_height,
                                   overlay_frame.origin.y - lab_height - sp, line_width+lab_height, lab_height);
    UILabel* lab1 = [[UILabel alloc]initWithFrame:lab1_frame];
    [lab1 setBackgroundColor:[UIColor greenColor]];
    [topView addSubview:lab1];
    [lab1 release];
    
    CGRect lab2_frame = CGRectMake(overlay_frame.origin.x + overlay_frame.size.width - lab_height*3 - sp,
                                   overlay_frame.origin.y - lab_height - sp, line_width+lab_height+1, lab_height);
    UILabel* lab2 = [[UILabel alloc]initWithFrame:lab2_frame];
    [lab2 setBackgroundColor:[UIColor greenColor]];
    [topView addSubview:lab2];
    [lab2 release];
    
    //    CGFloat height = [UIScreen mainScreen].bounds.size.height -  overlay_frame.origin.y;
    CGRect leftView_frame = CGRectMake(0, overlay_frame.origin.y, overlay_frame.origin.x, overlay_frame.size.height);
    UIView* leftView = [[UIView alloc]initWithFrame:leftView_frame];
    [leftView setBackgroundColor:bgColor];
    [leftView setAlpha:alpa];
    [self.view addSubview:leftView];
    [leftView release];
    CGRect lab3_frame = CGRectMake(overlay_frame.origin.x - lab_height - sp, 0, lab_height, line_width);
    UILabel* lab3 = [[UILabel alloc]initWithFrame:lab3_frame];
    [lab3 setBackgroundColor:[UIColor greenColor]];
    [leftView addSubview:lab3];
    [lab3 release];
    
    CGRect lab8_frame = CGRectMake(overlay_frame.origin.x - lab_height - sp, overlay_frame.size.height - line_width, lab_height, line_width);
    UILabel* lab8 = [[UILabel alloc]initWithFrame:lab8_frame];
    [lab8 setBackgroundColor:[UIColor greenColor]];
    [leftView addSubview:lab8];
    [lab8 release];
    
    
    //    CGFloat height = [UIScreen mainScreen].bounds.size.height -  overlay_frame.origin.y;
    CGRect rightView_frame = CGRectMake(overlay_frame.origin.x + overlay_frame.size.width,
                                        overlay_frame.origin.y, overlay_frame.size.width, overlay_frame.size.height);
    UIView* rightView = [[UIView alloc]initWithFrame:rightView_frame];
    [rightView setBackgroundColor:bgColor];
    [rightView setAlpha:alpa];
    [self.view addSubview:rightView];
    [rightView release];
    CGRect lab4_frame = CGRectMake(sp, 0, lab_height, line_width);
    UILabel* lab4 = [[UILabel alloc]initWithFrame:lab4_frame];
    [lab4 setBackgroundColor:[UIColor greenColor]];
    [rightView addSubview:lab4];
    [lab4 release];
    
    CGRect lab5_frame = CGRectMake(sp, overlay_frame.size.height - line_width, lab_height, line_width);
    UILabel* lab5 = [[UILabel alloc]initWithFrame:lab5_frame];
    [lab5 setBackgroundColor:[UIColor greenColor]];
    [rightView addSubview:lab5];
    [lab5 release];
    
    CGRect bottomView_frame = CGRectMake(0,
                                         overlay_frame.size.height + overlay_frame.origin.y,
                                         320,
                                         self.view.bounds.size.height - overlay_frame.size.height - + overlay_frame.origin.y );
    UIView* bottomView = [[UIView alloc]initWithFrame:bottomView_frame];
    [bottomView setBackgroundColor:bgColor];
    [bottomView setAlpha:alpa];
    [self.view addSubview:bottomView];
    [bottomView release];
    
    CGRect view_note_frame = CGRectMake(0, 50, [UIScreen mainScreen].bounds.size.width, 100);
    UIView* view_note = [[UIView alloc]initWithFrame:view_note_frame];
    [bottomView addSubview:view_note];
    [view_note setBackgroundColor:[UIColor clearColor]];
    [view_note release];    
    
    CGRect btn_exit_frame = CGRectMake((view_note.frame.size.width - 100)/ 2, 0, 100, 40);
    UIButton* btn_exit = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn_exit setFrame:btn_exit_frame];
    [btn_exit.layer setBorderColor:[UIColor whiteColor].CGColor];
    [btn_exit.layer setBorderWidth:1.0f];
    [btn_exit.layer setCornerRadius:5.0f];
    UIImage *image = [UIImage imageNamed:@"btn_bg.png"];
    UIImage *stretch = [image resizableImageWithCapInsets:UIEdgeInsetsMake(5, 14, 5, 14)];
    [btn_exit setBackgroundImage:stretch forState:UIControlStateNormal];
    [btn_exit setTitle:@"退出" forState:UIControlStateNormal];
    [btn_exit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_exit.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [view_note addSubview:btn_exit];
    [btn_exit addTarget:self action:@selector(doExit:) forControlEvents:UIControlEventTouchUpInside];
    //label
    CGRect lab_exit_frame = CGRectMake(btn_exit_frame.origin.x,
                                       btn_exit_frame.origin.y + btn_exit_frame.size.height + 5,
                                       60, 25);
    UILabel* lab_exit = [[UILabel alloc]initWithFrame:lab_exit_frame];
    [view_note addSubview:lab_exit];
    [lab_exit release];
    [lab_exit setTextColor:[UIColor whiteColor]];
    [lab_exit setBackgroundColor:[UIColor clearColor]];
    //    [lab_exit setText:@"退出"];
    //    [lab_exit setTextAlignment:UITextAlignmentCenter];
    [lab_exit setFont:[UIFont systemFontOfSize:15]];
    
    CGRect lab6_frame = CGRectMake(overlay_frame.origin.x + overlay_frame.size.width - line_width, 0, line_width+lab_height, lab_height);
    UILabel* lab6 = [[UILabel alloc]initWithFrame:lab6_frame];
    [lab6 setBackgroundColor:[UIColor greenColor]];
    [bottomView addSubview:lab6];
    [lab6 release];
    
    CGRect lab7_frame = CGRectMake(overlay_frame.origin.x - lab_height, 0, line_width+lab_height, lab_height);
    UILabel* lab7 = [[UILabel alloc]initWithFrame:lab7_frame];
    [lab7 setBackgroundColor:[UIColor greenColor]];
    [bottomView addSubview:lab7];
    [lab7 release];
    
    
    [overlayView setPoints:nil];
    wasCancelled = NO;    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (!isStatusBarHidden)
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.overlayView removeFromSuperview];
    [self stopCapture];
}

-(void)doExit:(id)sender
{
    //    [self.navigationController popViewControllerAnimated:YES];
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"确定退出扫描吗?" delegate:self cancelButtonTitle:@"退出" otherButtonTitles:@"取消", nil];
    [alert show];
    [alert release];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == alertView.cancelButtonIndex)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(zxingControllerDidCancel:)]) {
            [self.delegate zxingControllerDidCancel:self];
        }
//        [self.navigationController popViewControllerAnimated:YES];
        //[[UIApplication sharedApplication] performSelector:@selector(terminateWithSuccess)];
    }
}

-(void)openHistory:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
    if(delegate && [delegate respondsToSelector:@selector(openHistoryWithType:)])
    {
        [delegate performSelector:@selector(openHistoryWithType:) withObject:(id)self.view.tag];
    }
    //    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"等下面的版本" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    //    [alert show];
    //    [alert release];
}

- (CGImageRef)CGImageRotated90:(CGImageRef)imgRef
{
    CGFloat angleInRadians = -90 * (M_PI / 180);
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGRect imgRect = CGRectMake(0, 0, width, height);
    CGAffineTransform transform = CGAffineTransformMakeRotation(angleInRadians);
    CGRect rotatedRect = CGRectApplyAffineTransform(imgRect, transform);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bmContext = CGBitmapContextCreate(NULL,
                                                   rotatedRect.size.width,
                                                   rotatedRect.size.height,
                                                   8,
                                                   0,
                                                   colorSpace,
                                                   kCGImageAlphaPremultipliedFirst);
    CGContextSetAllowsAntialiasing(bmContext, FALSE);
    CGContextSetInterpolationQuality(bmContext, kCGInterpolationNone);
    CGColorSpaceRelease(colorSpace);
    //      CGContextTranslateCTM(bmContext,
    //                                                +(rotatedRect.size.width/2),
    //                                                +(rotatedRect.size.height/2));
    CGContextScaleCTM(bmContext, rotatedRect.size.width/rotatedRect.size.height, 1.0);
    CGContextTranslateCTM(bmContext, 0.0, rotatedRect.size.height);
    CGContextRotateCTM(bmContext, angleInRadians);
    //      CGContextTranslateCTM(bmContext,
    //                                                -(rotatedRect.size.width/2),
    //                                                -(rotatedRect.size.height/2));
    CGContextDrawImage(bmContext, CGRectMake(0, 0,
                                             rotatedRect.size.width,
                                             rotatedRect.size.height),
                       imgRef);
    
    CGImageRef rotatedImage = CGBitmapContextCreateImage(bmContext);
    CFRelease(bmContext);
    [(id)rotatedImage autorelease];
    
    return rotatedImage;
}

- (CGImageRef)CGImageRotated180:(CGImageRef)imgRef
{
    CGFloat angleInRadians = M_PI;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bmContext = CGBitmapContextCreate(NULL,
                                                   width,
                                                   height,
                                                   8,
                                                   0,
                                                   colorSpace,
                                                   kCGImageAlphaPremultipliedFirst);
    CGContextSetAllowsAntialiasing(bmContext, FALSE);
    CGContextSetInterpolationQuality(bmContext, kCGInterpolationNone);
    CGColorSpaceRelease(colorSpace);
    CGContextTranslateCTM(bmContext,
                          +(width/2),
                          +(height/2));
    CGContextRotateCTM(bmContext, angleInRadians);
    CGContextTranslateCTM(bmContext,
                          -(width/2),
                          -(height/2));
    CGContextDrawImage(bmContext, CGRectMake(0, 0, width, height), imgRef);
    
    CGImageRef rotatedImage = CGBitmapContextCreateImage(bmContext);
    CFRelease(bmContext);
    [(id)rotatedImage autorelease];
    
    return rotatedImage;
}

// DecoderDelegate methods

- (void)decoder:(Decoder *)decoder willDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset{
#ifdef DEBUG
    NSLog(@"DecoderViewController MessageWhileDecodingWithDimensions: Decoding image (%.0fx%.0f) ...", image.size.width, image.size.height);
#endif
}

- (void)decoder:(Decoder *)decoder
  decodingImage:(UIImage *)image
    usingSubset:(UIImage *)subset {
}

- (void)presentResultForString:(NSString *)resultString {
    self.result = [ResultParser parsedResultForString:resultString];
    if (beepSound != (SystemSoundID)-1) {
        AudioServicesPlaySystemSound(beepSound);
    }
#ifdef DEBUG
    NSLog(@"result string = %@", resultString);
#endif
}

- (void)presentResultPoints:(NSArray *)resultPoints
                   forImage:(UIImage *)image
                usingSubset:(UIImage *)subset {
    // simply add the points to the image view
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:resultPoints];
    [overlayView setPoints:mutableArray];
    [mutableArray release];
}

- (void)decoder:(Decoder *)decoder didDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset withResult:(TwoDDecoderResult *)twoDResult {
    [self presentResultForString:[twoDResult text]];
    [self presentResultPoints:[twoDResult points] forImage:image usingSubset:subset];
    self.decodeImage = image;
    // now, in a selector, call the delegate to give this overlay time to show the points
    [self performSelector:@selector(notifyDelegate:) withObject:[[twoDResult text] copy] afterDelay:0.0];
    decoder.delegate = nil;
}

- (void)notifyDelegate:(id)text {
    if (!isStatusBarHidden) [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [delegate zxingController:self didScanResult:text];
    [text release];
}

- (void)decoder:(Decoder *)decoder failedToDecodeImage:(UIImage *)image usingSubset:(UIImage *)subset reason:(NSString *)reason {
    decoder.delegate = nil;
    [overlayView setPoints:nil];
}

- (void)decoder:(Decoder *)decoder foundPossibleResultPoint:(CGPoint)point {
    [overlayView setPoint:point];
}

/*
 - (void)stopPreview:(NSNotification*)notification {
 // NSLog(@"stop preview");
 }
 
 - (void)notification:(NSNotification*)notification {
 // NSLog(@"notification %@", notification.name);
 }
 */

#pragma mark -
#pragma mark AVFoundation

- (BOOL)initCapture {
#if HAS_AVFF
    NSError *error = nil;
    AVCaptureDeviceInput *captureInput =
    [AVCaptureDeviceInput deviceInputWithDevice:
     [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo]
                                          error:&error];
    if (error != nil) {
        return NO;
    }
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    [captureOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [captureOutput setVideoSettings:videoSettings];
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession release];
    self.captureSession.sessionPreset = AVCaptureSessionPresetMedium; // 480x360 on a 4
    
    [self.captureSession addInput:captureInput];
    [self.captureSession addOutput:captureOutput];
    
    [captureOutput release];
    
    /*
     [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(stopPreview:)
     name:AVCaptureSessionDidStopRunningNotification
     object:self.captureSession];
     
     [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(notification:)
     name:AVCaptureSessionDidStopRunningNotification
     object:self.captureSession];
     
     [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(notification:)
     name:AVCaptureSessionRuntimeErrorNotification
     object:self.captureSession];
     
     [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(notification:)
     name:AVCaptureSessionDidStartRunningNotification
     object:self.captureSession];
     
     [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(notification:)
     name:AVCaptureSessionWasInterruptedNotification
     object:self.captureSession];
     
     [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(notification:)
     name:AVCaptureSessionInterruptionEndedNotification
     object:self.captureSession];
     */
    
    if (!self.prevLayer) {
        self.prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
    }
    // NSLog(@"prev %p %@", self.prevLayer, self.prevLayer);
    self.prevLayer.frame = self.view.bounds;
    self.prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer: self.prevLayer];
    
    [self.captureSession startRunning];
#endif
    return YES;
}

#if HAS_AVFF
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    if (!decoding) {
        return;
    }
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    /*Lock the image buffer*/
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    /*Get information about the image*/
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    uint8_t* baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    void* free_me = 0;
    if (true) { // iOS bug?
        uint8_t* tmp = baseAddress;
        int bytes = bytesPerRow*height;
        free_me = baseAddress = (uint8_t*)malloc(bytes);
        baseAddress[0] = 0xdb;
        memcpy(baseAddress,tmp,bytes);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext =
    CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace,
                          kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipFirst);
    
    CGImageRef capture = CGBitmapContextCreateImage(newContext);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    free(free_me);
    
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    
    CGRect cropRect = [overlayView cropRect];
    //  if (oneDMode) {
    //    // let's just give the decoder a vertical band right above the red line
    //    cropRect.origin.x = cropRect.origin.x + (cropRect.size.width / 2) - (ONE_D_BAND_HEIGHT + 1);
    //    cropRect.size.width = ONE_D_BAND_HEIGHT;
    //    // do a rotate
    //    CGImageRef croppedImg = CGImageCreateWithImageInRect(capture, cropRect);
    //    capture = [self CGImageRotated90:croppedImg];
    //    capture = [self CGImageRotated180:capture];
    //    //              UIImageWriteToSavedPhotosAlbum([UIImage imageWithCGImage:capture], nil, nil, nil);
    //    CGImageRelease(croppedImg);
    //    cropRect.origin.x = 0.0;
    //    cropRect.origin.y = 0.0;
    //    cropRect.size.width = CGImageGetWidth(capture);
    //    cropRect.size.height = CGImageGetHeight(capture);
    //  }
    
    // N.B.
    // - Won't work if the overlay becomes uncentered ...
    // - iOS always takes videos in landscape
    // - images are always 4x3; device is not
    // - iOS uses virtual pixels for non-image stuff
    
    {
        float height = CGImageGetHeight(capture);
        float width = CGImageGetWidth(capture);
        
        CGRect screen = self.view.bounds;//UIScreen.mainScreen.bounds;
        float tmp = screen.size.width;
        screen.size.width = screen.size.height;;
        screen.size.height = tmp;
        
        cropRect.origin.x = (width-cropRect.size.width)/2;
        cropRect.origin.y = (height-cropRect.size.height)/2;
    }
    CGImageRef newImage = CGImageCreateWithImageInRect(capture, cropRect);
    CGImageRelease(capture);
    //  UIImage *scrn = [[UIImage alloc] initWithCGImage:newImage];
    int backCameraImageOrientation = UIImageOrientationRight;
    UIImage *scrn = [[UIImage alloc] initWithCGImage:newImage scale:
                     (CGFloat)1.0 orientation:backCameraImageOrientation];
    CGImageRelease(newImage);
    Decoder *d = [[Decoder alloc] init];
    d.readers = readers;
    d.delegate = self;
    cropRect.origin.x = 0.0;
    cropRect.origin.y = 0.0;
    decoding = [d decodeImage:scrn cropRect:cropRect] == YES ? NO : YES;
    [d release];
    [scrn release];
}
#endif

- (void)stopCapture {
    decoding = NO;
#if HAS_AVFF
    [captureSession stopRunning];
    AVCaptureInput* input = [captureSession.inputs objectAtIndex:0];
    [captureSession removeInput:input];
    AVCaptureVideoDataOutput* output = (AVCaptureVideoDataOutput*)[captureSession.outputs objectAtIndex:0];
    [captureSession removeOutput:output];
    [self.prevLayer removeFromSuperlayer];
    
    /*
     // heebee jeebees here ... is iOS still writing into the layer?
     if (self.prevLayer) {
     layer.session = nil;
     AVCaptureVideoPreviewLayer* layer = prevLayer;
     [self.prevLayer retain];
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 12000000000), dispatch_get_main_queue(), ^{
     [layer release];
     });
     }
     */
    
    self.prevLayer = nil;
    self.captureSession = nil;
#endif
}

#pragma mark - Torch

- (void)setTorch:(BOOL)status {
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        [device lockForConfiguration:nil];
        if ( [device hasTorch] ) {
            if ( status ) {
                [device setTorchMode:AVCaptureTorchModeOn];
            } else {
                [device setTorchMode:AVCaptureTorchModeOn];
            }
        }
        [device unlockForConfiguration];
        
    }
}

- (BOOL)torchIsOn {
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        if ( [device hasTorch] ) {
            return [device torchMode] == AVCaptureTorchModeOn;
        }
        [device unlockForConfiguration];
    }
    return NO;
}

@end
