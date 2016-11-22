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

protocol AlbumDownloadedDelegate: class {
	
	func isDownloadingMusic(progress: Int)

}

class AlbumDownloadController: UITableViewController {
	
	weak var delegate: AlbumDownloadedDelegate?
	
	lazy var db: FMDatabaseQueue = DBHelper.sharedInstance.queue!

	lazy var downloadAlbums: Array<String> = {
		
		var temp: Array = [] as Array<String>
		
		let distinct = "SELECT distinct album FROM t_downloading;"
		
		self.db.inDatabase { (database) in
			
			let s = database?.executeQuery(distinct, withArgumentsIn: nil)
			
			while (s?.next())! {
				
				let album = s?.string(forColumn: "album")!
				
				temp.append(album!)
				
			}
			
			s?.close()
			
		}
		
		return temp
		
	}()
	
	lazy var downloadingArray: Array<String> = {
		
		var temp: Array = [] as Array<String>
		
		let query = "SELECT * FROM t_downloading WHERE downloaded = 0;"
		
		self.db.inDatabase { (database) in
			
			let s = database?.executeQuery(query, withArgumentsIn: nil)
			
			while (s?.next())! {
				
				let identifier = (s?.string(forColumn: "author")!)! + " - " + (s?.string(forColumn: "title")!)!
				
				temp.append(identifier)
				
			}
			
			s?.close()
			
		}
		
		return temp
		
	}()
	
	var op: AFHTTPRequestOperation?
	

	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		tableView.separatorStyle = .none
		
		tableView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0)
		
		tableView.register(DownloadedCell.self, forCellReuseIdentifier: "downloaded")
		
		getNotification()
		
	}
	
	
	
	func getNotification() {
		
		let center = NotificationCenter.default
		
		center.addObserver(self, selector: #selector(fullAlbum(sender:)), name: Notification.Name("fullAlbum"), object: nil)
		
	}
	
	deinit {
		
		NotificationCenter.default.removeObserver(self, name: Notification.Name("fullAlbum"), object: nil)
		
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
			
			let urlComponent = track.url.components(separatedBy: "/")
			
			let count = urlComponent.count
			
			//eg. 20160601.mp3
			let identifier: String = urlComponent[count - 3] + urlComponent[count - 2] + urlComponent[count - 1]
			
			let newIdentifier = track.artist + " - " + track.name
			
			downloadingArray.append(newIdentifier)
			
			let artist = self.doubleQuotation(single: track.artist)
			
			let name = self.doubleQuotation(single: track.name)
			
			let album = self.doubleQuotation(single: title)
			
			let sql = "INSERT INTO t_downloading(author,title,sourceURL,indexPath,thumb,album,downloaded,identifier) VALUES('\(artist)','\(name)','\(track.url)','\(track.ID)','\(track.cover)','\(album)','0', '\(identifier)');"
			
			
			DispatchQueue.global(qos: .background).async {
				
				self.db.inDeferredTransaction({ (database, roolback) in
					
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
				self.db.inTransaction({ (database, rollback) in
					
					database?.executeUpdate("UPDATE t_downloading SET downloaded = 1 WHERE identifier = '\(identifier)';", withArgumentsIn: nil)
					
				})
				
				// delete identifier and other infos
				
				let query = "SELECT * FROM t_downloading WHERE downloaded = 0;"
				
				var tempArray: Array<String> = []
				
				self.db.inDatabase({ (database) in
					
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
								
								self.beginDownloadMusic(urlStr: urlStr!, identifier: identifier!, newIdentifier: newIdentifier!)
								
							}
							
							s?.close()
						}
				
				})
				
			}, failure: { (operation, error) in
				
				debugPrint(error)
				
			})
			
			queue.addOperation(self.op!)
			
		}
			
	}
	
	
	
	

	

	

	

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
			
			db.inDatabase({ (database) in
				
				let s = database?.executeQuery(query, withArgumentsIn: nil)
				
				if (s?.next())! {
					
					let url = URL(string: (s?.string(forColumn: "thumb"))!)
					
					cell.imageView?.sd_setImage(with: url, placeholderImage: UIImage(named: "defaultCover"))
					
				}
				
				s?.close()
				
			})
			
		}
	
		return cell
	}
	
}
