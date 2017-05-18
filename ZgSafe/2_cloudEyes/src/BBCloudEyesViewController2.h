//
//  BBCloudEyesViewController.h
//  ZgSafe
//
//  Created by box on 13-10-25.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <IOTCamera/Camera.h>
#import <IOTCamera/AVIOCTRLDEFs.h>
#import <IOTCamera/AVIOCTRLDEFs.h>
#import <IOTCamera/Camera.h>
#import <IOTCamera/Monitor.h>
#import "CameraShowGLView.h"
#import "iToast.h"
#import "MyCamera.h"

#define MAX_IMG_BUFFER_SIZE	2764800	//1280 * 720 * 3
typedef enum
{
	MEDIA_CODEC_UNKNOWN			= 0x00,
	MEDIA_CODEC_VIDEO_MPEG4		= 0x4C,
	MEDIA_CODEC_VIDEO_H263		= 0x4D,
	MEDIA_CODEC_VIDEO_H264		= 0x4E,
	MEDIA_CODEC_VIDEO_MJPEG		= 0x4F,
	
    MEDIA_CODEC_AUDIO_ADPCM     = 0X8B,
	MEDIA_CODEC_AUDIO_PCM		= 0x8C,
	MEDIA_CODEC_AUDIO_SPEEX		= 0x8D,
	MEDIA_CODEC_AUDIO_MP3		= 0x8E,
    MEDIA_CODEC_AUDIO_G726      = 0x8F,
}ENUM_CODECID;

typedef NS_ENUM(NSUInteger, CameraSessionState) {
    kCameraSessionStateNone = 0,
    kCameraSessionStateConnecting,
    kCameraSessionStateConnected,
    kCameraSessionStateDisconnected,
    kCameraSessionStateUnknownDevice,
    kCameraSessionStateWrongPassword,
    kCameraSessionStateTimeOut,
    kCameraSessionStateUnsupported,
    kCameraSessionStateConnectFailed
};

typedef NS_ENUM(NSInteger, MyCameraConnectionMode) {
    kMyCameraConnectionModeNONE = -1,
    kMyCameraConnectionModeP2P,
    kMyCameraConnectionModeRelay,
    kMyCameraConnectionModeLAN
};

typedef NS_ENUM(NSUInteger, ChannelVideoType) {
    kChannelVideoTypeFPS = 110,
    kChannelVideoTypeBPS,
    kChannelVideoTypeFrameCount,
    kChannelVideoTypeIncompleteFrameCount,
    kChannelVideoTypeOnlinenm
};

typedef NS_ENUM(NSUInteger, AudioMode) {
    kAudioModeOff = 0,
    kAudioModeSpeaker = 1,
    kAudioModeMicrophone = 2,
};

@interface BBCloudEyesViewController : BBRootViewController
{
    MyCamera *camera;           // 摄像头
    AudioMode selectedAudioMode;
}
@property (nonatomic, retain) NSString *deviceID;       // 设备id(扫描或输入)

 
@property(nonatomic,assign)UIViewController *delegateVC;//上一个页面用于在手势验证通过之后，push本页面
@property (retain, nonatomic) IBOutlet UIButton *closeBtn;
@property (retain, nonatomic) IBOutlet UIView *toolBar;
@property (retain, nonatomic) IBOutlet UIButton *cloudAlbumBtn;
@property (retain, nonatomic) IBOutlet UIButton *takePhotoBtn;
@property (retain, nonatomic) IBOutlet UIButton *recordBtn;
@property (retain, nonatomic) IBOutlet UIButton *earBtn;
@property (retain, nonatomic) IBOutlet UIButton *screenTypeBtn;
@property (retain, nonatomic) IBOutlet UIButton *settingBtn;
@property (nonatomic,assign)UIViewController *lastViewController;


+ (void)verifyThenPushWithVC:(UIViewController *)viewControllor;

@end
