//
//  AlbumDownloadViewController.swift
//  破音万里
//
//  Created by Purchas on 2016/11/10.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit
import Alamofire
import FMDB
import AFNetworking
import PKHUD
import SCLAlertView

class AlbumDownloadController: UITableViewController {
	var downloadAlbums: Array<String>?
	var nowPlayingTitle: String?
	var nowPlayingCell: DownloadedCell?
	var downloadingCell: DownloadedCell?
	var allTracksCell: DownloadedCell?
	var op: AFHTTPRequestOperation?
	lazy var queue: FMDatabaseQueue = DBHelper.sharedInstance.queue!
    lazy var tracksDB: FMDatabase = {
        let path = self.dirDoc() + "/downloadingSong.db"
        let db: FMDatabase = FMDatabase(path: path)
        db.open()
        return db
    }()
	lazy var downloadingArray: Array<String> = {
		var temp: Array = [] as Array<String>
		let query = "SELECT * FROM t_downloading WHERE downloaded = 0;"
		let s = self.tracksDB.executeQuery(query, withArgumentsIn: [])
		while (s?.next())! {
			let identifier = (s?.string(forColumn: "author")!)! + " - " + (s?.string(forColumn: "title")!)!
			temp.append(identifier)
		}
		s?.close()
		return temp
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		tableView.separatorStyle = .none
        //TODO: 宏
		if UIScreen.main.bounds.size.height == 812 {
			tableView.contentInset = UIEdgeInsetsMake(44, 0, 34, 0)
		} else {
            tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0)
		}
		tableView.register(DownloadedCell.self, forCellReuseIdentifier: "downloaded")
		downloadAlbums = reloadDownloadAlbums()
		getNotification()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		let user = UserDefaults.standard
		let title = user.string(forKey: "title")
		nowPlayingTitle = title
		debugPrint(nowPlayingTitle)
		tableView.reloadData()
	}
	
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.downloadAlbums = reloadDownloadAlbums()
		self.tableView.reloadData()
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: Notification.Name("fullAlbum"), object: nil)
		NotificationCenter.default.removeObserver(self, name: Notification.Name("download"), object: nil)
	}
}

extension AlbumDownloadController {
	// MARK: - Table view data source
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return 2
		}
		return downloadAlbums!.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "downloaded", for: indexPath) as! DownloadedCell
		if indexPath.section == 0 {
			if (indexPath.row == 0) {
				cell.imageView?.image = UIImage.fontAwesomeIcon(name: .download, textColor: UIColor.colorByRGB(red: 17, green: 133, blue: 117, alpha: 0.8), size: CGSize(width: 30, height: 30))
				cell.textLabel?.text = String(self.downloadingArray.count) + "首正在缓存"
				downloadingCell = cell
			}
			if (indexPath.row == 1) {
				cell.imageView?.image = UIImage.fontAwesomeIcon(name: .list, textColor: UIColor.colorByRGB(red: 17, green: 133, blue: 117, alpha: 0.8), size: CGSize(width: 30, height: 30))
				cell.textLabel?.text = "所有歌曲"
				allTracksCell = cell
			}
		} else {
			let album = downloadAlbums?[indexPath.row]
			let query = "SELECT * FROM t_downloading WHERE album = '\(album!)';"
			let s = tracksDB.executeQuery(query, withArgumentsIn: [])

			cell.textLabel?.text = album!
            if (s?.next())! {
                let url = URL(string: (s?.string(forColumn: "thumb"))! + "!/fw/100" )
                cell.imageView?.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultCover"))
            }
			if album?.components(separatedBy: " - ").last == nowPlayingTitle {
				nowPlayingCell?.playing.isHidden = true
				cell.playing.isHidden = false
				nowPlayingCell = cell
			}
            s?.close()
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 55
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		if indexPath.section == 1 {
			let download = DownloadController()
			var tracks: Array<TrackEncoding> = []
			let title = downloadAlbums?[indexPath.row]
			let query = "SELECT * FROM t_downloading WHERE album = '\(title!)' and downloaded = 1 order by indexPath;"
            let s = tracksDB.executeQuery(query, withArgumentsIn: [])
            
            while (s?.next())! {
				let artist = (s?.string(forColumn: "author"))!
                let name = (s?.string(forColumn: "title"))!
                let url = (s?.string(forColumn: "sourceURL"))!
                let ID = (Int)((s?.int(forColumn: "indexPath"))!)
                let cover = (s?.string(forColumn: "thumb"))!
				let track = TrackEncoding(ID: ID, name: name, artist: artist, cover: cover, url: url)
                tracks.append(track)
            }
            s?.close()

			download.title = title?.components(separatedBy: " - ").last
            download.tracks = tracks
            download.delegate = self
            self.navigationController?.pushViewController(download, animated: true)
		} else {
			if (indexPath.row == 0) {
				if downloadingArray.count == 0 {
					HUD.flash(.labeledError(title: "当前并无正在缓存歌曲", subtitle: nil), delay: 0.6)
					return
				}
				
				let downloading = DownloadingController().then({
					$0.delegate = self
					$0.downloadingArray = downloadingArray
					if op == nil || op?.isPaused() == true {
						$0.isPaused = true
					} else {
						$0.isPaused = false
					}
				})
				self.navigationController?.pushViewController(downloading, animated: true)
				return
			}
			if (indexPath.row == 1) {
				let download = DownloadController()
				var tracks: Array<TrackEncoding> = []
				let query = "SELECT * FROM t_downloading WHERE downloaded = 1;"
				let s = tracksDB.executeQuery(query, withArgumentsIn: [])
				
				while (s?.next())! {
					let artist = (s?.string(forColumn: "author"))!
					let name = (s?.string(forColumn: "title"))!
					let url = (s?.string(forColumn: "sourceURL"))!
					let ID = (Int)((s?.int(forColumn: "indexPath"))!)
					let cover = (s?.string(forColumn: "thumb"))!
					let track = TrackEncoding(ID: ID, name: name, artist: artist, cover: cover, url: url)
					tracks.append(track)
				}
				s?.close()
				
				download.title = "本地歌曲"
				download.tracks = tracks
				download.delegate = self
				
				self.navigationController?.pushViewController(download, animated: true)
			}
		}
	}
	
	// Override to support conditional editing of the table view.
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		if indexPath.section == 0 {
			return false
		}
		return true
	}
	// Override delete confirmation title
	override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
		return "你真要删呐？"
	}
	
	// Override to support editing the table view.
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			let album = self.downloadAlbums?[indexPath.row]
			let query = "SELECT * FROM t_downloading WHERE album = '\(album!)' and downloaded = 1;"
			let s = tracksDB.executeQuery(query, withArgumentsIn: [])
			let path = self.dirDoc()
			let manager = FileManager.default

			while (s?.next())! {
				let identifier = (s?.string(forColumn: "identifier"))!
				let filepath = path + "/\(identifier)"
				do {
					if manager.fileExists(atPath: filepath) {
						try manager.removeItem(atPath: filepath)
					}
				} catch {
					print("Could not clear temp folder: \(error)")
				}
			}
			let delete = "DELETE FROM t_downloading WHERE album = '\(album!)' and downloaded = 1;"
			tracksDB.executeUpdate(delete, withArgumentsIn: [])
			s?.close()
			downloadAlbums?.remove(at: indexPath.row)
			// Delete the row from the data source
			tableView.deleteRows(at: [indexPath], with: .top)
			tableView.reloadData()
		}
	}
}

// MARK: Notifications
extension AlbumDownloadController {
	
	func getNotification() {
		let center = NotificationCenter.default
		center.addObserver(self, selector: #selector(fullAlbum(sender:)), name: Notification.Name("fullAlbum"), object: nil)
		center.addObserver(self, selector: #selector(download(sender:)), name: Notification.Name("download"), object: nil)
		center.addObserver(self, selector: #selector(playingOnline(sender:)), name: Notification.Name("nowPlayingTrack"), object: nil)
	}
	
    @objc func fullAlbum(sender: Notification) {
		let userInfo: Dictionary = sender.userInfo!
		let tracks = (userInfo["tracks"] as! Array<Track>?)!
		let title = userInfo["album"] as! String
		let a = downloadAlbums?.index(of: title)
		
		if a == nil {
			downloadAlbums?.append(title)
			self.tableView.reloadData()
		}
		
		for track in tracks {
			//eg. 20160601.mp3
			let identifier: String = self.getIdentifier(urlStr: track.url)
			let newIdentifier = track.artist + " - " + track.name
			downloadingArray.append(newIdentifier)
			let artist = self.doubleQuotation(single: track.artist)
			let name = self.doubleQuotation(single: track.name)
			let album = self.doubleQuotation(single: title)
			let sql = "INSERT INTO t_downloading(author,title,sourceURL,indexPath,thumb,album,downloaded,identifier) VALUES('\(artist)','\(name)','\(track.url)','\(track.ID)','\(track.cover)','\(album)','0', '\(identifier)');"
			
			queue.inDeferredTransaction({ (database, roolback) in
				database.executeUpdate(sql, withArgumentsIn: [])
			})
			
			if self.op == nil || (self.op?.isCancelled)! || (self.op?.isFinished)! || (self.op?.isPaused())! {
				if track == tracks.first {
					self.beginDownloadMusic(urlStr: track.url, identifier: identifier, newIdentifier: newIdentifier)
				}
			}
		}
	}
	
    @objc func download(sender: Notification) {
		let userInfo: Dictionary = sender.userInfo!
		let track = userInfo["track"] as! TrackEncoding
		let title = userInfo["title"] as! String
		let newIdentifier = track.artist + " - " + track.name
		let identifier = userInfo["identifier"] as! String
		downloadingArray.append(newIdentifier)
		
		if self.op == nil || (self.op?.isCancelled)! || (self.op?.isFinished)! || (self.op?.isPaused())! {
			self.beginDownloadMusic(urlStr: track.url, identifier: identifier, newIdentifier: newIdentifier)
		}
		
		let index = downloadAlbums?.index(of: title)
		if index != nil { return }
		downloadAlbums?.append(title)
		tableView.reloadData()
	}
	
	func beginDownloadMusic(urlStr: String, identifier: String, newIdentifier: String)  {
		let user = UserDefaults.standard
		// MARK: 检查网络状况是否允许下载
		let yes = user.bool(forKey: "wwanDownload")
		let monitor = Reachability.forInternetConnection()
		let reachable = monitor?.currentReachabilityStatus().rawValue
		
		if !yes && reachable != 2 {
			let appearance = SCLAlertView.SCLAppearance(
				showCloseButton: false
			)
			let alertView = SCLAlertView(appearance: appearance)

			alertView.addButton("取消") {
				HUD.flash(.labeledError(title: "取消下载", subtitle: nil), delay: 1.0)
			}
			alertView.addButton("继续下载") {
				if reachable == 0 {
					HUD.flash(.labeledError(title: "请检查网络状况", subtitle: nil), delay: 1.0)
					return
				}
				
				alertView.showWarning("温馨提示", subTitle: "您当前处于运营商网络中，是否继续下载")
				user.set(1, forKey: "wwanDownload")
				
				NotificationCenter.default.post(name: Notification.Name("wwanDownload"), object: nil)
				
				self.download(urlStr: urlStr, identifier: identifier, newIdentifier: newIdentifier)
			}
			alertView.showWarning("温馨提示", subTitle: "您当前处于运营商网络中，是否继续下载")
			return
		}
		
		if reachable == 2 || yes {
			self.download(urlStr: urlStr, identifier: identifier, newIdentifier: newIdentifier)
		}
		
		if reachable == 0 {
			HUD.flash(.labeledError(title: "请检查网络状况", subtitle: nil), delay: 1.0)
		}
	}
	
	func download(urlStr: String, identifier: String, newIdentifier: String) {
		// download loacation
		let filePath = self.dirDoc() + "/\(identifier)"
		// initialize download queue
		let queue = OperationQueue()
		let request = URLRequest(url: URL(string: urlStr)!)
		let index = self.downloadingArray.index(of: newIdentifier)

		op = AFHTTPRequestOperation.init(request: request)
		op?.outputStream = OutputStream(toFileAtPath: filePath, append: false)

		if index != nil {
			op?.setDownloadProgressBlock({ (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
				let downloadProgress: Double = (Double)(totalBytesRead) / (Double)(totalBytesExpectedToRead)
				let progress: Int = (Int)(downloadProgress * 100)

				if (progress % 10 == 0 || (Int)(progress) == 1) && downloadProgress <= 1 && downloadProgress >= 0.01 {
					let userInfo = [
						"index": index!,
						"percent": downloadProgress
						] as [String : Any]
					NotificationCenter.default.post(name: Notification.Name("percent"), object: nil, userInfo: userInfo)
					self.downloadingCell?.textLabel?.text = String(self.downloadingArray.count) + "首正在缓存"
				}
				if progress == 100 && self.downloadingArray.count == 1 {
					self.downloadingCell?.textLabel?.text = "0首正在缓存"
				}
			})

			
			op?.setCompletionBlockWithSuccess({ (operation, responseObject) in
				// change download Status
				self.queue.inDatabase({ (database) in
					database.executeUpdate("UPDATE t_downloading SET downloaded = 1 WHERE identifier = '\(identifier)';", withArgumentsIn: [])
					// delete identifier and other infos
					let query = "SELECT * FROM t_downloading WHERE downloaded = 0;"
					var tempArray: Array<String> = []
					let s = database.executeQuery(query, withArgumentsIn: [])
					
					while (s?.next())! {
						let identifier = (s?.string(forColumn: "author"))! + " - " + (s?.string(forColumn: "title"))!
						tempArray.append(identifier)
					}
					self.downloadingArray = tempArray
					// post download complete notification
					NotificationCenter.default.post(name: Notification.Name("downloadComplete"), object: nil, userInfo: nil)

					if self.downloadingArray.count > 0 {
						let newIdentifier = self.downloadingArray.first
						let splitArr = newIdentifier?.components(separatedBy: " - ")
						let author = self.doubleQuotation(single: (splitArr?.first)!)
						var title = ""

						if splitArr?.count == 2 {
							title = self.doubleQuotation(single: (splitArr?.last)!)
						} else if (splitArr?.count)! > 2 {
							for (index, split) in splitArr!.enumerated() {
								if index > 0  && index != (splitArr?.count)! - 1{
									title = title + self.doubleQuotation(single: split) + " - "
								} else if index > 0 && index == (splitArr?.count)! - 1 {
									title = title + self.doubleQuotation(single: split)
								}
								
							}
							
						}
						let query = "SELECT * FROM t_downloading WHERE author = '\(author)' and title = '\(title)';"
						let s = database.executeQuery(query, withArgumentsIn: [])
						
						if (s?.next())! {
							let urlStr = s?.string(forColumn: "sourceURL")
							let identifier = s?.string(forColumn: "identifier")
							DispatchQueue.global(qos: .background).async {
								self.beginDownloadMusic(urlStr: urlStr!, identifier: identifier!, newIdentifier: newIdentifier!)
							}
							s?.close()
						}
					}
					s?.close()
				})
				
			}, failure: { (operation, error) in
				debugPrint(error)
			})
			queue.addOperation(self.op!)
		}
	}
	@objc func playingOnline(sender: Notification) {
		let title = sender.userInfo!["album"] as! String
		if title == "本地歌曲" {
			nowPlayingCell?.playing.isHidden = true
			allTracksCell?.playing.isHidden = false
			nowPlayingCell = allTracksCell
			return
		}
		if (nowPlayingCell?.playing.isHidden == false) {
			nowPlayingCell?.playing.isHidden = true
		}
	}
}

extension AlbumDownloadController: TrackListDelegate {
	
	func didDeletedTrack(track: TrackEncoding, title: String) {
		let identifier = self.getIdentifier(urlStr: track.url)
		let album = self.doubleQuotation(single: track.artist + " - " + title)
		let delete = "DELETE FROM t_downloading WHERE identifier = ?;"
		
		op?.cancel()
		queue.inDatabase { (database) in
			database.executeUpdate(delete, withArgumentsIn: [identifier])
			let index = self.downloadAlbums?.index(of: album)
			
			if index != nil {
				self.downloadAlbums?.remove(at: index!)
				DispatchQueue.main.async {
					self.tableView.reloadData()
				}
			}
		}
		// delete local files
		let filePath = self.dirDoc() + "/" + self.getIdentifier(urlStr: track.url)
		let manager = FileManager.default
		
		do {
			if manager.fileExists(atPath: filePath) {
				try manager.removeItem(atPath: filePath)
			}
		} catch {
			debugPrint("Could not clear temp folder: \(error)")
		}
	}
}

extension AlbumDownloadController: DownloadingControllerDelegate {
	
	func didClickThePauseButton(button: UIButton) {
		
		if self.op == nil || (self.op?.isPaused())! {
			let newIdentifier = self.downloadingArray.first
			let splitArr = newIdentifier?.components(separatedBy: " - ")
			let artist = self.doubleQuotation(single: (splitArr?.first)!)
			var title = ""

			if splitArr?.count == 2 {
				title = self.doubleQuotation(single: (splitArr?.last)!)
			} else if (splitArr?.count)! > 2 {
				for (index, split) in splitArr!.enumerated() {
					if index > 0  && index != (splitArr?.count)! - 1{
						title = title + self.doubleQuotation(single: split) + " - "
					} else if index > 0 && index == (splitArr?.count)! - 1 {
						title = title + self.doubleQuotation(single: split)
					}
				}
			}
			
			let query = "SELECT * FROM t_downloading WHERE author = ? and title = ?;"
			let s = tracksDB.executeQuery(query, withArgumentsIn: [artist, title])
			
			if s?.next() == true {
				let url = s?.string(forColumn: "sourceURL")
				let identifier = s?.string(forColumn: "identifier")
				self.beginDownloadMusic(urlStr: url!, identifier: identifier!, newIdentifier: newIdentifier!)
			} else {
				debugPrint("没有找到这首歌，请排查原因")
			}
			s?.close()
			return
		}
		
		if (self.op?.isPaused())! {
			self.op?.resume()
		} else {
			self.op?.pause()
		}
	}
	
	func didClickTheDeleteButton(button: UIButton) {
		
		op?.pause()
		
		// 删除本地文件
		let select = "SELECT * FROM t_downloading WHERE downloaded = 0;"
		let s = tracksDB.executeQuery(select, withArgumentsIn: [])
		let manager = FileManager.default

		while s?.next() == true {
			let identifier = s?.string(forColumn: "identifier")
			let filepath = self.dirDoc() + "/\(String(describing: identifier))"
			do {
				if manager.fileExists(atPath: filepath) {
					try manager.removeItem(atPath: filepath)
				}
			} catch {
				print("删除文件失败: \(error)")
			}
		}
		
		s?.close()
		//delete the not downloaded datas
		let delete = "DELETE FROM t_downloading WHERE downloaded = 0;"
		queue.inTransaction { (database, _) in
			database.executeUpdate(delete, withArgumentsIn: [])
			// query dinstint albums
			self.downloadingArray.removeAll()
			self.tableView.reloadData()
		}
	}
	
	func reloadDownloadAlbums() -> Array<String>{
		var temp: Array = [] as Array<String>
		let distinct = "SELECT distinct album FROM t_downloading;"
		let s = self.tracksDB.executeQuery(distinct, withArgumentsIn: [])
		
		while (s?.next())! {
			let album = s?.string(forColumn: "album")!
			temp.append(album!)
		}
		s?.close()
		return temp
	}
}
