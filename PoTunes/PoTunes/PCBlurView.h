//
//  PCBlurView.h
//  破音万里
//
//  Created by Purchas on 11/7/15.
//  Copyright © 2015 Purchas. All rights reserved.
//

#import "FXBlurView.h"

#import "FXBlurView.h"

@interface PCBlurView : UIView

@property (nonatomic, copy) NSString *lrcName;

@property (nonatomic, copy) NSString *chLrcName;

@property (nonatomic, assign) NSTimeInterval currentTime;

@property (nonatomic, weak) UILabel *noLrcLabel;

@property (nonatomic, weak) FXBlurView *blurView;
@end
