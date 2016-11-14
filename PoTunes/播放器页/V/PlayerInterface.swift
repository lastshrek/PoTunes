
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
	
	let width = UIScreen.main.bounds.size.width
	let height = UIScreen.main.bounds.size.height
	var coverScroll: LTInfiniteScrollView?
	var cover: UIImageView?
	var bufferingIndicator: LDProgressView?
	var progress: LDProgressView?
	var timeView: UIView?
	var currentTime: UILabel?
	var leftTime: UILabel?
	var songName: UILabel?
	var artist: PCLabel?
	var album: PCLabel?
	var playModeView: UIImageView?
	var lrcView: LrcView?
	var repeatMode: AudioRepeatMode
	/** 播放模式 */
	enum AudioRepeatMode {
		case single
		case playlistOnce
		case playlist
		case towards
		case shuffle
	}
	/** 播放操作 */
	enum AudioPlayState {
		case play
		case pause
		case next
		case previous
	}
    
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = UIColor.black
		//专辑封面
		let cover: UIImageView = UIImageView()
		cover.autoresizingMask = [.flexibleHeight, .flexibleWidth]
		cover.image = UIImage(named: "noArtwork.jpg")
		self.cover = cover
		self.addSubview(cover)
		
		let coverScroll: LTInfiniteScrollView = LTInfiniteScrollView()
		coverScroll.dataSource = self
		coverScroll.delegate = self
		coverScroll.maxScrollDistance = 2
		coverScroll.reloadData(initialIndex: 0)
		self.coverScroll = coverScroll
		self.addSubview(coverScroll)
		
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
		let songName: UILabel = createLabel([.flexibleWidth, .flexibleTopMargin], shadowOffset: nil, textColor: UIColor.white, text: "尚未播放歌曲", textAlignment: .center)
		self.addSubview(songName)
		self.songName = songName
		//歌手名
		let artist: PCLabel = PCLabel()
		artist.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
		self.addSubview(artist)
		self.artist = artist
		//专辑名
		let album: PCLabel = PCLabel()
		album.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
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
    
	override func layoutSubviews() {
		super.layoutSubviews()
		
		self.coverScroll?.frame = CGRect(x: 0, y: 0, width: width, height: width)
		
		self.bufferingIndicator?.frame = CGRect(x: 0, y: height - 30, width: width, height: 30)
		self.progress?.frame = (self.bufferingIndicator?.frame)!
		self.timeView?.frame = CGRect(x: 0, y: self.progress!.frame.maxY, width: width, height: 20)
		self.currentTime?.frame = CGRect(x: 2, y: 0, width: width / 2, height: 20)
		self.leftTime?.frame = CGRect(x: width / 2 - 2, y: 0, width: width / 2, height: (self.timeView?.bounds.size.height)!)

		self.playModeView?.frame = CGRect(x: width / 2 - 10, y: height - 20, width: 20, height: 20)
		self.lrcView?.frame = CGRect(x: 0, y: 0, width: width, height: width)
	}
	
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

	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension PlayerInterface: LTInfiniteScrollViewDataSource {
	func numberOfViews() -> Int {
		return 10
	}
	
	func numberOfVisibleViews() -> Int {
		return 1
	}
	
	func viewAtIndex(_ index: Int, reusingView view: UIView?) -> UIView {
		let size = self.bounds.size.width / CGFloat(numberOfVisibleViews())
		let cover: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
		cover.image = UIImage(named: "noArtwork.jpg")
		return cover
	}
}

extension PlayerInterface: LTInfiniteScrollViewDelegate {
	func updateView(_ view: UIView, withProgress progress: CGFloat, scrollDirection direction: LTInfiniteScrollView.ScrollDirection) {
		
	}
	
	func scrollViewDidScrollToIndex(_ scrollView: LTInfiniteScrollView, index: Int) {
		print(index)
	}
}
// MARK : - 添加手势识别
extension PlayerInterface {
	func addGestureRecognizer() {
		//播放和暂停
		let singleTap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(playOrPause))
		singleTap.numberOfTapsRequired = 1;
		singleTap.numberOfTouchesRequired = 1;
		self.addGestureRecognizer(singleTap)
		//上一首
		let swipeFromLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(playPrevious(_:)))
		swipeFromLeft.direction = .right
		swipeFromLeft.numberOfTouchesRequired = 1;
		self.addGestureRecognizer(swipeFromLeft)
//		//下一首
//		let swipeFromRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer.init(target: self, action: <#T##Selector?#>)
//		swipeFromRight.numberOfTouchesRequired = 1;
//		[swipeFromRight setDirection:UISwipeGestureRecognizerDirectionLeft];
//		[self.backgroundView addGestureRecognizer:swipeFromRight];
//		//快进
//		UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(doSeeking:)];
//		longPress.numberOfTouchesRequired = 1;
//		longPress.minimumPressDuration = 0.5;
//		[self.backgroundView addGestureRecognizer:longPress];
//		//随机
//		UISwipeGestureRecognizer *doubleswipeFromRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(playShuffle:)];
//		[doubleswipeFromRight setDirection:UISwipeGestureRecognizerDirectionRight];
//		doubleswipeFromRight.numberOfTouchesRequired = 2;
//		[self.backgroundView addGestureRecognizer:doubleswipeFromRight];
//		
//		//随机
//		UISwipeGestureRecognizer *doubleswipeFromLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(playShuffle:)];
//		[doubleswipeFromLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
//		doubleswipeFromLeft.numberOfTouchesRequired = 2;
//		[self.backgroundView addGestureRecognizer:doubleswipeFromLeft];
//		
//		//单曲循环
//		UITapGestureRecognizer *doubleTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playSingle)];
//		doubleTouch.numberOfTouchesRequired = 2;
//		doubleTouch.numberOfTapsRequired = 1;
//		[self.backgroundView addGestureRecognizer:doubleTouch];
//		
//		//展示歌词
//		UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLyrics)];
//		doubleTap.numberOfTapsRequired = 2;
//		doubleTap.numberOfTouchesRequired = 1;
//		[self.backgroundView addGestureRecognizer:doubleTap];
//		
//		//当识别不出这是双击时才开启单击识别
//		[singleTap requireGestureRecognizerToFail:doubleTouch];
//		[singleTap requireGestureRecognizerToFail:doubleTap];
		
	}

}

extension PlayerInterface {
	func playOrPause() {
		
	}
	
	@objc func playPrevious(_ repeatMode: AudioRepeatMode) {
		
	}
}
