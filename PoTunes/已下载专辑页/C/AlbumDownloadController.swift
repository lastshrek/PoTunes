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
	
	lazy var downloadingArray: Array<Any> = {
		
		var temp: Array = [] as Array
		
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
			
			debugPrint("nil")
			
			downloadAlbums.append(title)
			
			self.tableView.reloadData()
			
		}
	
//		if () {
//			
//			
//			
//		}
		
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
			
			let query = "SELECT * FROM t_downloading WHERE album = '%@';" + album
			
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
