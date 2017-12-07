//
//  PlayerInterface.h
//  破音万里
//
//  Created by Purchas on 2017/3/13.
//  Copyright © 2017年 Purchas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTInfiniteScrollView.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>

@interface PlayerInterface : ASDisplayNode

@property (nonatomic, strong) NSArray* tracks;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) LTInfiniteScrollView *coverScroll;
@property (nonatomic, weak)	  UILabel *album;
@property (nonatomic, strong) NSString* type;
@property (nonatomic, assign) int playlistID;


- (void)playTracks:(NSArray *)tracks index:(NSInteger)index;
- (void)playOrPause;
- (void)playNext;
- (void)playPrevious;
- (void)doSeeking:(UILongPressGestureRecognizer*)recognizer;
- (void)playShuffle:(UISwipeGestureRecognizer*)recognizer;
- (void)singleRewind;
- (void)showLyrics;
- (void)shareToWechat:(int)scene;
@end
