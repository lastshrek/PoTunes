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

protocol PlaylistDelegate: class {
	func tabBarCount(count: Int)
}

let P_URL = "http://127.0.0.1:3000/api/app/playlists"
let T_URL = "http://127.0.0.1:3000/api/app/playlists/"

class PlaylistController: UITableViewController {
	
	var playlists: Array<Any> = []
	
	weak var delegate: PlaylistDelegate?
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		let width = self.view.bounds.size.width
		// Initialize tableView
		tableView.rowHeight = width * 300 / 640
		
		tableView.separatorStyle = .none
		
		tableView.backgroundColor = UIColor.black
		
		tableView.register(PlaylistCell.self, forCellReuseIdentifier: "playlist")
		// Refresh
		addPullToRefresh()
		// MARK: -  检查本地缓存播放列表
		checkLocalPlaylists()
		// add delegate
	}
	
	func checkLocalPlaylists() {
		// MARK: - 获取数据 - 未测试
		if self.playlists.count == 0 {
			
			let rootPath: String = self.dirDoc() as String
			
			let filePath: String = rootPath + "/article.plist"
			
			if let dictArr: NSArray  = NSArray(contentsOfFile: filePath) {
				// MARK: - 本地存有article.plist时需测试
				var contentArray = Array<Any>()
			
				for dict in dictArr {
				
					contentArray.append(dict)
				
				}
				self.playlists = contentArray
				
			} else {
				
				loadNewPlaylist()
			
			}
		}
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
		// 请求接口
		Alamofire.request(P_URL).response(completionHandler: { (response) in
		
			let playlists: Array = Reflect<Playlist>.mapObjects(data: response.data)
			
			if playlists.count == 0 {
			
				HUD.flash(.error, delay: 1.0)
				
				self.tableView.dg_stopLoading()
				
				self.delegate?.tabBarCount(count: 3)
				
				return
			}
			
			HUD.flash(.label("加载成功"), delay: 1.0)
			
			self.playlists = playlists//重设tabBar个数
			
			self.tableView.dg_stopLoading()
			
			self.tableView.reloadData()
			
			if playlists.count > 3 {
			
				self.delegate?.tabBarCount(count: 4)
			
			} else {
			
				self.delegate?.tabBarCount(count: 3)
			
			}
		})
	}
	
	// MARK: - Table view data source
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return self.playlists.count
	
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "playlist", for: indexPath) as! PlaylistCell
		
		let playlist: Playlist = (self.playlists[indexPath.row] as AnyObject) as! Playlist
		
		cell.textLabel?.text = "『" + playlist.title + "』"
		
		// MARK: - 设置count==3和4时分别显示的封面
		if self.playlists.count == 3 {
			
			cell.imageView?.image = UIImage(named:"defaultArtCover")
	
		} else {
		
			let url: URL = URL(string: playlist.cover)!
			
			cell.imageView?.sd_setImage(with: url, placeholderImage: UIImage(named:"defaultArtCover"))
		
		}
		
		// MARK: - 添加下载手势 - TODO
		let downloadSwipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(PlaylistController.download))
		
		downloadSwipe.direction = .right
		
		downloadSwipe.numberOfTouchesRequired = 1
		
		cell.addGestureRecognizer(downloadSwipe)
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// 取消点击效果
		tableView.deselectRow(at: indexPath, animated: false)
		
		HUD.show(.label("加载歌曲"))
		
		let playlist: Playlist = self.playlists[indexPath.row] as! Playlist

		let url = URL(string: T_URL + "\(playlist.ID)")
		// MARK: - 上线屏蔽 - TODO
		Alamofire.request(url!).response(completionHandler: { (response) in
			
			let tracks: Array = Reflect<Track>.mapObjects(data: response.data)
			
			if tracks.count == 0 {
			
				HUD.flash(.label("加载失败，请检查网络"), delay: 1.0)
				
				return
			}
			
			HUD.hide()
			
			// MARK: - Push Controller - TODO
			let songList: SongListController = SongListController()
			
			songList.tracks = tracks
			
			songList.title = playlist.title
			
			self.navigationController?.pushViewController(songList, animated: true)
		})
	}
	// MARK: - 下载每月歌曲 - TODO
	func download() {
		debugPrint("123")
	}
	
}


