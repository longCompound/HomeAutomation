//
//  My51cUdpSearcher.h
//  HDVSGetAndSet
//
//  Created by lds on 13-3-4.
//  Copyright (c) 2013 lds. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "DeviceInfoStruct.h"
#import "my51c_deviceDiscover.h"


@interface My51cUdpSearcher : NSObject
{
	id _delegate;
	int _nTimeout;
	BOOL _bStopThread, _bThreadIsRunning;
}
@property(nonatomic, assign)BOOL isSearching;


-(void)startSearchWithTimeout:(int)timeout delegate:(id)delegate;
-(BOOL)reBroadcast;
-(BOOL)reBroadcastWithInfo:(DeviceInfo_t)info;
-(void)stopSearch;

@end


@protocol My51cUdpSearchDelegate <NSObject>

@optional
-(void)onMy51cUdpSearchGotInfo:(DeviceInfo_t)info fromHost:(char*)host port:(int)port;
-(void)onMy51cUdpSearchDone;
- (void)didSetSuccess;
- (void)didSetFailed;

@end



