//
//  Player.swift
//  破音万里
//
//  Created by Purchas on 16/8/12.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class Player: UIViewController, UIScrollViewDelegate {
    
    var height: CGFloat?
    var width: CGFloat?
    var pageControl: UIPageControl?
    var scrollView: UIScrollView?
    var player: PlayerInterface?
    lazy var songs: NSArray = { [] }()
    

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
        
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let player: PlayerInterface = PlayerInterface()
        self.player = player
        self.scrollView?.addSubview(player)
    }
    //MARK: - 添加手势识别
    func setupGestureRecognizer() {
        //播放和暂停
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer.init(target: self, action:#selector(Player.playOrPause))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        self.player?.addGestureRecognizer(singleTap)
    }
    
    func playOrPause() {
        print(123)
        if self.songs.count == 0 {
            HUD.flash(.Success, delay: 1.0)
        }
    }
}
