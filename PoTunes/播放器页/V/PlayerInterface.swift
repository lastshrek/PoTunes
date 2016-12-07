
//
//  PlayerInterface.swift
//  破音万里
//
//  Created by Purchas on 16/8/12.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit
import LDProgressView
import LTInfiniteScrollViewSwift
import PKHUD
import FMDB
import LEColorPicker
import Alamofire

class PlayerInterface: UIView, UIApplicationDelegate {
    
    static let shared: PlayerInterface = {
        
        let instance = PlayerInterface()
        
        return instance
        
    }()
	
	// MARK: - basic components
	let width = UIScreen.main.bounds.size.width
	let height = UIScreen.main.bounds.size.height
	let backgroundView = UIView()
	var coverScroll = LTInfiniteScrollView()
	var reflection = UIImageView()
	var bufferingIndicator :LDProgressView?
	var progress: LDProgressView?
	var timeView = UIView()
	var currentTime = UILabel()
	var leftTime = UILabel()
	var name: TrackLabel?
	var artist: TrackLabel?
	var album: TrackLabel?
	var playModeView = UIImageView()
	var lrcView = LrcView()
	var tracks: Array<TrackEncoding> = []
	var index: Int?
	var progressOriginal: Float?
	var originalPoint: CGPoint?
	
	
	// MARK: - streamer
	var streamer = FSAudioController()
	var repeatMode: AudioRepeatMode?
	var paused: Bool = true
	// MARK: - Timer
	var currentTimeTimer: Timer?
	var playbackTimer: Timer?
	var lrcTimer: CADisplayLink?
	// MARK: - trackDB
	lazy var tracksDB: FMDatabase = {
		
		let path = self.dirDoc() + "/downloadingSong.db"
		
		let db: FMDatabase = FMDatabase(path: path)
		
		db.open()
		
		return db
	}()
	

	// MARK: - 播放模式
	enum AudioRepeatMode: Int {
		case single = 0
		case playlist
		case towards
		case shuffle
	}
	// MARK: - 播放操作
	enum AudioPlayState {
		case play
		case pause
		case next
		case previous
	}
	
	let lrcUrl = "https://poche.fm/api/app/lyrics/"
	
	override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		self.backgroundColor = UIColor.black
		
		initialSubviews()
		
		addGestureRecognizer()
		
		repeatMode = AudioRepeatMode.towards
        
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        self.becomeFirstResponder()
		
		// get last played
		getLastPlaySongAndPlayState()
		
	}
    
    override var canBecomeFirstResponder: Bool {
        
        return true
        
    }
	
	required init?(coder aDecoder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	
	}
	
	override func layoutSubviews() {
		
		super.layoutSubviews()
		
		backgroundView.frame = self.bounds
		
		reflection.frame =  CGRect(x: 0, y: height - width, width: width, height: width)
		
		coverScroll.frame = CGRect(x: 0, y: 0, width: width, height: width)

		lrcView.frame = CGRect(x: 0, y: 0, width: width, height: width)

		bufferingIndicator?.frame = CGRect(x: 0, y: width, width: width, height: 15)
		
		progress?.frame = CGRect(x: 0, y: width, width: width, height: 15)

		playModeView.frame = CGRect(x: width / 2 - 10, y: height - 50, width: 20, height: 20)

		// MARK: - 除3
		self.name?.frame = CGRect(x: 0, y: width + 20, width: width, height: 40)
		
		self.artist?.frame = CGRect(x: 0, y: width + 60, width: width, height: 40)
		
		self.album?.frame = CGRect(x: 0, y: width + 100, width: width, height: 40)
		
		timeView.frame = CGRect(x: 0, y: (self.progress?.frame.maxY)!, width: width, height: 20)
		
		currentTime.frame = CGRect(x: 2, y: 0, width: width / 2, height: 20)
		
		leftTime.frame = CGRect(x: width / 2 - 2, y: 0, width: width / 2, height: (self.timeView.bounds.size.height))
	}
	
    override func remoteControlReceived(with event: UIEvent?) {
        
        let remoteControl = event!.subtype
        
        switch remoteControl {
            
        case .remoteControlPlay, .remoteControlPause:
            
            self.playOrPause()
            
            break
            
        case .remoteControlNextTrack:
            
            self.playNext()
            
        case .remoteControlPreviousTrack:
            
            self.playPrevious()
            
        default: break
        }
    }
	
	func getLastPlaySongAndPlayState() {
		
		let user = UserDefaults.standard
		
		let tracksData = user.data(forKey: "tracksData")
		
		if tracksData == nil {
			
			self.repeatMode = AudioRepeatMode.towards
			
			return
			
		}
		
		let tracks = NSKeyedUnarchiver.unarchiveObject(with: tracksData!) as! Array<TrackEncoding>
		
		let index = user.integer(forKey: "index")
		
		let album = user.string(forKey: "album")
		
		let repeatMode = user.integer(forKey: "repeatMode")
		
		self.tracks = tracks
		
		self.index = index
		
		coverScroll.reloadData(initialIndex: index)
		
		
		changeInterface(index)
		
		self.album?.text = album
		
		if repeatMode == AudioRepeatMode.shuffle.rawValue {
			
			playModeView.image = UIImage(named: "shuffleOnB")
			
			self.repeatMode = AudioRepeatMode.shuffle
			
		} else if repeatMode == AudioRepeatMode.towards.rawValue {
			
			playModeView.image = UIImage(named: "repeatOnB")
			
			self.repeatMode = AudioRepeatMode.towards


			
		} else {
			
			playModeView.image = UIImage(named: "repeatOneB")
			
			self.repeatMode = AudioRepeatMode.single
			
		}
		
		
	}

}
// MARK: - initial subviews
extension PlayerInterface {
	
	func initialSubviews() {
		// backgourndView
		backgroundView.backgroundColor = UIColor.black
		
		backgroundView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
		
		self.addSubview(backgroundView)
		// 倒影封面
		reflection.autoresizingMask = [.flexibleHeight, .flexibleWidth]
		
		reflection.image = UIImage(named: "noArtwork")?.reflection(withAlpha: 0.4)
		
		self.backgroundView.addSubview(reflection)
		
		self.backgroundView.sendSubview(toBack: reflection)
		
		coverScroll.dataSource = self
		
		coverScroll.delegate = self
		
		coverScroll.maxScrollDistance = 2
		
		coverScroll.reloadData(initialIndex: 0)
		
		self.backgroundView.addSubview(coverScroll)
		
		//缓冲条
		let bufferingIndicator: LDProgressView = createProgressView(false, progress: 0,
		                                                            animate: false,
		                                                            showText: false,
		                                                            showStroke: false,
		                                                            progressInset: 0,
		                                                            showBackground: false,
		                                                            outerStrokeWidth: 0,
		                                                            type: LDProgressSolid,
		                                                            autoresizingMask: [.flexibleWidth, .flexibleTopMargin],
		                                                            borderRadius: 0,
		                                                            backgroundColor: UIColor.lightText)
		
		self.bufferingIndicator = bufferingIndicator
		
		self.backgroundView.addSubview(bufferingIndicator)
		
		//进度条
		let progress: LDProgressView = createProgressView(false, progress: 0,
		                                                  animate: false,
		                                                  showText: false,
		                                                  showStroke: false,
		                                                  progressInset: 0,
		                                                  showBackground: false,
		                                                  outerStrokeWidth: 0,
		                                                  type: LDProgressSolid,
		                                                  autoresizingMask: [.flexibleWidth, .flexibleTopMargin],
		                                                  borderRadius: 0,
		                                                  backgroundColor: UIColor.clear)
		
		self.progress = progress
		
		self.backgroundView.addSubview(progress)
		
		//开始时间和剩余时间
		timeView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
		
		self.backgroundView.addSubview(timeView)
		//当前播放时间
		let currentTime = createLabel([.flexibleHeight, .flexibleWidth],
		                              shadowOffset: CGSize(width: 0, height: 0),
		                              textColor: UIColor.white,
		                              text: nil,
		                              textAlignment: .left)
		
		self.currentTime = currentTime
		
		self.timeView.addSubview(currentTime)
		
		//剩余时间
		let leftTime = createLabel([.flexibleHeight, .flexibleWidth, .flexibleLeftMargin],
		                           shadowOffset: CGSize(width: 0, height: 0),
		                           textColor: UIColor.white,
		                           text: nil,
		                           textAlignment: .right)
		
		self.timeView.addSubview(leftTime)
		
		self.leftTime = leftTime
		
		//歌曲名
		let name: TrackLabel = TrackLabel()
		
		name.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
		
		self.backgroundView.addSubview(name)
		
		self.name = name
		
		//歌手名
		let artist: TrackLabel = TrackLabel()
		
		artist.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
		
		self.backgroundView.addSubview(artist)
		
		self.artist = artist
		
		//专辑名
		let album: TrackLabel = TrackLabel()
		
		album.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
		
		album.text = "尚未播放歌曲"
		
		self.backgroundView.addSubview(album)
		
		self.album = album
		
		//播放模式
		playModeView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
		
		playModeView.image = UIImage(named: "repeatOnB.png")
		
		playModeView.contentMode = .scaleAspectFit
		
		self.backgroundView.addSubview(playModeView)
		
		// 歌词
		lrcView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
		
		lrcView.isHidden = true
		
		self.addSubview(lrcView)
		
		self.lrcView.renderStatic = false

	}
}
// MARK: - functional creation
extension PlayerInterface {
	
	func createProgressView(_ flat: Bool,
	                        progress: CGFloat,
	                        animate: Bool,
	                        showText: Bool,
	                        showStroke: Bool,
	                        progressInset: NSNumber,
	                        showBackground: Bool,
	                        outerStrokeWidth: NSNumber,
	                        type: LDProgressType,
	                        autoresizingMask: UIViewAutoresizing,
	                        borderRadius: NSNumber,
	                        backgroundColor: UIColor)
		-> LDProgressView {
		
		
			let buffer: LDProgressView = LDProgressView()

			buffer.flat = flat as NSNumber!
		
			buffer.progress = progress
		
			buffer.animate = animate as NSNumber!
		
			buffer.showText = showText as NSNumber!
		
			buffer.showStroke = showStroke as NSNumber!
		
			buffer.progressInset = progressInset
		
			buffer.showBackground = showBackground as NSNumber!
		
			buffer.outerStrokeWidth = outerStrokeWidth
		
			buffer.type = type
		
			buffer.borderRadius = borderRadius
		
			buffer.backgroundColor = backgroundColor
		
			buffer.autoresizingMask = autoresizingMask
		
			return buffer
			
	}
	
	func createLabel(_ autoresizingMask: UIViewAutoresizing, shadowOffset: CGSize?, textColor: UIColor, text: String?, textAlignment: NSTextAlignment) -> UILabel {
		
		let label: UILabel = UILabel()
		
		label.autoresizingMask = autoresizingMask
		
		label.textColor = textColor
		
		label.textAlignment = textAlignment
		
		if let unwrappedOffset = shadowOffset {
		
			label.shadowOffset = unwrappedOffset
		
		}
		
		if let unwrappedText = text {
		
			label.text = unwrappedText
		
		}
		
		return label
	}
}

// MARK: - play from tracks
extension PlayerInterface {
	// play tracks
	func playTracks(tracks: Array<TrackEncoding>, index: Int) {
		
		self.paused = false

		// check local files
		
		let track = tracks[index]
		
		let rootPath = self.dirDoc()
		
		let query = "SELECT * FROM t_downloading WHERE sourceURL = ?;"
		
		let s = tracksDB.executeQuery(query, withArgumentsIn: [track.url])
		
		if s?.next() == true {
			
			let isDownloaded = s?.bool(forColumn: "downloaded")
			
			if isDownloaded == true {
				
				let identifier = self.getIdentifier(urlStr: track.url)
				
				let filePath = rootPath + "/\(identifier)"
								
				streamer.activeStream.play(from: URL(fileURLWithPath: filePath))

				
			} else {
				
				streamer.activeStream.play(from: URL(string: track.url))

			}
		
		} else {
			
			streamer.activeStream.play(from: URL(string: track.url))
			
		}

		addCurrentTimeTimer()
		
		// 记录最后一次播放的歌曲和以及播放模式
		let user = UserDefaults.standard
		
		user.set(self.repeatMode?.rawValue, forKey: "repeatMode")
		
		let tracksData = NSKeyedArchiver.archivedData(withRootObject: tracks)
		
		user.set(self.album?.text, forKey: "album")
		
		user.set(tracksData, forKey: "tracksData")
		
		user.set(self.index!, forKey: "index")

	}
	
	func changeInterface(_ index: Int) {
	
		self.lrcView.renderStatic = false

		self.progress?.progress = 0
		
		self.bufferingIndicator?.progress = 0
		
		self.currentTime.text = "0:00"
		
		self.leftTime.text = "0:00"
		
		let track = self.tracks[self.index!] 
		
		self.name?.text = track.name
		
		self.artist?.text = track.artist
		
		if self.lrcView.isHidden == false {
			
			self.lrcView.noLrcLabel.text = "正在加载歌词"
			
			self.lrcView.noLrcLabel.isHidden = false
			
			let url = URL(string: lrcUrl + "\(track.ID)")
			
			Alamofire.request(url!).response(completionHandler: { (response) in
				
				let lrcString: LrcString = Reflect<LrcString>.mapObject(data: response.data)
				
				self.lrcView.parseLyrics(lyrics: lrcString.lrc.replacingOccurrences(of: "\\n", with: " "))
				
				self.lrcView.parseChLyrics(lyrics: lrcString.lrc_cn.replacingOccurrences(of: "\\n", with: " "))
				
			})
		
		}
		
		self.lrcView.noLrcLabel.isHidden = true
		
		let cover: UIImageView = UIImageView()
		
		cover.sd_setImage(with: URL(string: track.cover + "!/fw/600")) { (image, _, _, _) in
			
			self.reflection.image = image?.reflection(withAlpha: 0.4)

			let colorPicker: LEColorPicker = LEColorPicker()

			let colorScheme = colorPicker.colorScheme(from: cover.image)

			self.progress?.color = colorScheme?.backgroundColor

			self.name?.textColor = colorScheme?.backgroundColor

			self.artist?.textColor = colorScheme?.backgroundColor

			self.album?.textColor = colorScheme?.backgroundColor

			// 设置锁屏信息
//			let artwork: MPMediaItemArtwork = MPMediaItemArtwork.init(image: image!)
//
//			let duration: TimeInterval = Double((self.streamer.activeStream.duration.minute)) * 60 + Double((self.streamer.activeStream.duration.second))
//
//
//			let info : [String:AnyObject] = [
//				
//				MPMediaItemPropertyArtist : track.artist as AnyObject,
//				
//				MPMediaItemPropertyAlbumTitle : self.album!.text as AnyObject,
//				
//				MPMediaItemPropertyTitle: track.name as AnyObject,
//				
//				MPMediaItemPropertyArtwork: artwork,
//				
//				MPMediaItemPropertyPlaybackDuration: duration as AnyObject
//				
//			]
//
//			MPNowPlayingInfoCenter.default().nowPlayingInfo = info
			
			self.lrcView.renderStatic = true

			
		}
		
	}

	func addCurrentTimeTimer() {
		
		if self.paused == true { return }
		
		removeCurrentTimeTimer()
		// ensure the timer is up-to-now
		updateCurrentTime()
		
		updatePlayBackProgress()
		
		currentTimeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
		
		playbackTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updatePlayBackProgress), userInfo: nil, repeats: true)
		
		RunLoop.main.add(currentTimeTimer!, forMode: .commonModes)
		
		RunLoop.main.add(playbackTimer!, forMode: .commonModes)
		
	}
	// remove timers
	func removeCurrentTimeTimer() {
		
		currentTimeTimer?.invalidate()
		
		playbackTimer?.invalidate()
		
		currentTimeTimer = nil
		
		playbackTimer = nil
		
		bufferingIndicator?.progress = 0
		
		progress?.progress = 0
	
	}
	
	func updateCurrentTime() {
		
		if streamer.activeStream.duration.minute == 0 && streamer.activeStream.duration.second == 0 { return }
		// get currentTime and duration
		let cur: FSStreamPosition = (streamer.activeStream.currentTimePlayed)
		
		let total: FSStreamPosition = (streamer.activeStream.duration)
		// set play progress
		let progress: Double = (Double)(cur.minute * 60 + cur.second) / (Double)(total.minute * 60 + total.second)
		
		if progress > 1 { return }
		
		self.progress?.progress = CGFloat(progress)
		
		// set current time and time remaining
		var currSecond: String = String(cur.second)
		
		let totalLeftSecond = (total.minute * 60) + (total.second) - (cur.minute * 60) - (cur.second)
		
		let leftMin: String = String(totalLeftSecond / 60)
		
		var leftSec: String = String(totalLeftSecond % 60)
		
		if cur.second < 10 {
			
			currSecond = "0" + currSecond
		
		}
		
		if Int(leftSec)! < 10 {
			
			leftSec = "0" + leftSec
		
		}
		
		currentTime.text = NSString(format: "%d:%@", cur.minute, currSecond) as String
		
		leftTime.text = NSString(format: "%@:%@", leftMin, leftSec) as String
		
		// when play at the end of file
		weak var weakself: PlayerInterface? = self
//		self.streamer?.onStateChange = { (streamState) -> Void in
//			print("播放下一首")
//		}
		self.streamer.activeStream.onCompletion = { () -> Void in
			
//			self.progress?.progress = 0

			
//			self.lrcView?.noLrcLabel?.text = "暂无歌词"
			
			weakself?.playNext()
						
		}
	}
	
	func updatePlayBackProgress() {
		
		if (streamer.activeStream.contentLength) > 0 {
					
			if (bufferingIndicator?.progress)! >= CGFloat(1)  {

				playbackTimer?.invalidate()
			
				playbackTimer = nil
				
				bufferingIndicator?.progress = CGFloat(1)
				
			}
			
			let currentOffset = streamer.activeStream.currentSeekByteOffset
			
			let totalBufferedData = Int(currentOffset.start) + streamer.activeStream.prebufferedByteCount
			
			let bufferedDataFromTotal = Float(totalBufferedData) / Float(streamer.activeStream.contentLength)
			
			bufferingIndicator?.progress = CGFloat(bufferedDataFromTotal)
		
		}
		
	}
	
}
// MARK: - addGestureRecognizers
extension PlayerInterface {
	
	func addGestureRecognizer() {
		//播放和暂停
		let singleTap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(playOrPause))
		singleTap.numberOfTapsRequired = 1;
		singleTap.numberOfTouchesRequired = 1;
		self.addGestureRecognizer(singleTap)
		//上一首
		let swipeFromLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(playPrevious))
		swipeFromLeft.direction = .right
		swipeFromLeft.numberOfTouchesRequired = 1;
		self.addGestureRecognizer(swipeFromLeft)
		//下一首
		let swipeFromRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(playNext))
		swipeFromRight.numberOfTouchesRequired = 1
		swipeFromRight.direction = .left
		self.addGestureRecognizer(swipeFromRight)
		//快进
		let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(doSeeking(recognizer:)))
		longPress.numberOfTouchesRequired = 1
		longPress.minimumPressDuration = 0.5
		self.addGestureRecognizer(longPress)
		//随机
		let doubleswipeFromRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(playShuffle(_:)))
		doubleswipeFromRight.direction = .right
		doubleswipeFromRight.numberOfTouchesRequired = 2;
		self.addGestureRecognizer(doubleswipeFromRight)

		//顺序播放
		let doubleswipeFromLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(playShuffle(_:)))
		doubleswipeFromLeft.direction = .left
		doubleswipeFromLeft.numberOfTouchesRequired = 2;
		self.addGestureRecognizer(doubleswipeFromLeft)
		//单曲循环
		let doubleTouch: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(singleRewind))
		doubleTouch.numberOfTouchesRequired = 2
		doubleTouch.numberOfTapsRequired = 1
		self.addGestureRecognizer(doubleTouch)
		
		//展示歌词
		let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(showLyrics))
		doubleTap.numberOfTapsRequired = 2
		doubleTap.numberOfTouchesRequired = 1
		self.addGestureRecognizer(doubleTap)
		
		//当识别不出这是双击时才开启单击识别
		singleTap.require(toFail: doubleTouch)
		singleTap.require(toFail: doubleTap)
	}
}
// MARK: - Play Control
extension PlayerInterface {
	
	func playOrPause() {
		
		if self.tracks.count == 0 {
			
			HUD.flash(.label("向上滑动，更多精彩"), delay: 0.3)
			
			return
			
		}
		
		if self.paused == true {
			
			HUD.flash(.image(UIImage(named: "playB")), delay: 0.3)
			
		} else {
			
			HUD.flash(.image(UIImage(named: "pauseB")), delay: 0.3)

		}
		
		self.paused = !(self.paused)
		
		
		if streamer.activeStream.url == nil {
			
			playTracks(tracks: self.tracks, index: self.index!)
			
			return
			
		}
		
		streamer.pause()
		
	}
	
	func playPrevious() {
		
		if self.tracks.count == 0 {
			
			HUD.flash(.label("向上滑动，更多精彩"), delay: 0.3)
			
			return
			
			
		}
        
		let cur: FSStreamPosition = (self.streamer.activeStream.currentTimePlayed)

		
		if cur.minute == 0 || cur.second <= 5 {
				
				if self.repeatMode == AudioRepeatMode.shuffle {
						
						self.index = Int(arc4random()) % self.tracks.count
						
				} else if self.repeatMode == AudioRepeatMode.single {
						
						self.index = self.index!
						
				} else {
						
						if self.index == 0 {
								
								self.index = self.tracks.count - 1
								
						} else {
								
								self.index = self.index! - 1
								
						}
				}
		}
		
		playTracks(tracks: self.tracks, index: self.index!)
		
		self.coverScroll.scrollToIndex(self.index!, animated: true)
		
		changeInterface(self.index!)
		
		HUD.flash(.image(UIImage(named: "prevB")), delay: 0.3)
		
		
	}
	
	func playNext() {
		
		if self.tracks.count == 0 {
			
			HUD.flash(.label("向上滑动，更多精彩"), delay: 0.3)
			
			return
			
		}
				
		if self.repeatMode == AudioRepeatMode.shuffle {
			
			self.index = Int(arc4random()) % self.tracks.count
			
		} else if self.repeatMode == AudioRepeatMode.single {
			
			self.index = self.index!
			
		} else {
			
			if self.index == self.tracks.count - 1 {
				
				self.index = 0
				
			} else {
				
				self.index = self.index! + 1
				
			}
		
		}
		
		playTracks(tracks: self.tracks, index: self.index!)
		
		//change interface
		self.coverScroll.scrollToIndex(self.index!, animated: true)
		
		changeInterface(self.index!)
		
		HUD.flash(.image(UIImage(named: "nextB")), delay: 0.3)
	}
	
	func doSeeking(recognizer: UILongPressGestureRecognizer) {
		
		if self.tracks.count == 0 {
			
			HUD.flash(.label("向上滑动，更多精彩"), delay: 0.3)
			
			return
			
		}
		
		var seek: FSStreamPosition = FSStreamPosition()
		var lastPoint: CGPoint?
		
		
		if recognizer.state == .began {
			
			var tempBounds = self.backgroundView.bounds
			
			tempBounds.size.width -= 40
			
			tempBounds.size.height -= 40
			
			backgroundView.bounds = tempBounds
			
			// get current playing time
			let now = self.streamer.activeStream.currentTimePlayed
			
			self.progressOriginal = now.position
			
			self.originalPoint = recognizer.location(in: self)
		}
		
		if recognizer.state == .changed {
			
			let changingPoint = recognizer.location(in: self)
			
			let seekForwardPercent = self.progressOriginal! + Float((changingPoint.x - (self.originalPoint?.x)!) / width);
			
			if seekForwardPercent >= 1 || seekForwardPercent < 0 { return }
			
			self.progress?.progress = CGFloat(seekForwardPercent)
		}
		
		// change the progress
		if recognizer.state == .ended {
			
			// restore
			
			lastPoint = recognizer.location(in: self)
			
			backgroundView.frame = self.frame
			
			self.playModeView.frame = CGRect(x: self.width / 2 - 10,y: self.height - 20,width: 20,height: 20)
			
			// if didn't move don't change
			if lastPoint?.x == self.originalPoint?.x { return }
			
			seek.position = Float((self.progress?.progress)!)
			
			self.streamer.activeStream.seek(to: seek)
		}
	}
	
	func playShuffle(_ recognizer: UISwipeGestureRecognizer) {
		
		if recognizer.direction == .left {
			
			self.repeatMode = AudioRepeatMode.shuffle
			
			self.playModeView.image = UIImage(named: "shuffleOnB")
			
			HUD.flash(.image(UIImage(named: "shuffleOnB")), delay: 0.3)
		
		} else {
		
			self.repeatMode = AudioRepeatMode.towards
			
			self.playModeView.image = UIImage(named: "repeatOnB")
			
			HUD.flash(.image(UIImage(named: "repeatOnB")), delay: 0.3)
	
		}
		
		UserDefaults.standard.set(self.repeatMode?.rawValue, forKey: "repeatMode")
		
		UserDefaults.standard.synchronize()
	
	}
	
	func singleRewind() {
		
		if self.repeatMode == AudioRepeatMode.single {
			
			HUD.flash(.image(UIImage(named: "repeatOnB")), delay: 0.3)
			
			self.repeatMode = AudioRepeatMode.towards
			
			self.playModeView.image = UIImage(named: "repeatOnB")
			
		} else {
			
			HUD.flash(.image(UIImage(named: "repeatOneB")), delay: 0.3)
			
			self.repeatMode = AudioRepeatMode.single
			
			self.playModeView.image = UIImage(named: "repeatOneB")
			
		}
		
		UserDefaults.standard.set(self.repeatMode?.rawValue, forKey: "repeatMode")
		
		UserDefaults.standard.synchronize()
		
	}
	
	func showLyrics() {
		
		if self.tracks.count == 0 {
			
			HUD.flash(.label("向上滑动，更多精彩"), delay: 0.3)
			
			return
			
		}
		
		if lrcView.isHidden == true {
			
			self.lrcView.isHidden = false
			
			self.lrcView.alpha = 0
			
			UIView.animate(withDuration: 0.5, animations: { 
				
				self.lrcView.alpha = 1
				
			})
			
			UIView.commitAnimations()
			
			self.lrcView.noLrcLabel.isHidden = false
			
			addLrcTimer()
			
		} else {
			
			self.lrcView.alpha = 1
			
			UIView.animate(withDuration: 0.5, animations: { 
				
				self.lrcView.alpha = 0
				
			})
			
			UIView.commitAnimations()
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
				
				self.lrcView.isHidden = true
				
			})
			
			removeLrcTimer()
			
		}
		
	}
	
	func addLrcTimer() {
		
		if self.lrcView.isHidden == true { return }
		
		if self.streamer.activeStream.isPlaying() == false && self.lrcTimer != nil {
			
			updateLrcTimer()
			
			return
			
		}
		
		removeLrcTimer()
		
		updateLrcTimer()
		
		lrcTimer = CADisplayLink(target: self, selector: #selector(updateLrcTimer))
		
		self.lrcTimer?.add(to: RunLoop.main, forMode: .commonModes)
		
	}
	
	func updateLrcTimer() {
		
		// get now playing time and duration
		
		let cur = streamer.activeStream.currentTimePlayed
		
		self.lrcView.currentTime = Double(cur.minute * 60 + cur.second)
	}
	
	func removeLrcTimer() {
		
		self.lrcTimer?.invalidate()
		
		self.lrcTimer = nil
		
	}
	
}
// MARK: - LTInfiniteScrollViewDataSource
extension PlayerInterface: LTInfiniteScrollViewDataSource {
	
	func numberOfViews() -> Int {
		
		if self.tracks.count > 0 {
		
			return self.tracks.count
		
		}
		
		return 1
	}
	
	func numberOfVisibleViews() -> Int {
		
		return 1
		
	}
	
	func viewAtIndex(_ index: Int, reusingView view: UIView?) -> UIView {
		
		let size = self.bounds.size.width / CGFloat(numberOfVisibleViews())
		
		let cover: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))

		if self.tracks.count > 0 {
			
			let track: TrackEncoding = self.tracks[index]
			
			let urlStr: String = track.cover + "!/fw/600"
			
			let url: URL = URL(string: urlStr)!
			
			cover.sd_setImage(with: url, placeholderImage: UIImage(named: "noArtwork"), options: [], completed: { (image, _, _, _) in
				
				if index == self.index {
					
					self.reflection.image = cover.image?.reflection(withAlpha: 0.4)
					
				}

			})
			
		} else {
			
			cover.image = UIImage(named: "noArtwork")
		
		}
		
		return cover
	}
}
// MARK: - LTInfiniteScrollViewDelegate
extension PlayerInterface: LTInfiniteScrollViewDelegate {
	
	func updateView(_ view: UIView, withProgress progress: CGFloat, scrollDirection direction: LTInfiniteScrollView.ScrollDirection) {
		
	}
	
	func scrollViewDidScrollToIndex(_ scrollView: LTInfiniteScrollView, index: Int) {
		
		if self.tracks.count == 0 {
		
			return
		
		}
		
		self.index = index
		
		playTracks(tracks: self.tracks, index: index)
		
		changeInterface(index)
		
	}
}

