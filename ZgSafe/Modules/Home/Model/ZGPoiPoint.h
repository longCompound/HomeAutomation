//
//  ZGPoiPoint.h
//  ZgSafe
//
//  Created by Mark on 2017/6/15.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>


@interface ZGPoiPoint : NSObject <MKAnnotation>

@property (nonatomic, assign, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *subtitle;
@property (nonatomic, strong, readonly)  BMKPoiInfo * infoModel;

- (instancetype)initWith:(BMKPoiInfo *)infoModel;

@end
