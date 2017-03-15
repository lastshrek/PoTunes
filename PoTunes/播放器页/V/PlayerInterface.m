//
//  PlayerInterface.m
//  破音万里
//
//  Created by Purchas on 2017/3/13.
//  Copyright © 2017年 Purchas. All rights reserved.
//

#import "PlayerInterface.h"
#import "LDProgressView.h"
#import "UIImage+Reflection.h"
#import "PotunesRemix-swift.h"
#import "FSAudioController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Reachability.h"
#import "FMDB.h"
#import <SVProgressHUD/SVProgressHUD.h>

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

@interface PlayerInterface()<LTInfiniteScrollViewDelegate, LTInfiniteScrollViewDataSource, UIApplicationDelegate>

@property (nonatomic, weak) UIView* backgroundView;
@property (nonatomic, weak) UIImageView* reflection;
@property (nonatomic, weak) LDProgressView* progress;
@property (nonatomic, weak) LDProgressView* bufferingIndicator;
@property (nonatomic, weak) UIView* timeView;
@property (nonatomic, weak) UILabel* currentTime;
@property (nonatomic, weak) UILabel* leftTime;
@property (nonatomic, weak) TrackLabel* name;
@property (nonatomic, weak) TrackLabel* artist;
@property (nonatomic, weak) UIImageView* playModeView;
@property (nonatomic, weak) LrcView* lrcView;
@property (nonatomic, weak) UIImageView* nowCover;
@property (nonatomic, weak) UIColor* currentProgressColor;

@property (nonatomic, assign) CGFloat progressOriginal;
@property (nonatomic, assign) CGPoint originalPoint;
@property (nonatomic, assign) PCAudioPlayState repeatMode;
@property (nonatomic, assign) Boolean paused;
@property (nonatomic, assign) CGFloat maxPrebufferedByteCount;


@property (nonatomic, strong) FSAudioController* streamer;
@property (nonatomic, strong) NSTimer* currentTimeTimer;
@property (nonatomic, strong) NSTimer* playbackTimer;
@property (nonatomic, strong) CADisplayLink* lrcTimer;
@property (nonatomic, strong) FMDatabase* tracksDB;


@end

@implementation PlayerInterface

- (FMDatabase*)tracksDB {
	if (_tracksDB == nil) {
		NSString* path = [NSString stringWithFormat:@"%@/downloadingSong.db", [self dirDoc]];
		FMDatabase* db = [FMDatabase databaseWithPath:path];
		[db open];
		_tracksDB = db;
	}
	return _tracksDB;
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self setup];
	}
	return self;
}

- (void)setup {
	
	[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	
	[self initialSubviews];
	[self addGestureRecognizer];
	
}

#pragma mark - initialSubViews
- (void)initialSubviews {
	self.streamer = [[FSAudioController alloc] init];
	self.currentProgressColor = [UIColor whiteColor];
	self.streamer = [[FSAudioController alloc] init];
	self.repeatMode = PCAudioRepeatModeTowards;
	self.paused = true;
	//底
	UIView *backgroundView = [[UIView alloc] init];
	backgroundView.backgroundColor = [UIColor blackColor];
	[self addSubview:backgroundView];
	self.backgroundView = backgroundView;
	//倒影封面
	UIImageView *reflection = [[UIImageView alloc] init];
	reflection.image = [[UIImage imageNamed:@"noArtwork"] reflectionWithAlpha:0.4];
	[self.backgroundView addSubview:reflection];
	[self.backgroundView sendSubviewToBack:reflection];
	//封面队列
	LTInfiniteScrollView *coverScroll = [[LTInfiniteScrollView alloc] init];
	coverScroll.delegate = self;
	coverScroll.dataSource = self;
	coverScroll.maxScrollDistance = 2;
	[coverScroll reloadDataWithInitialIndex:0];
	[self.backgroundView addSubview:coverScroll];
	self.coverScroll = coverScroll;
	//缓冲条
	LDProgressView* bufferingIndicator = [self createProgressViewByShowBackground:@YES type:LDProgressSolid backgroundColor:[UIColor blackColor]];
	[self.backgroundView addSubview:bufferingIndicator];
	self.bufferingIndicator = bufferingIndicator;
	
	//进度条
	LDProgressView* progress = [self createProgressViewByShowBackground:@NO type:LDProgressSolid backgroundColor:[UIColor clearColor]];
	[self.backgroundView addSubview:progress];
	self.progress = progress;
	//开始时间和剩余时间
	UIView* timeView = [[UIView alloc] init];
	[self.backgroundView addSubview:timeView];
	self.timeView = timeView;
	//当前播放时间
	UILabel* currentTime = [self createLabelByAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin
												  shadowOffset:CGSizeMake(0, 0)
													 textColor:[UIColor whiteColor]
														  text:nil
												 textAlignment:NSTextAlignmentLeft];
	[self.timeView addSubview:currentTime];
	self.currentTime = currentTime;
	//剩余时间
	UILabel* leftTime = [self createLabelByAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin
												  shadowOffset:CGSizeMake(0, 0)
													 textColor:[UIColor whiteColor]
														  text:nil
												 textAlignment:NSTextAlignmentRight];
	[self.timeView addSubview:leftTime];
	self.leftTime = leftTime;
	/** 歌曲名 */
	TrackLabel* name = [[TrackLabel alloc] init];
	[self.backgroundView addSubview:name];
	self.name = name;
	//歌手名
	TrackLabel* artist = [[TrackLabel alloc] init];
	[self.backgroundView addSubview:artist];
	self.artist = artist;
	//专辑名
	TrackLabel* album = [[TrackLabel alloc] init];
	[self.backgroundView addSubview:album];
	album.text = @"尚未播放歌曲";
	self.album = album;
	//播放模式
	UIImageView* playModeView = [[UIImageView alloc] init];
	playModeView.image = [UIImage imageNamed:@"repeatOnB.png"];
	playModeView.contentMode = UIViewContentModeScaleAspectFit;
	[self.backgroundView addSubview:playModeView];
	self.playModeView = playModeView;
	//歌词
//	LrcView* lrcView = [[LrcView alloc] init];
//	lrcView.hidden = true;
//	[self addSubview:lrcView];
//	self.lrcView.renderStatic = false;
//	self.lrcView = lrcView;
}
- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGFloat height = [self height];
	CGFloat width = [self width];
	
	self.backgroundView.frame = self.bounds;
	self.reflection.frame = CGRectMake(0, height - width, height, height);
	self.coverScroll.frame = CGRectMake(0, 0, width, width);
	self.lrcView.frame = CGRectMake(0, 0, width, width);
	self.bufferingIndicator.frame = CGRectMake(0, width, width, 10);
	self.progress.frame = CGRectMake(0, width, width, 10);
	self.playModeView.frame = CGRectMake(width / 2 - 10, height - 50, 20, 20);
	self.name.frame = CGRectMake(0, width + 20, width, 40);
	self.artist.frame = CGRectMake(0, width + 60, width, 40);
	self.album.frame = CGRectMake(0, width + 100, width, 40);
	self.timeView.frame = CGRectMake(0, CGRectGetMaxY(self.progress.frame), width, 20);
	self.currentTime.frame = CGRectMake(2, 0, width / 2, 20);
	self.leftTime.frame = CGRectMake(width / 2 - 2, 0, width / 2, self.timeView.bounds.size.height);
	
}
- (LDProgressView *)createProgressViewByShowBackground:(NSNumber*)showBackground type: (LDProgressType)type backgroundColor:(UIColor*)backgroundColor {
	
	LDProgressView* buffer = [[LDProgressView alloc] init];
	buffer.flat = @YES;
	buffer.progress = 0;
	buffer.animate = @YES;
	buffer.showText = @NO;
	buffer.showStroke = @YES;
	buffer.progressInset = 0;
	buffer.showBackground = showBackground;
	buffer.outerStrokeWidth = 0;
	buffer.type = type;
	buffer.borderRadius = 0;
	buffer.backgroundColor = backgroundColor;
	
	return buffer;
}
- (UILabel*)createLabelByAutoresizingMask:(UIViewAutoresizing)autoresizingMask
							 shadowOffset:(CGSize)shadowOffset
								textColor:(UIColor*)textColor
									 text:(NSString*)text
							textAlignment:(NSTextAlignment)textAlignment {
	UILabel* label = [[UILabel alloc] init];
	label.autoresizingMask = autoresizingMask;
	label.textColor = textColor;
	label.textAlignment = textAlignment;
	label.adjustsFontSizeToFitWidth = true;
	label.shadowOffset = shadowOffset;
	label.text = text;
	return label;
}
#pragma mark - GestureRecognizer
- (void)addGestureRecognizer {
	//播放和暂停
	UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playOrPause)];
	singleTap.numberOfTapsRequired = 1;
	singleTap.numberOfTouchesRequired = 1;
	[self addGestureRecognizer:singleTap];
	//上一首
	UISwipeGestureRecognizer* swipeFromLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(playPrevious)];
	swipeFromLeft.direction = UISwipeGestureRecognizerDirectionRight;
	swipeFromLeft.numberOfTouchesRequired = 1;
	[self addGestureRecognizer:swipeFromLeft];
	//下一首
	UISwipeGestureRecognizer* swipeFromRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(playPrevious)];
	swipeFromLeft.direction = UISwipeGestureRecognizerDirectionLeft;
	swipeFromLeft.numberOfTouchesRequired = 1;
	[self addGestureRecognizer:swipeFromRight];
	//快进
	UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doSeeking:)];
	longPress.numberOfTouchesRequired = 1;
	longPress.minimumPressDuration = 0.5;
	[self addGestureRecognizer:longPress];
	//随机
	UISwipeGestureRecognizer* doubleswipeFromRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(playShuffle:)];
	doubleswipeFromRight.direction = UISwipeGestureRecognizerDirectionRight;
	doubleswipeFromRight.numberOfTouchesRequired = 2;
	[self addGestureRecognizer:doubleswipeFromRight];
	//顺序播放
	UISwipeGestureRecognizer* doubleswipeFromLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(playShuffle:)];
	doubleswipeFromLeft.direction = UISwipeGestureRecognizerDirectionRight;
	doubleswipeFromLeft.numberOfTouchesRequired = 2;
	[self addGestureRecognizer:doubleswipeFromLeft];
	//单曲循环
	UITapGestureRecognizer* doubleTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleRewind)];
	doubleTouch.numberOfTouchesRequired = 2;
	doubleTouch.numberOfTapsRequired = 1;
	[self addGestureRecognizer:doubleTouch];
	//展示歌词
	UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLyrics)];
	doubleTap.numberOfTapsRequired = 2;
	doubleTap.numberOfTouchesRequired = 1;
	[self addGestureRecognizer:doubleTap];
	
	[singleTap requireGestureRecognizerToFail:doubleTouch];
	[singleTap requireGestureRecognizerToFail:doubleTap];
}

- (void)playOrPause {
	if (self.tracks.count == 0) {
		[SVProgressHUD showErrorWithStatus:@"向上滑动，更多精彩"];
		return;
	}
}

- (void)playPrevious {
	
}

- (void)doSeeking:(UILongPressGestureRecognizer*)recognizer {
	
}

- (void)playShuffle:(UISwipeGestureRecognizer*)recognizer {
	
}

- (void)singleRewind {
	
}

- (void)showLyrics {
	
}

- (void)playTracks:(NSArray *)tracks index:(NSInteger)index {
	self.tracks = tracks;
	self.index = index;
	
	NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
	Boolean yes = [user boolForKey:@"wwanPlay"];
	Reachability* monitor = [Reachability reachabilityForInternetConnection];
	NetworkStatus reachable = [monitor currentReachabilityStatus];
	if(!yes && reachable != 2 && [self.type isEqualToString:@"local"]) {
		
	}
	
	if (reachable == 2 || [self.type isEqualToString:@"local"] || yes) {
		[self startPlay];
	}
}
- (void)startPlay {
	self.lrcView.lyricsLines = [[NSMutableArray alloc] init];
	self.lrcView.chLrcArray = [[NSMutableArray alloc] init];
	[self.lrcView.tableView reloadData];
	self.paused = false;
	
	Track* track = self.tracks[self.index];
	NSString* rootPath = [self dirDoc];
//	[self.streamer.activeStream playFromURL:[NSURL URLWithString:track.url]];
	self.streamer.url = [NSURL URLWithString:track.url];
	[self.streamer play];
	[self addCurrentTimeTimer];
}
- (void)addCurrentTimeTimer {
	if (self.paused == true) return;
	
	[self removeCurrentTimeTimer];
	//保证定时器的工作是即时的
	[self updateCurrentTime];
	
	[self updatePlayBackProgress];
	
	self.currentTimeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCurrentTime) userInfo:nil repeats:YES];
	self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updatePlayBackProgress) userInfo:nil repeats:YES];
	
	[[NSRunLoop mainRunLoop] addTimer:self.currentTimeTimer forMode:NSRunLoopCommonModes];
	[[NSRunLoop mainRunLoop] addTimer:self.playbackTimer forMode:NSRunLoopCommonModes];
}
- (void)removeCurrentTimeTimer {
	[self.currentTimeTimer invalidate];
	[self.playbackTimer invalidate];
	
	self.currentTimeTimer = nil;
	self.playbackTimer = nil;
}
- (void)updateCurrentTime {
	//计算进度值
	if (self.streamer.activeStream.duration.minute == 0 && self.streamer.activeStream.duration.second == 0) return;
	
	//取出当前播放时长以及总时长
	FSStreamPosition cur = self.streamer.activeStream.currentTimePlayed;
	
	FSStreamPosition total = self.streamer.activeStream.duration;
	
	//设置进度条进度
	double progress = (float)(cur.minute * 60 + cur.second) / (float)(total.minute * 60 + total.second);
	
	self.progress.progress = progress;
	
	//设置当前时间以及剩余时间
	
	NSString *curSecond = [NSString stringWithFormat:@"%d",cur.second];
	
	int totalLeftSecond = total.minute * 60 + total.second - cur.minute * 60 - cur.second;
	
	NSString *leftMin = [NSString stringWithFormat:@"%d",totalLeftSecond / 60];
	
	NSString *leftSec = [NSString stringWithFormat:@"%d",totalLeftSecond % 60];
	
	if (cur.second < 10) {
		
		curSecond = [NSString stringWithFormat:@"0%@",curSecond];
		
	}
	
	if ([leftSec intValue] < 10) {
		
		leftSec = [NSString stringWithFormat:@"0%@",leftSec];
		
	}
	
	self.currentTime.text = [NSString stringWithFormat:@"%d:%@",cur.minute, curSecond];
	
	self.leftTime.text = [NSString stringWithFormat:@"%@:%@",leftMin,leftSec];
	
	__weak PlayerInterface *weakSelf = self;
	
	self.streamer.onStateChange = ^(FSAudioStreamState state) {
		
		if (state == kFsAudioStreamPlaybackCompleted) {
			NSLog(@"播放完毕");
			
			[weakSelf playTracks:weakSelf.tracks index:weakSelf.index + 1];
			
		}
	};
}
- (void)updatePlayBackProgress {
	
	if (self.streamer.activeStream.contentLength > 0) {
		
		if (self.bufferingIndicator.progress >= 1.0) {
			
			[self.playbackTimer invalidate];
			
		}
		
		FSSeekByteOffset currentOffset = self.streamer.activeStream.currentSeekByteOffset;
		
		UInt64 totalBufferedData = currentOffset.start + self.streamer.activeStream.prebufferedByteCount;
		
		float bufferedDataFromTotal = (float)totalBufferedData / self.streamer.activeStream.contentLength;
		
		self.bufferingIndicator.progress = bufferedDataFromTotal;
		
	} else {
		
		self.bufferingIndicator.progress = (float)self.streamer.activeStream.prebufferedByteCount / _maxPrebufferedByteCount;
		
	}
}

#pragma mark - LTInfiniteScrollViewDataSource
- (NSInteger)numberOfViews {
	if (self.tracks.count > 0) return self.tracks.count;
	return 1;
}
- (NSInteger)numberOfVisibleViews {
	return 1;
}
- (UIView *)viewAtIndex:(NSInteger)index reusingView:(UIView *)view {
	CGFloat size = self.bounds.size.width;
	UIImageView* cover = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
	
	if (self.tracks.count > 0) {
		Track* track = self.tracks[index];
		NSString* urlStr = [NSString stringWithFormat:@"%@!/fw/600", track.cover];
		NSURL* url = [NSURL URLWithString:urlStr];
		
		[cover sd_setImageWithURL:url
				 placeholderImage:[UIImage imageNamed:@"noArtwork"]
						completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
							if (index == (NSInteger)self.index) {
								self.reflection.image = [image reflectionWithAlpha:0.4];
								self.nowCover = cover;
							}
						}];
	} else {
		cover.image = [UIImage imageNamed:@"noArtwork"];
	}
	return cover;
}

#pragma mark - LTInfiniteScrollViewDelegate
- (void)updateView:(UIView *)view withProgress:(CGFloat)progress scrollDirection:(ScrollDirection)direction {}
- (void)scrollView:(LTInfiniteScrollView *)scrollView didScrollToIndex:(NSInteger)index {
	if (self.tracks.count == 0) return;
	self.index = index;
	[self playTracks:self.tracks index:index];
}



@end

