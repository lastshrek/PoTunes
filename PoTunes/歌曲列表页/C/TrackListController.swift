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
import SCLAlertView

@objc  protocol TrackListDelegate: class {
	@objc optional func trackListControllerDidSelectRowAtIndexPath(indexPath: IndexPath)
	@objc optional func didDeletedTrack(track: TrackEncoding, title: String)
}

class TrackListController: UITableViewController {
	var tracks: Array<TrackEncoding> = []
	var playlistID: Int?
	var shareTable: UITableView?
	var hover: UIView?
	var sharedTrack: TrackEncoding?
	var selectedCell: TrackCell?
	var nowPlayingCell: TrackCell?
	var nowPlayingTrackID: Int?
	weak var delegate: TrackListDelegate?
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
		if UIScreen.main.bounds.size.height == 812 {
			tableView.contentInset = UIEdgeInsetsMake(44, 0, 34, 0)
		} else {
			tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
		}
		getNotification()
	}
	
	func getNotification() {
		let center = NotificationCenter.default
		center.addObserver(self, selector: #selector(nowPlayingTrackChange(sender:)), name: Notification.Name("nowPlayingTrack"), object: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: Notification.Name("nowPlayingTrack"), object: nil)
	}
	
	@objc func nowPlayingTrackChange(sender: Notification) {
		let userinfo = sender.userInfo
		let trackID = userinfo!["trackID"] as! Int
		self.nowPlayingTrackID = trackID
		self.tableView.reloadData()
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
			let track: TrackEncoding = self.tracks[indexPath.row]
            let cell: TrackCell = tableView.dequeueReusableCell(withIdentifier: "track", for: indexPath) as! TrackCell
			let downloadSwipe = UISwipeGestureRecognizer.init(target: self, action: #selector(downloadSingle(recognizer:))).then({
				$0.direction = .right
				$0.numberOfTouchesRequired = 1
			})
			let url: URL = URL(string: track.cover + "!/fw/100")!
			let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(shareToWechat(recognizer:)))
            cell.textLabel?.text = track.name
            cell.detailTextLabel?.text = track.artist
            cell.imageView?.sd_setImage(with: url, placeholderImage: UIImage(named:"noArtwork"))
			cell.playing.isHidden = true
            // Add download gesture recognizer
            // Add share to wechat gesture recognizer
			cell.addGestureRecognizer(downloadSwipe)
            cell.addGestureRecognizer(longPress)
			if (self.nowPlayingTrackID != nil && track.ID == self.nowPlayingTrackID) {
				cell.playing.isHidden = false
			}
			let user = UserDefaults.standard
			let trackID = user.integer(forKey: "trackID")
			if trackID == track.ID {
				cell.playing.isHidden = false
			}
            return cell
        }
        
		let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "wechat", for: indexPath).then({
			if indexPath.row == 0 {
				$0.textLabel?.text = "分享给微信好友"
				$0.imageView?.image = UIImage(named: "cm2_mlogo_weixin")
			} else {
				$0.textLabel?.text = "分享到微信朋友圈"
				$0.imageView?.image = UIImage(named: "cm2_mlogo_pyq")
			}
		})
        return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

        if tableView.tag == 2 {
			let description = sharedTrack?.artist
			let title = sharedTrack?.name
			let musicUrl = NSURL(string: "https://poche.fm/api/app/track/\(sharedTrack!.ID)") as URL!
			let thumbImage = self.selectedCell?.imageView?.image
			let musicFileURL = NSURL(string: self.sharedTrack!.url) as URL!
			var scene:SSDKPlatformType
			if indexPath.row == 0 {
				scene = SSDKPlatformType.subTypeWechatSession
			} else {
				scene = SSDKPlatformType.subTypeWechatTimeline
			}
			
			let shareParams = NSMutableDictionary()
			shareParams.ssdkSetupWeChatParams(byText: description,
			                                   title: title,
			                                   url: musicUrl,
			                                   thumbImage:thumbImage ,
			                                   image: nil,
			                                   musicFileURL: musicFileURL,
			                                   extInfo: nil,
			                                   fileData: nil,
			                                   emoticonData: nil,
			                                   sourceFileExtension: nil,
			                                   sourceFileData: nil,
			                                   type: SSDKContentType.audio,
			                                   forPlatformSubType: scene)
			
			ShareSDK.share(scene, parameters: shareParams) { (state : SSDKResponseState, nil, entity : SSDKContentEntity?, error :Error?) in
				switch state {
				case SSDKResponseState.success:
					HUD.flash(.label("分享成功"), delay: 0.5)
					self.dismissHover()
					break
				case SSDKResponseState.fail:
					HUD.flash(.label("授权失败,错误描述:\(String(describing: error))"), delay: 0.5)
					self.dismissHover()
					break
				case SSDKResponseState.cancel:
					HUD.flash(.label("操作取消"), delay: 0.5)
					self.dismissHover()
					break
				default:
					break
				}
			}
			
        } else {
            let main  = Notification.Name("selected")
            let player  = Notification.Name("player")
            let userInfo = [
                "indexPath": indexPath.row,
                "tracks": self.tracks,
                "type": "online",
                "title": self.title!,
                "playlistID": self.playlistID!
                ] as [String : AnyObject]
            let mainNotify: Notification = Notification.init(name: main, object: nil, userInfo: nil)
            let playerNotify: Notification = Notification.init(name: player, object: nil, userInfo: userInfo)
			let cell = tableView.cellForRow(at: indexPath) as! TrackCell
			self.nowPlayingCell?.accessoryView?.isHidden = true
			self.nowPlayingCell = cell
			cell.accessoryView?.isHidden = false			
			
            NotificationCenter.default.post(mainNotify)
            NotificationCenter.default.post(playerNotify)
			let userDefaults = UserDefaults.standard
			userDefaults.set(self.playlistID, forKey: "playlistID")
			userDefaults.set(true, forKey: "isPlaying")
			userDefaults.set(nil, forKey: "title")
			userDefaults.synchronize()
        }
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if tableView.tag != 2 {
			return 66
		}
		return 50
	}
    
	// MARK: SET Display style
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		if tableView.tag != 2 {
			let rotationAngleDegrees: CGFloat = 0
			let rotationAngleRadians: CGFloat = rotationAngleDegrees * (CGFloat)(Double.pi/180)
			let offsetPositioning: CGPoint = CGPoint(x: -200,y: -20)
			var transform: CATransform3D = CATransform3DIdentity
			transform = CATransform3DRotate(transform, rotationAngleRadians, 0.0, 0.0, 1.0);
			transform = CATransform3DTranslate(transform, offsetPositioning.x, offsetPositioning.y, 0.0)

			let card: UIView = cell.contentView.then({
				$0.layer.transform = transform
				$0.layer.opacity = 0.8
			})
			
			UIView.animate(withDuration: 0.2, animations: {
				card.layer.transform = CATransform3DIdentity
				card.layer.opacity = 1
			})
			
			UIView.commitAnimations()
		}
	}
	
    @objc func shareToWechat(recognizer: UIGestureRecognizer) {
        if recognizer.state.rawValue == 1 {
			let height = self.view.bounds.size.height
			let width = self.view.bounds.size.width
			let tap = UITapGestureRecognizer.init(target: self, action: #selector(dismissHover))

            hover?.removeFromSuperview()
            shareTable?.removeFromSuperview()
            sharedTrack = nil
			
			hover = UIView().then({
				$0.frame = self.tableView.bounds
				$0.backgroundColor = UIColor.black
				$0.alpha = 0
				self.view.addSubview($0)
			})
            self.tableView.isScrollEnabled = false
            hover?.addGestureRecognizer(tap)
            // Create shareTable
			shareTable = UITableView.init(frame: CGRect(x: 0, y: height, width: width, height: 100), style: .plain).then({
				$0.tag = 2
				$0.isScrollEnabled = false
				$0.delegate = self
				$0.dataSource = self
				$0.register(UITableViewCell.self, forCellReuseIdentifier: "wechat")
			})
			
            tableView.superview?.addSubview(shareTable!)

			UIView.animate(withDuration: 0.2, animations: {
                if UIScreen.main.bounds.size.height == 812 {
                    self.shareTable?.frame = CGRect(x: 0, y: height - 150, width: width, height: 100)
                } else {
                    self.shareTable?.frame = CGRect(x: 0, y: height - 100, width: width, height: 100)
                }
                
                self.hover?.alpha = 0.5
            })
            UIView.commitAnimations()
            // Get shared Track
            let position = recognizer.location(in: self.tableView)
            let indexPath = self.tableView.indexPathForRow(at: position)
            let cell = tableView.cellForRow(at: indexPath!)
			let track = self.tracks[(indexPath?.row)!]
			selectedCell = cell as! TrackCell?
            sharedTrack = track
        }
    }
    
	@objc func dismissHover() {
        hover?.removeFromSuperview()
        shareTable?.removeFromSuperview()
        tableView.isScrollEnabled = true
    }
	
    @objc func downloadSingle(recognizer: UIGestureRecognizer) {
		// check user network and whether allow to play
		let user = UserDefaults.standard
		let online = user.object(forKey: "online")
		if online == nil { return }
		
		let cell = recognizer.view as! TrackCell
		let indexPath = self.tableView.indexPath(for: cell)
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
		let userInfo = ["title": self.title!, "identifier": identifier, "track": track] as [String : Any]

		tracksDB.executeUpdate(sql, withArgumentsIn: [artist, title, track.url, track.ID, track.cover, self.title!,identifier])
		
		HUD.flash(.label("开始下载"), delay: 0.3) { (_) in
			NotificationCenter.default.post(name: Notification.Name("download"), object: nil, userInfo: userInfo)
		}
		s?.close()
    }
}
