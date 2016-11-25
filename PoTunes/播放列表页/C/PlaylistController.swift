//
//  Article.swift
//  破音万里
//
//  Created by Purchas on 16/8/22.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit
import Alamofire
import DGElasticPullToRefresh
import PKHUD
import FMDB

protocol PlaylistDelegate: class {
	
	func tabBarCount(count: Int)

}

let P_URL = "https://poche.fm/api/app/playlists/"

class PlaylistController: UITableViewController {
	
	var playlists: Array<Playlist> = []
	
	lazy var queue: FMDatabaseQueue = DBHelper.sharedInstance.queue!

	weak var delegate: PlaylistDelegate?
	
	lazy var playlistsDB: FMDatabase = {
		
		let path = self.dirDoc() + "/downloadingSong.db"
		
		let db: FMDatabase = FMDatabase(path: path)
		
		db.open()
		
		return db
	}()
	
	var recognizer: UIGestureRecognizer?
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		let width = self.view.bounds.size.width
		// Initialize tableView
		tableView.rowHeight = width * 300 / 640
		
		tableView.separatorStyle = .none
		
		tableView.backgroundColor = UIColor.black
		
		tableView.register(PlaylistCell.self, forCellReuseIdentifier: "playlist")
		
		tableView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0)
		
		tableView.contentOffset = CGPoint(x: 0, y: 0)
		
		// Refresh
		addPullToRefresh()
		// MARK: -  检查本地缓存播放列表
		checkLocalPlaylists()
		
		debugPrint(self.dirDoc())
		
	}
	
	func checkLocalPlaylists() {
		
		let query = "select * from t_playlists"
		
		let s = playlistsDB.executeQuery(query, withArgumentsIn: nil)
		
		if s?.next() == false {
			
			loadNewPlaylist()
			
		} else {
			
			let sql = "select * from t_playlists order by p_id desc"
			
			let s = playlistsDB.executeQuery(sql, withArgumentsIn: nil)
			
			while s?.next() == true {
				
				let playlist = Playlist()
			
				playlist.ID = (Int)((s?.int(forColumn: "id"))!)
				
				playlist.title = (s?.string(forColumn: "title"))!
				
				playlist.cover = (s?.string(forColumn: "cover"))!
				
				playlists.append(playlist)
				
			}
			
			s?.close()
			
			self.delegate?.tabBarCount(count: 4)
			
			tableView.reloadData()
			
		}
		
		s?.close()
		
	}
	
	func addPullToRefresh() {
		// Initialize tableView
		let loadingView = DGElasticPullToRefreshLoadingViewCircle()
		
		loadingView.tintColor = UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0)
		
		tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
			self?.loadNewPlaylist()
			}, loadingView: loadingView)
		
		tableView.dg_setPullToRefreshFillColor(UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0))
		
		tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
	}
	
	func loadNewPlaylist() {
		// FIXME: 版本号
		
		// 请求接口
		Alamofire.request(P_URL).response(completionHandler: { (response) in
			
			if response.error != nil {
				
				HUD.flash(.labeledError(title: "请检查网络", subtitle: nil), delay: 0.4)
				
				self.tableView.dg_stopLoading()
				
				self.delegate?.tabBarCount(count: 3)
				
				return
				
			}
			
			self.tableView.dg_stopLoading()

			let playlists: Array = Reflect<Playlist>.mapObjects(data: response.data)
			
			let query = "select * from t_playlists where p_id=(select max(p_id)from t_playlists);"
			
			let s = self.playlistsDB.executeQuery(query, withArgumentsIn: nil)
			
			if s?.next() == true {
				
				let maxID = (Int)((s?.int(forColumn: "p_id"))!)
				
				var temp: Array<Playlist> = []
				
				for playlist in playlists {
					
					if playlist.ID > maxID {
						
						temp.append(playlist)
						
					}
					
				}
				
				self.playlists = temp + self.playlists
				
				self.dumpPlaylist(playlists: temp)
				
			} else {
				
				self.playlists = playlists
				
				self.dumpPlaylist(playlists: playlists)
				
			}
			
			self.tableView.reloadData()
			
			if playlists.count > 3 {
			
				self.delegate?.tabBarCount(count: 4)
			
			} else {
			
				self.delegate?.tabBarCount(count: 3)
			
			}
			
			
			let user = UserDefaults.standard
			
			user.set("online", forKey: "online")
			
			user.synchronize()
			
		})
	}
	
	// store playlists
	func dumpPlaylist(playlists: Array<Playlist>) {
		
		let sql = "INSERT INTO t_playlists(p_id, title, cover) VALUES(?, ?, ?);"

		
		for playlist in playlists {
			
			DispatchQueue.global(qos: .background).async {
				
				let title = self.doubleQuotation(single: playlist.title)
				
				self.queue.inDeferredTransaction({ (database, roolback) in
					
					database?.executeUpdate(sql, withArgumentsIn: [playlist.ID, title, playlist.cover])
					
				})
			}
			
		}
		
	}
	
	// MARK: - Table view data source
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return self.playlists.count
	
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "playlist", for: indexPath) as! PlaylistCell
		
		let playlist: Playlist = self.playlists[indexPath.row]
		
		cell.textLabel?.text = "『" + playlist.title + "』"
		
		// MARK: - 设置count==3和4时分别显示的封面
		if self.playlists.count == 3 {
			
			cell.imageView?.image = UIImage(named:"defaultArtCover")
	
		} else {
		
			let url: URL = URL(string: playlist.cover)!
			
			cell.imageView?.sd_setImage(with: url, placeholderImage: UIImage(named:"defaultArtCover"))
			
			// MARK: - 添加下载手势 - TODO
			let downloadSwipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(download(recognizer:)))
			
			downloadSwipe.direction = .right
			
			downloadSwipe.numberOfTouchesRequired = 1
			
			cell.addGestureRecognizer(downloadSwipe)
		
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// 取消点击效果
		tableView.deselectRow(at: indexPath, animated: false)
		
		HUD.show(.label("加载歌曲"))
		
		let playlist: Playlist = self.playlists[indexPath.row]

		let url = URL(string: P_URL + "\(playlist.ID)")

		Alamofire.request(url!).response(completionHandler: { (response) in
			
			let tracks: Array = Reflect<Track>.mapObjects(data: response.data)
			
			if tracks.count == 0 {
			
				HUD.flash(.label("加载失败，请检查网络"), delay: 0.5)
				
				return
			}
			
			HUD.hide()
			
			// MARK: - Push Controller - TODO
			let trackList: TrackListController = TrackListController()
			
			trackList.tracks = tracks
			
			trackList.title = playlist.title
			
			self.navigationController?.pushViewController(trackList, animated: true)
			
		})
	}
	// MARK: - 下载每月歌曲 - TODO
	func download(recognizer: UIGestureRecognizer) {
				
		let position = recognizer.location(in: self.tableView)
		
		let indexPath: IndexPath = self.tableView.indexPathForRow(at: position)!
		
		let playlist = playlists[indexPath.row]
		
		let album = playlist.title
		
		let url = URL(string: P_URL + "\(playlist.ID)")
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			
			Alamofire.request(url!).response(completionHandler: { (response) in
				
				let tracks: Array = Reflect<Track>.mapObjects(data: response.data)

				var downloadArray: Array<Track> = []
				
				for track in tracks {
					
					let artist = self.doubleQuotation(single: track.artist)
					
					let title = self.doubleQuotation(single: track.name)
					
					let album = playlist.title
					
					let query = "SELECT * FROM t_downloading WHERE author = ? and title = ? and album = ?;"
					
					self.queue.inDatabase({ (database) in
						
						let s = database?.executeQuery(query, withArgumentsIn: [artist, title, album])
                        
						
						if s?.next() == false {
							
							downloadArray.append(track)
							
						}
						
						s?.close()
						
					})
					
				}
				
				if downloadArray.count == 0 {
					
					HUD.flash(.label("专辑已下载"), delay: 0.4)
				
				} else {
					
					HUD.flash(.label("开始下载"), delay: 0.3)
					
					let name = Notification.Name("fullAlbum")
					
					let userInfo = ["album": album, "tracks": downloadArray] as [String : Any]
					
					let notify = Notification.init(name: name, object: nil, userInfo: userInfo)
					
					NotificationCenter.default.post(notify)
					
				}
				
			})
		}
	}
}



