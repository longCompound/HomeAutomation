//
//  My51cUdpSearcher.m
//  HdvsGetAndSet
//
//  Created by lds on 13-3-4.
//  Copyright (c) 2013 lds. All rights reserved.
//

#import "My51cUdpSearcher.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <sys/ioctl.h>
#import <net/if.h>
#import <netdb.h>



@interface My51cUdpSearcher (Private)

-(void)startListenThread;
-(void)stopListenThread;
-(void)listen;

-(int)broadcast;

-(void)gotBroadcast:(char*)buffer length:(int)len fromIp:(char*)ip port:(int)port;
-(void)timeIsUp;

@end

@implementation My51cUdpSearcher

#pragma mark - PUBLIC

-(void)startSearchWithTimeout:(int)timeout delegate:(id)delegate
{
	self.isSearching = YES;
	[self stopListenThread];
	_nTimeout = timeout;
	_delegate = delegate;
	if (timeout > 0)
	{
		[self performSelector:@selector(timeIsUp) withObject:nil afterDelay:timeout];
	}
	[self startListenThread];
	[self broadcast];
}

-(void)stopSearch
{
	NSLog(@"stop search");
	_delegate = nil;
	if (_nTimeout > 0)
	{
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeIsUp) object:nil];
	}
	[self stopListenThread];
	self.isSearching = NO;
}

-(BOOL)reBroadcast
{
	if (_bThreadIsRunning)
	{
		return [self broadcast];
	}
	else
	{
		return NO;
	}
}

-(BOOL)reBroadcastWithInfo:(DeviceInfo_t)info
{
	if (_bThreadIsRunning)
	{
		return [self broadcastWithInfo:info];
	}
	else
	{
		return NO;
	}
}

#pragma mark - PRIVATE


-(void)timeIsUp
{
	[self stopListenThread];
}

-(void)startListenThread
{
	_bStopThread = NO;
	[NSThread detachNewThreadSelector:@selector(listen) toTarget:self withObject:nil];
}

-(void)stopListenThread
{
	while (_bThreadIsRunning)
	{
		_bStopThread = YES;
		usleep(5000);
		NSLog(@"while (_bThreadIsRunning)");
	}
	_bStopThread = YES;
	_delegate = nil;
	_nTimeout = 0;
}

-(void)listen
{
	_bThreadIsRunning = YES;
	
	
	int nBufferLength = 1024 * 4;
	char* buf = malloc(nBufferLength);
	int sockfd;
	int tolen ;
	socklen_t fromlen;
	struct sockaddr_in local_address;
	struct sockaddr_in from_address ;
	
	sockfd = socket(AF_INET,SOCK_DGRAM,0);
	local_address.sin_family = AF_INET ;
	local_address.sin_addr.s_addr = INADDR_ANY;
	local_address.sin_port = htons(UDP_PORT_RECV) ;
	tolen = sizeof(local_address);
	bind(sockfd , (struct sockaddr *)&local_address , tolen);
    BOOL isAPOk=NO;
	
	unsigned int n=0;
	while (!_bStopThread)
	{
		NSLog(@"listening...");
		struct timeval timeout;
		timeout.tv_sec = 0;
		timeout.tv_usec = 200 * 1000;
		fd_set  fdR;
		FD_ZERO(&fdR);
		FD_SET(sockfd, &fdR);
		NSLog(@"select 1");
		int nRet = select(sockfd + 1, &fdR, NULL, NULL, &timeout);
		NSLog(@"select 2");
		if(nRet > 0)
		{
			memset(&buf, nBufferLength, 0);
			if((n = recvfrom(sockfd,buf,1024*10,0,(struct sockaddr *)&from_address,&fromlen)) > 0)
			{
				isAPOk=YES;
                _bStopThread=YES;
				[self gotBroadcast:buf length:n fromIp:inet_ntoa(from_address.sin_addr) port:ntohs(from_address.sin_port)];
			}
		}
		NSLog(@"listening... over");
	}
    
	
Error:
	
	if (buf)
	{
		free(buf);
		buf = nil;
	}
	if (sockfd > 0)
	{
		close(sockfd);
		sockfd = 0;
	}
	if (!isAPOk)
	{
		[_delegate onMy51cUdpSearchDone];
	}
	NSLog(@"监听线程结束");
	_bThreadIsRunning = NO;
}

-(int)broadcast
{
	int sockfd = 0;;
	int tolen;
	struct sockaddr_in to_address;
	sockfd = socket(AF_INET,SOCK_DGRAM,0);		//第一个参数默认AF_INET	第二个参数, SOCK_DGRAM:UDP		SOCK_STREAM:TCP
	if (sockfd < 0)
	{
		return -1;
	}
	
	to_address.sin_family = AF_INET ;
	to_address.sin_addr.s_addr = INADDR_BROADCAST;
	//	to_address.sin_addr.s_addr = inet_addr("192.168.20.103");
	to_address.sin_port = htons(UDP_PORT_SEND) ;
	tolen = sizeof(to_address);
	
	
	int bEnabel = YES;
	int ret1 = setsockopt(sockfd, SOL_SOCKET, SO_BROADCAST, &bEnabel, sizeof(bEnabel));
	if (ret1 < 0)
	{
		perror("setsockopt:");
		NSLog(@"setsockopt: errno: %d ret:%d", errno, ret1);
	}
	
	DeviceInfo_t info = {0};
	info.nCmd = HDVSGET;
	strcpy(info.szPacketFlag,CMD_GET_FLAG);
	
    
	int ret2 = sendto(sockfd , &info , sizeof(DeviceInfo_t), 0 , (struct sockaddr *)&to_address , tolen);
	if (ret2 == sizeof(DeviceInfo_t))
	{
		NSLog(@"broadcast success: %ld", sizeof(DeviceInfo_t));
	}
	
	close(sockfd);
	sockfd = 0;
	if (ret1 < 0 || ret2 < 0)
	{
		return -1;
	}
	return 0;
}


-(int)broadcastWithInfo:(DeviceInfo_t)_info
{
	int sockfd = 0;;
	int tolen;
	struct sockaddr_in to_address;
	sockfd = socket(AF_INET,SOCK_DGRAM,0);		//第一个参数默认AF_INET	第二个参数, SOCK_DGRAM:UDP		SOCK_STREAM:TCP
	if (sockfd < 0)
	{
		return -1;
	}
	
	to_address.sin_family = AF_INET ;
	to_address.sin_addr.s_addr = INADDR_BROADCAST;
	//	to_address.sin_addr.s_addr = inet_addr("192.168.20.103");
	to_address.sin_port = htons(UDP_PORT_SEND) ;
	tolen = sizeof(to_address);
	
	
	int bEnabel = YES;
	int ret1 = setsockopt(sockfd, SOL_SOCKET, SO_BROADCAST, &bEnabel, sizeof(bEnabel));
	if (ret1 < 0)
	{
		perror("setsockopt:");
		NSLog(@"setsockopt: errno: %d ret:%d", errno, ret1);
	}
	
	DeviceInfo_t info = _info;
	info.nCmd = HDVSSET;
	strcpy(info.szPacketFlag,CMD_SET_INFO_FLAG);
	
    
	int ret2 = sendto(sockfd , &info , sizeof(DeviceInfo_t), 0 , (struct sockaddr *)&to_address , tolen);
	if (ret2 == sizeof(DeviceInfo_t))
	{
        [_delegate didSetSuccess];
        [self performSelector:@selector(stopListenThread) withObject:nil afterDelay:3.];
		NSLog(@"broadcast success: %ld", sizeof(DeviceInfo_t));
	}else{
        [_delegate didSetFailed];
    }
	
	close(sockfd);
	sockfd = 0;
	if (ret1 < 0 || ret2 < 0)
	{
		return -1;
	}
	return 0;
}



-(void)gotBroadcast:(char*)buffer length:(int)len fromIp:(char*)ip port:(int)port
{
	NSLog(@"gotBroadcast:(char*)buffer length:(int)len fromIp:(char*)ip port:(int)port delegate : %@", _delegate);
	if (len == sizeof(DeviceInfo_t) && buffer && port == UDP_PORT_SEND && [_delegate respondsToSelector:@selector(onMy51cUdpSearchGotInfo: fromHost:port:)])
	{
		DeviceInfo_t info = {0};
		memcpy(&info, buffer, sizeof(DeviceInfo_t));
		if (info.nCmd == RESPONDHDVSGET)
		{
			[_delegate onMy51cUdpSearchGotInfo:info fromHost:ip port:port];
		}
	}
}

-(void)dealloc
{
	NSLog(@"dealloc %@", [self class]);
	[super dealloc];
}

@end
