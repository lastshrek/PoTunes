//
//  MainScrollview.swift
//  破音万里
//
//  Created by Purchas on 2016/11/11.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class MainScrollview: UIScrollView {

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.backgroundColor = UIColor.black
		//设置内容滚动尺寸
		self.bounces = false
		self.showsVerticalScrollIndicator = false
		self.isPagingEnabled = true
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: NSCoder())!
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.contentSize = CGSize(width: 0, height: self.bounds.height * 2)
	}
	
}
