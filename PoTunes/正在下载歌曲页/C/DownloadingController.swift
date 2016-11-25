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
	
	var start: OperationButton?
	
	var delete: OperationButton?

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
		
		view.backgroundColor = UIColor.white
		
		// MARK: - start button
		let start = OperationButton()
		
		start.frame = CGRect(x: 0, y: 0, width: width / 2, height: 40)
		
		if isPaused == false {
			
			start.setImage(UIImage.fontAwesomeIcon(name: .pauseCircleO, textColor: UIColor.colorByRGB(red: 17, green: 133, blue: 117, alpha: 0.8), size: CGSize(width: 20, height: 20)), for: .normal)
			
			start.setTitle("全部暂停", for: .normal)
			
		} else {
			
			start.setImage(UIImage.fontAwesomeIcon(name: .download, textColor: UIColor.colorByRGB(red: 17, green: 133, blue: 117, alpha: 0.8), size: CGSize(width: 20, height: 20)), for: .normal)
			
			start.setTitle("全部开始", for: .normal)
			
		}
		
		start.addTarget(self, action: #selector(pause(button:)), for: .touchUpInside)
		
		self.start = start
		
		view.addSubview(start)
		
		// MARK: - delete button
		let delete = OperationButton()
		
		delete.frame = CGRect(x: width / 2, y: 0, width: width / 2, height: 40)
		
		delete.setImage(UIImage.fontAwesomeIcon(name: .trashO, textColor: UIColor.colorByRGB(red: 17, green: 133, blue: 117, alpha: 0.8), size: CGSize(width: 20, height: 20)), for: .normal)
		
		delete.setTitle("全部删除", for: .normal)
		
		delete.addTarget(self, action: #selector(delete(button:)), for: .touchUpInside)
		
		self.delete = delete
		
		view.addSubview(delete)
		
		return view
		
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		
		return 40
		
	}
	
}

extension DownloadingController {
	
	func pause(button: OperationButton) {
		
		
		
	}
	
	func delete(button: OperationButton) {
		
		
		
	}
	
}
