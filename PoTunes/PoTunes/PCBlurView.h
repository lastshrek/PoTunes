//
//  PCBlurView.h
//  破音万里
//
//  Created by Purchas on 11/7/15.
//  Copyright © 2015 Purchas. All rights reserved.
//


#import "DRNRealTimeBlurView.h"


@interface PCBlurView : DRNRealTimeBlurView

@property (nonatomic, copy) NSString *lrcName;

@property (nonatomic, copy) NSString *chLrcName;

@property (nonatomic, assign) NSTimeInterval currentTime;

@property (nonatomic, weak) UILabel *noLrcLabel;



@end
