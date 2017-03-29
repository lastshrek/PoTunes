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
		backgroundColor = UIColor.black
		//设置内容滚动尺寸
		bounces = false
		showsVerticalScrollIndicator = false
		isPagingEnabled = true
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: NSCoder())!
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		contentSize = CGSize(width: 0, height: self.bounds.height * 2)
	}
}
