//
//  BBNewsEyesViewController.h
//  ZgSafe
//
//  Created by apple on 14-7-11.
//  Copyright (c) 2014年 iXcoder. All rights reserved.
//

#define MAX_IMG_BUFFER_SIZE	(1280*720*4)
#define PT_SPEED 8
#define PT_DELAY 1.5
#define ZOOM_MAX_SCALE 5.0
#define ZOOM_MIN_SCALE 1.0
#define degreeToRadians(x) (M_PI * (x) / 180.0)

#import <UIKit/UIKit.h>
#import <IOTCamera/Camera.h>
#import <IOTCamera/Monitor.h>
#import <IOTCamera/AVIOCTRLDEFs.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MyCamera.h"
#import "AudioPickerContentController.h"
#import "CameraShowGLView.h"

@interface BBNewsEyesViewController : UIViewController
<MyCameraDelegate, MonitorTouchDelegate, UIScrollViewDelegate, UIPopoverControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate> {
    
	unsigned short mCodecId;
	CameraShowGLView *glView;
	CVPixelBufferPoolRef mPixelBufferPool;
	CVPixelBufferRef mPixelBuffer;
	CGSize mSizePixelBuffer;
	
    UIView *portraitView;
    UIView *landscapeView;
    Monitor *monitorPortrait;
    Monitor *monitorLandscape;
    UIScrollView *scrollViewPortrait;
    UIScrollView *scrollViewLandscape;
    UIActivityIndicatorView *loadingViewPortrait;
    UIActivityIndicatorView *loadingViewLandscape;
    NSString *directoryPath;
    
    MyCamera *camera;
    
    NSInteger selectedChannel;
    ENUM_AUDIO_MODE selectedAudioMode;
    Class popoverClass;
    
    int wrongPwdRetryTime;
	BOOL bStopShowCompletedLock;
}

@property (nonatomic, assign) BOOL bStopShowCompletedLock;
@property (nonatomic, assign) unsigned short mCodecId;
@property (nonatomic, assign) CGSize mSizePixelBuffer;
@property (nonatomic, assign) CameraShowGLView *glView;
@property CVPixelBufferPoolRef mPixelBufferPool;
@property CVPixelBufferRef mPixelBuffer;
@property (nonatomic, retain) IBOutlet UIView *portraitView;
@property (nonatomic, retain) IBOutlet UIView *landscapeView;
@property (nonatomic, retain) IBOutlet Monitor *monitorPortrait;
@property (nonatomic, retain) IBOutlet Monitor *monitorLandscape;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollViewPortrait;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollViewLandscape;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingViewPortrait;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingViewLandscape;
@property (nonatomic, retain) IBOutlet UIButton *btnSelectedAudioMode;
@property (nonatomic, retain) IBOutlet UIButton *btnSelectedAudioMode1;
@property (nonatomic, retain) MyCamera *camera;
@property NSInteger selectedChannel;
@property ENUM_AUDIO_MODE selectedAudioMode;;
@property (nonatomic, copy) NSString *directoryPath;
//@property (strong, atomic) ALAssetsLibrary* library;

- (IBAction)back:(id)sender;
- (IBAction)selectAudio:(id)sender;
- (IBAction)savePhoto:(id)sender;
- (IBAction)goAlbum:(id)sender;
- (IBAction)goSetup:(id)sender;
- (IBAction)goChange:(id)sender;

@end