//
//  NavigationController.swift
//  破音万里
//
//  Created by Purchas on 16/8/17.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
	
	var hidden: Bool?

	override class func initialize() {
		//设置导航栏样式
		let navBar: UINavigationBar = UINavigationBar.appearance()
		navBar.isHidden = true
		UINavigationBar.appearance().isTranslucent = true
	}
	

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		hidden = self.view.isHidden
	}
	
	override func pushViewController(_ viewController: UIViewController, animated: Bool) {
		if self.viewControllers.count > 0 {
			viewController.hidesBottomBarWhenPushed = true
		}
		super.pushViewController(viewController, animated: animated)
	}
}
