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
		
		self.selectedSegmentIndex = 0
		
		self.backgroundColor = UIColor.white

		self.tintColor = UIColor.white
		
		self.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.black], for: .selected)
		
		self.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.lightGray], for: .normal)
		
		self.layer.shadowRadius = 3
		
		self.layer.shadowOpacity = 0.2
		
		self.layer.shadowOffset = CGSize(width: 1, height: 1)
		
		UIColor.white.setFill()
		
		UIRectFill(rect)
		
	}
	
}
