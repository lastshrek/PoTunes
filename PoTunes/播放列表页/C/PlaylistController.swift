//
//  Article.swift
//  破音万里
//
//  Created by Purchas on 16/8/22.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit
import Alamofire
import PKHUD
import FMDB
import SCLAlertView
import PullToRefreshKit


protocol PlaylistDelegate: class {
	func tabBarCount(count: Int)
}

let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
//let P_URL = "http://localhost:3000/api/app/playlists?v=" + version
//let O_URL = "http://localhost:3000/api/app/playlists/"
let O_URL = "https://poche.fm/api/app/playlists/"
let P_URL = "https://poche.fm/api/app/playlists?v=" + version


class PlaylistController: UITableViewController {
	
	let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
	var playlists: Array<Playlist> = []
	var nowListening: Playlist?
	weak var delegate: PlaylistDelegate?
	lazy var queue: FMDatabaseQueue = DBHelper.sharedInstance.queue!
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
		tableView.backgroundColor = .white
		tableView.register(PlaylistCell.self, forCellReuseIdentifier: "playlist")
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
            if UIScreen.main.bounds.size.height == 812 {
                tableView.contentInset = UIEdgeInsetsMake(44, 0, 88, 0)//iPhoneX这里是88
            } else {
                tableView.contentInset = UIEdgeInsetsMake(64, 0, 88, 0)//iPhoneX这里是88
            }
            tableView.scrollIndicatorInsets = tableView.contentInset
            tableView.insetsContentViewsToSafeArea = false
        } else {
            // Fallback on earlier versions
            self.automaticallyAdjustsScrollViewInsets = false
        }
		// Refresh
		addPullToRefresh()
		// MARK: -  检查本地缓存播放列表
		checkLocalPlaylists()
	}
	
	
	func checkLocalPlaylists() {
		let query = "select * from t_playlists"
		let s = playlistsDB.executeQuery(query, withArgumentsIn: [])

		if s?.next() == false {
			loadNewPlaylist()
		} else {
			let sql = "select * from t_playlists order by p_id desc"
			let s = playlistsDB.executeQuery(sql, withArgumentsIn: [])

			while s?.next() == true {
				let playlist = Playlist()
				playlist.ID = (Int)((s?.int(forColumn: "p_id"))!)
				playlist.title = (s?.string(forColumn: "title"))!
				playlist.cover = (s?.string(forColumn: "cover"))!
				playlists.append(playlist)
			}
			s?.close()
			
			if playlists.count == 3 {
				self.delegate?.tabBarCount(count: 3)
			} else {
				self.delegate?.tabBarCount(count: 4)
			}
			tableView.reloadData()
		}
		
		s?.close()
		
	}
	
	func addPullToRefresh() {
		// Initialize tableView
        tableView.setUpHeaderRefresh {
            self.loadNewPlaylist()
        }.SetUp { (header) in
                header.setText("获取最新歌单", mode: .pullToRefresh)
                header.setText("松手刷新", mode: .releaseToRefresh)
                header.setText("刷新成功", mode: .refreshSuccess)
                header.setText("获取新歌单列表中", mode: .refreshing)
                header.setText("获取失败，请检查网络", mode: .refreshFailure)
                header.textLabel.textColor = .black
                header.imageView.image = nil
        }
	}
	
	func loadNewPlaylist() {
		// 请求接口
		Alamofire.request(P_URL).response(completionHandler: { (response) in
			if response.error != nil {
				HUD.flash(.labeledError(title: "请检查网络", subtitle: nil), delay: 0.4)
                self.tableView.endHeaderRefreshing(.failure, delay: 0.5)
				self.delegate?.tabBarCount(count: 3)
				return
			}
            self.tableView.endHeaderRefreshing(.success, delay:0.5)

			let playlists: Array = Reflect<Playlist>.mapObjects(data: response.data)
			let query = "select * from t_playlists where p_id=(select max(p_id)from t_playlists);"
			let s = self.playlistsDB.executeQuery(query, withArgumentsIn: [])

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
			
			if playlists.count > 3 {
				self.delegate?.tabBarCount(count: 4)
			} else {
				self.delegate?.tabBarCount(count: 3)
			}
			self.tableView.reloadData()

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
					database.executeUpdate(sql, withArgumentsIn: [playlist.ID, title, playlist.cover])
				})
			}
		}
	}
	
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		if playlists.count != 3 {
			return 2
		}
		return 1
	}
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if playlists.count != 3 {
			if (section == 0) {
				return 1
			} else {
				return self.playlists.count
			}
		}
		return self.playlists.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
	
		let cell = tableView.dequeueReusableCell(withIdentifier: "playlist", for: indexPath) as! PlaylistCell
		var playlist = Playlist()

		if playlists.count != 3 && indexPath.section == 0 {
			playlist.cover = "https://s.poche.fm/nowlistening/cover.png"
			playlist.ID = 0
			playlist.title = "破车最近在听的歌"
			nowListening = playlist
		} else {
			playlist = self.playlists[indexPath.row]
		}
		
		let url = URL(string: playlist.cover)
        cell.textLabel?.text = "『" + playlist.title + "』"
		
        cell.imageView?.sd_setImage(with: url, placeholderImage: UIImage(named:"defaultArtCover"), options: .refreshCached)

		
		// MARK: - 设置count==3和4时分别显示的封面
		if playlists.count != 3 {
			// MARK: - 添加下载手势 - TODO
			let downloadSwipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(download(recognizer:)))
			downloadSwipe.direction = .right
			downloadSwipe.numberOfTouchesRequired = 1
			cell.addGestureRecognizer(downloadSwipe)
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		HUD.show(.label("加载歌曲"))
		// 取消点击效果
		tableView.deselectRow(at: indexPath, animated: false)
		var playlist = Playlist()
		if playlists.count != 3 && indexPath.section == 0 {
			playlist = nowListening!
		} else {
			playlist = playlists[indexPath.row]
		}
		let url = URL(string: O_URL + "\(playlist.ID)")
	
		
		
		Alamofire.request(url!).response(completionHandler: { (response) in
			
			let tracks: Array = Reflect<Track>.mapObjects(data: response.data)
			
			if tracks.count == 0 {
				HUD.flash(.label("加载失败，请检查网络"), delay: 0.5)
				return
			}
			
			var temp: Array<TrackEncoding> = []
			
			for track in tracks {
				let trackEncoding = TrackEncoding(ID: track.ID, name: track.name, artist: track.artist, cover: track.cover, url: track.url)
				temp.append(trackEncoding)
			}
			
			HUD.hide()
			
			// MARK: - Push Controller - TODO
			let trackList: TrackListController = TrackListController().then({
				$0.tracks = temp
				$0.title = playlist.title
			})
			
			self.navigationController?.pushViewController(trackList, animated: true)
			
		})
	}
	// MARK: - 下载每月歌曲 - TODO
	@objc func download(recognizer: UIGestureRecognizer) {
		// check user network and whether allow to play
		let user = UserDefaults.standard
		let online = user.object(forKey: "online")
		if online == nil { return }

		let cell = recognizer.view as! PlaylistCell
		let indexPath = self.tableView.indexPath(for: cell)
		var playlist = Playlist()
		if indexPath?.section == 0 {
			playlist = nowListening!
		} else {
			playlist = playlists[(indexPath?.row)!]
		}
		let album = playlist.title
		let url = URL(string: O_URL + "\(playlist.ID)")

			
        Alamofire.request(url!).response(completionHandler: { (response) in
            let tracks: Array = Reflect<Track>.mapObjects(data: response.data)
            var downloadArray: Array<Track> = []

            for track in tracks {
				let album = playlist.title
                let query = "SELECT * FROM t_downloading WHERE author = ? and title = ? and album = ?;"
                self.queue.inDatabase({ (database) in
					let s = database.executeQuery(query, withArgumentsIn: [track.artist, track.name, album])
                    if s?.next() == false {
                        downloadArray.append(track)
                    }
                    s?.close()
                })
            }
            
            if downloadArray.count == 0 {
                HUD.flash(.label("专辑已下载"), delay: 0.4)
            } else {
                
                HUD.flash(.label("开始下载"), delay: 0.3, completion: { (_) in
                    
                    let name = Notification.Name("fullAlbum")
                    let userInfo = ["album": album, "tracks": downloadArray] as [String : Any]
                    let notify = Notification.init(name: name, object: nil, userInfo: userInfo)

                    NotificationCenter.default.post(notify)
                    
                })
            }
        })


		
	}
}



