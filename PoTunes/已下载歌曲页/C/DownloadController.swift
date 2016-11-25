//
//  DownloadController.swift
//  破音万里
//
//  Created by Purchas on 2016/11/22.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit


class DownloadController: TrackListController {
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
	}
	
	

}

extension DownloadController {
	
	// Override to support conditional editing of the table view.
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
		
	}
	
	// Override to support editing the table view.
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		
		if editingStyle == .delete {
			// Delete the row from the data source
			let track = tracks[indexPath.row]
			
			// Send Message to Delegate
			self.delegate?.didDeletedTrack!(track: track, title: self.title!)
			
			// delete TableView Data
			tracks.remove(at: indexPath.row)
			
			tableView.deleteRows(at: [indexPath], with: .top)
			
			if tracks.count == 0 {
				
				self.navigationController!.popToRootViewController(animated: true)
				
			}
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
		return "你真要删呐？"
	}
	
	
}
