//
//  BBDataFrameTool.h
//  SocketTrial
//
//  Created by iXcoder on 13-11-29.
//  Copyright (c) 2013年 iXcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBDataFrame.h"


#pragma mark -
#pragma mark BBDataFrameTool class

@interface BBDataFrameTool : NSObject

+ (NSData *)encodeDataFrame:(BBDataFrame *)frame;

+ (BBDataFrame *)decodeDataToFrame:(NSData *)data;
+ (NSInteger)highLowByteToInt:(Byte[2])b;
@end





