//
//  PCBaiduNavController.h
//  PoTunes
//
//  Created by Purchas on 15/9/12.
//  Copyright © 2015年 Purchas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapNaviKit/AMapNaviKit.h>
#import <AMapNaviKit/MAMapKit.h>


@class PCBaiduNavController;

@protocol PCBaiduNavControllerDelegate <NSObject>

@optional

- (void)navController:(PCBaiduNavController *)navController didClickTheAnnotationAccessoryControlBySendingUserLocation:(CLLocationCoordinate2D)userLocation andDestinationLocation:(CLLocationCoordinate2D)destinationLocation mapView:(MAMapView *)mapView title:(NSString *)title destinationTitle:(NSString *)destinationTitle;

@end

@interface PCBaiduNavController : UIViewController

@property (nonatomic, weak) id<PCBaiduNavControllerDelegate> delegate;


@end
