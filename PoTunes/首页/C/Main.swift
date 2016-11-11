//
//  Player.swift
//  破音万里
//
//  Created by Purchas on 16/8/12.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

protocol MainDelegate: NSObjectProtocol {
	func pop()
}

class Main: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate {
    
	var height: CGFloat?
	var width: CGFloat?
	var pageControl: UIPageControl?
	var scrollView: UIScrollView?
	var player: PlayerInterface?
	var selectedView: UIView?
	var selectedBtn: BarItem?
	lazy var songs: NSArray = { [] }()
	lazy var controllers: NSMutableArray = { [] }()
	weak var delegate: MainDelegate?
	
    

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
		// 添加手势识别
		setupGestureRecognizer()
		// 存储用户状态
		setupUserOnline()
		// 获取上次播放曲目
		//_ = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
		//print("--------")
	}
    


    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: - 添加ScrollView
    func setupScrollView() {
        let scrollView: UIScrollView = UIScrollView()
        scrollView.frame = self.view.bounds
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.black
        //设置内容滚动尺寸
        scrollView.contentSize = CGSize(width: 0, height: self.view.bounds.height * 2)
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isPagingEnabled = true
        self.view.addSubview(scrollView)
        self.scrollView = scrollView
    }
    // MARK: - 添加PageControll
    func setupPageControl() {
        let pageControl: UIPageControl = UIPageControl()
        pageControl.numberOfPages = 2
        pageControl.isHidden = true
        let centerX = self.width! * 0.5
        let centerY = self.height! - 30
        pageControl.center = CGPoint(x: centerX, y: centerY)
        pageControl.bounds = CGRect(x: 0, y: 0, width: 100, height: 30)
        pageControl.isUserInteractionEnabled = true
        self.view.addSubview(pageControl)
        self.pageControl = pageControl
    }
    // MARK: - 添加播放器界面
    func setupPlayerInterface() {
        let player: PlayerInterface = PlayerInterface(frame: self.view.bounds)
        player.frame = self.view.bounds
        self.player = player
        self.scrollView?.addSubview(player)
    }
    //MARK: - 添加手势识别 - TODO
    func setupGestureRecognizer() {
        //播放和暂停
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(Main.playOrPause))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        self.player!.addGestureRecognizer(singleTap)
    }
    //MARK: - TODO
    func playOrPause() {
        if self.songs.count == 0 {
					//MARK: - HUD - TODO
            return
        }
        
    }
    //MARK: - TODO
    func setupUserOnline() {
			let user: UserDefaults = UserDefaults.standard
			let online = user.object(forKey: "online")

			if (online != nil) {
				setupTabBarWithCount(4)
			} else {
				setupTabBarWithCount(3)
			}
    }
    //MARK: - 添加TabBar界面
    func setupTabBarWithCount(_ count: Int) {
			//每月文章列表页
			let playlist: PlaylistController = PlaylistController()
			playlist.delegate  = self
			setupSingleViewControllerToScrollView(playlist, hidden: false)
			
			//已下载专辑页面
			if count == 4 {
				let albumDownload: AlbumDownloadViewController = AlbumDownloadViewController()
				setupSingleViewControllerToScrollView(albumDownload, hidden: true)
			}
			//导航页面
			let navi: NaviController = NaviController()
			setupSingleViewControllerToScrollView(navi, hidden: true)
			//设置页面
			let setting: SettingController = SettingController()
			setupSingleViewControllerToScrollView(setting, hidden: true)
			// 添加BarItem
			for i in 0..<count {
				let button: BarItem = BarItem(frame: CGRect(x: CGFloat(i) * self.width! / CGFloat(count), y: self.height!, width: self.width! / CGFloat(count), height: 64))
				button.normalImage?.image = UIImage(named: String(i + 1))
				if i == 0 {
					self.buttonClick(button)
				}
				button.tag = i
				button.addTarget(self, action: #selector(Main.buttonClick(_:)), for: .touchUpInside)
				let swipeFromTop: UISwipeGestureRecognizer = UISwipeGestureRecognizer.init(target: self, action: #selector(Main.panTheButton(btn:)))
				swipeFromTop.direction = .down
				swipeFromTop.numberOfTouchesRequired = 1
				button.addGestureRecognizer(swipeFromTop)
				self.scrollView?.addSubview(button)
			}
    }
	//MARK: - TODO
	func setupSingleViewControllerToScrollView(_ controller: UIViewController, hidden: Bool) {
		let nav: NavigationController = NavigationController(rootViewController: controller)
		nav.view.frame = CGRect(x: 0, y: self.height! + 20, width: self.width!, height: self.height! - 20)
		self.controllers.add(nav)
		self.scrollView?.addSubview(nav.view)
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
		let controller: UINavigationController = self.controllers[btn.tag] as! UINavigationController
		controller.view.isHidden = false
		self.selectedView = controller.view
		//MARK: - TODO
        controller.popToRootViewController(animated: true)
	}
	// MARK: - 下拉Button
	func panTheButton(btn: BarItem) {
		self.scrollView?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
		self.scrollView?.isScrollEnabled = true
	}
	//MARK: - scrollView代理方法 - 防止在底部页面含有TableView时滑动
	 func scrollViewDidScroll(_ scrollView: UIScrollView) {
		/** 1.取出水平方向上的滚动距离 */
		let offsetY = scrollView.contentOffset.y
		
		if offsetY == self.height {
			scrollView.isScrollEnabled = false
		}
	}

}

extension Main: PlaylistDelegate {
	func tabBarCount(count: Int) {
		print("代理成功")
		self.setupTabBarWithCount(4)
	}
}
