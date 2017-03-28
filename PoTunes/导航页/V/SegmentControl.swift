//
//  SegmentControl.swift
//  破音万里
//
//  Created by Purchas on 2016/12/16.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class SegmentControl: UISegmentedControl {
	
	override func draw(_ rect: CGRect) {
		selectedSegmentIndex = 0
		backgroundColor = UIColor.white
		tintColor = UIColor.white
		layer.shadowRadius = 3
		layer.shadowOpacity = 0.2
		layer.shadowOffset = CGSize(width: 1, height: 1)
		setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.black], for: .selected)
		setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.lightGray], for: .normal)
		UIColor.white.setFill()
		UIRectFill(rect)
	}
}
