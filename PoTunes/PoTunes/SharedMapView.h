//
//  SharedMapView.h
//  officialDemoNavi
//
//  Created by 刘博 on 15/5/26.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapNaviKit/MAMapKit.h>

@interface SharedMapView : NSObject

@property (nonatomic, readonly) MAMapView *mapView;

+ (instancetype)sharedInstance;

- (void)stashMapViewStatus;
- (void)popMapViewStatus;

@end
