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

@interface PlayerInterface()<LTInfiniteScrollViewDelegate, LTInfiniteScrollViewDataSource>

@property (nonatomic, weak) UIView* backgroundView;
@property (nonatomic, weak) UIImageView* reflection;
@property (nonatomic, weak) LDProgressView* progress;
@property (nonatomic, weak) LDProgressView* bufferingIndicator;
@property (nonatomic, weak) UIView* timeView;
@property (nonatomic, weak) UILabel* currentTime;
@property (nonatomic, weak) UILabel* leftTime;
@property (nonatomic, weak) TrackLabel* name;
@property (nonatomic, weak) Track* artist;
@property (nonatomic, weak) UIImageView* playModeView;
@property (nonatomic, weak) LrcView* lrcView;
@property (nonatomic, weak) UIImageView* nowCover;
@property (nonatomic, weak) UIColor* currentProgressColor;

@property (nonatomic, assign) CGFloat progressOriginal;
@property (nonatomic, assign) CGPoint originalPoint;
@property (nonatomic, assign) PCAudioPlayState repeatMode;
@property (nonatomic, assign) Boolean paused;

@property (nonatomic, strong) FSAudioController* streamer;
@property (nonatomic, weak) NSTimer* currentTimeTimer;
@property (nonatomic, weak) NSTimer* playbackTimer;
@property (nonatomic, weak) CADisplayLink* lrcTimer;


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
- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self setup];
	}
	return self;
}


- (void)setup {
	
	[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
	
	self.backgroundColor = [UIColor whiteColor];
	
	[self initialSubviews];
	
	
}

- (void)initialSubviews {
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
	LDProgressView* bufferingIndicator = [self createProgressViewByFlat:false
															   progress:0
																animate:false
															   showText:false
															 showStroke:false
														  progressInset:0
														 showBackground:false
													   outerStrokeWidth:0
																   type:LDProgressSolid
													   autoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin
														   borderRadius:0
														backgroundColor:[UIColor lightTextColor]];
	[self.backgroundView addSubview:bufferingIndicator];
	self.bufferingIndicator = bufferingIndicator;
	
	//进度条
	LDProgressView* progress = [self createProgressViewByFlat:false
													 progress:0
													  animate:false
													 showText:false
												   showStroke:false
												progressInset:0
											   showBackground:false
											 outerStrokeWidth:0
														 type:LDProgressSolid
											 autoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin
												 borderRadius:0
											  backgroundColor:[UIColor clearColor]];
	[self.backgroundView addSubview:progress];
	self.progress = progress;
	
}

- (LDProgressView *)createProgressViewByFlat:(NSNumber*)flat
									progress:(CGFloat)progress
									animate:(NSNumber*)animate
									showText:(NSNumber*)showText
									showStroke:(NSNumber*)showStroke
									progressInset:(NSNumber*)progressInset
									showBackground:(NSNumber*)showBackground
									outerStrokeWidth: (NSNumber*)outerStrokeWidth
									type: (LDProgressType)type
									autoresizingMask:(UIViewAutoresizing)autoresizingMask
									borderRadius:(NSNumber*)borderRadius
									backgroundColor:(UIColor*)backgroundColor {
	
	LDProgressView* buffer = [[LDProgressView alloc] init];
	
	buffer.flat = flat;
	buffer.progress = progress;
	buffer.animate = animate;
	buffer.showText = showText;
	buffer.showStroke = showStroke;
	buffer.progressInset = progressInset;
	buffer.showBackground = showBackground;
	buffer.outerStrokeWidth = outerStrokeWidth;
	buffer.type = type;
	buffer.borderRadius = borderRadius;
	buffer.backgroundColor = backgroundColor;
	buffer.autoresizingMask = autoresizingMask;
	
	return buffer;
	
	
}

- (void)playTracks:(NSArray *)tracks index:(NSInteger)index {

}


@end

//
//class PlayerInterface: UIView, UIApplicationDelegate {
//	// MARK: - trackDB
//	lazy var tracksDB: FMDatabase = {
//		
//		let path = self.dirDoc() + "/downloadingSong.db"
//		
//		let db: FMDatabase = FMDatabase(path: path)
//		
//		db.open()
//		
//		return db
//	}()
//	
//	let lrcUrl = "https://poche.fm/api/app/lyrics/"
//	
//	override init(frame: CGRect) {
//		
//		initialSubviews()
//		addGestureRecognizer()
//		becomeFirstResponder()
//		getLastPlaySongAndPlayState()
//		getNotification()
//		
//	}
//	override var canBecomeFirstResponder: Bool { return true }
//	
//	required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//	
//	override func layoutSubviews() {
//		
//		super.layoutSubviews()
//		
//		backgroundView.frame = self.bounds
//		
//		let height = self.height()
//		
//		let width = self.width()
//		
//		reflection.frame =  CGRect(x: 0, y: height - width, width: width, height: width)
//		coverScroll.frame = CGRect(x: 0, y: 0, width: width, height: width)
//		lrcView.frame = CGRect(x: 0, y: 0, width: width, height: width)
//		bufferingIndicator?.frame = CGRect(x: 0, y: width, width: width, height: 15)
//		progress?.frame = CGRect(x: 0, y: width, width: width, height: 15)
//		playModeView.frame = CGRect(x: width / 2 - 10, y: height - 50, width: 20, height: 20)
//		// MARK: - 除3
//		self.name?.frame = CGRect(x: 0, y: width + 20, width: width, height: 40)
//		self.artist?.frame = CGRect(x: 0, y: width + 60, width: width, height: 40)
//		self.album?.frame = CGRect(x: 0, y: width + 100, width: width, height: 40)
//		timeView.frame = CGRect(x: 0, y: (self.progress?.frame.maxY)!, width: width, height: 20)
//		currentTime.frame = CGRect(x: 2, y: 0, width: width / 2, height: 20)
//		leftTime.frame = CGRect(x: width / 2 - 2, y: 0, width: width / 2, height: (self.timeView.bounds.size.height))
//	}
//	
//	// MARK: - 锁屏及线控操作
//	override func remoteControlReceived(with event: UIEvent?) {
//		
//		let remoteControl = event!.subtype
//		
//		switch remoteControl {
//			
//		case .remoteControlPlay, .remoteControlPause, .remoteControlTogglePlayPause:
//			
//			self.playOrPause()
//			
//		case .remoteControlNextTrack:
//			
//			self.playNext()
//			
//		case .remoteControlPreviousTrack:
//			
//			self.playPrevious()
//			
//		default: break
//			
//		}
//	}
//	// MARK: - 获取上次播放状态
//	func getLastPlaySongAndPlayState() {
//		
//		let user = UserDefaults.standard
//		
//		let tracksData = user.data(forKey: "tracksData")
//		
//		if tracksData == nil {
//			
//			self.repeatMode = AudioRepeatMode.towards
//			
//			return
//			
//		}
//		
//		let tracks = NSKeyedUnarchiver.unarchiveObject(with: tracksData!) as! Array<TrackEncoding>
//		
//		let index = user.integer(forKey: "index")
//		
//		let album = user.string(forKey: "album")
//		
//		let repeatMode = user.integer(forKey: "repeatMode")
//		
//		let type = user.object(forKey: "type")
//		
//		self.tracks = tracks
//		
//		self.index = index
//		
//		self.type = type as! String?
//		
//		coverScroll.reloadData(initialIndex: index)
//		
//		changeInterface(index)
//		
//		self.album?.text = album
//		
//		if repeatMode == AudioRepeatMode.shuffle.rawValue {
//			
//			playModeView.image = UIImage(named: "shuffleOnB")
//			
//			self.repeatMode = AudioRepeatMode.shuffle
//			
//		} else if repeatMode == AudioRepeatMode.towards.rawValue {
//			
//			playModeView.image = UIImage(named: "repeatOnB")
//			
//			self.repeatMode = AudioRepeatMode.towards
//			
//			
//			
//		} else {
//			
//			playModeView.image = UIImage(named: "repeatOneB")
//			
//			self.repeatMode = AudioRepeatMode.single
//			
//		}
//		
//	}
//	
//	// MARK: - 接收通知
//	func getNotification() {
//		
//		let center: NotificationCenter = NotificationCenter.default
//		
//		center.addObserver(self, selector: #selector(speaking), name: Notification.Name("speaking"), object: nil)
//		
//		center.addObserver(self, selector: #selector(nonspeaking), name: Notification.Name("nonspeaking"), object: nil)
//		
//		center.addObserver(self, selector: #selector(audioSessionDidChangeInterruptionType(notification:)),
//						   name: NSNotification.Name.AVAudioSessionRouteChange,
//						   object: AVAudioSession.sharedInstance())
//		
//	}
//	
//	func speaking() {
//		
//		streamer.volume = 0.1
//		
//	}
//	
//	func nonspeaking() {
//		
//		streamer.volume = 1
//		
//	}
//	// MARK: earphone plugged in
//	func audioSessionDidChangeInterruptionType(notification: NSNotification) {
//		
//		let interruptReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
//		
//		switch interruptReason {
//			
//		case 1:
//			
//			debugPrint("插入耳机")
//			
//			break
//			
//		case 2:
//			
//			debugPrint("拔出耳机")
//			
//			if self.paused == false {
//				
//				playOrPause()
//				
//			}
//			
//			self.paused = true
//			
//			break
//			
//		default:
//			
//			break
//		}
//		
//	}
//	
//	func refreshProgressColor() {
//		
//		let colorPicker: LEColorPicker = LEColorPicker()
//		
//		let colorScheme = colorPicker.colorScheme(from: nowCover?.image)
//		
//		self.progress?.color = colorScheme?.backgroundColor
//		
//		self.name?.textColor = colorScheme?.backgroundColor
//		
//		self.artist?.textColor = colorScheme?.backgroundColor
//		
//		self.album?.textColor = colorScheme?.backgroundColor
//		
//		
//	}
//	
//	}
//	// MARK: - initial subviews
//	extension PlayerInterface {
//		
//		func initialSubviews() {
//			
//			//开始时间和剩余时间
//			timeView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
//			
//			self.backgroundView.addSubview(timeView)
//			//当前播放时间
//			let currentTime = createLabel([.flexibleHeight, .flexibleWidth],
//										  shadowOffset: CGSize(width: 0, height: 0),
//										  textColor: UIColor.white,
//										  text: nil,
//										  textAlignment: .left)
//			
//			self.currentTime = currentTime
//			self.timeView.addSubview(currentTime)
//			
//			//剩余时间
//			let leftTime = createLabel([.flexibleHeight, .flexibleWidth, .flexibleLeftMargin],
//									   shadowOffset: CGSize(width: 0, height: 0),
//									   textColor: UIColor.white,
//									   text: nil,
//									   textAlignment: .right)
//			self.timeView.addSubview(leftTime)
//			self.leftTime = leftTime
//			
//			//歌曲名
//			let name: TrackLabel = TrackLabel()
//			
//			name.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
//			
//			self.backgroundView.addSubview(name)
//			
//			self.name = name
//			
//			//歌手名
//			let artist: TrackLabel = TrackLabel()
//			
//			artist.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
//			
//			self.backgroundView.addSubview(artist)
//			
//			self.artist = artist
//			
//			//专辑名
//			let album: TrackLabel = TrackLabel()
//			
//			album.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
//			
//			album.text = "尚未播放歌曲"
//			
//			self.backgroundView.addSubview(album)
//			
//			self.album = album
//			
//			//播放模式
//			playModeView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
//			
//			playModeView.image = UIImage(named: "repeatOnB.png")
//			
//			playModeView.contentMode = .scaleAspectFit
//			
//			self.backgroundView.addSubview(playModeView)
//			
//			// 歌词
//			lrcView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
//			
//			lrcView.isHidden = true
//			
//			self.addSubview(lrcView)
//			
//			self.lrcView.renderStatic = false
//			
//		}
//		
//	}
//	// MARK: - functional creation
//	extension PlayerInterface {
//		
//		
//		
//		func createLabel(_ autoresizingMask: UIViewAutoresizing, shadowOffset: CGSize?, textColor: UIColor, text: String?, textAlignment: NSTextAlignment) -> UILabel {
//			
//			let label: UILabel = UILabel()
//			
//			label.autoresizingMask = autoresizingMask
//			
//			label.textColor = textColor
//			
//			label.textAlignment = textAlignment
//			
//			label.adjustsFontSizeToFitWidth = true
//			
//			if let unwrappedOffset = shadowOffset {
//				
//				label.shadowOffset = unwrappedOffset
//				
//			}
//			
//			if let unwrappedText = text {
//				
//				label.text = unwrappedText
//				
//			}
//			
//			return label
//		}
//	}
//	
//	// MARK: - play from tracks
//	extension PlayerInterface {
//		// MARK: - play tracks
//		func playTracks(tracks: Array<TrackEncoding>, index: Int) {
//			// MARK: - 判断网络状态以及是否允许网络播放
//			let user = UserDefaults.standard
//			
//			let yes = user.bool(forKey: "wwanPlay")
//			
//			let monitor = Reachability.forInternetConnection()
//			
//			let reachable = monitor?.currentReachabilityStatus().rawValue
//			
//			if !yes && reachable != 2 && type != "local" {
//				
//				let appearance = SCLAlertView.SCLAppearance(
//															
//															showCloseButton: false
//															)
//				
//				let alertView = SCLAlertView(appearance: appearance)
//				
//				alertView.addButton("取消") {
//					
//					self.streamer.activeStream.stop()
//					
//				}
//				
//				alertView.addButton("继续播放") {
//					
//					if reachable == 0 {
//						
//						HUD.flash(.labeledError(title: "请检查网络状况", subtitle: nil), delay: 1.0)
//						
//						return
//						
//					}
//					
//					self.startPlay()
//					
//					user.set(1, forKey: "wwanPlay")
//					
//					NotificationCenter.default.post(name: Notification.Name("wwanPlay"), object: nil)
//					
//					self.paused = false
//					
//				}
//				
//				alertView.showWarning("温馨提示", subTitle: "您当前处于运营商网络中，是否继续播放")
//				
//				return
//			}
//			
//			if reachable == 2 || type == "local" || yes {
//				
//				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//					
//					self.startPlay()
//					
//				})
//				
//			}
//			
//			if reachable == 0 {
//				
//				HUD.flash(.labeledError(title: "请检查网络状况", subtitle: nil), delay: 1.0)
//				
//			}
//			
//		}
//		
//		func startPlay() {
//			
//			self.lrcView.lyricsLines.removeAll()
//			
//			self.lrcView.chLrcArray.removeAll()
//			
//			self.lrcView.tableView.reloadData()
//			
//			self.paused = false
//			
//			// check local files
//			
//			let track = tracks[self.index!]
//			
//			let rootPath = self.dirDoc()
//			
//			let query = "SELECT * FROM t_downloading WHERE sourceURL = ?;"
//			
//			let s = tracksDB.executeQuery(query, withArgumentsIn: [track.url])
//			
//			if s?.next() == true {
//				
//				let isDownloaded = s?.bool(forColumn: "downloaded")
//				
//				if isDownloaded == true {
//					
//					let identifier = self.getIdentifier(urlStr: track.url)
//					
//					let filePath = rootPath + "/\(identifier)"
//					
//					streamer.activeStream.play(from: URL(fileURLWithPath: filePath))
//					
//					
//				} else {
//					
//					streamer.activeStream.play(from: URL(string: track.url))
//					
//				}
//				
//			} else {
//				
//				streamer.activeStream.play(from: URL(string: track.url))
//				
//			}
//			
//			addCurrentTimeTimer()
//			
//			// 记录最后一次播放的歌曲和以及播放模式
//			
//			let user = UserDefaults.standard
//			
//			user.set(self.repeatMode.rawValue, forKey: "repeatMode")
//			
//			let tracksData = NSKeyedArchiver.archivedData(withRootObject: tracks)
//			
//			user.set(self.album?.text, forKey: "album")
//			
//			user.set(tracksData, forKey: "tracksData")
//			
//			user.set(self.type, forKey: "type")
//			
//			user.set(self.index!, forKey: "index")
//			
//			changeInterface(self.index!)
//			
//			
//		}
//		// MARK: Change interface
//		func changeInterface(_ index: Int) {
//			
//			self.progress?.progress = 0
//			
//			self.bufferingIndicator?.progress = 0
//			
//			self.currentTime.text = "0:00"
//			
//			self.leftTime.text = "0:00"
//			
//			let track = self.tracks[self.index!]
//			
//			self.name?.text = track.name
//			
//			self.artist?.text = track.artist
//			
//			if self.lrcView.isHidden == false {
//				
//				loadLyrics(trackID: track.ID)
//				
//			}
//			
//			self.lrcView.noLrcLabel.isHidden = true
//			
//			
//			nowCover?.sd_setImage(with: URL(string: track.cover + "!/fw/600"), placeholderImage: nowCover?.image, options: .retryFailed, progress: { (_, _) in
//				
//			}, completed: { (image, _, _, _) in
//				
//				
//				self.nowCover?.image = image
//				
//				DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
//					
//					self.lrcView.renderStatic = false
//					
//				}
//				
//				DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
//					
//					self.lrcView.renderStatic = true
//					
//					self.reflection.image = image?.reflection(withAlpha: 0.3)
//					
//					self.refreshProgressColor()
//					
//					
//				}
//				
//			})
//			
//			
//		}
//		// MARK: Load Lyrics
//		func loadLyrics(trackID: Int) {
//			
//			self.lrcView.noLrcLabel.text = "正在加载歌词"
//			
//			self.lrcView.noLrcLabel.isHidden = false
//			
//			let url = URL(string: lrcUrl + "\(trackID)")
//			
//			Alamofire.request(url!).response(completionHandler: { (response) in
//				
//				let lrcString: LrcString = Reflect<LrcString>.mapObject(data: response.data)
//				
//				if lrcString.lrc.characters.count == 0 || lrcString.lrc == "unwritten" {
//					
//					self.lrcView.noLrcLabel.text = "暂无歌词"
//					
//					self.lrcView.noLrcLabel.isHidden = false
//					
//					return
//					
//				}
//				
//				self.lrcView.parseLyrics(lyrics: lrcString.lrc.replacingOccurrences(of: "\\n", with: " "))
//				
//				if lrcString.lrc_cn.characters.count > 0 && lrcString.lrc_cn != "unwritten" {
//					
//					self.lrcView.parseChLyrics(lyrics: lrcString.lrc_cn.replacingOccurrences(of: "\\n", with: " "))
//					
//				}
//				
//			})
//			
//		}
//		
//		func addCurrentTimeTimer() {
//			
//			if self.paused == true { return }
//			
//			removeCurrentTimeTimer()
//			// ensure the timer is up-to-now
//			updateCurrentTime()
//			
//			updatePlayBackProgress()
//			
//			currentTimeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
//			
//			playbackTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updatePlayBackProgress), userInfo: nil, repeats: true)
//			
//			RunLoop.main.add(currentTimeTimer!, forMode: .commonModes)
//			
//			RunLoop.main.add(playbackTimer!, forMode: .commonModes)
//			
//		}
//		// remove timers
//		func removeCurrentTimeTimer() {
//			
//			currentTimeTimer?.invalidate()
//			
//			playbackTimer?.invalidate()
//			
//			currentTimeTimer = nil
//			
//			playbackTimer = nil
//			
//			bufferingIndicator?.progress = 0
//			
//			progress?.progress = 0
//			
//		}
//		
//		func updateCurrentTime() {
//			
//			if streamer.activeStream.duration.minute == 0 && streamer.activeStream.duration.second == 0 { return }
//			// get currentTime and duration
//			let cur: FSStreamPosition = (streamer.activeStream.currentTimePlayed)
//			
//			let total: FSStreamPosition = (streamer.activeStream.duration)
//			// set play progress
//			let progress: Double = (Double)(cur.minute * 60 + cur.second) / (Double)(total.minute * 60 + total.second)
//			
//			if progress > 1 { return }
//			
//			self.progress?.progress = CGFloat(progress)
//			
//			// set current time and time remaining
//			var currSecond: String = String(cur.second)
//			
//			let totalLeftSecond = (total.minute * 60) + (total.second) - (cur.minute * 60) - (cur.second)
//			
//			let leftMin: String = String(totalLeftSecond / 60)
//			
//			var leftSec: String = String(totalLeftSecond % 60)
//			
//			if cur.second < 10 {
//				
//				currSecond = "0" + currSecond
//				
//			}
//			
//			if Int(leftSec)! < 10 {
//				
//				leftSec = "0" + leftSec
//				
//			}
//			
//			currentTime.text = NSString(format: "%d:%@", cur.minute, currSecond) as String
//			
//			leftTime.text = NSString(format: "%@:%@", leftMin, leftSec) as String
//			
//			refreshProgressColor()
//			
//			// when play at the end of file
//			weak var weakself: PlayerInterface? = self
//			
//			self.streamer.activeStream.onCompletion = { () -> Void in
//				
//				weakself?.playNext()
//				
//			}
//			
//			let artwork: MPMediaItemArtwork = MPMediaItemArtwork.init(image: (nowCover?.image)!)
//			
//			let duration: TimeInterval = Double((self.streamer.activeStream.duration.minute)) * 60 + Double((self.streamer.activeStream.duration.second))
//			
//			let elapsedPlaybackTime = cur.minute * 60 + cur.second
//			
//			let track: TrackEncoding = tracks[index!];
//			
//			let info : [String:AnyObject] = [
//											 
//											 MPMediaItemPropertyArtist : track.artist as AnyObject,
//											 
//											 MPMediaItemPropertyAlbumTitle : self.album!.text as AnyObject,
//											 
//											 MPMediaItemPropertyTitle: track.name as AnyObject,
//											 
//											 MPMediaItemPropertyArtwork: artwork,
//											 
//											 MPMediaItemPropertyPlaybackDuration: duration as AnyObject,
//											 
//											 MPNowPlayingInfoPropertyElapsedPlaybackTime: elapsedPlaybackTime as AnyObject
//											 
//											 ]
//			
//			MPNowPlayingInfoCenter.default().nowPlayingInfo = info
//			
//			
//		}
//		
//		func updatePlayBackProgress() {
//			
//			if (streamer.activeStream.contentLength) > 0 {
//				
//				if (bufferingIndicator?.progress)! >= CGFloat(1)  {
//					
//					playbackTimer?.invalidate()
//					
//					playbackTimer = nil
//					
//					bufferingIndicator?.progress = CGFloat(1)
//					
//				}
//				
//				let currentOffset = streamer.activeStream.currentSeekByteOffset
//				
//				let totalBufferedData = Int((currentOffset.start)) + (streamer.activeStream.prebufferedByteCount)
//				
//				let bufferedDataFromTotal = Float(totalBufferedData) / Float((streamer.activeStream.contentLength))
//				
//				bufferingIndicator?.progress = CGFloat(bufferedDataFromTotal)
//				
//			}
//			
//		}
//		
//	}
//	// MARK: - addGestureRecognizers
//	extension PlayerInterface {
//		
//		func addGestureRecognizer() {
//			//播放和暂停
//			let singleTap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(playOrPause))
//			singleTap.numberOfTapsRequired = 1;
//			singleTap.numberOfTouchesRequired = 1;
//			self.addGestureRecognizer(singleTap)
//			//上一首
//			let swipeFromLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(playPrevious))
//			swipeFromLeft.direction = .right
//			swipeFromLeft.numberOfTouchesRequired = 1;
//			self.addGestureRecognizer(swipeFromLeft)
//			//下一首
//			let swipeFromRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(playNext))
//			swipeFromRight.numberOfTouchesRequired = 1
//			swipeFromRight.direction = .left
//			self.addGestureRecognizer(swipeFromRight)
//			//快进
//			let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(doSeeking(recognizer:)))
//			longPress.numberOfTouchesRequired = 1
//			longPress.minimumPressDuration = 0.5
//			self.addGestureRecognizer(longPress)
//			//随机
//			let doubleswipeFromRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(playShuffle(_:)))
//			doubleswipeFromRight.direction = .right
//			doubleswipeFromRight.numberOfTouchesRequired = 2;
//			self.addGestureRecognizer(doubleswipeFromRight)
//			
//			//顺序播放
//			let doubleswipeFromLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(playShuffle(_:)))
//			doubleswipeFromLeft.direction = .left
//			doubleswipeFromLeft.numberOfTouchesRequired = 2;
//			self.addGestureRecognizer(doubleswipeFromLeft)
//			//单曲循环
//			let doubleTouch: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(singleRewind))
//			doubleTouch.numberOfTouchesRequired = 2
//			doubleTouch.numberOfTapsRequired = 1
//			self.addGestureRecognizer(doubleTouch)
//			
//			//展示歌词
//			let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(showLyrics))
//			doubleTap.numberOfTapsRequired = 2
//			doubleTap.numberOfTouchesRequired = 1
//			self.addGestureRecognizer(doubleTap)
//			
//			//当识别不出这是双击时才开启单击识别
//			singleTap.require(toFail: doubleTouch)
//			singleTap.require(toFail: doubleTap)
//		}
//	}
//	// MARK: - Play Control
//	extension PlayerInterface {
//		
//		// MARK: - 播放暂停
//		func playOrPause() {
//			
//			if tracks.count == 0 {
//				HUD.flash(.label("向上滑动，更多精彩"), delay: 0.3)
//				return
//			}
//			
//			self.paused = !(self.paused)
//			
//			if paused == false {
//				
//				HUD.flash(.image(UIImage(named: "playB")), delay: 0.1, completion: { (_) in
//					self.playCommon()
//				})
//				
//			} else {
//				HUD.flash(.image(UIImage(named: "pauseB")), delay: 0.1, completion: { (_) in
//					self.playCommon()
//				})
//			}
//			
//		}
//		
//		func playCommon() {
//			
//			if self.streamer.activeStream.url == nil {
//				self.playTracks(tracks: self.tracks, index: self.index!)
//				return
//			}
//			self.streamer.pause()
//			
//		}
//		// MARK: - 上一首
//		func playPrevious() {
//			
//			if self.tracks.count == 0 {
//				
//				HUD.flash(.label("向上滑动，更多精彩"), delay: 0.3)
//				
//				return
//				
//			}
//			
//			let cur: FSStreamPosition = (self.streamer.activeStream.currentTimePlayed)
//			
//			if cur.minute == 0 || cur.second <= 5 {
//				
//				if self.repeatMode == AudioRepeatMode.shuffle {
//					
//					self.index = Int(arc4random()) % self.tracks.count
//					
//				} else if self.repeatMode == AudioRepeatMode.single {
//					
//					self.index = self.index!
//					
//				} else {
//					
//					if self.index == 0 {
//						
//						self.index = self.tracks.count - 1
//						
//					} else {
//						
//						self.index = self.index! - 1
//						
//					}
//					
//				}
//			}
//			
//			self.coverScroll.scrollToIndex(self.index!, animated: true)
//			
//			HUD.flash(.image(UIImage(named: "prevB")), delay: 0.1) { (_) in
//				
//				self.playTracks(tracks: self.tracks, index: self.index!)
//				
//			}
//			
//		}
//		
//		func playNext() {
//			
//			if self.tracks.count == 0 {
//				
//				HUD.flash(.label("向上滑动，更多精彩"), delay: 0.3)
//				
//				return
//				
//			}
//			
//			if self.repeatMode == AudioRepeatMode.shuffle {
//				
//				self.index = Int(arc4random()) % self.tracks.count
//				
//			} else if self.repeatMode == AudioRepeatMode.single {
//				
//				self.index = self.index!
//				
//			} else {
//				
//				if self.index == self.tracks.count - 1 {
//					
//					self.index = 0
//					
//				} else {
//					
//					self.index = self.index! + 1
//					
//				}
//				
//			}
//			
//			self.coverScroll.scrollToIndex(self.index!, animated: true)
//			
//			playTracks(tracks: self.tracks, index: self.index!)
//			
//		}
//		
//		func doSeeking(recognizer: UILongPressGestureRecognizer) {
//			
//			if self.tracks.count == 0 {
//				
//				HUD.flash(.label("向上滑动，更多精彩"), delay: 0.3)
//				
//				return
//				
//			}
//			
//			var seek: FSStreamPosition = FSStreamPosition()
//			
//			var lastPoint: CGPoint?
//			
//			if recognizer.state == .began {
//				
//				var tempBounds = self.backgroundView.bounds
//				
//				tempBounds.size.width -= 40
//				
//				tempBounds.size.height -= 400
//				
//				backgroundView.bounds = tempBounds
//				
//				// get current playing time
//				let now = self.streamer.activeStream.currentTimePlayed
//				
//				self.progressOriginal = now.position
//				
//				self.originalPoint = recognizer.location(in: self)
//			}
//			
//			if recognizer.state == .changed {
//				
//				let changingPoint = recognizer.location(in: self)
//				
//				let seekForwardPercent = self.progressOriginal! + Float((changingPoint.x - (self.originalPoint?.x)!) / self.width());
//				
//				if seekForwardPercent >= 1 || seekForwardPercent < 0 { return }
//				
//				self.progress?.progress = CGFloat(seekForwardPercent)
//				
//			}
//			
//			// change the progress
//			if recognizer.state == .ended {
//				
//				// restore
//				lastPoint = recognizer.location(in: self)
//				
//				backgroundView.frame = self.frame
//				
//				self.playModeView.frame = CGRect(x: self.width() / 2 - 10,y: self.height() - 20,width: 20,height: 20)
//				
//				// if didn't move don't change
//				if lastPoint?.x == self.originalPoint?.x { return }
//				
//				seek.position = Float((self.progress?.progress)!)
//				
//				self.streamer.activeStream.seek(to: seek)
//				
//			}
//		}
//		
//		func playShuffle(_ recognizer: UISwipeGestureRecognizer) {
//			
//			if recognizer.direction == .left {
//				
//				self.repeatMode = AudioRepeatMode.shuffle
//				
//				self.playModeView.image = UIImage(named: "shuffleOnB")
//				
//				HUD.flash(.image(UIImage(named: "shuffleOnB")), delay: 0.3)
//				
//			} else {
//				
//				self.repeatMode = AudioRepeatMode.towards
//				
//				self.playModeView.image = UIImage(named: "repeatOnB")
//				
//				HUD.flash(.image(UIImage(named: "repeatOnB")), delay: 0.3)
//				
//			}
//			
//			UserDefaults.standard.set(self.repeatMode.rawValue, forKey: "repeatMode")
//			UserDefaults.standard.synchronize()
//			
//		}
//		
//		func singleRewind() {
//			
//			if self.repeatMode == AudioRepeatMode.single {
//				HUD.flash(.image(UIImage(named: "repeatOnB")), delay: 0.3)
//				repeatMode = AudioRepeatMode.towards
//				playModeView.image = UIImage(named: "repeatOnB")
//				
//			} else {
//				HUD.flash(.image(UIImage(named: "repeatOneB")), delay: 0.3)
//				repeatMode = AudioRepeatMode.single
//				playModeView.image = UIImage(named: "repeatOneB")
//			}
//			
//			UserDefaults.standard.set(self.repeatMode.rawValue, forKey: "repeatMode")
//			
//			UserDefaults.standard.synchronize()
//			
//		}
//		
//		func showLyrics() {
//			if self.tracks.count == 0 {
//				HUD.flash(.label("向上滑动，更多精彩"), delay: 0.3)
//				return
//			}
//			if lrcView.isHidden == true {
//				
//				self.lrcView.isHidden = false
//				self.lrcView.alpha = 0
//				
//				UIView.animate(withDuration: 0.5, animations: { self.lrcView.alpha = 1 })
//				
//				UIView.commitAnimations()
//				
//				addLrcTimer()
//				
//				self.lrcView.renderStatic = false
//				self.lrcView.renderStatic = true
//				
//				if self.lrcView.lyricsLines.count == 0 {
//					
//					let track = tracks[self.index!]
//					loadLyrics(trackID: track.ID)
//					
//				}
//				
//			} else {
//				
//				self.lrcView.alpha = 1
//				
//				UIView.animate(withDuration: 0.5, animations: { self.lrcView.alpha = 0 })
//				UIView.commitAnimations()
//				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { self.lrcView.isHidden = true })
//				
//				removeLrcTimer()
//				
//			}
//			
//		}
//		
//		func addLrcTimer() {
//			
//			if self.lrcView.isHidden == true { return }
//			
//			if self.streamer.activeStream.isPlaying() == false && self.lrcTimer != nil {
//				updateLrcTimer()
//				return
//			}
//			
//			removeLrcTimer()
//			updateLrcTimer()
//			
//			lrcTimer = CADisplayLink(target: self, selector: #selector(updateLrcTimer))
//			
//			self.lrcTimer?.add(to: RunLoop.main, forMode: .commonModes)
//			
//		}
//		
//		func updateLrcTimer() {
//			// get now playing time and duration
//			let cur = streamer.activeStream.currentTimePlayed
//			self.lrcView.currentTime(time: Double((cur.minute) * 60 + (cur.second)))
//		}
//		
//		func removeLrcTimer() {
//			self.lrcTimer?.invalidate()
//			self.lrcTimer = nil
//		}
//		
//	}
//	// MARK: - LTInfiniteScrollViewDataSource
//	extension PlayerInterface: LTInfiniteScrollViewDataSource {
//		
//		func numberOfViews() -> Int {
//			if self.tracks.count > 0 { return self.tracks.count }
//			return 1
//		}
//		
//		func numberOfVisibleViews() -> Int { return 1 }
//		
//		func viewAtIndex(_ index: Int, reusingView view: UIView?) -> UIView {
//			
//			let size = self.bounds.size.width / CGFloat(numberOfVisibleViews())
//			let cover = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
//			
//			if self.tracks.count > 0 {
//				
//				let track: TrackEncoding = self.tracks[index]
//				let urlStr: String = track.cover + "!/fw/600"
//				let url: URL = URL(string: urlStr)!
//				
//				cover.sd_setImage(with: url, placeholderImage: UIImage(named: "noArtwork"), options: [], completed: { (image, _, _, _) in
//					
//					if index == self.index {
//						self.reflection.image = cover.image?.reflection(withAlpha: 0.4)
//						self.nowCover = cover
//					}
//					
//				})
//				
//			} else { cover.image = UIImage(named: "noArtwork") }
//			
//			return cover
//		}
//	}
//	// MARK: - LTInfiniteScrollViewDelegate
//	extension PlayerInterface: LTInfiniteScrollViewDelegate {
//		
//		func updateView(_ view: UIView, withProgress progress: CGFloat, scrollDirection direction: LTInfiniteScrollView.ScrollDirection) {}
//		
//		func scrollViewDidScrollToIndex(_ scrollView: LTInfiniteScrollView, index: Int) {
//			if self.tracks.count == 0 { return }
//			
//			self.index = index
//			playTracks(tracks: self.tracks, index: index)
//			
//		}
//	}
//	

