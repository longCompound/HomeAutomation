//
//  MKMapView+MapViewUtil.h
//  ZgSafe
//
//  Created by Mark on 2017/6/15.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (MapViewUtil)

- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;

@end
