//
//  DownloadingController.swift
//  破音万里
//
//  Created by Purchas on 2016/11/23.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit
import PKHUD

protocol DownloadingControllerDelegate: class {
	
	func didClickThePauseButton(button: UIButton)
	
	func didClickTheDeleteButton(button: UIButton)
	
}

let width = UIScreen.main.bounds.size.width

class DownloadingController: UITableViewController {
	
	var isPaused: Bool?
	
	
	var downloadingArray: Array<String>?
	
	weak var delegate: DownloadingControllerDelegate?

	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "identifier")
		
	}
}

// MARK: - Table view data source
extension DownloadingController {
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return downloadingArray!.count
	
	}
	
}

// MARK: - Table view delegate
extension DownloadingController {
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "identifier", for: indexPath)
		
		// Configure the cell...
		cell.textLabel?.text = downloadingArray?[indexPath.row]
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 40))
		
		view.backgroundColor  = UIColor.lightGray
		
		return view
		
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		
		return 40
		
	}
	
}
