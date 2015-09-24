//
//  ViewController.m
//  PoTunes
//
//  Created by Purchas on 15/9/1.
//  Copyright © 2015年 Purchas. All rights reserved.
//

#import "ViewController.h"
#import "Common.h"
#import "LDProgressView.h"
#import "PCLabel.h"
#import "UIImage+Reflection.h"
#import "PCButton.h"
#import "PCArticleViewController.h"
#import "PCNavigationController.h"
#import "UIImageView+WebCache.h"
#import "FSAudioController.h"
#import "MBProgressHUD+MJ.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AppDelegate.h"
#import "PCMyMusicViewController.h"
#import "FSPlaylistItem.h"
#import "PCSong.h"
#import "PCPlaylist.h"
#import "PCNaviController.h"
#import "PCSettingViewController.h"
#import "iflyMSC/IFlySpeechSynthesizer.h"
#import "iflyMSC/IFlySpeechSynthesizerDelegate.h"
#import "iflyMSC/IFlySpeechError.h"
#import "TDImageColors.h"

/** 播放模式 */
typedef NS_ENUM(NSUInteger, PCAudioRepeatMode) {
    PCAudioRepeatModeSingle,
    PCAudioRepeatModePlaylistOnce,
    PCAudioRepeatModePlaylist,
    PCAudioRepeatModeTowards,
    PCAudioRepeatModeShuffle
};
/** 播放操作 */
typedef NS_ENUM(NSUInteger, PCAudioPlayState) {
    PCAudioPlayStatePlay,
    PCAudioPlayStatePause,
    PCAudioPlayStateNext,
    PCAudioPlayStatePrevious
};

@interface ViewController ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIPageControl *pageControl;
@property (nonatomic, weak) UIView *backgroundView;
@property (nonatomic, weak) UIImageView *cover;
@property (nonatomic, weak) UIImageView *reflectionCover;
@property (nonatomic, weak) LDProgressView *progress;
@property (nonatomic, weak) LDProgressView *bufferingIndicator;
@property (nonatomic, weak) UILabel *currentTime;
@property (nonatomic, weak) UILabel *leftTime;
@property (nonatomic, weak) UILabel *songLabel;
@property (nonatomic, weak) PCLabel *artistLabel;
@property (nonatomic, weak) PCLabel *albumLabel;
@property (nonatomic, weak) PCButton *selectedBtn;
@property (nonatomic, weak) UIView *selectedView;
@property (nonatomic, weak) UIView *timeView;
@property (nonatomic, weak) UIView *invisibleView;
@property (nonatomic, strong) NSMutableArray *controllers;
@property (nonatomic, strong) FSAudioController *audioController;
@property (nonatomic, assign) BOOL paused;
@property (nonatomic, assign) float maxPrebufferedByteCount;

/** 歌曲相关 */
@property (nonatomic, assign) CGFloat progressOriginal;
@property (nonatomic, assign) CGPoint originalPoint;
@property (nonatomic, strong) NSArray *songs;
@property (nonatomic, assign) NSInteger index;
/**
 *  播放进度定时器
 */
@property (nonatomic, strong) NSTimer *currentTimeTimer;
@property (nonatomic, strong) NSTimer *PlayBackTimer;
@property (nonatomic, readonly) PCAudioRepeatMode *repeatMode;
@property (nonatomic, strong) IFlySpeechSynthesizer *iFlySpeechSynthesizer;
//当前播放进度
@property (nonatomic, assign) float nowProgress;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.height = self.view.bounds.size.height;
    self.width = self.view.bounds.size.width;
    /** 添加UIScrollView */
    [self setupScrollView];
    /** 添加PageControll */
    [self setupPageControl];
    /** 添加播放器界面 */
    [self setupPlayerInterface];
    /** 添加TabBar */
    [self setupTabBar];
    /** 注册通知 */
    [self getNotification];
    //设置appdelegate的block
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.remoteEventBlock = ^(UIEvent *event) {
        switch (event.subtype) {
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

#pragma mark - 隐藏statusBar
- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (FSAudioController *)audioController {
    if (_audioController == nil) {
        FSAudioController *audioController = [[FSAudioController alloc] init];
        _audioController = audioController;
    }
    
    return _audioController;
}
- (NSArray *)songs {
    if (_songs == nil) {
        _songs = [NSArray array];
    }
    
    return _songs;
}
- (float)nowProgress {
    if (!_nowProgress) {
        _nowProgress = 0;
    }
    return _nowProgress;
}
#pragma mark - 添加ScrollView
- (void)setupScrollView {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = self.view.bounds;
    scrollView.delegate = self;
    scrollView.backgroundColor = [UIColor blackColor];
    self.scrollView = scrollView;
    /** 设置内容滚动尺寸 */
    scrollView.contentSize = CGSizeMake(0, self.height * 2);
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    [self.view addSubview:scrollView];
}
#pragma mark - 添加PageControl
- (void)setupPageControl {
    /** 添加 */
    UIPageControl * pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = 2;
    pageControl.hidden = YES;
    CGFloat centerX = self.width * 0.5;
    CGFloat centerY = self.height - 30;
    pageControl.center = CGPointMake(centerX, centerY);
    pageControl.bounds = CGRectMake(0, 0, 100, 30);
    pageControl.userInteractionEnabled = YES;
    [self.view addSubview:pageControl];
    self.pageControl = pageControl;
}
#pragma mark - 添加播放器界面
- (void)setupPlayerInterface {
    //播放器背景
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    backgroundView.backgroundColor = [UIColor blackColor];
    self.backgroundView = backgroundView;
    [self.scrollView addSubview:backgroundView];
    //添加播放器手势操作
    [self setupGestureRecognizer];
    //专辑封面
    UIImageView *cover = [[UIImageView alloc] init];
    cover.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    cover.image = [UIImage imageNamed:@"defaultCover"];
    cover.frame = CGRectMake(0, 0, self.width, self.width);
    [cover.image reflectionWithAlpha:0.5];
    self.cover = cover;
    [self.backgroundView addSubview:cover];
    //倒影封面
    UIImageView *reflection = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.height - self.width, self.width, self.width)];
    reflection.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    reflection.image = [self.cover.image reflectionWithAlpha:0.4];
    [self.backgroundView addSubview:reflection];
    [self.backgroundView sendSubviewToBack:reflection];
    self.reflectionCover = reflection;
    
    
    //缓冲条
    LDProgressView *bufferingIndicator = [[LDProgressView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.cover.frame), self.width, 12)];
    bufferingIndicator.flat = @NO;
    bufferingIndicator.progress = 0;
    bufferingIndicator.animate = @NO;
    bufferingIndicator.showText = @NO;
    bufferingIndicator.showStroke = @NO;
    bufferingIndicator.progressInset = @1;
    bufferingIndicator.showBackground = @NO;
    bufferingIndicator.outerStrokeWidth = @0;
    bufferingIndicator.type = LDProgressSolid;
    bufferingIndicator.borderRadius = @0;
    bufferingIndicator.backgroundColor = [UIColor lightTextColor];
    bufferingIndicator.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    self.bufferingIndicator = bufferingIndicator;
    [self.backgroundView addSubview:bufferingIndicator];
    //进度条
    LDProgressView *progress = [[LDProgressView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.cover.frame), self.width, 12)];
    progress.flat = @NO;
    progress.progress = 0;
    progress.animate = @NO;
    progress.showText = @NO;
    progress.showStroke = @NO;
    progress.progressInset = @0;
    progress.showBackground = @NO;
    progress.outerStrokeWidth = @0;
    progress.type = LDProgressSolid;
    progress.borderRadius = @0;
    progress.backgroundColor = [UIColor clearColor];
    progress.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    self.progress = progress;
    [self.backgroundView addSubview:progress];
    
    
    //开始时间以及剩余时间
    UIView *timeView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(progress.frame), self.width, 25)];
    timeView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    self.timeView = timeView;
    [self.backgroundView addSubview:timeView];
    
    UILabel *currentLabel = [[UILabel alloc] init];
    currentLabel.frame = CGRectMake(2, 0, self.width / 2, timeView.bounds.size.height);
    currentLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    currentLabel.shadowOffset = CGSizeMake(0, 0);
    currentLabel.textColor = [UIColor whiteColor];
    self.currentTime = currentLabel;
    currentLabel.text = @"";
    currentLabel.textAlignment = NSTextAlignmentLeft;
    [timeView addSubview:currentLabel];
    
    UILabel *leftLabel = [[UILabel alloc] init];
    leftLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin;
    leftLabel.shadowOffset = CGSizeMake(0, 0);
    leftLabel.frame = CGRectMake(self.width / 2 - 2, 0, self.width / 2, timeView.bounds.size.height);
    self.leftTime = leftLabel;
    leftLabel.text = @"";
    leftLabel.textColor = [UIColor whiteColor];
    leftLabel.textAlignment = NSTextAlignmentRight;
    [timeView addSubview:leftLabel];
    
    //歌曲名
    UILabel *songLabel = [[UILabel alloc] init];
    songLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    songLabel.text = @"尚未播放歌曲";
    songLabel.textColor = [UIColor whiteColor];
    songLabel.textAlignment = NSTextAlignmentCenter;
    self.songLabel = songLabel;
    [self.backgroundView addSubview:songLabel];
    //歌手名
    PCLabel *artistLabel = [[PCLabel alloc] init];
    artistLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    self.artistLabel = artistLabel;
    [self.backgroundView addSubview:artistLabel];
    //专辑名
    PCLabel *albumLabel = [[PCLabel alloc] init];
    self.albumLabel = albumLabel;
    albumLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    [self.backgroundView addSubview:albumLabel];
    
    int height = self.view.bounds.size.height;
    switch (height) {
        case 480:
            songLabel.frame = CGRectMake(0, CGRectGetMaxY(timeView.frame) + 15, self.width, 40);
            songLabel.font = [UIFont fontWithName:@"BebasNeue" size:30];
            artistLabel.frame = CGRectMake(0, CGRectGetMaxY(songLabel.frame), self.width, 20);
            albumLabel.frame = CGRectMake(0, CGRectGetMaxY(artistLabel.frame), self.width, 20);
            break;
        case 568:
            songLabel.frame = CGRectMake(0, CGRectGetMaxY(timeView.frame) + 40, self.width, 40);
            songLabel.font = [UIFont fontWithName:@"BebasNeue" size:30];
            artistLabel.frame = CGRectMake(0, CGRectGetMaxY(songLabel.frame), self.width, 20);
            albumLabel.frame = CGRectMake(0, CGRectGetMaxY(artistLabel.frame), self.width, 20);
            break;
        case 667:
            songLabel.frame = CGRectMake(0, CGRectGetMaxY(timeView.frame) + 40, self.width, 40);
            songLabel.font = [UIFont fontWithName:@"BebasNeue" size:40];
            artistLabel.frame = CGRectMake(0, CGRectGetMaxY(songLabel.frame) + 20, self.width, 25);
            artistLabel.font = [UIFont fontWithName:@"BebasNeue" size:25];
            albumLabel.frame = CGRectMake(0, CGRectGetMaxY(artistLabel.frame) + 20, self.width, 25);
            albumLabel.font = [UIFont fontWithName:@"BebasNeue" size:23];
            break;
        default:
            songLabel.frame = CGRectMake(0, CGRectGetMaxY(timeView.frame) + 60, self.width, 42);
            songLabel.font = [UIFont fontWithName:@"BebasNeue" size:40];
            artistLabel.frame = CGRectMake(0, CGRectGetMaxY(songLabel.frame) + 20, self.width, 27);
            artistLabel.font = [UIFont fontWithName:@"BebasNeue" size:25];
            albumLabel.frame = CGRectMake(0, CGRectGetMaxY(artistLabel.frame) + 20, self.width, 27);
            albumLabel.font = [UIFont fontWithName:@"BebasNeue" size:25];
            break;
    }
}
#pragma mark - 添加TabBar界面
- (void)setupTabBar {
    self.controllers = [NSMutableArray array];
    //每月文章列表页
    PCArticleViewController *article = [[PCArticleViewController alloc] init];
    [self setupSingleViewControllerToScrollView:article hidden:NO];
    //已下载歌曲页面
    PCMyMusicViewController *myMusic  =[[PCMyMusicViewController alloc] init];
    [self setupSingleViewControllerToScrollView:myMusic hidden:YES];
    //导航页面
    PCNaviController *navi = [[PCNaviController alloc] init];
    [self setupSingleViewControllerToScrollView:navi hidden:YES];
    //设置页面
    PCSettingViewController *setting = [[PCSettingViewController alloc] init];
    [self setupSingleViewControllerToScrollView:setting hidden:YES];
    /** 添加Button */
    for (int i = 0; i < 4; i++) {
        PCButton *button;
        switch (i) {
            case 0:
                button = [[PCButton alloc] initWithFrame:CGRectMake(i * self.width / 4, self.height, self.width / 4, 64) image:@"songsButton"];
                [self buttonClick:button];
                break;
            case 1:
                button = [[PCButton alloc] initWithFrame:CGRectMake(i * self.width / 4, self.height, self.width / 4, 64) image:@"albumsButton"];
                break;
            case 2:
                button = [[PCButton alloc] initWithFrame:CGRectMake(i * self.width / 4, self.height, self.width / 4, 64) image:@"artistsButtonInverted"];
                break;
            case 3:
                button = [[PCButton alloc] initWithFrame:CGRectMake(i * self.width / 4, self.height, self.width / 4, 64) image:@"podcastsButton"];
                break;
            default:
                break;
        }
        button.tag = i;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(panTheButton:) forControlEvents:UIControlEventTouchDragInside];
        [self.scrollView addSubview:button];
    }
}
- (void)setupSingleViewControllerToScrollView:(UIViewController *)controller hidden:(BOOL)hidden {
    PCNavigationController *nav = [[PCNavigationController alloc] initWithRootViewController:controller];
    nav.view.frame = CGRectMake(0, self.height + 20, self.width, self.height - 20);
    [self.scrollView addSubview:nav.view];
    [self.controllers addObject:nav];
    nav.view.hidden = hidden;
    if (hidden == NO) {
        self.selectedView = nav.view;
    }
}

#pragma mark - 获取通知
- (void)getNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(didSelectedSong:) name:@"selected" object:nil];
    [center addObserver:self selector:@selector(speaking) name:@"speaking" object:nil];
    [center addObserver:self selector:@selector(nonspeaking) name:@"nonspeaking" object:nil];
}
- (void)didSelectedSong:(NSNotification *)sender {
    //滚到上层
    self.scrollView.scrollEnabled = YES;
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    NSArray *songs = sender.userInfo[@"songs"];
    NSInteger index = [sender.userInfo[@"indexPath"] integerValue];
    self.songs = songs;
    self.index = index;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self playFromPlaylist:songs itemIndex:index state:PCAudioPlayStatePlay];
        [self changePlayerInterfaceDuringUsing:self.songs[index] row:index state:PCAudioPlayStatePlay];
    });
    
}
- (void)speaking {
    self.audioController.volume = 0.1;
}
- (void)nonspeaking {
    self.audioController.volume = 1;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"selected" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"speaking" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"nonspeaking" object:nil];
}
#pragma mark - 播放相关
/** 开始播放 */
- (void)playFromPlaylist:(NSArray *)playlist itemIndex:(NSUInteger)index state:(PCAudioPlayState)state {
    self.paused = NO;
    //检查文件是否已存在
    NSString *rootPath = [self dirDoc];
    PCSong *song = playlist[index];
    NSString *filePath = [rootPath  stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ - %@.mp3",song.artist,song.songName]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //播放本地
    if ([fileManager fileExistsAtPath:filePath]) {
        song.URL = filePath;
        [self.audioController playFromURL:[NSURL fileURLWithPath:song.URL]];
    } else {
        [self.audioController playFromURL:[NSURL URLWithString:song.URL]];
    }
    
    [self addCurrentTimeTimer];
    if (state == PCAudioPlayStatePlay) [MBProgressHUD showPlayState:@"playB" toView:self.backgroundView];
    if (state == PCAudioPlayStatePause) [MBProgressHUD showPlayState:@"pauseB" toView:self.backgroundView];
    
}
- (void)changePlayerInterfaceDuringUsing:(PCSong *)song row:(NSInteger)row state:(PCAudioPlayState)state{
    self.progress.progress = 0;
    //倒影封面
    [self.cover sd_setImageWithURL:[NSURL URLWithString:song.cover] placeholderImage:self.cover.image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.reflectionCover.image = [self.cover.image reflectionWithAlpha:0.3];
        //修改进度条颜色
        TDImageColors *imageColors = [[TDImageColors alloc] initWithImage:self.cover.image count:5];
        self.progress.color = imageColors.colors[1];
        //修改歌名
        self.songLabel.text = song.songName;
        //修改歌手名
        self.artistLabel.text = song.artist;
        self.artistLabel.textColor = imageColors.colors[1];
        //修改专辑名
        self.albumLabel.text = song.album;
        self.albumLabel.textColor = imageColors.colors[1];
        //设置锁屏信息
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        //设置专辑名称
        info[MPMediaItemPropertyAlbumTitle] = song.album;
        info[MPMediaItemPropertyArtist] = song.artist;
        info[MPMediaItemPropertyTitle] = song.songName;
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:self.cover.image];
        
        
        
        info[MPMediaItemPropertyArtwork] = artwork;
        NSTimeInterval duration = self.audioController.activeStream.duration.minute * 60 + self.audioController.activeStream.duration.second;
        info[MPMediaItemPropertyPlaybackDuration] = @(duration);
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = info;
    }];
}
#pragma mark - 获取文件主路径
- (NSString *)dirDoc{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

/** 给播放器添加手势操作 */
- (void)setupGestureRecognizer {
    //播放和暂停
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playOrPause)];
    singleTap.numberOfTapsRequired = 1;
    [self.backgroundView addGestureRecognizer:singleTap];
    //上一首
    UISwipeGestureRecognizer *swipeFromLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(playPrevious)];
    [swipeFromLeft setDirection:UISwipeGestureRecognizerDirectionRight];
    swipeFromLeft.numberOfTouchesRequired = 1;
    [self.backgroundView addGestureRecognizer:swipeFromLeft];
    //下一首
    UISwipeGestureRecognizer *swipeFromRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(playNext)];
    swipeFromRight.numberOfTouchesRequired = 1;
    [swipeFromRight setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.backgroundView addGestureRecognizer:swipeFromRight];
    //快进
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doSeeking:)];
    longPress.numberOfTouchesRequired = 1;
    longPress.minimumPressDuration = 0.5;
    [self.backgroundView addGestureRecognizer:longPress];
}
/** 播放或者暂停 */
- (void)playOrPause {
    [self.audioController pause];
    if (self.audioController.isPlaying) {
        [MBProgressHUD showPlayState:@"playB" toView:self.backgroundView];
        self.paused = NO;
    } else {
        [MBProgressHUD showPlayState:@"pauseB" toView:self.backgroundView];
        self.paused = YES;
    }
}
/** 下一首 */
- (void)playNext {
    if (self.index == self.songs.count - 1) {
        self.index = 0;
    } else {
        self.index = self.index + 1;
    }
    
    [self playFromPlaylist:self.songs itemIndex:self.index state:PCAudioPlayStateNext];
    
    PCSong *song = self.songs[self.index];
    [self changePlayerInterfaceDuringUsing:song row:self.index state:PCAudioPlayStateNext];
    [MBProgressHUD showPlayState:@"nextB" toView:self.backgroundView];
}
/** 上一首 */
- (void)playPrevious {
#warning 没有添加播放小于五秒的上一首播放
    if (self.index == 0) {
        self.index = self.songs.count - 1;
    } else {
        self.index = (int)self.index - 1;
    }
    
    [self playFromPlaylist:self.songs itemIndex:self.index state:PCAudioPlayStatePrevious];
    
    PCSong *song = self.songs[self.index];
    [self changePlayerInterfaceDuringUsing:song row:self.index state:PCAudioPlayStatePrevious];
    [MBProgressHUD showPlayState:@"prevB" toView:self.backgroundView];
}
/** 快进快退 */
- (void)doSeeking:(UILongPressGestureRecognizer *)recognizer {
    FSStreamPosition seek;
    CGPoint lastPoint;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        //缩小
        CGRect tempBounds = self.backgroundView.bounds;
        tempBounds.size.width -= 40;
        tempBounds.size.height -= 40;
        self.backgroundView.bounds = tempBounds;
        //获取按住播放时间
        FSStreamPosition now = self.audioController.activeStream.currentTimePlayed;
        self.progressOriginal = now.position;
        self.originalPoint = [recognizer locationInView:self.view];
    }
    //改变进度条的值
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint changingPoint = [recognizer locationInView:self.view];
        CGFloat seekForwardPercent =  self.progressOriginal + ((changingPoint.x - self.originalPoint.x) / self.width);
        if (seekForwardPercent >= 1 || seekForwardPercent < 0) {
            return;
        }
        self.progress.progress = seekForwardPercent;
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        //还原
        lastPoint = [recognizer locationInView:self.view];
        self.backgroundView.frame = self.view.frame;
        //如果没有移动不移动进度条
        if (lastPoint.x == self.originalPoint.x) {
            return;
        }
        seek.position = self.progress.progress;
        [self.audioController.activeStream seekToPosition:seek];
    }
}

#pragma mark - 添加定时器
- (void)addCurrentTimeTimer {
    if (self.paused == YES) return;
    
    [self removeCurrentTimeTimer];
    //保证定时器的工作是即时的
    [self updateCurrentTime];
    [self updatePlayBackProgress];
    
    self.currentTimeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCurrentTime) userInfo:nil repeats:YES];
    self.PlayBackTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updatePlayBackProgress) userInfo:nil repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:self.currentTimeTimer forMode:NSRunLoopCommonModes];
    [[NSRunLoop mainRunLoop] addTimer:self.PlayBackTimer forMode:NSRunLoopCommonModes];
    
}
#pragma mark - 移除定时器
- (void)removeCurrentTimeTimer {
    
    [self.currentTimeTimer invalidate];
    [self.PlayBackTimer invalidate];
    
    self.currentTimeTimer = nil;
    self.PlayBackTimer = nil;
    
}
/** 更新播放进度 */
- (void)updateCurrentTime {
    //计算进度值
    if (self.audioController.activeStream.duration.minute == 0 && self.audioController.activeStream.duration.second == 0) return;
    //取出当前播放时长以及总时长
    FSStreamPosition cur = self.audioController.activeStream.currentTimePlayed;
    FSStreamPosition total = self.audioController.activeStream.duration;
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
    
    
#warning 没考虑好
    //当播放停止或者暂停时移除监视器
    if (totalLeftSecond <= 1) {
        [self playNext];
    }
}

- (void)updatePlayBackProgress {
    if (self.audioController.activeStream.contentLength > 0) {
        
        if (self.bufferingIndicator.progress >= 1.0) {
            [self.PlayBackTimer invalidate];
        }
        
        FSSeekByteOffset currentOffset = self.audioController.activeStream.currentSeekByteOffset;
        UInt64 totalBufferedData = currentOffset.start + self.audioController.activeStream.prebufferedByteCount;
        float bufferedDataFromTotal = (float)totalBufferedData / self.audioController.activeStream.contentLength;
        self.bufferingIndicator.progress = bufferedDataFromTotal;
        
    } else {
        self.bufferingIndicator.progress = (float)self.audioController.activeStream.prebufferedByteCount / _maxPrebufferedByteCount;
    }
}
#pragma mark - 点击tabBarButton事件
- (void)buttonClick:(PCButton *)btn {
    self.selectedBtn.selected = NO;
    btn.selected = YES;
    self.selectedBtn = btn;
    self.selectedView.hidden = YES;
    UIViewController *controller = self.controllers[btn.tag];
    controller.view.hidden = NO;
    self.selectedView = controller.view;
}
#pragma mark - 下拉Button事件
- (void)panTheButton:(PCButton *)btn {
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    self.scrollView.scrollEnabled = YES;
}

#pragma mark - scrollView代理方法
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    /** 1.取出水平方向上的滚动距离 */
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY == self.height) {
        scrollView.scrollEnabled = NO;
    }
    
}

@end
