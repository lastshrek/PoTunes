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
	
	lazy var controllers: Array<UINavigationController> = { [] }()
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
			if UIScreen.main.bounds.size.height == 812 {
				controller.view.frame = CGRect(x: 0, y: 50, width: frame.size.width, height: frame.size.height)
			} else {
				controller.view.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
			}
		}
	}
	
	func setupControllers(frame: CGRect) {
		//每月文章列表页
		let playlist: PlaylistController = PlaylistController()

		playlist.delegate = self
		setupSingleViewControllerToScrollView(playlist, hidden: false, frame: frame)
		//已下载专辑页面
		setupSingleViewControllerToScrollView(AlbumDownloadController(), hidden: true, frame: frame)
		//导航页面
		setupSingleViewControllerToScrollView(NaviController(), hidden: true, frame: frame)
		//设置页面
		setupSingleViewControllerToScrollView(SettingController(), hidden: true, frame: frame)
	}
	
	//MARK: - TODO
	func setupSingleViewControllerToScrollView(_ controller: UIViewController, hidden: Bool, frame: CGRect) {
		let nav = UINavigationController(rootViewController: controller)
		self.controllers.append(nav)
		self.addSubview(nav.view)
		nav.view.isHidden = hidden
		if hidden == false {
			self.selectedView = nav.view
		}
	}
	
	//MARK: - 点击tabBarButton事件
	@objc func buttonClick(_ btn: BarItem) {
		self.selectedBtn?.isSelected = false
		self.selectedBtn?.bgImage.isHidden = true
		
		btn.isSelected = true
		btn.bgImage.isHidden = false
		self.selectedBtn = btn
		
		self.selectedView?.isHidden = true
		self.selectedView?.endEditing(true)
		
		let controller = self.controllers[btn.tag]
		controller.view.isHidden = false
		self.selectedView = controller.view
		controller.popToRootViewController(animated: true)
	}
	
	func setupTabBarItem(_ count: Int, frame: CGRect) {
		let nameArr: Array<String> = ["home", "music", "nav", "mine"]
		
		for i in 0..<count {
			var button: BarItem = BarItem(frame: CGRect(x: CGFloat(i) * self.bounds.size.width / CGFloat(count), y: 0, width: self.bounds.size.width / CGFloat(count), height: 64))
			if UIScreen.main.bounds.size.height == 812 {
				button = BarItem(frame: CGRect(x: CGFloat(i) * self.bounds.size.width / CGFloat(count), y: 30, width: self.bounds.size.width / CGFloat(count), height: 64))
			}
			
			
			if count == 3 && (i == 1 || i == 2) {
				button.tag = i + 1
			} else if count == 4 || i == 0 {
				button.tag = i
			}
			button.setImage(UIImage(named:nameArr[i]), for: .normal)
			button.setImage(UIImage(named:(nameArr[i] + "_selected")), for: .selected)
			
			if i == 0 {
				self.buttonClick(button)
			}
			
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
	@objc func panTheButton(btn: BarItem) {
		self.delegate?.pan()
	}

}

extension MainControllers: PlaylistDelegate {
	func tabBarCount(count: Int) {
		self.setupTabBarItem(count, frame: self.size!)
	}
}
