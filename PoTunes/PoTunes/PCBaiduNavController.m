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
#import "SharedMapView.h"
#import "CommonUtility.h"
typedef NS_ENUM(NSInteger, TravelTypes)
{
    TravelTypeCar = 0,      // 驾车方式
    TravelTypeWalk,         // 步行方式
};


typedef NS_ENUM(NSInteger, NavigationTypes)
{
    NavigationTypeNone = 0,
    NavigationTypeSimulator, // 模拟导航
    NavigationTypeGPS,       // 实时导航
};
typedef NS_ENUM(NSInteger, MapSelectPointState)
{
    MapSelectPointStateNone = 0,
    MapSelectPointStateStartPoint, // 当前操作为选择起始点
    MapSelectPointStateWayPoint,   // 当前操作为选择途径点
    MapSelectPointStateEndPoint,   // 当前操作为选择终止点
};
@interface PCBaiduNavController()<MAMapViewDelegate, UISearchBarDelegate, AMapSearchDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) MAMapView *mapView;
@property (nonatomic, weak) UISearchBar *searchBar;
@property (nonatomic, strong) UILabel *naviInfoLabel;
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) NSMutableArray *tips;
@property (nonatomic, weak) UITableView *tableView;
//用户位置
@property (nonatomic, strong) AMapNaviPoint *userLocation;
//目的位置
@property (nonatomic, assign) CLLocationCoordinate2D destinationLocation;

@property (nonatomic) TravelTypes travelType;

@property (nonatomic, strong) NSMutableArray *annotations;


@end

@implementation PCBaiduNavController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor whiteColor];
    [MAMapServices sharedServices].apiKey = @"62443358a250ee522aba69dfa3c1d247";
    [AMapNaviServices sharedServices].apiKey = @"62443358a250ee522aba69dfa3c1d247";
    
    
    [self initMapView];
    
    [self initSearchBar];
    
    [self initTableView];
//    [self initNaviManager];
//    [self initIFlySpeech];
//    [self initNaviViewController];
//    [self configSubViews];
    
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
#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    
    if(userLocation != nil) {
        //取出当前位置的坐标
        CLLocationDegrees lati = userLocation.location.coordinate.latitude;
        CLLocationDegrees longi = userLocation.location.coordinate.longitude;
                
        self.userLocation = [AMapNaviPoint locationWithLatitude:lati longitude:longi];;
        
        NSLog(@"%f,%f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
    }
}

- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    if ([view.annotation isKindOfClass:[GeocodeAnnotation class]]) {
        
        if ([self.delegate respondsToSelector:@selector(navController:didClickTheAnnotationAccessoryControlBySendingUserLocation:andDestinationLocation:)]) {
            [self.delegate navController:self didClickTheAnnotationAccessoryControlBySendingUserLocation:self.userLocation andDestinationLocation:self.destinationLocation];
        }
        [self.navigationController popViewControllerAnimated:YES];
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
        
        poiAnnotationView.canShowCallout = YES;
        
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
        
        
        
        self.destinationLocation =  geocodeAnnotation.coordinate;
        
        NSLog(@"%f",self.destinationLocation.latitude);

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
