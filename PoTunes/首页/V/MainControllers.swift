//
//  MainControllers.swift
//  破音万里
//
//  Created by Purchas on 2016/11/11.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit
import FontAwesome_swift

protocol MainPageControllersDelegate: class {
	func pan()
}

class MainControllers: UIView {
	
	lazy var controllers: Array<NavigationController> = { [] }()
	
	var selectedView: UIView?
	
	var selectedBtn: BarItem?
	
	var size: CGRect?
	
	weak var delegate: MainPageControllersDelegate?
	
	var reachable: Int?

	override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		setupControllers(frame: frame)
		
		self.backgroundColor = UIColor.white
		
		self.size = frame
	
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: NSCoder())!
	}
	
	override func layoutSubviews() {
		
		super.layoutSubviews()
		
		for controller in self.controllers {
			
			controller.view.frame = CGRect(x: 0, y: 64, width: frame.size.width, height: frame.size.height)
			
		}
		
		
	}
	
	func setupControllers(frame: CGRect) {
		//每月文章列表页
		let playlist: PlaylistController = PlaylistController()
		
		playlist.delegate = self
		
		setupSingleViewControllerToScrollView(playlist, hidden: false, frame: frame)
		
		//已下载专辑页面
		let albumDownload = AlbumDownloadController()
				
		setupSingleViewControllerToScrollView(albumDownload, hidden: true, frame: frame)
		//导航页面
		let navi: NaviController = NaviController()
		
		setupSingleViewControllerToScrollView(navi, hidden: true, frame: frame)
		//设置页面
		let setting: SettingController = SettingController()
		
		setupSingleViewControllerToScrollView(setting, hidden: true, frame: frame)
	}
	
	//MARK: - TODO
	func setupSingleViewControllerToScrollView(_ controller: UIViewController, hidden: Bool, frame: CGRect) {
		
		let nav: NavigationController = NavigationController(rootViewController: controller)
				
		self.controllers.append(nav)
		
		self.addSubview(nav.view)
		
		nav.view.isHidden = hidden
		
		if hidden == false {
		
			self.selectedView = nav.view
		
		}
		
	}
	
	//MARK: - 点击tabBarButton事件
	func buttonClick(_ btn: BarItem) {
		
		self.selectedBtn?.isSelected = false
		
		btn.isSelected = true
		
		self.selectedBtn = btn
		
		self.selectedView?.isHidden = true
		
		let controller = self.controllers[btn.tag]
		
		controller.view.isHidden = false
		
		self.selectedView = controller.view

		controller.popToRootViewController(animated: true)
		
	}
	
	func setupTabBarItem(_ count: Int, frame: CGRect) {
		
		let iconArr: Array = [FontAwesome.home, FontAwesome.music, FontAwesome.road, FontAwesome.wrench]
		
		for i in 0..<count {
		
			let button: BarItem = BarItem(frame: CGRect(x: CGFloat(i) * self.bounds.size.width / CGFloat(count), y: 0, width: self.bounds.size.width / CGFloat(count), height: 64))
			
			button.setTitle(String.fontAwesomeIcon(name: iconArr[i]), for: .normal)
			
			if i == 0 {
			
				self.buttonClick(button)
			
			}
			
			button.tag = i
			
			button.addTarget(self, action: #selector(MainControllers.buttonClick(_:)), for: .touchUpInside)
			
			// 添加下滑事件
			let swipeFromTop: UISwipeGestureRecognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(MainControllers.panTheButton(btn:)))
			
			swipeFromTop.direction = .down
			
			swipeFromTop.numberOfTouchesRequired = 1
			
			button.addGestureRecognizer(swipeFromTop)
			
			self.addSubview(button)
					
		}
	}
	
	// MARK: - 下拉Button
	func panTheButton(btn: BarItem) {
		
		self.delegate?.pan()
	
	}

}

extension MainControllers: PlaylistDelegate {
	
	func tabBarCount(count: Int) {
	
		self.setupTabBarItem(count, frame: self.size!)
	
	}

}
