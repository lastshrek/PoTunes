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
	
	var index: Int?

	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		tableView.register(DownloadingCell.self, forCellReuseIdentifier: "Track")
		
		tableView.separatorStyle = .none
		
		tableView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0)
		
		tableView.contentOffset = CGPoint(x: 0, y: 0)

		
		getNotification()
		
	}
	
	deinit {
		
		NotificationCenter.default.removeObserver(self, name: Notification.Name("percent"), object: nil)
		
		NotificationCenter.default.removeObserver(self, name: Notification.Name("downloadComplete"), object: nil)

		
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
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "Track") as! DownloadingCell
		
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
			
			setPause(button: start)
			
		} else {
			
			setStart(button: start)
			
		}
		
		start.addTarget(self, action: #selector(pause(button:)), for: .touchUpInside)
		
		self.start = start
		
		view.addSubview(start)
		
		// MARK: - delete button
		let delete = OperationButton()
		
		delete.frame = CGRect(x: width / 2, y: 0, width: width / 2, height: 40)
		
		delete.setImage(UIImage.fontAwesomeIcon(name: .spinner, textColor: UIColor.colorByRGB(red: 17, green: 133, blue: 117, alpha: 0.8), size: CGSize(width: 20, height: 20)), for: .normal)
		
		delete.setTitle("全部删除", for: .normal)
		
		delete.addTarget(self, action: #selector(delete(button:)), for: .touchUpInside)
		
		self.delete = delete
		
		view.addSubview(delete)
		
		return view
		
	}
	
	override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		
		return 40
		
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: false)
		
	}
	
}

// MARK: - Button Operations
extension DownloadingController {
	
	func pause(button: OperationButton) {
		
		if downloadingArray?.count == 0 {
			
			HUD.flash(.labeledError(title: "当前并无正在缓存歌曲", subtitle: nil), delay: 0.6)
			
			return
			
		}
		
		self.delegate?.didClickThePauseButton(button: button)
		
		if button.titleLabel?.text == "全部开始" {
			
			setPause(button: button)
			
		} else {
			
			
			setStart(button: button)
			
		}
		
	}
	
	func delete(button: OperationButton) {
		
		if downloadingArray?.count == 0 {
			
			HUD.flash(.labeledError(title: "当前并无正在缓存歌曲", subtitle: nil), delay: 0.6)
			
			return
			
		}
		
		self.delegate?.didClickTheDeleteButton(button: button)
		
		downloadingArray?.removeAll()
		
		tableView.reloadData()
		
		if downloadingArray?.count == 0 {
			
			
			
		}
	}
	
	func setStart(button: OperationButton) {
		
		button.setImage(UIImage.fontAwesomeIcon(name: .download, textColor: UIColor.colorByRGB(red: 17, green: 133, blue: 117, alpha: 0.8), size: CGSize(width: 20, height: 20)), for: .normal)
		
		button.setTitle("全部开始", for: .normal)
		
	}
	
	func setPause(button: OperationButton) {
		
		button.setImage(UIImage.fontAwesomeIcon(name: .pauseCircleO, textColor: UIColor.colorByRGB(red: 17, green: 133, blue: 117, alpha: 0.8), size: CGSize(width: 20, height: 20)), for: .normal)
		
		button.setTitle("全部暂停", for: .normal)
		
	}
	
}

extension DownloadingController {
	
	func getNotification() {
		
		let center = NotificationCenter.default
		
		center.addObserver(self, selector: #selector(percentChange(sender:)), name: Notification.Name("percent"), object: nil)
		
		center.addObserver(self, selector: #selector(downloadComplete), name: Notification.Name("downloadComplete"), object: nil)

		
	}
	
	func percentChange(sender: Notification) {
		
		let userInfo = sender.userInfo!
		
		let index = userInfo["index"] as! Int
		
		self.index = index
		
		let indexPath = IndexPath(row: index, section: 0)
		
		let cell = tableView.cellForRow(at: indexPath) as! DownloadingCell
		
		let progress = userInfo["percent"] as! Double
		
		cell.progressView.isHidden = false
		
		cell.progressView.setProgress(CGFloat(progress), animated: true)
		
	}
	
	
	func downloadComplete() {
		
		downloadingArray?.remove(at: index!)
		
		DispatchQueue.main.async {
			
			self.tableView.reloadData()
			
			if self.downloadingArray?.count == 0 {
				
				self.setStart(button: self.start!)
				
				self.navigationController!.popToRootViewController(animated: true)
				
			}
			
		}
		
	}
	
	
}
