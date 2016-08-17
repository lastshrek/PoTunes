//
//  Player.swift
//  破音万里
//
//  Created by Purchas on 16/8/12.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class Main: UIViewController, UIScrollViewDelegate {
    
    var height: CGFloat?
    var width: CGFloat?
    var pageControl: UIPageControl?
    var scrollView: UIScrollView?
    var player: PlayerInterface?
    lazy var songs: NSArray = { [] }()
    lazy var controllers: NSMutableArray = { [] }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.height = self.view.bounds.size.height
        self.width = self.view.bounds.size.width
        //添加ScrollView
        setupScrollView()
        //添加PageControl
        setupPageControl()
        //添加播放器界面
        setupPlayerInterface()
        //添加手势识别
        setupGestureRecognizer()
        //存储用户状态
        setupUserOnline()
        
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - 添加ScrollView
    func setupScrollView() {
        let scrollView: UIScrollView = UIScrollView()
        scrollView.frame = self.view.bounds
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.blackColor()
        //设置内容滚动尺寸
        scrollView.contentSize = CGSizeMake(0, self.view.bounds.height * 2)
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.pagingEnabled = true
        self.view.addSubview(scrollView)
        self.scrollView = scrollView
    }
    // MARK: - 添加PageControll
    func setupPageControl() {
        let pageControl: UIPageControl = UIPageControl()
        pageControl.numberOfPages = 2
        pageControl.hidden = true
        let centerX = self.width! * 0.5
        let centerY = self.height! - 30
        pageControl.center = CGPointMake(centerX, centerY)
        pageControl.bounds = CGRectMake(0, 0, 100, 30)
        pageControl.userInteractionEnabled = true
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
            HUD.flash(.Error, delay: 1.0)
            return
        }
        
    }
    //MARK: - TODO
    func setupUserOnline() {
        let user: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let online:String? = user.valueForKey("online") as? String
        if online == nil {
            
        }
    }
    //MARK: - TODO
    func setupTabBarWithCount(count: Int) {
        //每月文章列表页
        let article: ArticleController = ArticleController()
        setupSingleViewControllerToScrollView(article, hidden: false)
        
    }
    //MARK: - TODO
    func setupSingleViewControllerToScrollView(controller: UIViewController, hidden: Bool) {
        
    }
}
