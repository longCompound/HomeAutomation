//
//  ZGMapViewController.m
//  ZgSafe
//
//  Created by Mark on 2017/6/15.
//  Copyright © 2017年 iXcoder. All rights reserved.
//

#import "ZGMapViewController.h"
#import <MapKit/MapKit.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import "ZGPoiPoint.h"
#import "MKMapView+MapViewUtil.h"

@interface ZGMapViewController () <MKMapViewDelegate,BMKPoiSearchDelegate> {
    __weak IBOutlet MKMapView *_mapView;
    NSMutableArray<ZGPoiPoint *>            *_dataArray;
    BMKPoiSearch                            *_poiSearch;
      
}

@end

@implementation ZGMapViewController

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _mapView.frame = CGRectMake(0, self.topBar.bottom, self.view.width, self.view.height - self.topBar.bottom);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.topBar setupBackTrace:nil title:@"办公地点" rightActionTitle:nil];
    _dataArray = [NSMutableArray<ZGPoiPoint *> array];
    [self loadData];
    // Do any additional setup after loading the view from its nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData
{
    if (!_poiSearch) {
        _poiSearch = [[BMKPoiSearch alloc]init];
        _poiSearch.delegate = self;
    }
    BMKNearbySearchOption * option = [[BMKNearbySearchOption alloc] init];
    option.radius = 500;
    option.location = CLLocationCoordinate2DMake(29.526199, 106.717878);
    option.keyword = [_keyWord copy];
    option.pageIndex = 0;
    option.pageCapacity = 20;
    [_poiSearch poiSearchNearBy:option];
}

- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResult errorCode:(BMKSearchErrorCode)errorCode
{
    [self loadDisplayData:poiResult.poiInfoList];
}

- (void)loadDisplayData:(NSArray *)data
{
    if (_dataArray.count > 0) {
        [_mapView removeAnnotations:_dataArray];
        [_dataArray removeAllObjects];
    }
    [data enumerateObjectsUsingBlock:^(BMKPoiInfo * obj, NSUInteger idx, BOOL *stop) {
        [_dataArray addObject:[[ZGPoiPoint alloc] initWith:obj]];
    }];
    _mapView.zoomEnabled = YES;
    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(29.526199, 106.717878) zoomLevel:15 animated:NO];
    [_mapView addAnnotations:_dataArray];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views
{
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *ID = @"annoView";
    MKPinAnnotationView *annoView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:ID];
    if (annoView == nil) {
        annoView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ID];
        // 显示气泡
        annoView.canShowCallout = YES;
        // 设置绿色
        annoView.pinColor = MKPinAnnotationColorRed;
    }
    return annoView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
}

@end
