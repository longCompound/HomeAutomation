//
//  BBDataFrame.m
//  SocketTrial
//
//  Created by iXcoder on 13-11-30.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import "BBDataFrame.h"
@interface BBDataFrame()
{
    NSStringEncoding gbkEncoding;
    NSString* dataEncoded;
}

@end;

@implementation BBDataFrame

- (id)init
{
    if (self = [super init]) {
        self.platform = 4;  // 默认平台版本
        self.version = 2;   // 默认协议版本
        gbkEncoding = GBK_ENCODEING;
        dataEncoded = nil;
    }
    return self;
}

-(NSString*)dataString
{
    if (dataEncoded!=nil) {
        return dataEncoded;
    }
    dataEncoded = [[NSString alloc] initWithData:self.data encoding:gbkEncoding];
    return dataEncoded;
}
-(void) dealloc {
    [dataEncoded release];
    [super dealloc];
}

@end
