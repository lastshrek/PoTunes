//
//  PlayerController.swift
//  破音万里
//
//  Created by Purchas on 2016/11/14.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class PlayerController: UIViewController {

	var player: PlayerInterface!


	override func viewDidLoad() {
		super.viewDidLoad()
		// 添加播放器界面
		player = PlayerInterface.init()
		player.layoutThatFits(ASSizeRange(min: CGSize(width: 0, height: 0), max: self.view.bounds.size))
		self.view.addSubview(player.view)
        getNotification()
        addGestureRecognizer()
	}
}
// MARK: - GestureRecognizer
extension PlayerController {
    func addGestureRecognizer() {
        // 播放和暂停
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(playOrPause))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(singleTap)
        //下一首
        let swipeFromLeft = UISwipeGestureRecognizer.init(target: self, action: #selector(playNext))
        swipeFromLeft.direction = .right;
        swipeFromLeft.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(swipeFromLeft)
        //上一首
        let swipeFromRight = UISwipeGestureRecognizer.init(target: self, action: #selector(playPrevious))
        swipeFromLeft.direction = .left
        swipeFromLeft.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(swipeFromRight)
        //快进
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(doSeeking(sender:)))
        longPress.numberOfTouchesRequired = 1
        longPress.minimumPressDuration = 0.5
        self.view.addGestureRecognizer(longPress)
        //随机
        let doubleswipeFromRight = UISwipeGestureRecognizer.init(target: self, action: #selector(playShuffle(sender:)))
        doubleswipeFromRight.direction = .right
        doubleswipeFromRight.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(doubleswipeFromRight)
        //顺序播放
        let doubleswipeFromLeft = UISwipeGestureRecognizer.init(target: self, action: #selector(playShuffle(sender:)))
        doubleswipeFromLeft.direction = .left
        doubleswipeFromLeft.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(doubleswipeFromLeft)
        //单曲循环
        let doubleTouch = UITapGestureRecognizer.init(target: self, action: #selector(singleRewind))
        doubleTouch.numberOfTouchesRequired = 2
        doubleTouch.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(doubleTouch)
        //展示歌词
        let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(showLyrics))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(doubleTap)
        
        singleTap.require(toFail: doubleTouch)
        singleTap.require(toFail: doubleTap)
    }
}
// MARK: -
extension PlayerController {
    @objc func playOrPause() {
        self.player.playOrPause()
    }
    @objc func playNext() {
        self.player.playNext()
    }
    @objc func playPrevious() {
        self.player.playPrevious()
    }
    @objc func doSeeking(sender: UILongPressGestureRecognizer) {
        self.player.doSeeking(sender)
    }
    
    @objc func playShuffle(sender: UISwipeGestureRecognizer) {
        self.player.playShuffle(sender)
    }
    @objc func singleRewind() {
        self.player.singleRewind()
    }
    @objc func showLyrics() {
        self.player.showLyrics()
    }
}
// MARK: - getNotifications
extension PlayerController {
	func getNotification() {
		// 播放歌曲通知
		NotificationCenter.default.addObserver(self, selector: #selector(didSelectTrack(_:)), name: Notification.Name("player"), object: nil)
	}
	
    @objc func didSelectTrack(_ notification: Notification) {
		let userInfo: Dictionary = notification.userInfo!
		let tracks = (userInfo["tracks"] as! Array<TrackEncoding>?)!
		let index = userInfo["indexPath"] as? NSInteger
		let title = userInfo["title"] as? String
		self.player?.type = userInfo["type"] as? String
		self.player?.playTracks(tracks, index: index!)
		self.player?.coverScroll.reloadData(withInitialIndex: index!)
		self.player?.album?.text = title?.components(separatedBy: " - ").last
	}
}

