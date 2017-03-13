//
//  PlayerInterface.h
//  破音万里
//
//  Created by Purchas on 2017/3/13.
//  Copyright © 2017年 Purchas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTInfiniteScrollView.h"

@interface PlayerInterface : UIView

@property (nonatomic, strong) NSArray *tracks;
@property (nonatomic, assign) int *index;
@property (nonatomic, strong) LTInfiniteScrollView *coverScroll;
@property (nonatomic, weak) UILabel *album;
@property (nonatomic, assign) NSString* type;


+ (PlayerInterface *) sharedInstance;
- (void)playTracks:(NSArray *)tracks index:(int)index;

@end
