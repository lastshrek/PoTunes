//
//  ViewController.m
//  PoTunes
//
//  Created by Purchas on 15/9/1.
//  Copyright © 2015年 Purchas. All rights reserved.
//

#import "ViewController.h"
#import "PoTunes-swift.h"
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
#import "TDImageColors.h"
#import "DarwinNotificationHelper.h"
#import "FMDB.h"
#import "PCBlurView.h"
#import "AFNetworking.h"
#import "DMCPlayback.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "Reachability.h"

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
    PCAudioPlayStatePrevious,

};

@interface ViewController ()<UIScrollViewDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate>
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
@property (nonatomic, weak) UIImageView *playModeImageView;
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
@property (nonatomic, assign) PCAudioRepeatMode audioRepeatMode;
/** 下载歌曲数据库 */
@property (nonatomic, strong) FMDatabase *downloadedSongDB;
/** 歌词 */
@property (nonatomic, weak) PCBlurView *lrcView;
/** 显示歌词的定时器 */
@property (nonatomic, strong) CADisplayLink *lrcTimer;
/** 存储专辑封面 */
@property (nonatomic, weak) UIImage *originalImage;

/** CWPlayerback */
@property (nonatomic, strong) DMCPlayback *player;

/** 当前播放器 */
@property (nonatomic, copy) NSString *currentPlayer;
/** 检测网络状态 */
@property (nonatomic, strong) Reachability *conn;
/** 当前网络状态 */
@property (nonatomic, assign) int reachable;
@end

@implementation ViewController

- (FMDatabase *)downloadedSongDB {
    
    if (_downloadedSongDB == nil) {
        
        //打开数据库
        NSString *path = [[self dirDoc] stringByAppendingPathComponent:@"downloadingSong.db"];
        
        _downloadedSongDB = [FMDatabase databaseWithPath:path];
        
        [_downloadedSongDB open];
        
        //创表

        [_downloadedSongDB executeUpdate:@"CREATE TABLE IF NOT EXISTS t_downloading (id integer PRIMARY KEY, author text, title text, sourceURL text,indexPath integer,thumb text,album text,downloaded bool, identifier text);"];
        
        if (![_downloadedSongDB columnExists:@"identifier" inTableWithName:@"t_downloading"]) {
            
            NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ text", @"t_downloading", @"identifier"];
            
            [_downloadedSongDB executeUpdate:sql];
        }
        
        _downloadedSongDB.shouldCacheStatements = YES;
        
    }
    return _downloadedSongDB;
    
}
- (void)viewDidLoad {
    
    [super viewDidLoad];

    
    /** 添加播放器界面 */
    [self setupPlayerInterface];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    NSString *online = [user objectForKey:@"online"];
    
    if (online == nil) {
        [self setupTabBarWithCount:3];
    }
    
    if ([online isEqualToString:@"online"]) {
        [self setupTabBarWithCount:4];

    }
    /** 注册通知 */
    [self getNotification];
    
    //设置appdelegate的block
    [self setupDelegateBlock];
    
    //获取上次播放曲目
    [self getLastPlaySongAndPlayState];
    
    NSLog(@"%@",[self dirDoc]);
    
    self.paused = YES;
    
    DMCPlayback *player = [[DMCPlayback alloc] init];
    
    self.player = player;
    


}
#pragma mark - 获取文件主路径
- (NSString *)dirDoc{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
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
    cover.image = [UIImage imageNamed:@"noArtwork.jpg"];
    cover.frame = CGRectMake(0, 0, self.width, self.width);
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
    bufferingIndicator.progressInset = 0;
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
    
    
    switch ((int)self.height) {
        case 480:
            songLabel.frame = CGRectMake(0, CGRectGetMaxY(timeView.frame) + 15, self.width, 40);
            songLabel.font = [UIFont fontWithName:@"BebasNeue" size:30];
            artistLabel.frame = CGRectMake(0, CGRectGetMaxY(songLabel.frame), self.width, 20);
            albumLabel.frame = CGRectMake(0, CGRectGetMaxY(artistLabel.frame), self.width, 20);
            break;
        case 568:
            songLabel.frame = CGRectMake(0, CGRectGetMaxY(timeView.frame) + 40, self.width, 40);
            songLabel.font = [UIFont fontWithName:@"BebasNeue" size:30];
            artistLabel.frame = CGRectMake(0, CGRectGetMaxY(songLabel.frame) + 15, self.width, 20);
            albumLabel.frame = CGRectMake(0, CGRectGetMaxY(artistLabel.frame) + 15, self.width, 20);
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
    UIImageView *playModeImageView = [[UIImageView alloc] init];
    playModeImageView.frame = CGRectMake(self.width / 2 - 10, self.height - 20, 20, 20);
    playModeImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    playModeImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.playModeImageView = playModeImageView;
    [self.backgroundView addSubview:playModeImageView];
    
    //添加歌词
    PCBlurView *lrcView = [[PCBlurView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.width)];
    lrcView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    lrcView.hidden = YES;
    self.lrcView = lrcView;
    [self.backgroundView addSubview:lrcView];
    
    
}
#pragma mark - 添加TabBar界面
- (void)setupTabBarWithCount:(int)count {
    self.controllers = [NSMutableArray array];
    //每月文章列表页
    PCArticleViewController *article = [[PCArticleViewController alloc] init];
    [self setupSingleViewControllerToScrollView:article hidden:NO];
    //已下载歌曲页面
    if (count == 4) {
        PCMyMusicViewController *myMusic  =[[PCMyMusicViewController alloc] init];
        [self setupSingleViewControllerToScrollView:myMusic hidden:YES];
    }
    //导航页面
    PCNaviController *navi = [[PCNaviController alloc] init];
    [self setupSingleViewControllerToScrollView:navi hidden:YES];
    //设置页面
    PCSettingViewController *setting = [[PCSettingViewController alloc] init];
    [self setupSingleViewControllerToScrollView:setting hidden:YES];
    /** 添加Button */
    for (int i = 0; i < count; i++) {
        PCButton *button = [[PCButton alloc] initWithFrame:CGRectMake(i * self.width / count, self.height, self.width / count, 64) image:[NSString stringWithFormat:@"%d", i + 1]];
        if (i == 0) {
            [self buttonClick:button];
        }
        button.tag = i;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        UISwipeGestureRecognizer *swipeFromTop = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(panTheButton:)];
        [swipeFromTop setDirection:UISwipeGestureRecognizerDirectionDown];
        swipeFromTop.numberOfTouchesRequired = 1;
        [button addGestureRecognizer:swipeFromTop];
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
                [self playNext:self.audioRepeatMode];
                break;
            
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self playPrevious:self.audioRepeatMode];
                break;
            
            default:
                break;
        }
    };
}
#pragma mark - 获取上次播放进度以及状态
- (void)getLastPlaySongAndPlayState {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSData *songsData = [defaults objectForKey:@"songsData"];
    
    if (songsData == nil) {
                
        self.audioRepeatMode = PCAudioRepeatModePlaylist;
        
        return;
    
    }
    
    NSArray *songs = [NSKeyedUnarchiver unarchiveObjectWithData:songsData];
    
    NSNumber *index = [defaults objectForKey:@"index"];
    
    NSNumber *repeatMode = [defaults objectForKey:@"repeatMode"];
    
    self.songs = songs;
    
    self.index = [index integerValue];
    
    self.audioRepeatMode = [repeatMode intValue];
    
    if (self.audioRepeatMode == PCAudioRepeatModeSingle) {
        
        self.playModeImageView.image = [UIImage imageNamed:@"repeatOneB"];
        
    } else if (self.audioRepeatMode == PCAudioRepeatModeShuffle) {
        
        self.playModeImageView.image = [UIImage imageNamed:@"shuffleOnB"];
    
    } else {
    
        self.playModeImageView.image = [UIImage imageNamed:@"repeatOnB"];
    
    }
    
    [self changePlayerInterfaceDuringUsing:self.songs[self.index] row:self.index];
    
}

#pragma mark - 获取通知
- (void)getNotification {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
   
    [center addObserver:self selector:@selector(didSelectedSong:) name:@"selected" object:nil];
    
    [center addObserver:self selector:@selector(speaking) name:@"speaking" object:nil];
    
    [center addObserver:self selector:@selector(nonspeaking) name:@"nonspeaking" object:nil];
    
    [center addObserver:self selector:@selector(setupFullTabBar) name:@"finishLoading" object:nil];
    
    [center addObserver:self selector:@selector(audioSessionDidChangeInterruptionType:)
                                                 name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    
    [center addObserver:self selector:@selector(networkStateChange) name:kReachabilityChangedNotification object:nil];
    
    self.conn = [Reachability reachabilityForInternetConnection];
    
    [self.conn startNotifier];
    
    self.reachable = [self.conn currentReachabilityStatus];

}
- (void)didSelectedSong:(NSNotification *)sender {
    //滚到上层
    self.scrollView.scrollEnabled = YES;
    
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    NSArray *songs = sender.userInfo[@"songs"];
    
    NSInteger index = [sender.userInfo[@"indexPath"] integerValue];
    
    self.songs = songs;
    
    self.index = index;
        
    NSString *type = sender.userInfo[@"type"];
    
    //判断用户网络状态以及是否允许网络播放
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    BOOL yes = [[user objectForKey:@"wwanPlay"] boolValue];
    
    
    if (!yes && self.conn.currentReachabilityStatus != 2 && ![type isEqualToString:@"local"]) {
        
        //初始化AlertView
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                        message:@"您当前处于运营商网络中，是否继续播放"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确认",nil];
        [alert show];
        
        return;
    }
    
    
    if (self.conn.currentReachabilityStatus == 2 || [type isEqualToString:@"local"] || yes) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self playFromPlaylist:songs itemIndex:index state:PCAudioPlayStatePlay];
            
            [self changePlayerInterfaceDuringUsing:self.songs[index] row:index];
            
        });
    }
}
- (void)speaking {
    
    self.audioController.volume = 0.1;
    
}
- (void)nonspeaking {
   
    self.audioController.volume = 1;
    
}
- (void)setupFullTabBar {
    [self setupTabBarWithCount:4];
}
- (void)audioSessionDidChangeInterruptionType:(NSNotification *)notification {
    
    NSInteger interruptReason = [[notification.userInfo objectForKey:@"AVAudioSessionRouteChangeReasonKey"] integerValue];
    
    if (interruptReason == 2) {
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
            dispatch_sync(dispatch_get_main_queue(), ^{
            
                [self.audioController pause];
            });
        });
    }
    
}
- (void)networkStateChange {
    // 1.检测wifi状态
    Reachability *wifi = [Reachability reachabilityForLocalWiFi];
    // 2.检测手机是否能上网络(WIFI\3G\2.5G)
    Reachability *conn = [Reachability reachabilityForInternetConnection];
    
    // 3.判断网络状态
    if ([wifi currentReachabilityStatus] != NotReachable) { // 有wifi
        self.reachable = 2;
    } else if ([conn currentReachabilityStatus] != NotReachable) { // 没有使用wifi, 使用手机自带网络进行上网
        self.reachable = 1;
    } else { // 没有网络
        self.reachable = 0;
    }
}
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"selected" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"speaking" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"nonspeaking" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"finishLoading" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    
    [self.conn stopNotifier];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}
#pragma mark - 播放相关

/** 开始播放 */
- (void)playFromPlaylist:(NSArray *)playlist itemIndex:(NSUInteger)index state:(PCAudioPlayState)state {
    
    self.paused = NO;
    
    self.audioController = nil;
    
    self.audioController = [[FSAudioController alloc] init];
    
    //检查文件是否已存在
    NSString *rootPath = [self dirDoc];
    
    PCSong *song = playlist[index];
    
    NSString *songQuery = [NSString stringWithFormat:@"SELECT * FROM t_downloading WHERE sourceURL = '%@';", song.sourceURL];
    
    FMResultSet *songS = [self.downloadedSongDB executeQuery:songQuery];
    
    NSString *filePath;
    
    if (songS.next) {
        
        filePath = [rootPath  stringByAppendingPathComponent:[songS stringForColumn:@"identifier"]];
        
    }

    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    self.currentPlayer = @"PC";
    //播放本地
    
    if ([fileManager fileExistsAtPath:filePath]) {
        
        NSString *author = [song.author stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        
        NSString *title = [song.title stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM t_downloading WHERE author = '%@' and title = '%@';", author, title];
        
        FMResultSet *s = [self.downloadedSongDB executeQuery:query];

        if (s.next) {
            
            BOOL downloaded = (BOOL)[s stringForColumn:@"downloaded"];
            
            if (downloaded) {
                
                [self.audioController.activeStream playFromURL:[NSURL fileURLWithPath:filePath]];
                
            } else {
                
                [self.audioController.activeStream playFromURL:[NSURL URLWithString:song.sourceURL]];

            }
        }

    } else {
        
        if (![song.sourceURL hasPrefix:@"http"]) {
            
            self.audioController = nil;
            
            self.currentPlayer = @"topdmc";
            
            [DMCPlayback playWithTrackID:song.sourceURL];
            
            [DMCPlayback listenFeedbackUpdatesWithBlock:^(DMCTrack *track) {
                
                if (track.timePlayed == track.duration) {
                    
                    [self playNext:self.audioRepeatMode];
                    
                }
                
                self.currentTime.text = [NSString stringWithFormat:@"%d:%d", (int)track.timePlayed / 60, (int)(track.timePlayed) % 60];
                
                self.leftTime.text = [NSString stringWithFormat:@"%d:%d", (int)(track.duration) / 60, (int)(track.duration) % 60];
                
                self.progress.progress = (float)track.timePlayed / (float)track.duration;
                
            } andFinishedBlock:^{
                
            }];
            
        } else {
            
            [self.audioController.activeStream playFromURL:[NSURL URLWithString:song.sourceURL]];

        }
    }
    //添加进度条定时器
    [self addCurrentTimeTimer];
    //添加歌词定时器
    [self addLrcTimer];
    
    
    if (self.audioRepeatMode != PCAudioRepeatModeSingle && self.audioRepeatMode != PCAudioRepeatModeShuffle) {
        
        if (state == PCAudioPlayStatePlay) [MBProgressHUD showPlayState:@"playB" toView:self.backgroundView];
        
        if (state == PCAudioPlayStatePause) [MBProgressHUD showPlayState:@"pauseB" toView:self.backgroundView];
    }
}
- (void)changePlayerInterfaceDuringUsing:(PCSong *)song row:(NSInteger)row {
    
    self.progress.progress = 0;
    
    self.lrcView.lrcName = nil;
    
    self.lrcView.chLrcName = nil;
    
    self.lrcView.noLrcLabel.text = @"暂无歌词";
    

    //倒影封面
    [self.cover sd_setImageWithURL:[NSURL URLWithString:song.thumb] placeholderImage:self.cover.image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.lrcView.renderStatic = NO;
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.lrcView.renderStatic = YES;
            self.reflectionCover.image = [image reflectionWithAlpha:0.3];
        });
        
        TDImageColors *imageColors = [[TDImageColors alloc] initWithImage:self.cover.image count:2];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.progress.color = imageColors.colors[1];
        });
        
        
        //修改歌名
        self.songLabel.text = song.title;
        
        //修改歌手名
        self.artistLabel.text = song.author;
        self.artistLabel.textColor = imageColors.colors[1];
        
        //修改专辑名
        self.albumLabel.text = song.album;
        self.albumLabel.textColor = imageColors.colors[1];
        
        //设置歌词
        NSString *identifier = [NSString stringWithFormat:@"%@ - %@",song.author, song.title];
        
        NSString *lrcString = [song.sourceURL stringByReplacingOccurrencesOfString:@".mp3" withString:@".lrc"];
        
        identifier = [identifier stringByReplacingOccurrencesOfString:@" / " withString:@" "];
        
        NSString *rootPath = [self dirDoc];
        
        NSString *filePath = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.lrc", identifier]];
        
        filePath = [filePath stringByReplacingOccurrencesOfString:@" / " withString:@" "];
        
        NSFileManager *manager = [NSFileManager defaultManager];
        
        if ([manager fileExistsAtPath:filePath]) {
            
            self.lrcView.lrcName = [identifier stringByAppendingString:@".lrc"];
            
            self.lrcView.noLrcLabel.hidden = YES;
            
            if ([manager fileExistsAtPath:[filePath stringByReplacingOccurrencesOfString:@".lrc" withString:@"ch.lrc"]]) {
                
                self.lrcView.chLrcName = [identifier stringByAppendingString:@"ch.lrc"];
                
                [manager removeItemAtPath:[filePath stringByReplacingOccurrencesOfString:@".lrc" withString:@"ch.lrc"] error:nil];
                
            } else {
                
                [self beginDownloadLyricWithIdentifier:[identifier stringByAppendingString:@"ch"] URL:[lrcString stringByReplacingOccurrencesOfString:@".lrc" withString:@"ch.lrc"] success:^(id responseObject) {
                    
                    self.lrcView.chLrcName = [identifier stringByAppendingString:@"ch.lrc"];
                    
                    [manager removeItemAtPath:[filePath stringByReplacingOccurrencesOfString:@".lrc" withString:@"ch.lrc"] error:nil];
                    
                } failure:^(NSError *error) {
                    
                    [manager removeItemAtPath:[filePath stringByReplacingOccurrencesOfString:@".lrc" withString:@"ch.lrc"] error:nil];

                }];
            }
            
        } else {
            
            self.lrcView.noLrcLabel.text = @"正在下载";
            
            [self beginDownloadLyricWithIdentifier:identifier URL:lrcString success:^(id responseObject) {
               
                self.lrcView.lrcName = [identifier stringByAppendingString:@".lrc"];
                
                self.lrcView.noLrcLabel.hidden = YES;
                
                [self beginDownloadLyricWithIdentifier:[identifier stringByAppendingString:@"ch"] URL:[lrcString stringByReplacingOccurrencesOfString:@".lrc" withString:@"ch.lrc"] success:^(id responseObject) {
                    
                    self.lrcView.chLrcName = [identifier stringByAppendingString:@"ch.lrc"];
                    
                    [manager removeItemAtPath:[filePath stringByReplacingOccurrencesOfString:@".lrc" withString:@"ch.lrc"] error:nil];
                    
                } failure:^(NSError *error) {
                                    
                }];
                
                [manager removeItemAtPath:filePath error:nil];

            
            } failure:^(NSError *error) {
                
                self.lrcView.noLrcLabel.text = @"暂无歌词";
                
                self.lrcView.noLrcLabel.hidden = NO;
                
                self.lrcView.lrcName = nil;
                
                [manager removeItemAtPath:filePath error:nil];
                
            }];
            
        }
    
        //设置锁屏信息
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        //设置专辑名称
        info[MPMediaItemPropertyAlbumTitle] = song.album;
        info[MPMediaItemPropertyArtist] = song.author;
        info[MPMediaItemPropertyTitle] = song.title;
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:self.cover.image];
        info[MPMediaItemPropertyArtwork] = artwork;
        NSTimeInterval duration = self.audioController.activeStream.duration.minute * 60 + self.audioController.activeStream.duration.second;
        info[MPMediaItemPropertyPlaybackDuration] = @(duration);
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = info;
        
        //记录最后一次播放的歌曲以及播放模式
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:@(self.audioRepeatMode) forKey:@"repeatMode"];
        NSData *songsData = [NSKeyedArchiver archivedDataWithRootObject:self.songs];
        [defaults setObject:songsData forKey:@"songsData"];
        [defaults setObject:@(self.index) forKey:@"index"];
    }];
    
    if (song.thumb.length == 0) {
        self.cover.image = [UIImage imageNamed:@"noArtwork.jpg"];
        self.reflectionCover.image = [[UIImage imageNamed:@"noArtwork.jpg"] reflectionWithAlpha:0.3];
    }
}
- (void)beginDownloadLyricWithIdentifier:(NSString *)identifier URL:(NSString *)URLString success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure {
    
    NSString *rootPath = [self dirDoc];
    
    //保存路径
    NSString *filePath = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.lrc", identifier]];
    
    filePath = [filePath stringByReplacingOccurrencesOfString:@" / " withString:@" "];
    
    //初始化队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSURL *URL = [NSURL URLWithString:URLString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    op.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        success(responseObject);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure(error);
        
    }];
    
    //开始下载
    [queue addOperation:op];
}
#pragma mark - 给播放器添加手势操作
- (void)setupGestureRecognizer {
    //播放和暂停
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playOrPause)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.backgroundView addGestureRecognizer:singleTap];
    //上一首
    UISwipeGestureRecognizer *swipeFromLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(playPrevious:)];
    [swipeFromLeft setDirection:UISwipeGestureRecognizerDirectionRight];
    swipeFromLeft.numberOfTouchesRequired = 1;
    [self.backgroundView addGestureRecognizer:swipeFromLeft];
    //下一首
    UISwipeGestureRecognizer *swipeFromRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(playNext:)];
    swipeFromRight.numberOfTouchesRequired = 1;
    [swipeFromRight setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.backgroundView addGestureRecognizer:swipeFromRight];
    //快进
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doSeeking:)];
    longPress.numberOfTouchesRequired = 1;
    longPress.minimumPressDuration = 0.5;
    [self.backgroundView addGestureRecognizer:longPress];
    //随机
    UISwipeGestureRecognizer *doubleswipeFromRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(playShuffle:)];
    [doubleswipeFromRight setDirection:UISwipeGestureRecognizerDirectionRight];
    doubleswipeFromRight.numberOfTouchesRequired = 2;
    [self.backgroundView addGestureRecognizer:doubleswipeFromRight];
    
    //随机
    UISwipeGestureRecognizer *doubleswipeFromLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(playShuffle:)];
    [doubleswipeFromLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    doubleswipeFromLeft.numberOfTouchesRequired = 2;
    [self.backgroundView addGestureRecognizer:doubleswipeFromLeft];
    
    //单曲循环
    UITapGestureRecognizer *doubleTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playSingle)];
    doubleTouch.numberOfTouchesRequired = 2;
    doubleTouch.numberOfTapsRequired = 1;
    [self.backgroundView addGestureRecognizer:doubleTouch];
    
    //展示歌词
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLyrics)];
    doubleTap.numberOfTapsRequired = 2;
    doubleTap.numberOfTouchesRequired = 1;
    [self.backgroundView addGestureRecognizer:doubleTap];

    //当识别不出这是双击时才开启单击识别
    [singleTap requireGestureRecognizerToFail:doubleTouch];
    [singleTap requireGestureRecognizerToFail:doubleTap];
}
/** 播放或者暂停 */
- (void)playOrPause {
    
    //当前无播放列表
    if (self.songs.count == 0) {
        
        [MBProgressHUD showError:@"向上滑动，更多精彩"];
        
        return;
    }
    
    if (self.paused == YES) {

        [DMCPlayback pause];
        
        [MBProgressHUD showPlayState:@"playB" toView:self.backgroundView];
        
    } else {
        
        [DMCPlayback pause];
        
        [MBProgressHUD showPlayState:@"pauseB" toView:self.backgroundView];

    
    }
    self.paused = !(self.paused);

    if (self.audioController.activeStream == nil && self.currentPlayer == nil) {
        
        [self playFromPlaylist:self.songs itemIndex:self.index state:PCAudioPlayStatePlay];
        
        return;
    }
    
    [self.audioController pause];
  
}
/** 下一首 */
- (void)playNext:(PCAudioRepeatMode)audioRepeatMode {
    
    //当前无播放列表
    if (self.songs.count == 0) {
    
        [MBProgressHUD showError:@"向上滑动，更多精彩"];
        
        return;
    }
    
    self.audioController = nil;
    
    if (self.audioRepeatMode == PCAudioRepeatModeShuffle){
    
        self.index = arc4random() % self.songs.count;
        
    } else if (self.audioRepeatMode == PCAudioRepeatModeSingle) {
        
        self.index = self.index;
        
    } else {
        
        if (self.index == self.songs.count - 1) {
        
            self.index = 0;
        
        } else {
            
            self.index = self.index + 1;
        }
    }
    
    [DMCPlayback stop];
    
    [self playFromPlaylist:self.songs itemIndex:self.index state:PCAudioPlayStateNext];
    
    PCSong *song = self.songs[self.index];
    
    [self changePlayerInterfaceDuringUsing:song row:self.index];
    
    [MBProgressHUD showPlayState:@"nextB" toView:self.backgroundView];
    
}
/** 上一首 */
- (void)playPrevious:(PCAudioRepeatMode)audioRepeatMode {
    
    if (self.songs.count == 0) {
    
        [MBProgressHUD showError:@"向上滑动，更多精彩"];
        
        return;
    
    }
    
    self.audioController = nil;
    
    FSStreamPosition cur = self.audioController.activeStream.currentTimePlayed;
    
    if (cur.minute == 0 || cur.second <= 5) {
        
        if (self.audioRepeatMode == PCAudioRepeatModeShuffle) {
            
            self.index = arc4random() % self.songs.count;
            
        } else if (self.audioRepeatMode == PCAudioRepeatModeSingle) {
            
            self.index = self.index;
            
        } else {
            
            if (self.index == 0) {
                
                self.index = self.songs.count - 1;
                
            } else {
                
                self.index = (int)self.index - 1;
                
            }
        }
    }
    
    [DMCPlayback stop];
    
    [self playFromPlaylist:self.songs itemIndex:self.index state:PCAudioPlayStatePrevious];
    
    PCSong *song = self.songs[self.index];
    
    [self changePlayerInterfaceDuringUsing:song row:self.index];
    
    [MBProgressHUD showPlayState:@"prevB" toView:self.backgroundView];
    
    self.view.userInteractionEnabled = YES;
    
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
        
        self.playModeImageView.frame = CGRectMake(self.width / 2 - 10, self.height - 20, 20, 20);
        //如果没有移动不移动进度条
        if (lastPoint.x == self.originalPoint.x) {
            return;
        }
        seek.position = self.progress.progress;
        
        [self.audioController.activeStream seekToPosition:seek];
    }
}
/** 随机 */
- (void)playShuffle:(UISwipeGestureRecognizer *)gestureRecognizer {
    
    [DMCPlayback stop];
    
    if (gestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
    
        [MBProgressHUD showPlayState:@"shuffleOnB" toView:self.backgroundView];
        
        self.audioRepeatMode = PCAudioRepeatModeShuffle;
        
        self.playModeImageView.image = [UIImage imageNamed:@"shuffleOnB"];


    } else {
        
        [MBProgressHUD showPlayState:@"shuffleOffB" toView:self.backgroundView];
        
        self.audioRepeatMode = PCAudioRepeatModeTowards;
        
        self.playModeImageView.image = [UIImage imageNamed:@"repeatOnB"];

    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:@(self.audioRepeatMode) forKey:@"repeatMode"];
    
}
/** 单曲循环 */
- (void)playSingle {
    
    [DMCPlayback stop];
    
    if (self.audioRepeatMode == PCAudioRepeatModeSingle) {
      
        [MBProgressHUD showPlayState:@"repeatOnB" toView:self.backgroundView];
        
        self.audioRepeatMode = PCAudioRepeatModeTowards;
        
        self.playModeImageView.image = [UIImage imageNamed:@"repeatOnB"];
    
    } else {
        
        [MBProgressHUD showPlayState:@"repeatOneB" toView:self.backgroundView];
        
        self.audioRepeatMode = PCAudioRepeatModeSingle;
        
        self.playModeImageView.image = [UIImage imageNamed:@"repeatOneB"];


    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:@(self.audioRepeatMode) forKey:@"repeatMode"];
    
}
/** 展示歌词 */
- (void)showLyrics {
    //歌词
    if (self.lrcView.hidden == YES) {
        
        self.lrcView.hidden = NO;

        self.lrcView.alpha = 0;
        
        [UIView animateWithDuration:0.5 animations:^{
        
            self.lrcView.alpha = 1;
            
        }];
        
        [UIView commitAnimations];
        
        [self addLrcTimer];
    
    } else {
        
        self.lrcView.alpha = 1;
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.lrcView.alpha = 0;

        }];
        
        [UIView commitAnimations];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
            self.lrcView.hidden = YES;

        });

    }
    
}
#pragma mark - 添加定时器
/** 进度条定时 */
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
/** 歌词定时器 */
- (void)addLrcTimer {
    
    if (self.lrcView.hidden == YES) return;
    
    if (self.audioController.activeStream.isPlaying == NO && self.lrcTimer) {
    
        [self updateLrcTimer];
        
        return;
    }
    
    [self removeLrcTimer];
    
    [self updateLrcTimer];
    
    self.lrcTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrcTimer)];
    
    [self.lrcTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
#pragma mark - 移除定时器
- (void)removeCurrentTimeTimer {
    
    [self.currentTimeTimer invalidate];
    
    [self.PlayBackTimer invalidate];
    
    self.currentTimeTimer = nil;
    
    self.PlayBackTimer = nil;
    
}
- (void)removeLrcTimer {
    
    [self.lrcTimer invalidate];
    
    self.lrcTimer = nil;
    
}
- (void)updateLrcTimer {
    
    //取出当前播放时长以及总时长
    FSStreamPosition cur = self.audioController.activeStream.currentTimePlayed;
    
    self.lrcView.currentTime = cur.minute * 60 + cur.second;
}
/** 更新播放进度以及缓冲进度 */
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

    __weak ViewController *weakSelf = self;
    
    self.audioController.onStateChange = ^(FSAudioStreamState state) {
    
        if (state == kFsAudioStreamPlaybackCompleted) {
        
            [weakSelf playNext:weakSelf.audioRepeatMode];
        
        }
    };
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
    
    NSNotification *pop = [NSNotification notificationWithName:@"pop" object:nil userInfo:nil];
    
    [[NSNotificationCenter defaultCenter] postNotification:pop];

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
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self playFromPlaylist:self.songs itemIndex:self.index state:PCAudioPlayStatePlay];
            
            [self changePlayerInterfaceDuringUsing:self.songs[self.index] row:self.index];
            
            NSUserDefaults *users = [NSUserDefaults standardUserDefaults];
            
            [users setObject:[NSNumber numberWithInt:1] forKey:@"wwanPlay"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"wwanPlay" object:nil userInfo:nil];
            
            
        });
        
        return;
        
    }
    
    if (buttonIndex == 0) {
        
        [self.audioController.activeStream pause];
    
    }
}
@end
