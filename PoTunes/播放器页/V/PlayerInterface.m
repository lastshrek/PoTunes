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
#import "PotunesRemix-Swift.h"
#import "FSAudioController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Reachability.h"
#import "FMDB.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <SCLAlertView_Objective_C/SCLAlertView.h>
#import <TDImageColors/TDImageColors.h>
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
@property (nonatomic, assign) FSSeekByteOffset offset;
@property (nonatomic, assign) int interuptReason;


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
	//获取上次播放曲目
	[self getLastPlayTrackAndPlaystate];
	/** 注册通知 */
	[self getNotification];
	//设置appdelegate的block
	[self setupDelegateBlock];
}
#pragma mark - initialSubViews
- (void)initialSubviews {
	self.streamer = [[FSAudioController alloc] init];
	self.currentProgressColor = [UIColor whiteColor];
	self.streamer = [[FSAudioController alloc] init];
	self.repeatMode = PCAudioRepeatModeTowards;
	self.paused = YES;
	//底
	UIView *backgroundView = [[UIView alloc] init];
	backgroundView.backgroundColor = [UIColor blackColor];
	[self addSubview:backgroundView];
	self.backgroundView = backgroundView;
	//倒影封面
	UIImageView *reflection = [[UIImageView alloc] init];
	reflection.image = [[UIImage imageNamed:@"noArtwork"] reflectionWithAlpha:0.4];
	reflection.contentMode = UIViewContentModeScaleAspectFit;
	self.reflection = reflection;
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
	LDProgressView* progress = [self createProgressViewByShowBackground:@NO type:LDProgressGradient backgroundColor:[UIColor clearColor]];
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
	LrcView* lrcView = [[LrcView alloc] init];
	lrcView.hidden = YES;
	lrcView.renderStatic = NO;
	[self addSubview:lrcView];
	self.lrcView = lrcView;
	//当前封面
	UIImageView* nowCover = [[UIImageView alloc] init];
	nowCover.image = [UIImage imageNamed:@"noArtwork"];
	self.nowCover = nowCover;
	self.nowCover.hidden = YES;
	[self addSubview:nowCover];
	[self sendSubviewToBack:self.nowCover];
	
}
- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGFloat height = [self height];
	CGFloat width = [self width];
	self.backgroundView.frame = self.bounds;
	self.reflection.frame = CGRectMake(0, height - width, width, width);
	self.nowCover.frame = CGRectMake(0, 0, width, width);
	self.coverScroll.frame = CGRectMake(0, 0, width, width);
	self.bufferingIndicator.frame = CGRectMake(0, width, width, 10);
	self.progress.frame = CGRectMake(0, width, width, 10);
	self.playModeView.frame = CGRectMake(width / 2 - 10, height - 50, 20, 20);
	self.name.frame = CGRectMake(0, width + 20, width, 40);
	self.artist.frame = CGRectMake(0, width + 60, width, 40);
	self.album.frame = CGRectMake(0, width + 100, width, 40);
	self.timeView.frame = CGRectMake(0, CGRectGetMaxY(self.progress.frame), width, 20);
	self.currentTime.frame = CGRectMake(2, 0, width / 2, 20);
	self.leftTime.frame = CGRectMake(width / 2 - 2, 0, width / 2, self.timeView.bounds.size.height);
	self.lrcView.frame = CGRectMake(0, 0, width, width);
}
- (LDProgressView *)createProgressViewByShowBackground:(NSNumber*)showBackground
												  type: (LDProgressType)type
									   backgroundColor:(UIColor*)backgroundColor {
	
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
	label.adjustsFontSizeToFitWidth = YES;
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
	UISwipeGestureRecognizer* swipeFromLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(playNext)];
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
	self.paused = !(self.paused);
	if (self.paused == false) {
		[SVProgressHUD showImage:[UIImage imageNamed:@"playB"] status:@"继续播放"];
		if (self.streamer.activeStream) {
			FSStreamPosition seek;
			seek.position = self.progress.progress;
			[self.streamer.activeStream seekToPosition:seek];
		}
	} else {
		[SVProgressHUD showImage:[UIImage imageNamed:@"pauseB"] status:@"暂停播放"];
		self.interuptReason = 0;
	}
	
	if (self.streamer.activeStream == nil) {
		[self playTracks:self.tracks index:self.index];
		return;
	}
	[self.streamer.activeStream pause];
}
- (void)playPrevious {
	if (self.tracks.count == 0) {
		[SVProgressHUD showErrorWithStatus:@"向上滑动，更多精彩"];
		return;
	}
	
	FSStreamPosition cur = self.streamer.activeStream.currentTimePlayed;
	if (cur.minute == 0 || cur.second <= 5) {
		if (self.repeatMode == PCAudioRepeatModeShuffle) {
			self.index = arc4random() % self.tracks.count;
		} else if (self.repeatMode == PCAudioRepeatModeSingle) {
			self.index = self.index;
		} else {
			if (self.index == 0) {
				self.index = self.tracks.count - 1;
			} else {
				self.index = self.index - 1;
			}
		}
	}
	
	[self.coverScroll scrollToIndex:self.index animated:YES];
	[SVProgressHUD showImage:[UIImage imageNamed:@"prevB"] status:nil];
	[self playTracks:self.tracks index:self.index];
}
- (void)playNext {
	if (self.tracks.count == 0) {
		[SVProgressHUD showErrorWithStatus:@"向上滑动，更多精彩"];
		return;
	}
	
	if (self.repeatMode == PCAudioRepeatModeShuffle) {
		self.index = arc4random() % self.tracks.count;
	} else if (self.repeatMode == PCAudioRepeatModeSingle) {
		self.index = self.index;
	} else {
		if (self.index == self.tracks.count - 1) {
			self.index = 0;
		} else {
			self.index = self.index + 1;
		}
	}
	
	[self.coverScroll scrollToIndex:self.index animated:YES];
	[SVProgressHUD showImage:[UIImage imageNamed:@"nextB"] status:nil];
	[self playTracks:self.tracks index:self.index];
}
- (void)doSeeking:(UILongPressGestureRecognizer*)recognizer {
	if (self.tracks.count == 0) {
		[SVProgressHUD showErrorWithStatus:@"向上滑动，更多精彩"];
		return;
	}
	
	FSStreamPosition seek;
	CGPoint lastPoint;
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		//缩小
		CGRect tempBounds = self.backgroundView.bounds;
		tempBounds.size.width -= 40;
		tempBounds.size.height -= 40;
		self.backgroundView.bounds = tempBounds;
		
		//获取按住播放时间
		FSStreamPosition now = self.streamer.activeStream.currentTimePlayed;
		self.progressOriginal = now.position;
		self.originalPoint = [recognizer locationInView:self];
	}
	//改变进度条的值
	if (recognizer.state == UIGestureRecognizerStateChanged) {
		CGPoint changingPoint = [recognizer locationInView:self];
		CGFloat seekForwardPercent =  self.progressOriginal + ((changingPoint.x - self.originalPoint.x) / self.width);
		if (seekForwardPercent >= 1 || seekForwardPercent < 0) { return; }
		self.progress.progress = seekForwardPercent;
	}
	
	if (recognizer.state == UIGestureRecognizerStateEnded) {
		//还原
		lastPoint = [recognizer locationInView:self];
		
		self.backgroundView.frame = self.frame;
		self.playModeView.frame = CGRectMake(self.width / 2 - 10, self.height - 20, 20, 20);
		//如果没有移动不移动进度条
		if (lastPoint.x == self.originalPoint.x) { return; }
		seek.position = self.progress.progress;
		[self.streamer.activeStream seekToPosition:seek];
	}
}
- (void)playShuffle:(UISwipeGestureRecognizer*)recognizer {
	if (self.tracks.count == 0) {
		[SVProgressHUD showErrorWithStatus:@"向上滑动，更多精彩"];
		return;
	}
	
	if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
		[SVProgressHUD showImage:[UIImage imageNamed:@"shuffleOnB"] status:nil];
		self.repeatMode = PCAudioRepeatModeShuffle;
		self.playModeView.image = [UIImage imageNamed:@"shuffleOnB"];
	} else {
		[SVProgressHUD showImage:[UIImage imageNamed:@"shuffleOffB"] status:nil];
		self.repeatMode = PCAudioRepeatModeTowards;
		self.playModeView.image = [UIImage imageNamed:@"repeatOnB"];
	}
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:@(self.repeatMode) forKey:@"repeatMode"];
	[defaults synchronize];
}
- (void)singleRewind {
	if (self.repeatMode == PCAudioRepeatModeSingle) {
		[SVProgressHUD showImage:[UIImage imageNamed:@"repeatOnB"] status:nil];
		self.repeatMode = PCAudioRepeatModeTowards;
		self.playModeView.image = [UIImage imageNamed:@"repeatOnB"];
	} else {
		[SVProgressHUD showImage:[UIImage imageNamed:@"repeatOneB"] status:nil];
		self.repeatMode = PCAudioRepeatModeSingle;
		self.playModeView.image = [UIImage imageNamed:@"repeatOneB"];
	}
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:@(self.repeatMode) forKey:@"repeatMode"];
	[defaults synchronize];
}
- (void)showLyrics {
	if (self.tracks.count == 0) {
		[SVProgressHUD showErrorWithStatus:@"向上滑动，更多精彩"];
		return;
	}
	
	if (self.lrcView.hidden == YES) {
		self.lrcView.hidden = NO;
		self.lrcView.alpha = 0;
		
		self.lrcView.renderStatic = NO;
		self.lrcView.renderStatic = YES;
		
		[UIView animateWithDuration:0.5 animations:^{ self.lrcView.alpha = 1; }];
		[UIView commitAnimations];
		[self addLrcTimer];
		
		if (self.lrcView.lyricsLines.count == 0) {
			Track* track = self.tracks[self.index];
			[self loadLyrics:(int)track.ID];
		}
		
	} else {
		self.lrcView.alpha = 1;
		[UIView animateWithDuration:0.5 animations:^{ self.lrcView.alpha = 0; }];
		[UIView commitAnimations];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			self.lrcView.hidden = YES;
		});
		[self removeLrcTimer];
	}
}
- (void)loadLyrics:(NSInteger)trackID {
	self.lrcView.noLrcLabel.text = @"正在加载歌词";
	self.lrcView.noLrcLabel.hidden = NO;
	
	NSString* lrcUrl = @"https://poche.fm/api/app/lyrics/";
	lrcUrl = [NSString stringWithFormat:@"%@%ld", lrcUrl, (long)trackID];
	
	AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
	[manager GET:lrcUrl parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
		NSString* lrc = responseObject[@"lrc"];
		NSString* lrc_cn = responseObject[@"lrc_cn"];
		if ((NSNull *)lrc == [NSNull null]) {
			self.lrcView.noLrcLabel.text = @"暂无歌词";
			self.lrcView.noLrcLabel.hidden = NO;
			return;
		}
		[self.lrcView parseLyricsWithLyrics:[lrc stringByReplacingOccurrencesOfString:@"\\n" withString:@" "]];
		if ((NSNull *)lrc_cn == [NSNull null]) return;
		if (lrc_cn.length > 0 && ![lrc_cn isEqualToString:@"unwritten"]) {
			[self.lrcView parseChLyricsWithLyrics:[lrc_cn stringByReplacingOccurrencesOfString:@"\\n" withString:@" "]];
		}
	} failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
		self.lrcView.noLrcLabel.text = @"暂无歌词";
	}];
	

}
#pragma mark - getLastPlayTrackAndPlaystate
- (void)getLastPlayTrackAndPlaystate {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData* tracksData = [defaults objectForKey:@"tracksData"];
	if (tracksData == nil) {
		self.repeatMode = PCAudioRepeatModePlaylist;
		return;
	}
	
	NSString* album = [defaults stringForKey:@"album"];
	self.tracks = [NSKeyedUnarchiver unarchiveObjectWithData:tracksData];
	self.index = [defaults integerForKey:@"index"];
	self.type = [defaults stringForKey:@"type"];
	self.album.text = album;
	self.repeatMode = [defaults integerForKey:@"repeatMode"];
	
	if (self.repeatMode == PCAudioRepeatModeSingle) {
		self.playModeView.image = [UIImage imageNamed:@"repeatOneB"];
	} else if (self.repeatMode == PCAudioRepeatModeShuffle) {
		self.playModeView.image = [UIImage imageNamed:@"shuffleOnB"];
	} else {
		self.playModeView.image = [UIImage imageNamed:@"repeatOnB"];
	}
	
	[self.coverScroll reloadDataWithInitialIndex:self.index];
	[self changeInterface:self.index];
}
#pragma mark - Play
- (void)playTracks:(NSArray *)tracks index:(NSInteger)index {
	self.tracks = tracks;
	self.index = index;
	NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
	BOOL yes = [user boolForKey:@"wwanPlay"];
	Reachability* monitor = [Reachability reachabilityForInternetConnection];
	NetworkStatus reachable = [monitor currentReachabilityStatus];
	
	if(!yes && reachable != 2 && ![self.type isEqualToString:@"local"]) {
		SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
		[alert addButton:@"继续播放" actionBlock:^{
			if (reachable == 0) {
				[SVProgressHUD showErrorWithStatus:@"貌似断网了，请检查网络状况"];
			}
			
			[self startPlay];
			[user setBool:YES forKey:@"wwanPlay"];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"wwanPlay" object:nil userInfo:nil];
		}];
		[alert addButton:@"取消" actionBlock:^{}];
		[alert showWarning:@"温馨提示" subTitle:@"您当前处于运营商网络中，是否继续播放" closeButtonTitle:nil duration:0.0f];
	}
	if (reachable == 2 || [self.type isEqualToString:@"local"] || yes) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[self startPlay];
		});
	}
	if (reachable == 0) {
		[SVProgressHUD showErrorWithStatus:@"貌似断网了，请检查网络状况"];
	}
}
- (void)startPlay {
	//Remove Last Track Lyrics
	self.lrcView.lyricsLines = [[NSMutableArray alloc] init];
	self.lrcView.chLrcArray = [[NSMutableArray alloc] init];
	[self.lrcView.tableView reloadData];
	
	self.paused = false;
	self.streamer = nil;
	self.streamer = [[FSAudioController alloc] init];
	
	Track* track = self.tracks[self.index];
	NSString* rootPath = [self dirDoc];
	NSString* query = @"SELECT * FROM t_downloading WHERE sourceURL = ?;";
	FMResultSet* s = [self.tracksDB executeQuery:query withArgumentsInArray:@[track.url]];
	
	if (s.next) {
		BOOL isDownloaded = [s stringForColumn:@"downloaded"];
		if (isDownloaded) {
			NSString* identifier = [self getIdentifierWithUrlStr:track.url];
			NSString* filePath = [NSString stringWithFormat:@"%@/%@", rootPath, identifier];
			self.streamer.url = [NSURL fileURLWithPath:filePath];
			[self.streamer play];
		} else {
			self.streamer.url = [NSURL URLWithString:track.url];
			[self.streamer play];
		}
	} else {
		self.streamer.url = [NSURL URLWithString:track.url];
		[self.streamer play];
	}
	[self addCurrentTimeTimer];
	[self changeInterface:self.index];
	//记录最后一次播放的歌曲和以及播放模式
	NSData* tracksData = [NSKeyedArchiver archivedDataWithRootObject:self.tracks];
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:@(self.repeatMode) forKey:@"repeatMode"];
	[defaults setObject:tracksData forKey:@"tracksData"];
	[defaults setInteger:self.index forKey:@"index"];
	[defaults setObject:self.type forKey:@"type"];
	[defaults setValue:self.album.text forKey:@"album"];
	[defaults synchronize];
}
- (void)changeInterface:(NSInteger)index {
	Track* track = self.tracks[self.index];
	NSString* urlStr = [NSString stringWithFormat:@"%@!/fw/600", track.cover];

	self.name.text = track.name;
	self.artist.text = track.artist;
	self.progress.progress = 0;
	self.bufferingIndicator.progress = 0;
	self.currentTime.text = @"0:00";
	self.leftTime.text = @"0:00";
	if (self.lrcView.hidden == NO) {
		[self loadLyrics:track.ID];
	}
	dispatch_async(dispatch_get_main_queue(), ^{
		// 更新界面
		[self.nowCover sd_setImageWithURL:[NSURL URLWithString:urlStr] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
			self.reflection.image = [image reflectionWithAlpha:0.4];
			self.nowCover.image = image;
			[self refreshProgressColor:image];
			[self refreshBlurView];
		}];
	});
	
}
- (void)refreshBlurView {
	self.lrcView.renderStatic = NO;
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		self.lrcView.renderStatic = YES;
	});
}
- (void)refreshProgressColor:(UIImage*)image {
	TDImageColors* imageColors= [[TDImageColors alloc] initWithImage:image count:2];
	self.progress.color = imageColors.colors[1];
	self.name.textColor = imageColors.colors[1];
	self.artist.textColor = imageColors.colors[1];
	self.album.textColor = imageColors.colors[1];
}
#pragma mark - Notifications
- (void)getNotification {
	AVAudioSession *sessionInstance = [AVAudioSession sharedInstance];
	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	[center addObserver:self selector:@selector(speaking) name:@"speaking" object:nil];
	[center addObserver:self selector:@selector(nonspeaking) name:@"nonspeaking" object:nil];
	[center addObserver:self selector:@selector(audioSessionDidChangeInterruptionType:)
				   name:AVAudioSessionRouteChangeNotification object:sessionInstance];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(audioSessionWasInterrupted:)
												 name:AVAudioSessionInterruptionNotification
											   object:sessionInstance];
	[center addObserver:self selector:@selector(refreshBlurView) name:@"becomeActive" object:nil];
}
- (void)dealloc {
	NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
	[center removeObserver:self name:@"speaking" object:nil];
	[center removeObserver:self name:@"nonspeaking" object:nil];
	[center removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
	[center removeObserver:self name:@"becomeActive" object:nil];
	[center removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
}
- (void)speaking { self.streamer.volume = 0.1; }
- (void)nonspeaking { self.streamer.volume = 1; }
- (void)audioSessionDidChangeInterruptionType:(NSNotification *)notification {
	NSInteger interruptReason = [[notification.userInfo objectForKey:@"AVAudioSessionRouteChangeReasonKey"] integerValue];
	if (interruptReason == 2) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				dispatch_sync(dispatch_get_main_queue(), ^{
					if (self.paused == NO) {
						[self playOrPause];
					}
			});
		});
	}
}




- (void)audioSessionWasInterrupted:(NSNotification *)notification {
	NSLog(@"%@", notification);
	int reason = [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
	if (AVAudioSessionInterruptionTypeBegan == reason) {
		NSLog(@"打断来了");
		if (self.streamer.activeStream.isPlaying) {
			[self.streamer.activeStream pause];
			self.paused = YES;
			self.interuptReason = 1;
		}
		return;
	}
	if (AVAudioSessionInterruptionTypeEnded == reason) {
		NSLog(@"打断走了");
		if (notification.userInfo[@"refreshProgress"] != nil) return;
		if (self.paused == YES && self.interuptReason == 1) {
			[self playOrPause];
			self.interuptReason = 0;
		}
	}
}
#pragma mark - DelegateBlock
- (void)setupDelegateBlock {
	AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
	appDelegate.remoteEventBlock = ^(UIEvent *event) {
		switch (event.subtype) {
			case UIEventSubtypeRemoteControlTogglePlayPause | UIEventSubtypeRemoteControlPlay | UIEventSubtypeRemoteControlPause:
				[self playOrPause];
				break;
			case UIEventSubtypeRemoteControlPlay:
				[self playOrPause];
				break;
			case UIEventSubtypeRemoteControlPause:
				[self playOrPause];
				break;
			case UIEventSubtypeRemoteControlNextTrack:
				[self playNext];
				break;
			case UIEventSubtypeRemoteControlPreviousTrack:
				[self playPrevious];
				break;
			default:
				break;
		}
	};
}
#pragma mark - Various Timers
- (void)addCurrentTimeTimer {
	if (self.paused == YES) return;
	[self removeCurrentTimeTimer];
	//保证定时器的工作是即时的
	[self updateCurrentTime];
	[self updatePlayBackProgress];
	self.currentTimeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
															 target:self
														   selector:@selector(updateCurrentTime)
																			  userInfo:nil repeats:YES];
	self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updatePlayBackProgress) userInfo:nil repeats:YES];
	[[NSRunLoop mainRunLoop] addTimer:self.currentTimeTimer forMode:NSRunLoopCommonModes];
	[[NSRunLoop mainRunLoop] addTimer:self.playbackTimer forMode:NSRunLoopCommonModes];
}
- (void)addLrcTimer {
	if (self.lrcView.hidden == YES) return;
	if (self.streamer.activeStream.isPlaying == NO && self.lrcTimer) {
		[self updateLrcTimer];
		return;
	}
	[self removeLrcTimer];
	[self updateLrcTimer];
	self.lrcTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrcTimer)];
	[self.lrcTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
- (void)updateCurrentTime {
	//计算进度值
	if (self.streamer.activeStream == nil) { return; }
	if (self.streamer.activeStream.duration.minute == 0 && self.streamer.activeStream.duration.second == 0) return;
	//取出当前播放时长以及总时长
	FSStreamPosition cur = self.streamer.activeStream.currentTimePlayed;
	FSStreamPosition total = self.streamer.activeStream.duration;
	if (self.streamer.isPlaying) self.offset = self.streamer.activeStream.currentSeekByteOffset;

	//设置进度条进度
	self.progress.progress = self.streamer.activeStream.currentTimePlayed.position;
	//设置当前时间以及剩余时间
	NSInteger totalLeftSecond = total.minute * 60 + total.second - cur.minute * 60 - cur.second;
	
//	printf("总时长%u\n", total.minute * 60 + total.second);
//	printf("已播放%u\n", cur.minute * 60 + cur.second);
	

	NSString *curSecond = [NSString stringWithFormat:@"%d",cur.second];
	NSString *leftMin = [NSString stringWithFormat:@"%ld",totalLeftSecond / 60];
	NSString *leftSec = [NSString stringWithFormat:@"%ld",totalLeftSecond % 60];
	
	if (cur.second < 10) curSecond = [NSString stringWithFormat:@"0%@",curSecond];
	if ([leftSec intValue] < 10) leftSec = [NSString stringWithFormat:@"0%@",leftSec];

	self.currentTime.text = [NSString stringWithFormat:@"%d:%@",cur.minute, curSecond];
	self.leftTime.text = [NSString stringWithFormat:@"%@:%@",leftMin,leftSec];
	__weak PlayerInterface *weakSelf = self;
	self.streamer.onStateChange = ^(FSAudioStreamState state) {
		if (state == kFsAudioStreamPlaybackCompleted) {
			[weakSelf playTracks:weakSelf.tracks index:weakSelf.index + 1];
		}
	};
	
	self.streamer.activeStream.onStateChange = ^(FSAudioStreamState state) {
		if (state == kFsAudioStreamPlaybackCompleted) {
			[self playNext];
		}
		
		if (state == kFsAudioStreamFailed) {
			FSStreamPosition seek;
			seek.position = self.progress.progress;
			[self.streamer.activeStream seekToPosition:seek];
		}
		
		if (state == kFsAudioStreamRetryingFailed) {
			NSLog(@"多次播放失败");
		}
		
		if (state == kFSAudioStreamEndOfFile) {
			if (self.playbackTimer == nil) return;
			[self.playbackTimer invalidate];
			self.playbackTimer = nil;
			self.bufferingIndicator.progress = 1;
		}
		
		if (state == kFsAudioStreamUnknownState) {
			NSLog(@"unknown state");
		}
		
		if (state == kFsAudioStreamStopped) {
			NSLog(@"播放停止");
		}
	};
	//设置锁屏信息
	NSMutableDictionary* info = [NSMutableDictionary dictionary];
	MPMediaItemArtwork* artwork;
	if (self.nowCover.image) {
		artwork = [[MPMediaItemArtwork alloc] initWithImage:self.nowCover.image];
	} else {
		artwork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageNamed:@"noArtwork"]];
	}
	
	int duration = self.streamer.activeStream.duration.minute * 60 + self.streamer.activeStream.duration.second;
	int elapsedPlaybackTime = cur.minute * 60 + cur.second;
	Track* track = self.tracks[self.index];
	info[MPMediaItemPropertyPlaybackDuration] = [NSNumber numberWithInt:duration];
	info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = [NSNumber numberWithInt:elapsedPlaybackTime];
	info[MPMediaItemPropertyAlbumTitle] = self.album.text;
	info[MPMediaItemPropertyArtist] = track.artist;
	info[MPMediaItemPropertyTitle] = track.name;
	info[MPMediaItemPropertyArtwork] = artwork;
	[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = info;
}
- (void)updatePlayBackProgress {
	if (self.streamer.activeStream == nil) return;
	if (self.streamer.activeStream.contentLength > 0) {
		FSSeekByteOffset currentOffset = self.streamer.activeStream.currentSeekByteOffset;
		UInt64 totalBufferedData = currentOffset.start + self.streamer.activeStream.prebufferedByteCount;
		float bufferedDataFromTotal = (float)totalBufferedData / self.streamer.activeStream.contentLength;
		self.bufferingIndicator.progress = bufferedDataFromTotal;
	} else {
		self.bufferingIndicator.progress = (float)self.streamer.activeStream.prebufferedByteCount / _maxPrebufferedByteCount;
	}
}
- (void)updateLrcTimer {
	FSStreamPosition cur = self.streamer.activeStream.currentTimePlayed;
	[self.lrcView currentTimeWithTime:(cur.minute * 60 + cur.second)];
}
- (void)removeCurrentTimeTimer {
	[self.currentTimeTimer invalidate];
	[self.playbackTimer invalidate];
	self.currentTimeTimer = nil;
	self.playbackTimer = nil;
	self.bufferingIndicator.progress = 0;
	self.progress.progress = 0;
}
- (void)removeLrcTimer {
	[self.lrcTimer invalidate];
	self.lrcTimer = nil;
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
		
		[cover sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"noArtwork"]
						completed:^(UIImage *image,
									NSError *error,
									SDImageCacheType cacheType,
									NSURL *imageURL) {
							
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
	[self playTracks:self.tracks index:index];
}

@end

