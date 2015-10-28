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
#import "SharedMapView.h"
#import <AVFoundation/AVFoundation.h>
#import "Common.h"
#import "MBProgressHUD+MJ.h"
typedef NS_ENUM(NSInteger, TravelTypes) {
    TravelTypeCar = 0,      // 驾车方式
    TravelTypeWalk,         // 步行方式
};

@interface PCNaviController() <MAMapViewDelegate, AMapNaviManagerDelegate, AMapNaviViewControllerDelegate, PCBaiduNavControllerDelegate, AVSpeechSynthesizerDelegate>


@property (nonatomic, weak) MAMapView *mapView;
@property (nonatomic, strong) AMapNaviManager *naviManager;
@property (nonatomic, strong) AMapNaviViewController *naviViewController;
@property (nonatomic, strong) AMapNaviPoint *startPoint;
@property (nonatomic, strong) AMapNaviPoint *endPoint;
@property (nonatomic, strong) NSTimer *currentTimer;
@property (nonatomic, strong) AVSpeechSynthesizer *player;
@property (nonatomic) TravelTypes travelType;
@property (nonatomic, weak) UISegmentedControl *segmentedDrivingStrategy;
@property (nonatomic, weak) UIButton *navBtn;
@property (nonatomic, weak) UIButton *startBtn;
@property (nonatomic, weak) UIButton *endBtn;


@property (nonatomic, assign) AMapNaviDrivingStrategy drivingStrategy;

@end

@implementation PCNaviController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    [MAMapServices sharedServices].apiKey = @"62443358a250ee522aba69dfa3c1d247";
    [AMapNaviServices sharedServices].apiKey = @"62443358a250ee522aba69dfa3c1d247";
    [self initNaviManager];
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
- (void)configSubViews {
    
    CGFloat width = self.view.bounds.size.width - 20 * 2;
    CGFloat height = self.view.bounds.size.height;
    
    //出行方式
    UISegmentedControl *segmentedTravleType = [[UISegmentedControl alloc] initWithItems:@[@"驾车", @"步行"]];
    segmentedTravleType.frame = CGRectMake(20, 60, width, 50);
    segmentedTravleType.selectedSegmentIndex = 0;
    segmentedTravleType.tintColor = PCColor(207, 22, 232, 1.0);
    [segmentedTravleType addTarget:self action:@selector(travelTypeChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedTravleType];
    
    UISegmentedControl *segmentedDrivingStrategy = [[UISegmentedControl alloc] initWithItems:@[@"速度优先", @"路况优先"]];
    segmentedDrivingStrategy.frame = CGRectMake(20, CGRectGetMaxY(segmentedTravleType.frame) + 30, width, 50);
    segmentedDrivingStrategy.selectedSegmentIndex = 0;
    segmentedDrivingStrategy.tintColor = PCColor(207, 22, 232, 1.0);
    [segmentedDrivingStrategy addTarget:self action:@selector(drivingStrategyChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentedDrivingStrategy];
    self.segmentedDrivingStrategy = segmentedDrivingStrategy;
    
    UIButton *startBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(segmentedDrivingStrategy.frame) + 30, width, 50)];
    [startBtn setTitle:@"我的位置" forState:UIControlStateNormal];
    [startBtn setTitleColor:PCColor(207, 22, 232, 1.0) forState:UIControlStateNormal];
    startBtn.titleLabel.font = [UIFont fontWithName:@"BebasNeue.otf" size:16];
    startBtn.layer.borderColor  = PCColor(207, 22, 232, 1.0).CGColor;
    startBtn.layer.borderWidth  = 0.5;
    startBtn.layer.cornerRadius = 5;
    [startBtn addTarget:self action:@selector(location:) forControlEvents:UIControlEventTouchUpInside];
    startBtn.tag = 1;
    [self.view addSubview:startBtn];
    self.startBtn = startBtn;
    
    
    UIButton *endBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(startBtn.frame) + 30, width, 50)];
    [endBtn setTitle:@"目的地" forState:UIControlStateNormal];
    [endBtn setTitleColor:PCColor(207, 22, 232, 1.0) forState:UIControlStateNormal];
    endBtn.titleLabel.font = [UIFont fontWithName:@"BebasNeue.otf" size:16];
    endBtn.layer.borderColor  = PCColor(207, 22, 232, 1.0).CGColor;
    endBtn.layer.borderWidth  = 0.5;
    endBtn.layer.cornerRadius = 5;
    endBtn.tag = 2;
    self.endBtn = endBtn;
    [endBtn addTarget:self action:@selector(location:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:endBtn];
    
    
    UIButton *navBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    navBtn.layer.borderColor  = PCColor(207, 22, 232, 1.0).CGColor;
    navBtn.layer.borderWidth  = 0.5;
    navBtn.layer.cornerRadius = 5;
    
    [navBtn setFrame:CGRectMake(20, height - 80, width, 50)];
    [navBtn setTitle:@"开始导航" forState:UIControlStateNormal];
    [navBtn setTitleColor:PCColor(207, 22, 232, 1.0) forState:UIControlStateNormal];
    navBtn.titleLabel.font = [UIFont fontWithName:@"BebasNeue.otf" size:16];
    self.navBtn = navBtn;
    [navBtn addTarget:self action:@selector(startGPSNavi:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:navBtn];
}
- (void)configNaviViewController {
    
    [_naviViewController setShowUIElements:YES];

}


#pragma mark - Button Action

- (void)travelTypeChanged:(id)item {

    UISegmentedControl *segCtrl = (UISegmentedControl *)item;

    TravelTypes travelType = segCtrl.selectedSegmentIndex;
    if (travelType != self.travelType) {
        self.travelType = travelType;
    }
    if (segCtrl.selectedSegmentIndex == 1) {
        self.segmentedDrivingStrategy.hidden = YES;
    } else {
        self.segmentedDrivingStrategy.hidden = NO;
    }
}

- (void)drivingStrategyChanged:(id)item {
    
    UISegmentedControl *segCtrl = (UISegmentedControl *)item;
    
    switch (segCtrl.selectedSegmentIndex) {
        case 0:
            self.drivingStrategy = AMapNaviDrivingStrategyDefault;
            break;
            
//            AMapNaviDrivingStrategyDefault = 0,             //0 速度优先
//            AMapNaviDrivingStrategySaveMoney = 1,           //1 费用优先
//            AMapNaviDrivingStrategyShortDistance = 2,       //2 距离优先
//            AMapNaviDrivingStrategyNoExpressways = 3,       //3 普通路优先（不走快速路、高速路）
//            AMapNaviDrivingStrategyFastestTime = 4,         //4 时间优先，躲避拥堵
//            AMapNaviDrivingStrategyAvoidCongestion = 12,    //12 躲避拥堵且不走收费道路.注意：当选择驾车策略12（躲避拥堵且不走收费道路）进行路径规划时，返回的策略值为4（时间优先，躲避拥堵）
            
            
        default:
            self.drivingStrategy = AMapNaviDrivingStrategyFastestTime;
            break;
    }
}

- (void)location:(UIButton *)btn {
    
    PCBaiduNavController *baidu = [[PCBaiduNavController alloc] init];
    baidu.delegate = self;
    baidu.title = btn.titleLabel.text;
    baidu.view.tag = btn.tag;
    [self.navigationController pushViewController:baidu animated:YES];
    
}

- (void)startGPSNavi:(UIButton *)button {
    // 算路
    if ([self.endBtn.titleLabel.text isEqualToString:@"目的地"]) {
        
        [MBProgressHUD showError:@"请选择目的地位置"];
        
    } else {
        
        if ([button.currentTitle isEqualToString:@"开始导航"]) {
            [self calculateRoute];
        } else {
            [self.naviManager presentNaviViewController:self.naviViewController animated:YES];
        }
        
        
    }
}

- (void)calculateRoute {
    
    NSArray *startPoints = @[_startPoint];
    NSArray *endPoints   = @[_endPoint];
    
    if (self.travelType == 0) {
        
            [self.naviManager calculateDriveRouteWithStartPoints:startPoints
                                                       endPoints:endPoints
                                                       wayPoints:nil
                                                 drivingStrategy:self.drivingStrategy];
    } else {
        
        [self.naviManager calculateWalkRouteWithStartPoints:startPoints
                                                  endPoints:endPoints];
    }
}


#pragma mark - AMapNaviManager Delegate

- (void)naviManager:(AMapNaviManager *)naviManager didPresentNaviViewController:(UIViewController *)naviViewController {
    
//    [self.naviManager startEmulatorNavi];
    
    [self.naviManager startGPSNavi];

    
    [self.navBtn setTitle:@"继续导航" forState:UIControlStateNormal];
}

- (void)naviManagerOnCalculateRouteSuccess:(AMapNaviManager *)naviManager {
    
    [self.naviManager presentNaviViewController:self.naviViewController animated:YES];
}

- (void)naviManager:(AMapNaviManager *)naviManager onCalculateRouteFailure:(NSError *)error {
}


- (void)naviManager:(AMapNaviManager *)naviManager didUpdateNaviInfo:(AMapNaviInfo *)naviInfo
{
    
}
//语音播报
- (void)naviManager:(AMapNaviManager *)naviManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType {

    AVSpeechSynthesizer *player = [[AVSpeechSynthesizer alloc] init];
    player.delegate = self;
    self.player = player;
    AVSpeechUtterance *utterance = [[AVSpeechUtterance alloc] initWithString:soundString];
    utterance.voice = [AVSpeechSynthesisVoice voiceWithLanguage:@"zh-TW"];
    utterance.volume = 1.0;
    utterance.rate = 0.8;
    utterance.pitchMultiplier = 0.7;
    [player speakUtterance:utterance];
    
}
#pragma mark - AManNaviViewController Delegate

- (void)naviViewControllerCloseButtonClicked:(AMapNaviViewController *)naviViewController {
    
    [self.naviManager stopNavi];
    
    [self.naviManager dismissNaviViewControllerAnimated:YES];
    
    [self.player stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    
    [self.navBtn setTitle:@"开始导航" forState:UIControlStateNormal];

}

- (void)naviViewControllerMoreButtonClicked:(AMapNaviViewController *)naviViewController {
    
    [self.naviManager dismissNaviViewControllerAnimated:YES];

}
#pragma mark - iFlySpeechSynthesizer Delegate
//语音开始播放发送通知
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didStartSpeechUtterance:(AVSpeechUtterance *)utterance {
    
    NSNotification *speaking = [NSNotification notificationWithName:@"speaking" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:speaking];

}
//语音播放结束发送通知
- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance {

    NSNotification *nonspeaking = [NSNotification notificationWithName:@"nonspeaking" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:nonspeaking];

}


#pragma mark - PCBaiduNavControllerDelegate

- (void)navController:(PCBaiduNavController *)navController didClickTheAnnotationAccessoryControlBySendingUserLocation:(CLLocationCoordinate2D)userLocation andDestinationLocation:(CLLocationCoordinate2D)destinationLocation mapView:(MAMapView *)mapView title:(NSString *)title destinationTitle:(NSString *)destinationTitle {
        
    if ([title isEqualToString:self.startBtn.titleLabel.text]) {
        
        [self.startBtn setTitle:destinationTitle forState:UIControlStateNormal];
        self.startPoint = [AMapNaviPoint locationWithLatitude:userLocation.latitude longitude:userLocation.longitude];

    } else {
        
        [self.endBtn setTitle:destinationTitle forState:UIControlStateNormal];
        self.endPoint = [AMapNaviPoint locationWithLatitude:destinationLocation.latitude longitude:destinationLocation.longitude];
        if (self.startPoint == nil) {
            self.startPoint = [AMapNaviPoint locationWithLatitude:userLocation.latitude longitude:userLocation.longitude];
        }

    }
    
    self.naviViewController = [[AMapNaviViewController alloc] initWithMapView:mapView delegate:self];
    
}

@end
