//
//  NavPointAnnotation.h
//  officialDemoNavi
//
//  Created by LiuX on 14-8-26.
//  Copyright (c) 2014年 AutoNavi. All rights reserved.
//

#import <AMapNaviKit/MAPointAnnotation.h>

typedef NS_ENUM(NSInteger, NavPointAnnotationType)
{
    NavPointAnnotationStart,
    NavPointAnnotationWay,
    NavPointAnnotationEnd
};

@interface NavPointAnnotation : MAPointAnnotation

@property (nonatomic, assign) NavPointAnnotationType navPointType;

@end
