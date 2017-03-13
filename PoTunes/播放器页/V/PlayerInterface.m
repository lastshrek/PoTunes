//
//  PlayerInterface.m
//  破音万里
//
//  Created by Purchas on 2017/3/13.
//  Copyright © 2017年 Purchas. All rights reserved.
//

#import "PlayerInterface.h"


/** 播放模式 */
typedef NS_ENUM(NSUInteger, PCAudioRepeatMode) {
	PCAudioRepeatModeSingle,
	PCAudioRepeatModePlaylist,
	PCAudioRepeatModeTowards,
	PCAudioRepeatModeShuffle
};
/** 播放操作 */
typedef NS_ENUM(NSUInteger, PCAudioPlayState) {
	PCAudioPlayStatePlay,
	PCAudioPlayStatePause,
	PCAudioPlayStateNext,
	PCAudioPlayStatePrevious,
};

@interface PlayerInterface()

@property (nonatomic, weak) UIView *backgroundView;
@property (nonatomic, weak) UIImageView *reflection;



@end

@implementation PlayerInterface

static PlayerInterface *sharedInstance = nil;

+ (PlayerInterface *)sharedInstance {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init] ;
	});
	return sharedInstance;
}

- (void)playTracks:(NSArray *)tracks index:(int)index {
	
}


@end
