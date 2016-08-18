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
		
		UIApplication.sharedApplication().statusBarStyle = .LightContent
		//设置导航栏样式
		let navBar: UINavigationBar = UINavigationBar.appearance()
		navBar.hidden = true
		UINavigationBar.appearance().translucent = true
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		self.hidden = self.view.hidden
	}

	override func didReceiveMemoryWarning() {
			super.didReceiveMemoryWarning()
			// Dispose of any resources that can be recreated.
	}
    
	override func pushViewController(viewController: UIViewController, animated: Bool) {
		if self.viewControllers.count > 0 {
			viewController.hidesBottomBarWhenPushed = true
		}
		super.pushViewController(viewController, animated: animated)
	}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
