//
//  PCNaviController.m
//  PoTunes
//
//  Created by Purchas on 15/9/15.
//  Copyright © 2015年 Purchas. All rights reserved.
//

#import "PCNaviController.h"
#import "PCBaiduNavController.h"
#import <AMapNaviKit/AMapNaviKit.h>
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"
#import "iflyMSC/IFlySpeechError.h"
#import "SharedMapView.h"


@interface PCNaviController() <MAMapViewDelegate, AMapNaviManagerDelegate, IFlySpeechSynthesizerDelegate, AMapNaviViewControllerDelegate, PCBaiduNavControllerDelegate>

//@property (nonatomic, weak) MAMapView *mapView;
//@property (nonatomic, weak) UISearchBar *searchBar;
//@property (nonatomic, strong) AMapSearchAPI *search;
//@property (nonatomic, strong) AMapNaviViewController *naviViewController;
//@property (nonatomic, strong) AMapNaviManager *naviManager;
//@property (nonatomic, strong) IFlySpeechSynthesizer *iFlySpeechSynthesizer;
//
//
////用户位置
//@property (nonatomic, strong) MAUserLocation *userLocation;
//@property (nonatomic, weak) UITableView *tableView;
//@property (nonatomic, strong) NSMutableArray *tips;
//
@property (nonatomic, weak) MAMapView *mapView;

@property (nonatomic, strong) AMapNaviManager *naviManager;

@property (nonatomic, strong) IFlySpeechSynthesizer *iFlySpeechSynthesizer;
@property (nonatomic, strong) AMapNaviViewController *naviViewController;

@property (nonatomic, strong) AMapNaviPoint* startPoint;
@property (nonatomic, strong) AMapNaviPoint* endPoint;
@property (nonatomic, strong) NSTimer *currentTimer;


@end

@implementation PCNaviController

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [MAMapServices sharedServices].apiKey = @"62443358a250ee522aba69dfa3c1d247";
    [AMapNaviServices sharedServices].apiKey = @"62443358a250ee522aba69dfa3c1d247";
    [self initMapView];
    
    [self initNaviManager];
    
    [self initIFlySpeech];
    
    [self initNaviViewController];
    
    [self configSubViews];
    
    [self configNaviViewController];
    
    

}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self clearMapView];
}

#pragma mark - Utility

- (void)clearMapView {
    
    self.mapView.showsUserLocation = NO;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    [self.mapView removeOverlays:self.mapView.overlays];
    
    self.mapView.delegate = nil;
    
    [[SharedMapView sharedInstance] popMapViewStatus];
}

#pragma mark - Init & Construct

- (void)initMapView {
    
    if (self.mapView == nil) {
        self.mapView = [[SharedMapView sharedInstance] mapView];
    }
    
    [[SharedMapView sharedInstance] stashMapViewStatus];
    
    self.mapView.frame = self.view.bounds;
    
    self.mapView.delegate = self;
    
    self.mapView.showsUserLocation = YES;
}
- (void)initNaviManager {
    if (self.naviManager == nil) {
        _naviManager = [[AMapNaviManager alloc] init];
    }
    
    self.naviManager.delegate = self;
}
- (void)initIFlySpeech {
    if (self.iFlySpeechSynthesizer == nil) {
        _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    }
    
    _iFlySpeechSynthesizer.delegate = self;
}
- (void)initNaviViewController {
    if (_naviViewController == nil) {
        _naviViewController = [[AMapNaviViewController alloc] initWithMapView:self.mapView delegate:self];
    }
}
- (void)configSubViews {
    UIButton *startBtn = [[UIButton alloc] initWithFrame:CGRectMake(60, 100, 200, 30)];
    [startBtn setTitle:@"我的位置" forState:UIControlStateNormal];
    [startBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    startBtn.titleLabel.font = [UIFont fontWithName:@"BebasNeue.otf" size:16];
    startBtn.layer.borderColor  = [UIColor lightGrayColor].CGColor;
    startBtn.layer.borderWidth  = 0.5;
    startBtn.layer.cornerRadius = 5;
    [startBtn addTarget:self action:@selector(location:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startBtn];
    
    
    UIButton *endBtn = [[UIButton alloc] initWithFrame:CGRectMake(60, 150, 200, 30)];
    [endBtn setTitle:@"目的地" forState:UIControlStateNormal];
    [endBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    endBtn.titleLabel.font = [UIFont fontWithName:@"BebasNeue.otf" size:16];
    endBtn.layer.borderColor  = [UIColor lightGrayColor].CGColor;
    endBtn.layer.borderWidth  = 0.5;
    endBtn.layer.cornerRadius = 5;
    [endBtn addTarget:self action:@selector(location:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:endBtn];
    
    
    UIButton *navBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    navBtn.layer.borderColor  = [UIColor lightGrayColor].CGColor;
    navBtn.layer.borderWidth  = 0.5;
    navBtn.layer.cornerRadius = 5;
    
    [navBtn setFrame:CGRectMake(60, 200, 200, 30)];
    [navBtn setTitle:@"开始导航" forState:UIControlStateNormal];
    [navBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    navBtn.titleLabel.font = [UIFont fontWithName:@"BebasNeue.otf" size:16];
    
    [navBtn addTarget:self action:@selector(startGPSNavi:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:navBtn];
}
- (void)configNaviViewController {
    [_naviViewController setShowUIElements:NO];
    
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    backButton.layer.borderColor  = [UIColor lightGrayColor].CGColor;
    backButton.layer.borderWidth  = 0.5;
    backButton.layer.cornerRadius = 5;
    
    [backButton setFrame:CGRectMake(60, 210, 200, 30)];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton setBackgroundColor:[UIColor whiteColor]];
    backButton.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    
    [backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [_naviViewController.view addSubview:backButton];

}

#pragma mark - 添加定时器
- (void)addCurrentTimeTimer {
    [self removeCurrentTimeTimer];
    //保证定时器的工作是即时的
    [self updateCurrentTime];
    self.currentTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCurrentTime) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.currentTimer forMode:NSRunLoopCommonModes];
    
}

- (void)removeCurrentTimeTimer {
    [self.currentTimer invalidate];
    self.currentTimer = nil;
}
- (void)updateCurrentTime {
//    NSLog(@"%d",self.iFlySpeechSynthesizer.isSpeaking);
    if (self.iFlySpeechSynthesizer.isSpeaking) {
       
    } else {
           }
    
}
#pragma mark - Button Action

- (void)location:(UIButton *)btn {
    PCBaiduNavController *baidu = [[PCBaiduNavController alloc] init];
    [self.navigationController pushViewController:baidu animated:YES];
    baidu.delegate = self;
}

- (void)startGPSNavi:(id)sender {
    // 算路
    [self calculateRoute];
}

- (void)calculateRoute {
    NSArray *startPoints = @[_startPoint];
    NSArray *endPoints   = @[_endPoint];
    
    [self.naviManager calculateDriveRouteWithStartPoints:startPoints endPoints:endPoints wayPoints:nil drivingStrategy:0];
}

- (void)backButtonAction
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.iFlySpeechSynthesizer stopSpeaking];
        [self removeCurrentTimeTimer];
    });
    
    [self.naviManager stopNavi];
    
    [self.naviManager dismissNaviViewControllerAnimated:YES];
}
#pragma mark - AMapNaviManager Delegate




- (void)naviManager:(AMapNaviManager *)naviManager didPresentNaviViewController:(UIViewController *)naviViewController {
    
    [self.naviManager startEmulatorNavi];
}

- (void)naviManagerOnCalculateRouteSuccess:(AMapNaviManager *)naviManager
{
    [self.naviManager presentNaviViewController:self.naviViewController animated:YES];
}

- (void)naviManager:(AMapNaviManager *)naviManager onCalculateRouteFailure:(NSError *)error {
}


- (void)naviManager:(AMapNaviManager *)naviManager didUpdateNaviInfo:(AMapNaviInfo *)naviInfo
{
    
//    [_naviInfoLabel setText:[NSString stringWithFormat:@"%@", naviInfo]];
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
#pragma mark - AManNaviViewController Delegate

- (void)naviViewControllerCloseButtonClicked:(AMapNaviViewController *)naviViewController
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self.iFlySpeechSynthesizer stopSpeaking];
    });
    
    [self.naviManager stopNavi];
    
    [self.naviManager dismissNaviViewControllerAnimated:YES];
}

#pragma mark - iFlySpeechSynthesizer Delegate

- (void)synthesize:(NSString *)text toUri:(NSString*)uri {
    NSNotification *nonspeaking = [NSNotification notificationWithName:@"nonspeaking" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:nonspeaking];
}


- (void)onCompleted:(IFlySpeechError *)error
{
    NSNotification *bug = [NSNotification notificationWithName:@"bug" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:bug];
    
}
- (void) onSpeakBegin {
    NSNotification *speaking = [NSNotification notificationWithName:@"speaking" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:speaking];
}

- (void) onSpeakProgress:(int) progress {
    if (progress == 100) {
        NSNotification *nonspeaking = [NSNotification notificationWithName:@"nonspeaking" object:nil userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:nonspeaking];
    }
}
#pragma mark - PCBaiduNavControllerDelegate

- (void)navController:(PCBaiduNavController *)navController didClickTheAnnotationAccessoryControlBySendingUserLocation:(AMapNaviPoint *)userLocation andDestinationLocation:(CLLocationCoordinate2D)destinationLocation {
    self.startPoint = [AMapNaviPoint locationWithLatitude:userLocation.latitude longitude:userLocation.longitude];
    self.endPoint   = [AMapNaviPoint locationWithLatitude:destinationLocation.latitude longitude:destinationLocation.longitude];

}

@end
