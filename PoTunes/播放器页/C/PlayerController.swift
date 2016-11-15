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
		
	}
	
	func didSelectTrack(_ notification: Notification) {
				
		let userInfo: Dictionary = notification.userInfo!
		
		let tracks = (userInfo["tracks"] as! Array<Any>?)!
		
		let index = userInfo["indexPath"] as? Int
		
		self.player?.tracks = tracks
		
		self.player?.index = index
		
		self.player?.coverScroll?.reloadData()
		
		self.player?.coverScroll?.scrollToIndex(index!, animated: true)
		
		let track: Track = tracks[index!] as! Track
		
		self.player?.name?.text = track.name
		
		self.player?.artist?.text = track.artist
		
		self.player?.playTracks(tracks: tracks, index: index!)
	
//		let type: String = userInfo["type"] as! String
	}
}

