//
//  Player.swift
//  破音万里
//
//  Created by Purchas on 16/8/12.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit
import Masonry


class Main: UIViewController, UIGestureRecognizerDelegate, UIAlertViewDelegate {
    
	var height: CGFloat?
	var width: CGFloat?
	var pageControl: UIPageControl?
	var scrollView: UIScrollView?
	var player: PlayerInterface?
	var mainControllers: MainControllers?
	lazy var songs: NSArray = { [] }()

	override func viewDidLoad() {
		
		super.viewDidLoad()
	
		self.height = self.view.bounds.size.height
		self.width = self.view.bounds.size.width
		// 添加ScrollView
		setupScrollView()
		// 添加PageControl
		setupPageControl()
		// 添加播放器界面
		setupPlayerInterface()
		// 添加下方页面
		setupControllers()
		// 获取上次播放曲目
		//_ = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
		//print("--------")
	}
    

	// 去除状态栏
	override var prefersStatusBarHidden : Bool {
		return true
	}
    
	// MARK: - 添加ScrollView
	func setupScrollView() {
		let scrollView: UIScrollView = MainScrollview()
		scrollView.frame = self.view.bounds
		scrollView.delegate = self
		self.view.addSubview(scrollView)
		self.scrollView = scrollView
	}
	// MARK: - 添加PageControll
	func setupPageControl() {
		let pageControl: UIPageControl = MainPageControl()
		self.view.addSubview(pageControl)
		self.pageControl = pageControl
	}
	// MARK: - 添加播放器界面
	func setupPlayerInterface() {
		let player: PlayerInterface = PlayerInterface(frame: self.view.bounds)
		player.frame = self.view.bounds
		self.player = player
		scrollView?.addSubview(player)
	}
	// MARK: - 添加Controllers
	func setupControllers() {
		let mainControllers: MainControllers = MainControllers()
		mainControllers.frame  = CGRect(x: 0, y: self.height!, width: self.width!, height: self.height! - 20)
		mainControllers.delegate = self
		self.mainControllers = mainControllers
		scrollView?.addSubview(mainControllers)
	}
}
// MARK: - 向下滑动BarItem
extension Main: MainPageControllersDelegate {
	func pan() {
		scrollView?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
		scrollView?.isScrollEnabled = true
	}
}
// MARK: - scrollView代理方法 - 防止在底部页面含有TableView时滑动
extension Main: UIScrollViewDelegate {
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		/** 1.取出水平方向上的滚动距离 */
		let offsetY = scrollView.contentOffset.y
		
		if offsetY == self.height {
			scrollView.isScrollEnabled = false
		}
	}
}

