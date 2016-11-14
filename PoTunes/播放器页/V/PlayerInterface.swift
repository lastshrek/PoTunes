
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
	

	// MARK: - 播放模式
	enum AudioRepeatMode {
		case single
		case playlistOnce
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
		self.reflection?.frame =  CGRect(x: 0, y: height - width, width: width, height: height)

		self.lrcView?.frame = CGRect(x: 0, y: 0, width: width, height: width)
		
		self.bufferingIndicator?.frame = CGRect(x: 0, y: height - 30, width: width, height: 30)
		self.progress?.frame = (self.bufferingIndicator?.frame)!

		self.playModeView?.frame = CGRect(x: width / 2 - 10, y: height - 50, width: 20, height: 20)
		
		// MARK: - 除3
		self.name?.frame = CGRect(x: 0, y: width, width: width, height: 40)
		self.artist?.frame = CGRect(x: 0, y: width + 40, width: width, height: 40)
	
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
		
		//缓冲条
		let bufferingIndicator: LDProgressView = createProgressView(false, progress: 0, animate: false, showText: false, showStroke: false, progressInset: 0, showBackground: false, outerStrokeWidth: 0, type: LDProgressSolid, autoresizingMask: [.flexibleWidth, .flexibleTopMargin], borderRadius: 0, backgroundColor: UIColor.clear)
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
		let lrcView: LrcView = LrcView()
		lrcView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
		lrcView.isHidden = true
		self.lrcView = lrcView
		self.addSubview(lrcView)
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
		let doubleswipeFromRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(playShuffle))
		doubleswipeFromRight.direction = .right
		doubleswipeFromRight.numberOfTouchesRequired = 2;
		self.addGestureRecognizer(doubleswipeFromRight)
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
// MARK: - 播放方法
extension PlayerInterface {
	func playOrPause() {
		
	}
	
	func playPrevious() {
		
	}
	
	func playNext() {
		
	}
	
	func doSeeking() {
		
	}
	
	func playShuffle() {
		
	}
	
	func singleRewind() {
		
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
			
			
				self.reflection?.image = cover.image
			
			
			
			cover.sd_setHighlightedImage(with: url, options: nil, completed: { (image, _, _, _) in
				
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
		
	}
}
