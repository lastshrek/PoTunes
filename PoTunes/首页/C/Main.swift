//
//  Player.swift
//  破音万里
//
//  Created by Purchas on 16/8/12.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit
import FMDB


class Main: UIViewController, UIGestureRecognizerDelegate, UIAlertViewDelegate {
    
	let height = UIScreen.main.bounds.size.height
	
	let width = UIScreen.main.bounds.size.width
	
	var pageControl = MainPageControl()
	
	var scrollView = MainScrollview()
	
	var mainControllers: MainControllers = MainControllers()
	
	var player: PlayerController = PlayerController()
	
	lazy var songs: NSArray = { [] }()
	
	var db: FMDatabase?

	override func viewDidLoad() {
		
		super.viewDidLoad()
		// 添加ScrollView
		setupScrollView()
		// 添加PageControl
		setupPageControl()
		// 添加播放器界面
		setupPlayerInterface()
		// 添加下方页面
		setupControllers()
		// 注册通知
		getNotification()
		// 获取上次播放曲目
		//_ = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
		//print("--------")
		// create DB
		createDB()
		
	}
    

	// 去除状态栏
	override var prefersStatusBarHidden : Bool {
		
		return true
	
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		
		return .lightContent
		
	}
	
	// MARK: - 添加ScrollView
	func setupScrollView() {
		
		scrollView.frame = self.view.bounds
		
		scrollView.delegate = self
		
		self.view.addSubview(scrollView)
	
	}
	// MARK: - 添加PageControll
	func setupPageControl() {
	
		self.view.addSubview(pageControl)
	
	}
	// MARK: - 添加播放器界面
	func setupPlayerInterface() {
	
		player.view.frame = self.view.bounds
		
		scrollView.addSubview(player.view)
	
	}
	// MARK: - 添加Controllers
	func setupControllers() {
	
		mainControllers.frame  = CGRect(x: 0, y: height, width: width, height: height)
		
		mainControllers.delegate = self
				
		scrollView.addSubview(mainControllers)
	
	}
	
	// MARK: - createDB
	func createDB() {
		
		// DB Location
		
		let path = self.dirDoc().appending("/downloadingSong.db")
		
		db = FMDatabase(path: path)
		
		db?.open()
		
		let createStr = "CREATE TABLE IF NOT EXISTS t_downloading (id integer PRIMARY KEY, author text, title text, sourceURL text,indexPath integer,thumb text,album text,downloaded bool, identifier text);CREATE TABLE IF NOT EXISTS t_playlists (id integer PRIMARY KEY, title text, cover text, p_id integer);"
		
		db?.executeStatements(createStr)
		
		db?.shouldCacheStatements()
		
	}
	
}
// MARK: - 向下滑动BarItem
extension Main: MainPageControllersDelegate {
	
	func pan() {
		
		scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
		
		scrollView.isScrollEnabled = true
		
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

// MARK: - 添加通知
extension Main {
	
	func getNotification() {
		
		let center: NotificationCenter = NotificationCenter.default
		
		center.addObserver(self, selector: #selector(didSelectTrack(_:)), name: Notification.Name("selected"), object: nil)
		
	}
	
		
	func didSelectTrack(_ notification: Notification) {
		
		//滚到上层
		self.scrollView.isScrollEnabled = true
		
		self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
		
	}
}

