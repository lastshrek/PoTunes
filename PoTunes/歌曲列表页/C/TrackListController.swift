//
//  SongListController.swift
//  破音万里
//
//  Created by Purchas on 2016/11/12.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit
import PKHUD
import FMDB

@objc  protocol TrackListDelegate: class {
	
	@objc optional func trackListControllerDidSelectRowAtIndexPath(indexPath: IndexPath)
	
	@objc optional func didDeletedTrack(track: Track, title: String)

}

class TrackListController: UITableViewController {
	
	var tracks: Array<Track> = []
	
	var shareTable: UITableView?
	
	var hover: UIView?
	
	var sharedTrack: Track?
	
	weak var delegate: TrackListDelegate?
    
	var selectedCell: TrackCell?
	
    lazy var queue: FMDatabaseQueue = DBHelper.sharedInstance.queue!
    
    lazy var tracksDB: FMDatabase = {
        
        let path = self.dirDoc() + "/downloadingSong.db"
        
        let db: FMDatabase = FMDatabase(path: path)
        
        db.open()
        
        return db
    }()
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		tableView.register(TrackCell.self, forCellReuseIdentifier: "track")
        
		tableView.separatorStyle = .none
		
		tableView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0)
		
		tableView.contentOffset = CGPoint(x: 0, y: 0)

        
	}
	
}
// MARK: - UITableViewDataSource
extension TrackListController {
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 1
		
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		if tableView.tag == 2 { return 2 }
		
		return tracks.count
		
	}
}

// MARK: - UITableViewDelegate
extension TrackListController {
	
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
			let downloadSwipe = UISwipeGestureRecognizer.init(target: self, action: #selector(downloadSingle(recognizer:)))
			
			downloadSwipe.direction = .right
			
			downloadSwipe.numberOfTouchesRequired = 1
			
			cell.addGestureRecognizer(downloadSwipe)
            
            // Add share to wechat gesture recognizer
            
            let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(shareToWechat(recognizer:)))
            
            cell.addGestureRecognizer(longPress)
            
            return cell
            
        }
        
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "wechat", for: indexPath)
		
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
			
			dismissHover()
            
            
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
	
    // FIXME: Hover position
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
            
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(dismissHover))
            
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
    
    func dismissHover() {
        
        hover?.removeFromSuperview()
        
        shareTable?.removeFromSuperview()
        
        tableView.isScrollEnabled = true
        
    }
	
	func downloadSingle(recognizer: UIGestureRecognizer) {
		
		// check user network and whether allow to play
		let user = UserDefaults.standard
		
		let online = user.object(forKey: "online")
		
		if online == nil { return }
		

		let position = recognizer.location(in: tableView)
		
		let indexPath = tableView.indexPathForRow(at: position)
		
		// FIXME: 检查网络状况是否允许播放
		
		let track = tracks[(indexPath?.row)!]
		
		let artist = self.doubleQuotation(single: track.artist)
		
		let title = self.doubleQuotation(single: track.name)
		
		let query = "SELECT * FROM t_downloading WHERE author = ? and title = ? and album = ?;"
        
        let s = tracksDB.executeQuery(query, withArgumentsIn: [artist, title, self.title!])
        
        if (s?.next())! {
            
            let downloaded = s?.bool(forColumn: "downloaded")
            
            if downloaded == true {
                
                HUD.flash(.label("歌曲已下载"), delay: 0.3)
                
                return
                
            } else {
                
                HUD.flash(.label("歌曲正在下载中"), delay: 0.3)
                
            }
            
            s?.close()
            
            
            return
            
        }
        
        let identifier = self.getIdentifier(urlStr: track.url)
        
        let sql = "INSERT INTO t_downloading(author,title,sourceURL,indexPath,thumb,album,downloaded,identifier) VALUES(?,?,?,?,?,?,'0',?)"
        
        tracksDB.executeUpdate(sql, withArgumentsIn: [artist, title, track.url, track.ID, track.cover, self.title!,identifier])
        
        
        let userInfo = ["title": self.title!, "identifier": identifier, "track": track] as [String : Any]
        
        NotificationCenter.default.post(name: Notification.Name("download"), object: nil, userInfo: userInfo)
        
        HUD.flash(.label("开始下载"), delay: 0.3)
        
        
        s?.close()

        
    }
}
