//
//  DownloadingController.swift
//  破音万里
//
//  Created by Purchas on 2016/11/23.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit
import PKHUD
import Then

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
		if #available(iOS 11.0, *) {
			tableView.contentInsetAdjustmentBehavior = .never
			if UIScreen.main.bounds.size.height == 812 {
				tableView.contentInset = UIEdgeInsetsMake(44, 0, 88, 0)
			} else {
				tableView.contentInset = UIEdgeInsetsMake(64, 0, 88, 0)
			}
			tableView.scrollIndicatorInsets = tableView.contentInset
			tableView.insetsContentViewsToSafeArea = false
		} else {
			// Fallback on earlier versions
			self.automaticallyAdjustsScrollViewInsets = false
		}
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
		return downloadingArray!.count
	}
}

// MARK: - Table view delegate
extension DownloadingController {
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = DownloadingCell(style: .default, reuseIdentifier: "Track")
		// Configure the cell...
		cell.textLabel?.text = downloadingArray?[indexPath.row]
		return cell
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		
		let view = UIView().then( {
			$0.backgroundColor = UIColor.white
			$0.frame = CGRect(x: 0, y: 0, width: width, height: 40)
		})
		// MARK: - start button
		start = OperationButton().then({
			$0.frame = CGRect(x: 0, y: 0, width: width / 2, height: 40)
			$0.addTarget(self, action: #selector(pause(button:)), for: .touchUpInside)
			view.addSubview($0)
			
			if isPaused == false {
				setPause(button: $0)
			} else {
				setStart(button: $0)
			}
		})
		// MARK: - delete button
		delete = OperationButton().then({
			$0.frame = CGRect(x: width / 2, y: 0, width: width / 2, height: 40)
			$0.setImage(UIImage.fontAwesomeIcon(name: .spinner,
			                                    textColor: UIColor.colorByRGB(red: 17, green: 133, blue: 117, alpha: 0.8),
			                                    size: CGSize(width: 20, height: 20)), for: .normal)
			$0.setTitle("全部删除", for: .normal)
			$0.addTarget(self, action: #selector(delete(button:)), for: .touchUpInside)
			view.addSubview($0)
		})
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
	@objc func pause(button: OperationButton) {
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
	
	@objc func delete(button: OperationButton) {
		if downloadingArray?.count == 0 {
			HUD.flash(.labeledError(title: "当前并无正在缓存歌曲", subtitle: nil), delay: 0.6)
			return
		}
		self.delegate?.didClickTheDeleteButton(button: button)
		downloadingArray?.removeAll()
		tableView.reloadData()
        self.start?.setTitle("全部开始", for: .normal)
	}
	
	func setStart(button: OperationButton) {
		button.setImage(UIImage.fontAwesomeIcon(name: .download,
		                                        textColor: UIColor.colorByRGB(red: 17, green: 133, blue: 117, alpha: 0.8),
		                                        size: CGSize(width: 20, height: 20)), for: .normal)
		button.setTitle("全部开始", for: .normal)
	}
	
	func setPause(button: OperationButton) {
		button.setImage(UIImage.fontAwesomeIcon(name: .pauseCircleO,
		                                        textColor: UIColor.colorByRGB(red: 17, green: 133, blue: 117, alpha: 0.8),
		                                        size: CGSize(width: 20, height: 20)), for: .normal)
		button.setTitle("全部暂停", for: .normal)
	}
}

extension DownloadingController {
	
	func getNotification() {
		let center = NotificationCenter.default
		center.addObserver(self, selector: #selector(percentChange(sender:)), name: Notification.Name("percent"), object: nil)
		center.addObserver(self, selector: #selector(downloadComplete), name: Notification.Name("downloadComplete"), object: nil)
	}
	
	@objc func percentChange(sender: Notification) {
		let userInfo = sender.userInfo!
		let index = userInfo["index"] as! Int
		self.index = index
		let indexPath = IndexPath(row: index, section: 0)
		let cell = tableView.cellForRow(at: indexPath) as? DownloadingCell
		
		if cell == nil {
            return
        }
		
		let progress = userInfo["percent"] as! Double
		cell?.progressView.isHidden = false
		cell?.progressView.setProgress(CGFloat(progress), animated: true)
	}
	
	
	@objc func downloadComplete() {
		downloadingArray?.remove(at: index!)
		DispatchQueue.main.async {
            self.tableView.deleteRows(at: [IndexPath(row: self.index!, section: 0)], with: .fade)
			if self.downloadingArray?.count == 0 {
				self.setStart(button: self.start!)
				self.navigationController!.popToRootViewController(animated: true)
			}
		}
	}
}
