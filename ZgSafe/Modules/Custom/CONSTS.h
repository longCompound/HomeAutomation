//
//  CONSTS.h
//  Hupan
//
//  Copyright 2010 iTotem Studio. All rights reserved.
//


#define REQUEST_DOMAIN @"http://cx.itotemstudio.com/api.php" // default env

//text
#define TEXT_LOAD_MORE_NORMAL_STATE @"向上拉动加载更多..."
#define TEXT_LOAD_MORE_LOADING_STATE @"更多数据加载中..."


//other consts
typedef enum : NSUInteger{
	kTagWindowIndicatorView = 501,
	kTagWindowIndicator,
} WindowSubViewTag;

typedef enum : NSUInteger{
    kTagHintView = 101
} HintViewTag;

#pragma mark - framework demo

#define PAGE_COUNT 10
#define KEY_APPLICATION                         @"KEY_APPLICATION"
#define APPLICATION_LIST_REQUEST_CANCEL_SUBJECT @"APPLICATION_LIST_REQUEST_CANCEL_SUBJECT"
#define KEY_VERSION                             @"KEY_VERSION"
