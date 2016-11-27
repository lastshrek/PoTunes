//
//  PlayerController.swift
//  破音万里
//
//  Created by Purchas on 2016/11/14.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class PlayerController: UIViewController {

	var player: PlayerInterface?

	override func viewDidLoad() {

		super.viewDidLoad()
		
		// 添加播放器界面
		let player: PlayerInterface = PlayerInterface.init(frame: self.view.bounds)
		
		player.frame = self.view.bounds
		
		self.player = player
		
		self.view.addSubview(player)
		
		// 注册通知
		getNotification()
	}
}


// MARK: - getNotifications
extension PlayerController {
	
	func getNotification() {
		
		let center: NotificationCenter = NotificationCenter.default
		// 播放歌曲通知
		center.addObserver(self, selector: #selector(didSelectTrack(_:)), name: Notification.Name("player"), object: nil)
		
		center.addObserver(self, selector: #selector(audioSessionDidChangeInterruptionType(notification:)), name: NSNotification.Name.AVAudioSessionRouteChange, object: AVAudioSession.sharedInstance())
		
	}
	
	func didSelectTrack(_ notification: Notification) {
				
		let userInfo: Dictionary = notification.userInfo!
		
		let tracks = (userInfo["tracks"] as! Array<Any>?)!
		
		let index = userInfo["indexPath"] as? Int
		
		let title = userInfo["title"] as? String
		
		self.player?.tracks = tracks
		
		self.player?.index = index
		
		self.player?.coverScroll.reloadData(initialIndex: index!)
		
		self.player?.coverScroll.scrollToIndex(index!, animated: true)
				
		self.player?.playTracks(tracks: tracks, index: index!)
		
		self.player?.changeInterface(index!)
		
		self.player?.album?.text = title?.components(separatedBy: " - ").last
	
//		let type: String = userInfo["type"] as! String
	}
	
	func audioSessionDidChangeInterruptionType(notification: NSNotification) {
		
		let interruptReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
		
		if interruptReason == 2 {
			
			self.player?.streamer.pause()
			
		}
		
	}
}

