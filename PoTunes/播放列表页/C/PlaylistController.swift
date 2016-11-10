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
import PullToMakeSoup


let P_URL = "http://127.0.0.1:3000/api/app/playlists"
let THEATERS_URL = "https://api.douban.com/v2/movie/in_theaters"



class PlaylistController: UITableViewController {
	
	var playlists: Array<Any> = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let width = self.view.bounds.size.width
		// Initialize tableView
		tableView.rowHeight = width * 300 / 640
		tableView.separatorStyle = .none
		tableView.backgroundColor = UIColor.black
		tableView.register(PlaylistCell.self, forCellReuseIdentifier: "playlist")
		// Refresh
		
			HUD.show(.label("shit"))
			Alamofire.request(P_URL).response(completionHandler: { (response) in
				let playlists: Array = Reflect<Playlist>.mapObjects(data: response.data)
				self.playlists = playlists
				self.tableView.reloadData()
				HUD.hide()
			})

		self.tableView.dg_setPullToRefreshFillColor(UIColor(red: 57/255.0, green: 67/255.0, blue: 89/255.0, alpha: 1.0))
		self.tableView.dg_setPullToRefreshBackgroundColor(UIColor(red: 78/255.0, green: 221/255.0, blue: 200/255.0, alpha: 1.0))
		// MARK: - 获取数据 - 未测试
		if self.playlists.count == 0 {
			let rootPath: String = self.dirDoc() as String
			let filePath: String = rootPath + "/article.plist"
			if let dictArr: NSArray  = NSArray(contentsOfFile: filePath) {
				if dictArr.count == 0 {
					// 下拉刷新
//					self.tableView.dg_startLoading()
				} else {
					var contentArray = Array<Any>()
					for dict in dictArr {
						contentArray.append(dict)
					}
					self.playlists = contentArray
				}
			}
//			let  = NSArray(contentOfFile:filePath)
		}
	}
	
	
	// MARK: - Table view data source
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.playlists.count
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "playlist", for: indexPath) as! PlaylistCell
		// MARK: - 设置标题 - TODO
		let playlist: Playlist = (self.playlists[indexPath.row] as AnyObject) as! Playlist

		cell.textLabel?.text = playlist.title
		let url: URL = URL(string: playlist.cover)!
		cell.imageView?.sd_setImage(with: url, placeholderImage: UIImage(named:"defaultArtCover"))
		// MARK: - 设置count==3和4时分别显示的封面 - TODO
		
		// MARK: - 添加下载手势 - TODO
		let downloadSwipe: UISwipeGestureRecognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(PlaylistController.download))
		downloadSwipe.direction = .right
		downloadSwipe.numberOfTouchesRequired = 1
		cell.addGestureRecognizer(downloadSwipe)
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
	
	}
	// MARK: - 下载整个播放列表 - TODO
	func download() {
		debugPrint("123")
	}
}

