//
//  SettingController.swift
//  破音万里
//
//  Created by Purchas on 2016/11/10.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit
import PKHUD
import FontAwesome_swift

class SettingController: UITableViewController {
	
	let images: Array<FontAwesome> = [.map, .wifi, .fire]
	
	let infos: Array<String> = ["使用2G/3G/4G网络播放", "使用2G/3G/4G网络缓存", "wwanPlay", "wwanDownload"]
	
	let color = UIColor.colorByRGB(red: 17, green: 133, blue: 117, alpha: 1)

    override func viewDidLoad() {
		
		super.viewDidLoad()
		
		tableView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0)
		
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "setting")
		
		tableView.isScrollEnabled = false
		
		initFooterView()
        
        getNotification()
	}
	
	func initFooterView() {
		
		let footer = UIView()
		
		footer.frame = CGRect(x: 0, y: 0, width: 300, height: self.view.height() - 176)
		
		tableView.tableFooterView = footer
		
		// Clear Cache
		let clearBtn = UIButton()
		
		clearBtn.frame = CGRect(x: 20, y: footer.height() - 120, width: self.view.width() - 50, height: 50)
		
		clearBtn.setTitle("清空缓存", for: .normal)
		
		clearBtn.setTitleColor(color, for: .normal)
		
		clearBtn.addTarget(self, action: #selector(clearCaches), for: .touchUpInside)
		
		footer.addSubview(clearBtn)
		
		
	}
	
	func clearCaches() {
		
		HUD.flash(.label("清除缓存中"), delay: 0.5)
		
		let manager = FileManager.default
		
		let rootPath = self.dirDoc()
		
		let enumerator = manager.enumerator(atPath: rootPath)
		
		while let element = enumerator?.nextObject() as? String {
			
			if element.hasPrefix("FSCache-") {
				
				let fullPath = rootPath + "/" + element
				
				do {
					
					try
						manager.removeItem(atPath: fullPath)

				} catch {
					
					debugPrint("删除失败")
				
				}
				
			}
			
		}
		
		HUD.flash(.success, delay: 0.5)
		
	}
	
	func getNotification() {
		
		let center = NotificationCenter.default
		
		center.addObserver(self, selector: #selector(switchOn), name: Notification.Name("wwanPlay"), object: nil)
		
		center.addObserver(self, selector: #selector(switchOn), name: Notification.Name("wwanDownload"), object: nil)
		
	}
	
	func switchOn() {
		
		DispatchQueue.main.async {
			
			self.tableView.reloadData()
		
		}
		
	}
	

	deinit {
		
		NotificationCenter.default.removeObserver(self, name: Notification.Name("wwanPlay"), object: nil)
		
		NotificationCenter.default.removeObserver(self, name: Notification.Name("wwanDownload"), object: nil)
		
	}

}

extension SettingController {

	// MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return 3
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "setting", for: indexPath)
		
		if indexPath.row == 0 {
			
			cell.textLabel?.text = "废人操作说明书"
			
			
		} else {
			
			cell.textLabel?.text = infos[indexPath.row - 1]
			
			let switchView = UISwitch.init(frame: CGRect(x: self.view.width() - 60, y: 6, width: 40, height: 40))
			
			let user = UserDefaults.standard
			
			let query = infos[indexPath.row + 1]
			
			let yes = user.bool(forKey: query)
			
			switchView.isOn = yes
			
			switchView.tag = indexPath.row - 1
			
			switchView.tintColor = color
			
			switchView.onTintColor = color
			
			switchView.addTarget(self, action: #selector(switchAction(sender:)), for: .valueChanged)
			
			cell.contentView.addSubview(switchView)
			
		}
		
		cell.imageView?.image = UIImage.fontAwesomeIcon(name: images[indexPath.row], textColor: color, size: CGSize(width: 30, height: 30))
		
		cell.textLabel?.textColor = color
				
		return cell
	}
	
	func switchAction(sender: UISwitch) {
		
		let index = sender.tag
		
		let user = UserDefaults.standard

		user.set(sender.isOn, forKey: infos[index + 2])

	}
	
}

extension SettingController {
	
	// MARK: - Table view delegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		if indexPath.row == 0 {
			
			let guide = UserGuideController()
			
			self.navigationController?.pushViewController(guide, animated: true)
			
		}
		
	}

}
