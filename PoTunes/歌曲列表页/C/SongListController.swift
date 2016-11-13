//
//  SongListController.swift
//  破音万里
//
//  Created by Purchas on 2016/11/12.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class SongListController: UITableViewController {
	
	var tracks: Array<Any> = []
	var shareToWechat: UITableView?
	var hover: UIView?
	var sharedTrack: Track?
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		tableView.register(TrackCell.self, forCellReuseIdentifier: "track")
		
		tableView.separatorStyle = .none
	}
	
	func didClickPlayBtn(btn: UIButton) {
		
	}
}
// MARK: - UITableViewDataSource
extension SongListController {
	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		if tableView.tag == 2 { return 2 }
		
		return self.tracks.count
	}
}

// MARK: - UITableViewDelegate
extension SongListController {
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell: TrackCell = tableView.dequeueReusableCell(withIdentifier: "track", for: indexPath) as! TrackCell
		
		// Configure the cell...
		let track: Track = self.tracks[indexPath.row] as! Track
		
		cell.textLabel?.text = track.name
		
		cell.detailTextLabel?.text = track.artist
		
		let url: URL = URL(string: track.cover + "!/fw/100")!
		
		cell.imageView?.sd_setImage(with: url, placeholderImage: UIImage(named:"noArtwork"))
		
		cell.playBtn.addTarget(self, action: #selector(SongListController.didClickPlayBtn(btn:)), for: .touchUpInside)
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		
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
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		
		if tableView.tag != 2 {
		
			return 66
		
		}
		
		return 44
	}
	// MARK: SET Display style
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		
		if tableView.tag != 2 {
			
			let rotationAngleDegrees: CGFloat = 0
			
			let rotationAngleRadians: CGFloat = rotationAngleDegrees * (CGFloat)(M_PI/180)
			
			let offsetPositioning: CGPoint = CGPoint(x: -200,y: -20)
			
			var transform: CATransform3D = CATransform3DIdentity
			
			transform = CATransform3DRotate(transform, rotationAngleRadians, 0.0, 0.0, 1.0);
			
			transform = CATransform3DTranslate(transform, offsetPositioning.x, offsetPositioning.y, 0.0)
			
			let card: UIView = cell.contentView
			
			card.layer.transform = transform
			
			card.layer.opacity = 0.8
			
			UIView.animate(withDuration: 0.2, animations: {
				
				card.layer.transform = CATransform3DIdentity
				
				card.layer.opacity = 1
			
			})

		}
	}
	
}
