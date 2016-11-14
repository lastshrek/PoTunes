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
	var mainControllers: MainControllers?
	var player: PlayerController?
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
		// 注册通知
		getNotification()
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
		let player: PlayerController = PlayerController()
		player.view.frame = self.view.bounds
		self.player = player
		scrollView?.addSubview(player.view)
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

// MARK: - 添加通知
extension Main {
	
	func getNotification() {
		
		let center: NotificationCenter = NotificationCenter.default
		
		center.addObserver(self, selector: #selector(didSelectTrack(_:)), name: Notification.Name("selected"), object: nil)
	}
	
	func didSelectTrack(_ notification: Notification) {
		
		//滚到上层
		self.scrollView?.isScrollEnabled = true
		
		self.scrollView?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
		
		
		
//		//判断用户网络状态以及是否允许网络播放
//		NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
//		
//		BOOL yes = [[user objectForKey:@"wwanPlay"] boolValue];
//		
//		
//		if (!yes && self.conn.currentReachabilityStatus != 2 && ![type isEqualToString:@"local"]) {
//			
//			//初始化AlertView
//			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
//			message:@"您当前处于运营商网络中，是否继续播放"
//			delegate:self
//			cancelButtonTitle:@"取消"
//			otherButtonTitles:@"确认",nil];
//			[alert show];
//			
//			return;
//		}
//		
//		
//		if (self.conn.currentReachabilityStatus == 2 || [type isEqualToString:@"local"] || yes) {
//			
//			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//				
//				[self playFromPlaylist:songs itemIndex:index state:PCAudioPlayStatePlay];
//				
//				[self changePlayerInterfaceDuringUsing:self.songs[index] row:index];
//				
//				});
//		}

		
	}
}

