//
//  BBNewEyesViewController.h
//  ZgSafe
//
//  Created by apple on 14-6-10.
//  Copyright (c) 2014年 iXcoder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IOTCamera/AVIOCTRLDEFs.h>
#import <IOTCamera/Camera.h>
#import <IOTCamera/Monitor.h>
#import "CameraShowGLView.h"

@interface BBNewEyesViewController : BBRootViewController<CameraDelegate, MonitorTouchDelegate>
{
    unsigned short mCodecId;
	CameraShowGLView *glView;
	CVPixelBufferPoolRef mPixelBufferPool;
	CVPixelBufferRef mPixelBuffer;
	CGSize mSizePixelBuffer;
    
	BOOL bStopShowCompletedLock;
	
    Camera *camera;
    Monitor *monitor;
}

@property (nonatomic, assign) BOOL bStopShowCompletedLock;
@property (nonatomic, assign) unsigned short mCodecId;
@property (nonatomic, assign) CGSize mSizePixelBuffer;
@property (nonatomic, assign) CameraShowGLView *glView;
@property CVPixelBufferPoolRef mPixelBufferPool;
@property CVPixelBufferRef mPixelBuffer;
@property (nonatomic, retain) Camera *camera;
@property (nonatomic, retain) IBOutlet Monitor *monitor;

@end
