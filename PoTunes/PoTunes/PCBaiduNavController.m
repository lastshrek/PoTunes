//
//  PCBaiduNavController.m
//  PoTunes
//
//  Created by Purchas on 15/9/12.
//  Copyright © 2015年 Purchas. All rights reserved.
//

#import "PCBaiduNavController.h"
#import <AMapNaviKit/AMapNaviKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "GeoDetailViewController.h"
#import "GeocodeAnnotation.h"
#import "CommonUtility.h"
#import "UIView+Geometry.h"
#import "NavPointAnnotation.h"
#import "MACombox.h"
#import "Toast+UIView.h"
#import "MoreMenuView.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"
#import "iflyMSC/IFlySpeechError.h"

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
@interface PCBaiduNavController()<MAMapViewDelegate, UISearchBarDelegate, AMapSearchDelegate, UISearchDisplayDelegate, UITableViewDelegate, UITableViewDataSource, AMapNaviManagerDelegate,MoreMenuViewDelegate,AMapNaviViewControllerDelegate, AMapNaviHUDViewControllerDelegate,IFlySpeechSynthesizerDelegate>

@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, weak) UISearchBar *searchBar;
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) NSMutableArray *tips;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) AMapNaviPoint* startPoint;
@property (nonatomic, strong) AMapNaviPoint* endPoint;
//用户位置
@property (nonatomic, strong) MAUserLocation *userLocation;
@property (nonatomic) TravelTypes travelType;
@property (nonatomic) NavigationTypes naviType;
@property (nonatomic) MapSelectPointState selectPointState;

@property (nonatomic, strong) AMapNaviManager *naviManager;
@property (nonatomic) BOOL calRouteSuccess; // 指示是否算路成功
@property (nonatomic, strong) MAPolyline *polyline;

@property (nonatomic, strong) NavPointAnnotation *wayAnnotation;
@property (nonatomic, strong) NavPointAnnotation *endAnnotation;
@property (nonatomic, strong) NavPointAnnotation *beginAnnotation;
@property (nonatomic, strong) NSDictionary *strategyMap;
@property (nonatomic, assign) BOOL startCurrLoc;
@property (nonatomic, strong) MACombox *strategyCombox;
@property (nonatomic, strong) MACombox *startPointCombox;
@property (nonatomic, strong) MACombox *endPointCombox;
@property (nonatomic, strong) MACombox *wayPointCombox;


@property (nonatomic, strong) AMapNaviViewController *naviViewController;
@property (nonatomic, strong)     MoreMenuView *moreMenuView;
@property (nonatomic, strong) IFlySpeechSynthesizer *iFlySpeechSynthesizer;



@end

@implementation PCBaiduNavController

- (void)viewDidLoad {
    [super viewDidLoad];
    [MAMapServices sharedServices].apiKey = @"62443358a250ee522aba69dfa3c1d247";
    [AMapNaviServices sharedServices].apiKey =@"62443358a250ee522aba69dfa3c1d247";
    //创建地图
    [self initMaps];
//    [self initNaviViewController];

    //创建searchBar
    [self initSearchBar];

    //创建searchDisplayController
    [self initTableView];
    //创建buttons
    [self initsubviews];
    //初始化NaviManager
    [self initNaviManager];
    [self initCalRouteStrategyMap];
    [self initSettingState];
    [self initIFlySpeech];
}

- (void)initIFlySpeech
{
    if (self.iFlySpeechSynthesizer == nil)
    {
        _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    }
    
    _iFlySpeechSynthesizer.delegate = self;
}

#pragma mark - init
- (void)initMaps {
   
    MAMapView *mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    mapView.delegate = self;
    //开启定位
    mapView.showsUserLocation = YES;
    mapView.pausesLocationUpdatesAutomatically = NO;
    [mapView setUserTrackingMode:MAUserTrackingModeFollowWithHeading animated:YES];
    self.mapView = mapView;
    [self.mapView setCompassImage:[UIImage imageNamed:@"compass"]];
    [self.view addSubview:_mapView];
    
    //初始化searchAPI
    AMapSearchAPI *search = [[AMapSearchAPI alloc] initWithSearchKey:@"62443358a250ee522aba69dfa3c1d247" Delegate:self];
    self.search = search;
    
    if (_calRouteSuccess)
    {
        [self.mapView addOverlay:_polyline];
    }
}
- (void)initNaviManager {
    if (self.naviManager == nil)
    {
        _naviManager = [[AMapNaviManager alloc] init];
    }
    
    self.naviManager.delegate = self;
}
- (AMapNaviViewController *)naviViewController
{
    if (_naviViewController == nil)
    {
        _naviViewController = [[AMapNaviViewController alloc] initWithMapView:self.mapView delegate:self];
    }
    return _naviViewController;
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
- (void)initTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 88, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 88)];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.hidden = YES;
    self.tableView =  tableView;
    [self.view addSubview:tableView];
    
}
- (void)initsubviews {
    UISegmentedControl *segCtrl = [[UISegmentedControl alloc] initWithItems:@[@"驾车" , @"步行"]];
    
    segCtrl.tintColor = [UIColor grayColor];
    segCtrl.left = (self.view.frame.size.width - 180) / 2;
    segCtrl.top  = 90;
    segCtrl.frame = CGRectMake(segCtrl.left, segCtrl.top, 180, 30);
//    [segCtrl addTarget:self action:@selector(segCtrlClick:) forControlEvents:UIControlEventValueChanged];
    [segCtrl setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:17]}
                           forState:UIControlStateNormal];
    

    segCtrl.selectedSegmentIndex = 0;
    [self.view addSubview:segCtrl];
    
    UILabel *startPointLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(segCtrl.frame), 320, 20)];
    
    startPointLabel.textAlignment = NSTextAlignmentCenter;
    startPointLabel.font          = [UIFont systemFontOfSize:14];
    startPointLabel.text          = [NSString stringWithFormat:@"起 点：%f, %f", _startPoint.latitude, _startPoint.longitude];
//    [NSString stringWithFormat:@"起 点：%f, %f", _startPoint.latitude, _startPoint.longitude];
    
    [self.view addSubview:startPointLabel];
    
    UILabel *endPointLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(segCtrl.frame) + 30, 320, 20)];
    
    endPointLabel.textAlignment = NSTextAlignmentCenter;
    endPointLabel.font          = [UIFont systemFontOfSize:14];
    endPointLabel.text          = [NSString stringWithFormat:@"终 点：%f, %f", _endPoint.latitude, _endPoint.longitude];
    
    [self.view addSubview:endPointLabel];
    
    UIButton *routeBtn = [self createToolButton];
    [routeBtn setTitle:@"路径规划" forState:UIControlStateNormal];
    [routeBtn addTarget:self action:@selector(routeCal:) forControlEvents:UIControlEventTouchUpInside];
    routeBtn.left = segCtrl.left;
    routeBtn.top  = CGRectGetMaxY(endPointLabel.frame);
    [self.view addSubview:routeBtn];
    
    UIButton *simuBtn = [self createToolButton];
    [simuBtn setTitle:@"模拟导航" forState:UIControlStateNormal];
    [simuBtn addTarget:self action:@selector(simulatorNavi:) forControlEvents:UIControlEventTouchUpInside];
    simuBtn.left = segCtrl.left + 70;
    simuBtn.top  = CGRectGetMaxY(endPointLabel.frame);
    [self.view addSubview:simuBtn];
    
    UIButton *gpsBtn = [self createToolButton];
    [gpsBtn setTitle:@"实时导航" forState:UIControlStateNormal];
//    [gpsBtn addTarget:self action:@selector(gpsNavi:) forControlEvents:UIControlEventTouchUpInside];
    gpsBtn.left = segCtrl.left + 140;
    gpsBtn.top  = CGRectGetMaxY(endPointLabel.frame);
    [self.view addSubview:gpsBtn];

    
}
- (void)initTravelType
{
    _travelType = TravelTypeCar;
}
- (void)initCalRouteStrategyMap
{
    _strategyMap = @{@"速度优先"   : @0,
                     @"费用优先"   : @1,
                     @"距离优先"   : @2,
                     @"普通路优先"             : @3,
                     @"时间优先(躲避拥堵)"      : @4,
                     @"躲避拥堵且不走收费道路"   : @12};
}

- (void)initSettingState
{
    _startPointCombox.inputTextField.text = @"";
    _wayPointCombox.inputTextField.text   = @"";
    _endPointCombox.inputTextField.text   = @"";
    
    _beginAnnotation = nil;
    _wayAnnotation   = nil;
    _endAnnotation   = nil;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    _selectPointState = MapSelectPointStateNone;
    _naviType = NavigationTypeNone;
}
- (void)initMoreMenuView
{
    _moreMenuView = [[MoreMenuView alloc] initWithFrame:self.naviViewController.view.bounds];
    _moreMenuView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _moreMenuView.delegate = self;
}
#pragma mark - Utils Methods

- (UIButton *)createToolButton {
    UIButton *toolBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    toolBtn.layer.borderColor  = [UIColor lightGrayColor].CGColor;
    toolBtn.layer.borderWidth  = 0.5;
    toolBtn.layer.cornerRadius = 5;
    [toolBtn setBounds:CGRectMake(0, 0, 60, 30)];
    [toolBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    toolBtn.titleLabel.font = [UIFont systemFontOfSize: 13.0];
    
    return toolBtn;
}
- (void)showRouteWithNaviRoute:(AMapNaviRoute *)naviRoute {
    if (naviRoute == nil) {
        return;
    }
    
    // 清除旧的overlays
    if (_polyline) {
        [self.mapView removeOverlay:_polyline];
        self.polyline = nil;
    }
    
    NSUInteger coordianteCount = [naviRoute.routeCoordinates count];
    CLLocationCoordinate2D coordinates[coordianteCount];
    for (int i = 0; i < coordianteCount; i++) {
        AMapNaviPoint *aCoordinate = [naviRoute.routeCoordinates objectAtIndex:i];
        coordinates[i] = CLLocationCoordinate2DMake(aCoordinate.latitude, aCoordinate.longitude);
    }
    
    _polyline = [MAPolyline polylineWithCoordinates:coordinates count:coordianteCount];
    [self.mapView addOverlay:_polyline];
    
    //设置地图缩放级别
}


#pragma mark - Button Actions
- (void)routeCal:(id)sender {
    AMapNaviPoint *start = [[AMapNaviPoint alloc] init];
    start.latitude = 39.881267;
    start.longitude = 116.684884;
    self.startPoint = start;
    AMapNaviPoint *end = [[AMapNaviPoint alloc] init];
    end.latitude = 39.899384;
    end.longitude = 116.322952;
    self.endPoint = end;
    NSArray *startPoints = @[start];
    NSArray *endPoints   = @[end];
    
    if (self.travelType == TravelTypeCar)
    {
        [self.naviManager calculateDriveRouteWithStartPoints:startPoints endPoints:endPoints wayPoints:nil drivingStrategy:0];
    }
    else
    {
        [self.naviManager calculateWalkRouteWithStartPoints:startPoints endPoints:endPoints];
    }
}
- (void)calRoute {
    NSArray *startPoints = @[_startPoint];
    NSArray *endPoints   = @[_endPoint];

    [self.naviManager calculateDriveRouteWithStartPoints:startPoints endPoints:endPoints wayPoints:nil drivingStrategy:0];

}
- (void)simulatorNavi:(id)sender
{
    _naviType = NavigationTypeSimulator;
    
    [self calRoute];
}
#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    if(userLocation != nil) {
        //取出当前位置的坐标
        self.userLocation = userLocation;
//        NSLog(@"latitude : %f,longitude: %f",self.userLocation.coordinate.latitude,self.userLocation.coordinate.longitude);
    }
}

- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    if ([view.annotation isKindOfClass:[GeocodeAnnotation class]]) {
        [self gotoDetailForGeocode:[(GeocodeAnnotation*)view.annotation geocode]];
        
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
    if ([annotation isKindOfClass:[NavPointAnnotation class]])
    {
        static NSString *annotationIdentifier = @"annotationIdentifier";
        
        MAPinAnnotationView *pointAnnotationView = (MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        if (pointAnnotationView == nil)
        {
            pointAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                                  reuseIdentifier:annotationIdentifier];
        }
        
        pointAnnotationView.animatesDrop   = NO;
        pointAnnotationView.canShowCallout = NO;
        pointAnnotationView.draggable      = NO;
        
        NavPointAnnotation *navAnnotation = (NavPointAnnotation *)annotation;
        
        if (navAnnotation.navPointType == NavPointAnnotationStart)
        {
            [pointAnnotationView setPinColor:MAPinAnnotationColorGreen];
        }
        else if (navAnnotation.navPointType == NavPointAnnotationEnd)
        {
            [pointAnnotationView setPinColor:MAPinAnnotationColorRed];
        }
        return pointAnnotationView;
    }
    
    return nil;
}

//- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation {
//    if ([annotation isKindOfClass:[GeocodeAnnotation class]]) {
//        static NSString *geoCellIdentifier = @"geoCellIdentifier";
//        
//        MAPinAnnotationView *poiAnnotationView = (MAPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:geoCellIdentifier];
//        if (poiAnnotationView == nil) {
//            poiAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
//                                                                reuseIdentifier:geoCellIdentifier];
//        }
//        
//        poiAnnotationView.canShowCallout = YES;
//        poiAnnotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//        return poiAnnotationView;
//    }
//    
//    return nil;
//}
- (MAOverlayView *)mapView:(MAMapView *)mapView viewForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAPolyline class]])
    {
        MAPolylineView *polylineView = [[MAPolylineView alloc] initWithPolyline:overlay];
        
        polylineView.lineWidth   = 5.0f;
        polylineView.strokeColor = [UIColor redColor];
        
        return polylineView;
    }
    return nil;
}
#pragma mark - AMapNaviManager Delegate

- (void)naviManager:(AMapNaviManager *)naviManager error:(NSError *)error {
    NSLog(@"error:{%@}",error.localizedDescription);
}

- (void)naviManager:(AMapNaviManager *)naviManager didPresentNaviViewController:(UIViewController *)naviViewController
{
    [self.naviManager startEmulatorNavi];

}

- (void)naviManager:(AMapNaviManager *)naviManager didDismissNaviViewController:(UIViewController *)naviViewController
{
    //退出导航界面后恢复地图状态
    self.mapView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
    [self.view insertSubview:self.mapView atIndex:0];
    [self.mapView removeOverlay:self.polyline];
}

- (void)naviManagerOnCalculateRouteSuccess:(AMapNaviManager *)naviManager
{
    NSLog(@"OnCalculateRouteSuccess");
    
    [self showRouteWithNaviRoute:[[naviManager naviRoute] copy]];
    
    [self.naviManager presentNaviViewController:self.naviViewController animated:YES];
    
    _calRouteSuccess = YES;
}

//- (void)naviManager:(AMapNaviManager *)naviManager onCalculateRouteFailure:(NSError *)error
//{
//    NSLog(@"onCalculateRouteFailure");
//    
//    [self.view makeToast:@"算路失败"
//                duration:2.0
//                position:[NSValue valueWithCGPoint:CGPointMake(160, 240)]];
//}
- (void)naviHUDViewControllerBackButtonClicked:(AMapNaviHUDViewController *)naviHUDViewController {
    [_naviManager dismissNaviViewControllerAnimated:YES];
}


- (void)naviManagerNeedRecalculateRouteForYaw:(AMapNaviManager *)naviManager
{
    NSLog(@"NeedReCalculateRouteForYaw");
}

- (void)naviManager:(AMapNaviManager *)naviManager didStartNavi:(AMapNaviMode)naviMode
{
    NSLog(@"didStartNavi");
}

- (void)naviManagerDidEndEmulatorNavi:(AMapNaviManager *)naviManager
{
    NSLog(@"DidEndEmulatorNavi");
}

- (void)naviManagerOnArrivedDestination:(AMapNaviManager *)naviManager
{
    NSLog(@"OnArrivedDestination");
}

- (void)naviManager:(AMapNaviManager *)naviManager onArrivedWayPoint:(int)wayPointIndex
{
    NSLog(@"onArrivedWayPoint");
}

- (void)naviManager:(AMapNaviManager *)naviManager didUpdateNaviLocation:(AMapNaviLocation *)naviLocation
{
    //    NSLog(@"didUpdateNaviLocation");
}

- (void)naviManager:(AMapNaviManager *)naviManager didUpdateNaviInfo:(AMapNaviInfo *)naviInfo
{
    //    NSLog(@"didUpdateNaviInfo");
}

- (BOOL)naviManagerGetSoundPlayState:(AMapNaviManager *)naviManager
{
    //    NSLog(@"GetSoundPlayState");
    
    return 0;
}

- (void)naviManager:(AMapNaviManager *)naviManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType
{
    NSLog(@"playNaviSoundString:{%ld:%@}", (long)soundStringType, soundString);
    
    if (soundStringType == AMapNaviSoundTypePassedReminder)
    {
        //用系统自带的声音做简单例子，播放其他提示音需要另外配置
//        AudioServicesPlaySystemSound(1009);
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [_iFlySpeechSynthesizer startSpeaking:soundString];
        });
    }
}

- (void)naviManagerDidUpdateTrafficStatuses:(AMapNaviManager *)naviManager
{
    NSLog(@"DidUpdateTrafficStatuses");
}

#pragma mark - MACombox Delegate

- (void)dropMenuWillHide:(MACombox *)combox
{
    [self.view sendSubviewToBack:combox];
}


- (void)dropMenuWillShow:(MACombox *)combox
{
    [self.view bringSubviewToFront:combox];
    
    [_startPointCombox hideDropMenu];
    [_endPointCombox   hideDropMenu];
    [_wayPointCombox   hideDropMenu];
    [_strategyCombox   hideDropMenu];
}


- (void)maCombox:(MACombox *)macombox didSelectItem:(NSString *)item
{
    if (macombox == _startPointCombox)
    {
        if ([item isEqualToString:@"地图选点"])
        {
            _selectPointState = MapSelectPointStateStartPoint;
            
            _wayPointCombox.inputTextField.text = @"";
            _endPointCombox.inputTextField.text = @"";
            
            _startCurrLoc = NO;
        }
        else if ([item isEqualToString:@"使用当前位置"])
        {
            if (_beginAnnotation)
            {
                [self.mapView removeAnnotation:_beginAnnotation];
                _beginAnnotation = nil;
            }
            _startCurrLoc = YES;
            if (_selectPointState == MapSelectPointStateStartPoint)
            {
                _selectPointState = MapSelectPointStateNone;
            }
        }
        else
        {
            _startCurrLoc = NO;
            if (_selectPointState == MapSelectPointStateStartPoint)
            {
                _selectPointState = MapSelectPointStateNone;
            }
        }
    }
    else if (macombox == _wayPointCombox)
    {
        if ([item isEqualToString:@"地图选点"])
        {
            _selectPointState = MapSelectPointStateWayPoint;
            
            if (!_startCurrLoc) _startPointCombox.inputTextField.text = @"";
            _endPointCombox.inputTextField.text = @"";
        }
        else
        {
            if (_selectPointState == MapSelectPointStateWayPoint)
            {
                _selectPointState = MapSelectPointStateNone;
            }
        }
    }
    else if (macombox == _endPointCombox)
    {
        if ([item isEqualToString:@"地图选点"])
        {
            _selectPointState = MapSelectPointStateEndPoint;
            
            if (!_startCurrLoc) _startPointCombox.inputTextField.text = @"";
            _wayPointCombox.inputTextField.text = @"";
        }
        else
        {
            if (_selectPointState == MapSelectPointStateEndPoint)
            {
                _selectPointState = MapSelectPointStateNone;
            }
        }
    }
}

#pragma mark - MoreMenuView Delegate

- (void)moreMenuViewFinishButtonClicked
{
    [_moreMenuView removeFromSuperview];
    
    _moreMenuView.delegate = nil;
    _moreMenuView = nil;
}

- (void)moreMenuViewViewModeChangeTo:(AMapNaviViewShowMode)viewShowMode
{
    if (self.naviViewController)
    {
        [self.naviViewController setViewShowMode:viewShowMode];
    }
}

- (void)moreMenuViewNightTypeChangeTo:(BOOL)isShowNightType
{
    if (self.naviViewController)
    {
        [self.naviViewController setShowStandardNightType:isShowNightType];
    }
}
#pragma mark - AManNaviViewController Delegate

- (void)naviViewControllerCloseButtonClicked:(AMapNaviViewController *)naviViewController
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.iFlySpeechSynthesizer stopSpeaking];
    });
    
    [self.naviManager stopNavi];
    
    
    [self.naviManager dismissNaviViewControllerAnimated:YES];
}

- (void)naviViewControllerMoreButtonClicked:(AMapNaviViewController *)naviViewController
{
    if (naviViewController.viewShowMode == AMapNaviViewShowModeCarNorthDirection)
    {
        naviViewController.viewShowMode = AMapNaviViewShowModeMapNorthDirection;
    }
    else
    {
        naviViewController.viewShowMode = AMapNaviViewShowModeCarNorthDirection;
    }
}

- (void)naviViewControllerTurnIndicatorViewTapped:(AMapNaviViewController *)naviViewController
{
    [self.naviManager readNaviInfoManual];
}

#pragma mark - Utility

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

/* 清除annotation. */
- (void)clear {
    [self.mapView removeAnnotations:self.mapView.annotations];
}

- (void)clearAndSearchGeocodeWithKey:(NSString *)key {
    /* 清除annotation. */
    [self clear];
    
    [self searchGeocodeWithKey:key];
}

- (void)gotoDetailForGeocode:(AMapGeocode *)geocode {
    if (geocode != nil)
    {
        NSLog(@"%f,%f",geocode.location.latitude,geocode.location.longitude);
        GeoDetailViewController *geoDetailViewController = [[GeoDetailViewController alloc] init];
        geoDetailViewController.geocode = geocode;
        
        [self.navigationController pushViewController:geoDetailViewController animated:YES];
    }
}
#pragma mark - AMapSearchDelegate

/* 地理编码回调.*/
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response {
    if (response.geocodes.count == 0) return;
    
    NSMutableArray *annotations = [NSMutableArray array];
    
    [response.geocodes enumerateObjectsUsingBlock:^(AMapGeocode *obj, NSUInteger idx, BOOL *stop) {
        GeocodeAnnotation *geocodeAnnotation = [[GeocodeAnnotation alloc] initWithGeocode:obj];
        
        [annotations addObject:geocodeAnnotation];
    }];
    
    if (annotations.count == 1)
    {
        GeocodeAnnotation *geocodeAnnotation = annotations[0];
        [self.mapView setCenterCoordinate:geocodeAnnotation.coordinate animated:YES];
    }
    else
    {
        [self.mapView setVisibleMapRect:[CommonUtility minMapRectForAnnotations:annotations]
                               animated:YES];
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
        self.mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading;
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
    
}


#pragma mark - iFlySpeechSynthesizer Delegate

- (void)onCompleted:(IFlySpeechError *)error
{
    NSLog(@"Speak Error:{%d:%@}", error.errorCode, error.errorDesc);
}
#pragma mark - Life Cycle

- (id)init {
    if (self = [super init]) {
        self.tips = [NSMutableArray array];
    }
    return self;
}
@end
