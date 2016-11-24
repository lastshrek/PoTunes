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

class AlbumDownloadController: UITableViewController {
		
	lazy var queue: FMDatabaseQueue = DBHelper.sharedInstance.queue!
    
    lazy var tracksDB: FMDatabase = {
        
        let path = self.dirDoc() + "/downloadingSong.db"
        
        let db: FMDatabase = FMDatabase(path: path)
        
        db.open()
        
        return db
    }()

	lazy var downloadAlbums: Array<String> = {
		
		var temp: Array = [] as Array<String>
		
		let distinct = "SELECT distinct album FROM t_downloading;"
		
        let s = self.tracksDB.executeQuery(distinct, withArgumentsIn: nil)
        
        while (s?.next())! {
            
            let album = s?.string(forColumn: "album")!
            
            temp.append(album!)
            
        }
        
        s?.close()
			
		return temp
		
	}()
	
	lazy var downloadingArray: Array<String> = {
		
		var temp: Array = [] as Array<String>
		
		let query = "SELECT * FROM t_downloading WHERE downloaded = 0;"
		
        let s = self.tracksDB.executeQuery(query, withArgumentsIn: nil)
        
        while (s?.next())! {
            
            let identifier = (s?.string(forColumn: "author")!)! + " - " + (s?.string(forColumn: "title")!)!
            
            temp.append(identifier)
            
        }
        
        s?.close()
			
		return temp
		
	}()
	
	var op: AFHTTPRequestOperation?

	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		tableView.separatorStyle = .none
		
		tableView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0)
		
		tableView.register(DownloadedCell.self, forCellReuseIdentifier: "downloaded")
		
		getNotification()
		
		// 修复之前的下载文件名称
		repaireFormerTrackName()
        
		
	}
	
	deinit {
		
		NotificationCenter.default.removeObserver(self, name: Notification.Name("fullAlbum"), object: nil)
		
		NotificationCenter.default.removeObserver(self, name: Notification.Name("download"), object: nil)
		
	}
	
	
}

extension AlbumDownloadController {
	
	// MARK: - Table view data source
	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 2
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		if section == 0 {
			
			return 1
			
		} else {
			
			return downloadAlbums.count
		}
		
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "downloaded", for: indexPath) as! DownloadedCell
		
		if indexPath.section == 0 {
			
			cell.imageView?.image = UIImage(named: "noArtwork.jpg")
			
			cell.textLabel?.text = "正在缓存"
			
		} else {
			
			let album = downloadAlbums[indexPath.row]
			
			cell.textLabel?.text = album
			
			let query = "SELECT * FROM t_downloading WHERE album = '\(album)';"
			
				
            let s = tracksDB.executeQuery(query, withArgumentsIn: nil)
            
            if (s?.next())! {
                
                let url = URL(string: (s?.string(forColumn: "thumb"))! + "!/fw/100" )
                
                cell.imageView?.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultCover"))
                
            }
            
            s?.close()
			
		}
	
		return cell
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

		return 66
		
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		if indexPath.section == 1 {
			
			let download = DownloadController()
			
			var tracks: Array<Track> = []
			
			let title = downloadAlbums[indexPath.row]
			
			let query = "SELECT * FROM t_downloading WHERE album = '\(title)' and downloaded = 1 order by indexPath;"
			
				
            let s = tracksDB.executeQuery(query, withArgumentsIn: nil)
            
            while (s?.next())! {
                
                let track = Track()
                
                track.artist = (s?.string(forColumn: "author"))!
                
                track.name = (s?.string(forColumn: "title"))!
                
                track.url = (s?.string(forColumn: "sourceURL"))!
                
                track.ID = (Int)((s?.int(forColumn: "indexPath"))!)
                
                track.cover = (s?.string(forColumn: "thumb"))!
                
                tracks.append(track)
                
            }
            
            s?.close()
            
            download.title = title.components(separatedBy: " - ").last
            
            download.tracks = tracks
            
            download.delegate = self
            
            self.navigationController?.pushViewController(download, animated: true)

			
		} else {
			
			let downloading = DownloadingController()
			
			if op == nil || op?.isPaused() == true {
				
				downloading.isPaused = true
				
			} else {
				
				downloading.isPaused = false
				
			}
			
			downloading.delegate = self
			
			downloading.downloadingArray = downloadingArray
			
			self.navigationController?.pushViewController(downloading, animated: true)
			
		}
		
	}
	
	// Override to support conditional editing of the table view.
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		if indexPath.section == 0 {
			
			return false
			
		} else {
			
			return true
			
		}
	}
	// Override delete confirmation title
	override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
		return "你真要删呐？"
	}
	
	// Override to support editing the table view.
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		
		if editingStyle == .delete {
			
			let album = self.downloadAlbums[indexPath.row]
			
			let query = "SELECT * FROM t_downloading WHERE album = '\(album)';"
			
				
				let s = tracksDB.executeQuery(query, withArgumentsIn: nil)
				
				let path = self.dirDoc()
				
				let manager = FileManager.default
				
				while (s?.next())! {
					
					let identifier = (s?.string(forColumn: "identifier"))!
					
					let filepath = path + "/\(identifier)"
					
					print(filepath)
					
					do {
						
						if manager.fileExists(atPath: filepath) {
							
							try manager.removeItem(atPath: filepath)
							
						}
						
					} catch {
						
						print("Could not clear temp folder: \(error)")
					
					}
				}
				
				let delete = "DELETE FROM t_downloading WHERE album = '\(album)';"
				
				tracksDB.executeUpdate(delete, withArgumentsIn: nil)
				
				s?.close()

			
			downloadAlbums.remove(at: indexPath.row)
			
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
		
	}
	
	func fullAlbum(sender: Notification) {
		
		let userInfo: Dictionary = sender.userInfo!
		
		let tracks = (userInfo["tracks"] as! Array<Track>?)!
		
		let title = userInfo["album"] as! String
		
		let a = downloadAlbums.index(of: title)
		
		if a == nil {
			
			downloadAlbums.append(title)
			
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
			
			
			DispatchQueue.global(qos: .background).async {
				
				self.queue.inDeferredTransaction({ (database, roolback) in
					
					database?.executeUpdate(sql, withArgumentsIn: nil)
					
				})
				
				if self.op == nil || (self.op?.isCancelled)! || (self.op?.isFinished)! || (self.op?.isPaused())! {
					
					if track == tracks.first {
						
						self.beginDownloadMusic(urlStr: track.url, identifier: identifier, newIdentifier: newIdentifier)
						
					}
				}
			}
		}
	}
	
	func download(sender: Notification) {
		
		let userInfo: Dictionary = sender.userInfo!
		
		let track = userInfo["track"] as! Track
		
		let title = userInfo["title"] as! String
		
		let newIdentifier = track.artist + " - " + track.name
		
		let identifier = userInfo["identifier"] as! String
		
		downloadingArray.append(newIdentifier)
		
		if self.op == nil || (self.op?.isCancelled)! || (self.op?.isFinished)! || (self.op?.isPaused())! {
			
			self.beginDownloadMusic(urlStr: track.url, identifier: identifier, newIdentifier: newIdentifier)
			
		}
		
		let index = downloadAlbums.index(of: title)
		
		if index != nil { return }
		
		downloadAlbums.append(title)
		
		tableView.reloadData()
	}
	
	func beginDownloadMusic(urlStr: String, identifier: String, newIdentifier: String)  {
		
		// download loacation
		let filePath = self.dirDoc() + "/\(identifier)"
		
		// initialize download queue
		
		let queue = OperationQueue()
		
		let request = URLRequest(url: URL(string: urlStr)!)
		
		self.op = AFHTTPRequestOperation.init(request: request)
		
		self.op?.outputStream = OutputStream(toFileAtPath: filePath, append: false)
		
		let index = self.downloadingArray.index(of: newIdentifier)
		
		if index != nil {
			
			self.op?.setDownloadProgressBlock({ (bytesRead, totalBytesRead, totalBytesExpectedToRead) in
				
				let downloadProgress: Double = (Double)(totalBytesRead) / (Double)(totalBytesExpectedToRead)
				
				print(downloadProgress)
				
				let progress: Int = (Int)(downloadProgress * 100)
				
				if progress % 10 == 0 || (Int)(progress) == 1 {
					
					let userInfo = [
						"index": index!,
						"percent": downloadProgress
						] as [String : Any]
					
					NotificationCenter.default.post(name: Notification.Name("percent"), object: nil, userInfo: userInfo)
					
				}
			})
			
			self.op?.setCompletionBlockWithSuccess({ (operation, responseObject) in
				
				// change download Status
				self.queue.inDatabase({ (database) in
					
					database?.executeUpdate("UPDATE t_downloading SET downloaded = 1 WHERE identifier = '\(identifier)';", withArgumentsIn: nil)
					
					// delete identifier and other infos
					
					let query = "SELECT * FROM t_downloading WHERE downloaded = 0;"
					
					var tempArray: Array<String> = []
					
					let s = database?.executeQuery(query, withArgumentsIn: nil)
					
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
						
						let title = self.doubleQuotation(single: (splitArr?.last)!)
						
						let query = "SELECT * FROM t_downloading WHERE author = '\(author)' and title = '\(title)';"
						
						
						let s = database?.executeQuery(query, withArgumentsIn: nil)
						
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
	
	func repaireFormerTrackName() {
		
		let user = UserDefaults.standard
		
		let repaired = user.object(forKey: "repaired")
		
		if repaired == nil {
			
			let query = "SELECT * FROM t_downloading"
			
			queue.inDatabase({ (database) in
				
				HUD.show(.label("数据升级中请稍候"))
				
				let s = database?.executeQuery(query, withArgumentsIn: nil)
				
				let manager = FileManager.default
				
				let rootPath = self.dirDoc()
				
				while (s?.next())! {
					
					let identy = s?.string(forColumn: "identifier")
					
					if identy == nil {
						
						// 修改数据库
						
						let urlStr: String = (s?.string(forColumn: "sourceURL"))!
						
						let identifier = self.getIdentifier(urlStr: urlStr)
						
						let identifierUpdate = "UPDATE t_downloading SET identifier = '\(identifier)' WHERE sourceURL = '\(urlStr)'"
						
						DispatchQueue.global(qos: .background).async {
							
							database?.executeUpdate(identifierUpdate, withArgumentsIn: nil)
							
						}
						
						let artist = s?.string(forColumn: "author")
						
						let title = s?.string(forColumn: "title")
						
						let filePath = rootPath + "/\(artist!)" + " - " + "\(title!).mp3"
						
						let realPath = filePath.replacingOccurrences(of: " / ", with: " ")
						
						do {
							
							if manager.fileExists(atPath: realPath) {
								
								let dstPath = rootPath + "/\(identifier)"
								
								try manager.moveItem(at: URL(string:realPath)! , to: URL(string:dstPath)!)
								
							}
							
						} catch {
							
							print("Could not clear temp folder: \(error)")
							
						}
						
						
					}
					
				}
				
				s?.close()
				
				DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
					
					HUD.hide()
					
					HUD.flash(.success, delay: 0.3)
				}
				
				user.set("repaired", forKey: "repaired")
				
			})
		}
	}

}

extension AlbumDownloadController: TrackListDelegate {
	
	func didDeletedTrack(track: Track) {
		
		
		
	}
	
	func trackListControllerDidSelectRowAtIndexPath(indexPath: IndexPath) {
		
		
		
	}
	
}

extension AlbumDownloadController: DownloadingControllerDelegate {
	
	func didClickThePauseButton(button: UIButton) {
		
	}
	
	func didClickTheDeleteButton(button: UIButton) {
		
	}
	
}
