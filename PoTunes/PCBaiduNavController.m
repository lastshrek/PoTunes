//
//  PCBaiduNavController.m
//  PoTunes
//
//  Created by Purchas on 15/9/12.
//  Copyright © 2015年 Purchas. All rights reserved.
//

#import "PCBaiduNavController.h"
#import <AMapSearchKit/AMapSearchAPI.h>
#import "GeocodeAnnotation.h"
#import "UIView+Geometry.h"
#import "CommonUtility.h"
#import "SharedMapView.h"

@interface PCBaiduNavController()<MAMapViewDelegate, UISearchBarDelegate, AMapSearchDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) MAMapView *mapView;
@property (nonatomic, weak) UISearchBar *searchBar;
@property (nonatomic, strong) UILabel *naviInfoLabel;
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) NSMutableArray *tips;
@property (nonatomic, weak) UITableView *tableView;
//用户位置
@property (nonatomic, assign) CLLocationCoordinate2D userLocation;
//用户选择的起始位置
//目的位置
@property (nonatomic, assign) CLLocationCoordinate2D selectedstartLocation;
@property (nonatomic, assign) BOOL isSelected;
//目的位置
@property (nonatomic, assign) CLLocationCoordinate2D destinationLocation;

@property (nonatomic, copy) NSString *destinationTitle;
@property (nonatomic, strong) NSMutableArray *annotations;


@end

@implementation PCBaiduNavController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initMapView];
    
    [self initSearchBar];
    
    [self initTableView];
    
    [self getNotification];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self clearMapView];
}
#pragma mark - Init & Construct

- (id)init {
    if (self = [super init]) {
        self.tips = [NSMutableArray array];
        self.annotations = [NSMutableArray array];
    }
    return self;
}

- (void)initMapView {
    
    [MAMapServices sharedServices].apiKey = @"62443358a250ee522aba69dfa3c1d247";
    [AMapNaviServices sharedServices].apiKey = @"62443358a250ee522aba69dfa3c1d247";
    
    if (self.mapView == nil) {
        self.mapView = [[SharedMapView sharedInstance] mapView];
    }
    
    [[SharedMapView sharedInstance] stashMapViewStatus];
    
    self.mapView.frame = self.view.bounds;
    
    self.mapView.delegate = self;
    
    self.mapView.showsUserLocation = YES;
    
    [self.view addSubview:self.mapView];
    
    //初始化searchAPI
    AMapSearchAPI *search = [[AMapSearchAPI alloc] initWithSearchKey:@"62443358a250ee522aba69dfa3c1d247" Delegate:self];
    self.search = search;
    
}
- (void)initTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 88, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 88)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.hidden = YES;
    self.tableView =  tableView;
    [self.view addSubview:tableView];

}
- (void)initSearchBar {
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 44, CGRectGetWidth(self.view.bounds), 44)];
    self.searchBar = searchBar;
    self.searchBar.barStyle     = UIBarStyleBlack;
    self.searchBar.translucent  = NO;
    self.searchBar.delegate     = self;
    self.searchBar.placeholder  = @"请输入要查询的地点";
    self.searchBar.keyboardType = UIKeyboardTypeDefault;
    [self.view addSubview:searchBar];
}


#pragma mark - Utility

- (void)clearMapView {
    
    self.mapView.showsUserLocation = NO;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView removeOverlays:self.mapView.overlays];
    
    self.mapView.delegate = nil;
    
    [[SharedMapView sharedInstance] popMapViewStatus];
}

- (void)clearAndSearchGeocodeWithKey:(NSString *)key {
    /* 清除annotation. */
    [self clear];

    [self searchGeocodeWithKey:key];
}

/* 清除annotation. */
- (void)clear {
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
}

/* 地理编码 搜索. */
- (void)searchGeocodeWithKey:(NSString *)key {
    if (key.length == 0) return;

    AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
    geo.address = key;
    [self.search AMapGeocodeSearch:geo];
}

/* 输入提示 搜索.*/
- (void)searchTipsWithKey:(NSString *)key {
    if (key.length == 0) return;
    AMapInputTipsSearchRequest *tips = [[AMapInputTipsSearchRequest alloc] init];
    tips.keywords = key;
    [self.search AMapInputTipsSearch:tips];
}


- (void)getNotification {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(pop) name:@"pop" object:nil];
}

- (void)pop {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pop" object:nil];
    
}
#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    
    if(userLocation != nil) {
        //取出当前位置的坐标
        self.userLocation = CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    }
}

- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    if ([view.annotation isKindOfClass:[GeocodeAnnotation class]]) {
        
        GeocodeAnnotation *annotation = view.annotation;
        
        if (self.view.tag == 1 && self.isSelected) {
            self.userLocation = CLLocationCoordinate2DMake(annotation.coordinate.latitude, annotation.coordinate.longitude);            
        }
        
        if ([self.delegate respondsToSelector:@selector(navController:didClickTheAnnotationAccessoryControlBySendingUserLocation:andDestinationLocation: mapView: title: destinationTitle:)]) {
            
            
            [self.delegate navController:self didClickTheAnnotationAccessoryControlBySendingUserLocation:self.userLocation andDestinationLocation:self.destinationLocation mapView:self.mapView title:self.title destinationTitle:self.destinationTitle];
        
        [self.navigationController popViewControllerAnimated:YES];
        
        }
    
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[GeocodeAnnotation class]]) {
        
        static NSString *geoCellIdentifier = @"geoCellIdentifier";
        
        MAPinAnnotationView *poiAnnotationView = (MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:geoCellIdentifier];
       
        if (poiAnnotationView == nil) {
        
            poiAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                                reuseIdentifier:geoCellIdentifier];
        }
        
        poiAnnotationView.canShowCallout            = YES;
        poiAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return poiAnnotationView;
    }
    
    return nil;
}


#pragma mark - AMapSearchDelegate
/* 地理编码回调.*/
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response {

    if (response.geocodes.count == 0) return;

    NSMutableArray *annotations = [NSMutableArray array];

    [response.geocodes enumerateObjectsUsingBlock:^(AMapGeocode *obj, NSUInteger idx, BOOL *stop) {

        GeocodeAnnotation *geocodeAnnotation = [[GeocodeAnnotation alloc] initWithGeocode:obj];
        
        if (self.view.tag == 1) {
            
            self.selectedstartLocation = CLLocationCoordinate2DMake(geocodeAnnotation.coordinate.latitude, geocodeAnnotation.coordinate.longitude);
            
            self.isSelected = YES;
            
        } else if (self.view.tag == 2){
         
            self.destinationLocation =  CLLocationCoordinate2DMake(geocodeAnnotation.coordinate.latitude, geocodeAnnotation.coordinate.longitude);
            self.isSelected = NO;
            
        }
        
        self.destinationTitle = geocodeAnnotation.title;
        
        [annotations addObject:geocodeAnnotation];
    }];

    if (annotations.count == 1) {

        GeocodeAnnotation *annotation = annotations[0];

        [self.mapView setCenterCoordinate:[annotation coordinate] animated:YES];



    } else {

        [self.mapView setVisibleMapRect:[CommonUtility minMapRectForAnnotations:annotations] animated:YES];
    }

    [self.mapView addAnnotations:annotations];


}

/* 输入提示回调. */
- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response {

    [self.tips setArray:response.tips];

    [self.tableView reloadData];
}



#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    NSString *key = searchBar.text;

    [self clearAndSearchGeocodeWithKey:key];

    [self searchTipsWithKey:key];

    if (self.tips.count > 0) {

    }

}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    if (searchBar.text.length > 0) {

        self.tableView.hidden = NO;

        NSString *key = searchBar.text;

        [self clearAndSearchGeocodeWithKey:key];

        [self searchTipsWithKey:key];

    }

    if (searchBar.text.length == 0) {

        self.tableView.hidden = YES;

    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tips.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *tipCellIdentifier = @"tipCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tipCellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tipCellIdentifier];
    }
    
    AMapTip *tip = self.tips[indexPath.row];
    
    cell.textLabel.text = tip.name;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AMapTip *tip = self.tips[indexPath.row];

    [self clearAndSearchGeocodeWithKey:tip.name];

    self.tableView.hidden = YES;

    [self.searchBar endEditing:YES];
}

@end