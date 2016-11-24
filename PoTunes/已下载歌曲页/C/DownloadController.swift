//
//  DownloadController.swift
//  破音万里
//
//  Created by Purchas on 2016/11/22.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

protocol DownloadControllerDelegate: TrackListDelegate {
	
	func didDeletedTrack(track: Track)
	
}

class DownloadController: TrackListController {
	
	

	override func viewDidLoad() {
		
		super.viewDidLoad()
		
//		tableView.separatorStyle = .none
//		
//		tableView.backgroundColor = UIColor.white
//		
//		tableView.register(TrackCell.self, forCellReuseIdentifier: "track")
		
	}
	
	// Override to support conditional editing of the table view.
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}
	
	// Override to support editing the table view.
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		
		if editingStyle == .delete {
			// Delete the row from the data source
			tableView.deleteRows(at: [indexPath], with: .fade)
			
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
		return "你真要删呐？"
	}


//	// MARK: - Table view data source
//
//	override func numberOfSections(in tableView: UITableView) -> Int {
//			// #warning Incomplete implementation, return the number of sections
//			return 1
//	}
//
//	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//			// #warning Incomplete implementation, return the number of rows
//		if tableView.tag == 2 {
//			
//			return 2
//			
//		} else {
//			
//			return tracks.count
//			
//		}
//	}
//	
//	
//	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//		
//		return 66
//		
//	}
//	
//	
//	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//		
//		let cell: TrackCell = tableView.dequeueReusableCell(withIdentifier: "track", for: indexPath) as! TrackCell
//		
//		// Configure the cell...
//		let track: Track = self.tracks[indexPath.row]
//		
//		cell.textLabel?.text = track.name
//		
//		cell.detailTextLabel?.text = track.artist
//		
//		let url: URL = URL(string: track.cover + "!/fw/100")!
//		
//		cell.imageView?.sd_setImage(with: url, placeholderImage: UIImage(named:"noArtwork"))
//		
//		return cell
//	}
	

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
