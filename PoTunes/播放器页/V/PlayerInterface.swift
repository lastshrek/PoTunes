
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


class PlayerInterface: UIView {
	// MARK: - basic components
	let width = UIScreen.main.bounds.size.width
	let height = UIScreen.main.bounds.size.height
	var coverScroll: LTInfiniteScrollView?
	var reflection: UIImageView?
	var bufferingIndicator: LDProgressView?
	var progress: LDProgressView?
	var timeView: UIView?
	var currentTime: UILabel?
	var leftTime: UILabel?
	var name: TrackLabel?
	var artist: TrackLabel?
	var album: TrackLabel?
	var playModeView: UIImageView?
	var lrcView: LrcView?
	var tracks: Array<Any> = []
	var index: Int?
	
	
	// MARK: - streamer
	var streamer: FSAudioController?
	var repeatMode: AudioRepeatMode?
	var paused: Bool = true
	var currentTimeTimer: Timer?
	var playbackTimer: Timer?
	

	// MARK: - 播放模式
	enum AudioRepeatMode {
		case single
//		case playlistOnce
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
	
	override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		self.backgroundColor = UIColor.black
		
		initialSubviews()
		
		addGestureRecognizer()
		
	}
    
	override func layoutSubviews() {
		super.layoutSubviews()
		self.coverScroll?.frame = CGRect(x: 0, y: 0, width: width, height: width)
		self.reflection?.frame =  CGRect(x: 0, y: height - width, width: width, height: width)

		self.lrcView?.frame = CGRect(x: 0, y: 0, width: width, height: width)
		
		self.bufferingIndicator?.frame = CGRect(x: 0, y: width, width: width, height: 15)
		self.progress?.frame = (self.bufferingIndicator?.frame)!

		self.playModeView?.frame = CGRect(x: width / 2 - 10, y: height - 50, width: 20, height: 20)
		
		// MARK: - 除3
		self.name?.frame = CGRect(x: 0, y: width + 20, width: width, height: 40)
		self.artist?.frame = CGRect(x: 0, y: width + 60, width: width, height: 40)
	
		self.timeView?.frame = CGRect(x: 0, y: self.progress!.frame.maxY, width: width, height: 20)
		self.currentTime?.frame = CGRect(x: 2, y: 0, width: width / 2, height: 20)
		self.leftTime?.frame = CGRect(x: width / 2 - 2, y: 0, width: width / 2, height: (self.timeView?.bounds.size.height)!)
	}
	
	override func remoteControlReceived(with event: UIEvent?) {
		
		let remoteControl = event!.subtype
		
		switch remoteControl {
		
			case .remoteControlTogglePlayPause, .remoteControlPlay, .remoteControlPause:
				self.playOrPause()
				break
			
			case .remoteControlNextTrack:
				self.playNext()
			
			case .remoteControlPreviousTrack:
				self.playPrevious()
			
			default: break
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
// MARK: - initial subviews
extension PlayerInterface {
	func initialSubviews() {
		let coverScroll: LTInfiniteScrollView = LTInfiniteScrollView()
		coverScroll.dataSource = self
		coverScroll.delegate = self
		coverScroll.maxScrollDistance = 2
		coverScroll.reloadData(initialIndex: 0)
		self.coverScroll = coverScroll
		self.addSubview(coverScroll)
		
		// 倒影封面
		let reflection: UIImageView = UIImageView()
		reflection.autoresizingMask = [.flexibleHeight, .flexibleWidth]
		reflection.image = UIImage(named: "noArtwork")?.reflection(withAlpha: 0.4)
		self.addSubview(reflection)
		self.reflection = reflection
		self.sendSubview(toBack: reflection)
		
		//缓冲条
		let bufferingIndicator: LDProgressView = createProgressView(false, progress: 0, animate: false, showText: false, showStroke: false, progressInset: 0, showBackground: false, outerStrokeWidth: 0, type: LDProgressSolid, autoresizingMask: [.flexibleWidth, .flexibleTopMargin], borderRadius: 0, backgroundColor: UIColor.lightText)
		self.bufferingIndicator = bufferingIndicator
		self.addSubview(bufferingIndicator)
		//进度条
		let progress: LDProgressView = createProgressView(false, progress: 0, animate: false, showText: false, showStroke: false, progressInset: 0, showBackground: false, outerStrokeWidth: 0, type: LDProgressSolid, autoresizingMask: [.flexibleWidth, .flexibleTopMargin], borderRadius: 0, backgroundColor: UIColor.clear)
		self.progress = progress
		self.addSubview(progress)
		//开始时间和剩余时间
		let timeView: UIView = UIView()
		timeView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
		self.addSubview(timeView)
		self.timeView = timeView
		//当前播放时间
		let currentTime = createLabel([.flexibleHeight, .flexibleWidth], shadowOffset: CGSize(width: 0, height: 0), textColor: UIColor.white, text: nil, textAlignment: .left)
		self.currentTime = currentTime
		self.timeView?.addSubview(currentTime)
		//剩余时间
		let leftTime = createLabel([.flexibleHeight, .flexibleWidth, .flexibleLeftMargin], shadowOffset: CGSize(width: 0, height: 0), textColor: UIColor.white, text: nil, textAlignment: .right)
		self.timeView?.addSubview(leftTime)
		self.leftTime = leftTime
		//歌曲名
		let name: TrackLabel = TrackLabel()
		name.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
		self.addSubview(name)
		self.name = name
		//歌手名
		let artist: TrackLabel = TrackLabel()
		artist.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
		self.addSubview(artist)
		self.artist = artist
		//专辑名
		let album: TrackLabel = TrackLabel()
		album.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
		album.text = "尚未播放歌曲"
		self.addSubview(album)
		self.album = album
		//播放模式
		let playModeView: UIImageView = UIImageView()
		playModeView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
		playModeView.image = UIImage(named: "repeatOnB.png")
		playModeView.contentMode = .scaleAspectFit
		self.playModeView = playModeView
		self.addSubview(playModeView)
		// 歌词
//		let lrcView: LrcView = LrcView()
//		lrcView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
//		lrcView.isHidden = true
//		self.lrcView = lrcView
//		self.addSubview(lrcView)
	}
}

// MARK: - functional creation
extension PlayerInterface {
	
	func createProgressView(_ flat: Bool, progress: CGFloat, animate: Bool, showText: Bool, showStroke: Bool, progressInset: NSNumber, showBackground: Bool, outerStrokeWidth: NSNumber, type: LDProgressType, autoresizingMask: UIViewAutoresizing, borderRadius: NSNumber, backgroundColor: UIColor) -> LDProgressView {
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
	func playTracks(tracks: Array<Any>, index: Int) {
		
		self.paused = false
		
		self.streamer = nil
		
		self.streamer = FSAudioController()
		
		let track: Track = tracks[index] as! Track
		
		self.streamer?.activeStream.play(from: URL(string: track.url))
		
		addCurrentTimeTimer()
		
	}

	func addCurrentTimeTimer() {
		
		if self.paused == true { return }
		
		removeCurrentTimeTimer()
		// ensure the timer is up-to-now
		updateCurrentTime()
		updatePlayBackProgress()
		
		self.currentTimeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCurrentTime), userInfo: nil, repeats: true)
		self.playbackTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updatePlayBackProgress), userInfo: nil, repeats: true)
		
		RunLoop.main.add(self.currentTimeTimer!, forMode: .commonModes)
		RunLoop.main.add(self.playbackTimer!, forMode: .commonModes)
		
	}
	// remove timers
	func removeCurrentTimeTimer() {
		self.currentTimeTimer?.invalidate()
		self.playbackTimer?.invalidate()
		self.currentTimeTimer = nil
		self.playbackTimer = nil
		self.bufferingIndicator?.progress = 0
		self.progress?.progress = 0
	}
	
	func updateCurrentTime() {
		if self.streamer?.activeStream.duration.minute == 0 && self.streamer?.activeStream.duration.second == 0 { return }
		// get currentTime and duration
		let cur: FSStreamPosition = (self.streamer?.activeStream.currentTimePlayed)!
		let total: FSStreamPosition = (self.streamer?.activeStream.duration)!
		// set play progress
		let progress: Double = (Double)(cur.minute * 60 + cur.second) / (Double)(total.minute * 60 + total.second)
		
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
		
		self.currentTime?.text = NSString(format: "%d:%@", cur.minute, currSecond) as String
		self.leftTime?.text = NSString(format: "%@:%@", leftMin, leftSec) as String
		
		// when play at the end of file
		weak var weakself: PlayerInterface? = self
//		self.streamer?.onStateChange = { (streamState) -> Void in
//			print("播放下一首")
//		}
		self.streamer?.activeStream.onCompletion = { () ->Void in
			
//			self.progress?.progress = 0
//			
//			self.lrcView.lrcName = nil;
////
//			self.lrcView.chLrcName = nil;
//			
//			self.lrcView?.noLrcLabel?.text = "暂无歌词"
			
			weakself?.playNext()
						
		}
	}
	
	func updatePlayBackProgress() {
		
		if (self.streamer?.activeStream.contentLength)! > 0 {
			
			print((self.bufferingIndicator?.progress)!)
		
			if (self.bufferingIndicator?.progress)! >= CGFloat(1)  {

				self.playbackTimer?.invalidate()
			
				self.playbackTimer = nil
				
				self.bufferingIndicator?.progress = CGFloat(1)
				
			}
			
			let currentOffset = self.streamer?.activeStream.currentSeekByteOffset
			
			let totalBufferedData = Int((currentOffset?.start)!) + (self.streamer?.activeStream.prebufferedByteCount)!
			
			let bufferedDataFromTotal = Float(totalBufferedData) / Float((self.streamer?.activeStream.contentLength)!)
			
			self.bufferingIndicator?.progress = CGFloat(bufferedDataFromTotal)
		
		}
		
	}
}

// MARK : - addGestureRecognizers
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
		let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer.init(target: self, action: #selector(doSeeking))
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
		
	}
	
	func playPrevious() {
		
	}
	
	func playNext() {
		
	}
	
	func doSeeking() {
		
	}
	
	func playShuffle(_ recognizer: UISwipeGestureRecognizer) {
		
		if recognizer.direction == .left {
			
			self.repeatMode = AudioRepeatMode.shuffle
			
			self.playModeView?.image = UIImage(named: "shuffleOnB")
			
			HUD.flash(.image(UIImage(named: "shuffleOnB")))
		
		} else {
		
			self.repeatMode = AudioRepeatMode.towards
			
			self.playModeView?.image = UIImage(named: "repeatOnB")
			
			HUD.flash(.image(UIImage(named: "repeatOnB")))
	
		}
		
		UserDefaults.standard.set(self.repeatMode, forKey: "repeatMode")
	}
	
	func singleRewind() {
		
		if self.repeatMode == AudioRepeatMode.single {
			
			HUD.flash(.image(UIImage(named: "repeatOnB")))
			
			self.repeatMode = AudioRepeatMode.towards
			
			self.playModeView?.image = UIImage(named: "repeatOnB")
			
		} else {
			
			HUD.flash(.image(UIImage(named: "repeatOneB")))
			
			self.repeatMode = AudioRepeatMode.single
			
			self.playModeView?.image = UIImage(named: "repeatOneB")
			
		}
		
		UserDefaults.standard.set(self.repeatMode, forKey: "repeatMode")
		
	}
	
	func showLyrics() {
		
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
			
			let track: Track = (self.tracks[index] as? Track)!
			
			let urlStr: String = track.cover + "!/fw/600"
			
			let url: URL = URL(string: urlStr)!
			
			cover.sd_setImage(with: url, placeholderImage: UIImage(named: "noArtwork"), options: [], completed: { (image, _, _, _) in
				
				if index == self.index {
					
					self.reflection?.image = cover.image?.reflection(withAlpha: 0.4)

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
		
		let track: Track = (self.tracks[index] as? Track)!
		
		self.name?.text = track.name
		
		self.artist?.text = track.artist
		
		let cover = self.coverScroll?.viewAtIndex(index) as! UIImageView
		
		print(index)
		
		self.reflection?.image = cover.image?.reflection(withAlpha: 0.4)
		
	}
}

