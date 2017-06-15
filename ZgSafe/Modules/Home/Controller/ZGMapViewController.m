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
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import <BaiduMapAPI_Map/BMKPinAnnotationView.h>

@interface ZGMapViewController () <BMKMapViewDelegate,BMKPoiSearchDelegate> {
    BMKMapView                             *_mapView;
    BMKPoiSearch                            *_poiSearch;
    CGFloat                         _maxLatitude;
    CGFloat                         _maxLongitude;
    
    CGFloat                         _minLatitude;
    CGFloat                         _minLongitude;
    CLLocationCoordinate2D          _tempPt;
}

@end

@implementation ZGMapViewController

- (void)loadView
{
    [super loadView];
    self.view.backgroundColor = [UIColor whiteColor];
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, self.topBar.bottom, self.view.width, self.view.height - self.topBar.bottom)];
    _mapView.delegate = self;
     _mapView.zoomEnabled = YES;
    [_mapView setZoomLevel:18];
    _mapView.centerCoordinate = CLLocationCoordinate2DMake(29.526199, 106.717878);
    [self.view addSubview:_mapView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _mapView.frame = CGRectMake(0, self.topBar.bottom, self.view.width, self.view.height - self.topBar.bottom);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.topBar setupBackTrace:nil title:@"办公地点" rightActionTitle:nil];
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
    [_mapView removeAnnotations:_mapView.annotations];
    NSMutableArray * temp = [NSMutableArray array];
    [data enumerateObjectsUsingBlock:^(BMKPoiInfo * obj, NSUInteger idx, BOOL *stop) {
        if(idx == 0){
            _maxLatitude = -90;
            _maxLongitude = -180;
            _minLatitude = 90;
            _minLongitude = 180;
        }
        _maxLatitude = MAX(_maxLatitude, obj.pt.latitude);
        _maxLongitude = MAX(_maxLongitude, obj.pt.longitude);
        _minLatitude = MIN(_minLatitude, obj.pt.latitude);
        _minLongitude = MIN(_minLongitude, obj.pt.longitude);
        BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];
        annotation.coordinate = obj.pt;
        annotation.title = obj.name;
        annotation.subtitle = obj.address;
        _tempPt = obj.pt;
        [temp addObject:annotation];
    }];
   
    _maxLatitude =  MAX(-90, _maxLatitude);
    _maxLongitude = MAX(-180, _maxLongitude);
    _minLatitude =  MIN(90, _minLatitude);
    _minLongitude = MIN(180, _minLongitude);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (temp.count > 1) {
            _mapView.centerCoordinate = CLLocationCoordinate2DMake((_maxLatitude+_minLatitude)/2, (_maxLongitude+_minLongitude)/2);
        } else if (temp.count == 1) {
            _mapView.centerCoordinate = _tempPt;
        } else {
            _mapView.centerCoordinate = CLLocationCoordinate2DMake(29.526199, 106.717878);
        }
        [_mapView addAnnotations:temp];
    });
}

- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    // 生成重用标示identifier
    NSString *AnnotationViewID = @"RadarMark";
    
    // 检查是否有重用的缓存
    BMKAnnotationView* annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
        ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorRed;
        // 设置重天上掉下的效果(annotation)
        ((BMKPinAnnotationView*)annotationView).animatesDrop = NO;
    }
    
    annotationView.annotation = annotation;
    // 单击弹出泡泡，弹出泡泡前提annotation必须实现title属性
    annotationView.canShowCallout = YES;
    // 设置是否可以拖拽
    annotationView.draggable = NO;
    
    return annotationView;
}

- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    
}

@end
