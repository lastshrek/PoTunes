//
//  SongListController.swift
//  破音万里
//
//  Created by Purchas on 2016/11/12.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit


protocol SongListDelegate: class {
	
	func songListControllerDidSelectRowAtIndexPath(indexPath: IndexPath)

}

class SongListController: UITableViewController {
	
	var tracks: Array<Track> = []
	
	var shareTable: UITableView?
	
	var hover: UIView?
	
	var sharedTrack: Track?
	
	weak var delegate: SongListDelegate?
    
    var selectedCell: TrackCell?
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		tableView.register(TrackCell.self, forCellReuseIdentifier: "track")
        
		tableView.separatorStyle = .none
	}
	

}
// MARK: - UITableViewDataSource
extension SongListController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		if tableView.tag == 2 { return 2 }
		
		return self.tracks.count
	}
}

// MARK: - UITableViewDelegate
extension SongListController {
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag != 2 {
            
            let cell: TrackCell = tableView.dequeueReusableCell(withIdentifier: "track", for: indexPath) as! TrackCell
            
            // Configure the cell...
            let track: Track = self.tracks[indexPath.row]
            
            cell.textLabel?.text = track.name
            
            cell.detailTextLabel?.text = track.artist
            
            let url: URL = URL(string: track.cover + "!/fw/100")!
            
            cell.imageView?.sd_setImage(with: url, placeholderImage: UIImage(named:"noArtwork"))
            
            // Add download gesture recognizer
            
            // Add share to wechat gesture recognizer
            
            let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(shareToWechat(recognizer:)))
            
            cell.addGestureRecognizer(longPress)
            
            return cell
            
        }
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "wechat", for: indexPath)
//
//        if cell == nil {
        
//            let cell = UITableViewCell.init(style: .default, reuseIdentifier: "wechat")
        
//        }
        
        if indexPath.row == 0 {
            
            cell.textLabel?.text = "分享给微信好友"
            
            cell.imageView?.image = UIImage(named: "cm2_mlogo_weixin")
            
        } else {
            
            cell.textLabel?.text = "分享到微信朋友圈"
            
            cell.imageView?.image = UIImage(named: "cm2_mlogo_pyq")
            
        }
        
        return cell
		
		
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
            
            
        } else {
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            let main  = Notification.Name("selected")
            
            let player  = Notification.Name("player")
            
            let userInfo = [
                "indexPath": indexPath.row,
                "tracks": self.tracks,
                "type": "online",
                "title": self.title!
                ] as [String : Any]
            
            
            let mainNotify: Notification = Notification.init(name: main, object: nil, userInfo: nil)
            
            let playerNotify: Notification = Notification.init(name: player, object: nil, userInfo: userInfo)
            
            
            NotificationCenter.default.post(mainNotify)
            
            NotificationCenter.default.post(playerNotify)
            
        }
        
	}
	// Override to support conditional editing of the table view.
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}
	
//	// Override to support editing the table view.
//	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//		
//		if editingStyle == .delete {
//			// Delete the row from the data source
//			tableView.deleteRows(at: [indexPath], with: .fade)
//		
//		}
//	}
//	
//	override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
//		return "你真要删呐？"
//	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		if tableView.tag != 2 {
		
			return 66
		
		}
		
		return 44
	}
    
	// MARK: SET Display style
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		
		if tableView.tag != 2 {
			
			let rotationAngleDegrees: CGFloat = 0
			
			let rotationAngleRadians: CGFloat = rotationAngleDegrees * (CGFloat)(M_PI/180)
			
			let offsetPositioning: CGPoint = CGPoint(x: -200,y: -20)
			
			var transform: CATransform3D = CATransform3DIdentity
			
			transform = CATransform3DRotate(transform, rotationAngleRadians, 0.0, 0.0, 1.0);
			
			transform = CATransform3DTranslate(transform, offsetPositioning.x, offsetPositioning.y, 0.0)
			
			let card: UIView = cell.contentView
			
			card.layer.transform = transform
			
			card.layer.opacity = 0.8
			
			UIView.animate(withDuration: 0.2, animations: {
				
				card.layer.transform = CATransform3DIdentity
				
				card.layer.opacity = 1
			
			})
		}
	}
    
    func shareToWechat(recognizer: UIGestureRecognizer) {
        
        if recognizer.state.rawValue == 1 {
            
            hover?.removeFromSuperview()
            
            shareTable?.removeFromSuperview()
            
            sharedTrack = nil
            
            let height = self.view.bounds.size.height
            
            let width = self.view.bounds.size.width
            
            hover = UIView()
            
            hover?.frame = self.tableView.bounds
            
            hover?.backgroundColor = UIColor.black
            
            hover?.alpha = 0
            
            self.view.addSubview(hover!)
            
            self.tableView.isScrollEnabled = false
            
            // Add Gesture
            
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(dismissHover(recognizer:)))
            
            hover?.addGestureRecognizer(tap)
            
            // Create shareTable
            shareTable = UITableView.init(frame: CGRect(x: 0, y: height - 200, width: width, height: 88), style: .plain)
            
            shareTable?.tag = 2
            
            shareTable?.delegate = self
            
            shareTable?.dataSource = self
            
            shareTable?.register(UITableViewCell.self, forCellReuseIdentifier: "wechat")

            
            self.tableView.superview?.addSubview(shareTable!)
            
            UIView.animate(withDuration: 0.2, animations: { 
                
                self.shareTable?.frame = CGRect(x: 0, y: height - 200, width: width, height: 88)
                
                self.hover?.alpha = 0.5
            })
            
            UIView.commitAnimations()
            
            // Get shared Track
            
            let position = recognizer.location(in: self.tableView)
            
            let indexPath = self.tableView.indexPathForRow(at: position)
            
            let cell = tableView.cellForRow(at: indexPath!)
            
            self.selectedCell = cell as! TrackCell?
            
            let track = self.tracks[(indexPath?.row)!]
            
            self.sharedTrack = track
            
        }
        
    }
    
    func dismissHover(recognizer: UIGestureRecognizer) {
        
        hover?.removeFromSuperview()
        
        shareTable?.removeFromSuperview()
        
        tableView.isScrollEnabled = true
        
    }
	
}
