//
//  DownloadController.swift
//  破音万里
//
//  Created by Purchas on 2016/11/22.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit


class DownloadController: TrackListController {
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
	}
	
	//MARK: 禁止本地下载
	override func downloadSingle(recognizer: UIGestureRecognizer) {
		
	
	}

}

extension DownloadController {
	
	// Override to support conditional editing of the table view.
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
		
	}
	
	// Override to support editing the table view.
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		
		if editingStyle == .delete {
			// Delete the row from the data source
			let track = tracks[indexPath.row]
			
			// Send Message to Delegate
			self.delegate?.didDeletedTrack!(track: track, title: self.title!)
			
			// delete TableView Data
			tracks.remove(at: indexPath.row)
			
			tableView.deleteRows(at: [indexPath], with: .top)
			
			if tracks.count == 0 {
				
				self.navigationController!.popToRootViewController(animated: true)
				
			}
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
		return "你真要删呐？"
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
				
		if tableView.tag == 2 {
			
			let message = WXMediaMessage()
			
			message.title = sharedTrack?.name
			
			message.description = sharedTrack?.artist
			
			message.setThumbImage(self.selectedCell?.imageView?.image)
			
			let ext = WXMusicObject()
			
			ext.musicUrl = "https://poche.fm"
			
			ext.musicDataUrl = self.sharedTrack?.url
			
			message.mediaObject = ext
			
			let req = SendMessageToWXReq.init()
			
			req.bText = false
			
			req.message = message
			
			if indexPath.row == 0 {
				
				req.scene = Int32(WXSceneSession.rawValue)
				
			} else {
				
				req.scene = Int32(WXSceneTimeline.rawValue)
				
			}
			
			
			WXApi.send(req)
			
			dismissHover()
			
			
		} else {
			
			tableView.deselectRow(at: indexPath, animated: true)
			
			let main  = Notification.Name("selected")
			
			let player  = Notification.Name("player")
			
			let userInfo = [
				"indexPath": indexPath.row,
				"tracks": self.tracks,
				"type": "local",
				"title": self.title!
				] as [String : Any]
			
			
			let mainNotify: Notification = Notification.init(name: main, object: nil, userInfo: nil)
			
			let playerNotify: Notification = Notification.init(name: player, object: nil, userInfo: userInfo)
			
			
			NotificationCenter.default.post(mainNotify)
			
			NotificationCenter.default.post(playerNotify)
			
		}
		
	}
}
