//
//  MainPageControl.swift
//  破音万里
//
//  Created by Purchas on 2016/11/11.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class MainPageControl: UIPageControl {

	override init(frame: CGRect) {
		super.init(frame: frame)
		numberOfPages = 2
		isHidden = true
		isUserInteractionEnabled = true
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: NSCoder())!
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		let centerX = self.bounds.size.width * 0.5
		let centerY = self.bounds.size.height - 30
		center = CGPoint(x: centerX, y: centerY)
		bounds = CGRect(x: 0, y: 44, width: 100, height: 30)
	}
}
