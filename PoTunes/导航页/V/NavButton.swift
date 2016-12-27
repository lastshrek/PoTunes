//
//  NavButton.swift
//  破音万里
//
//  Created by Purchas on 2016/12/16.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class NavButton: UIButton {

	override func draw(_ rect: CGRect) {
				
		self.setTitleColor(UIColor.colorByRGB(red: 225, green: 49, blue: 114, alpha: 1), for: .normal)
		
		self.titleLabel?.font = UIFont.init(name: "BebasNeue.otf", size: 16)
		
		self.layer.shadowRadius = 3
		
		self.layer.shadowOpacity = 0.2
		
		self.layer.shadowOffset = CGSize(width: 1, height: 1)
		
		UIColor.white.setFill()
		
		UIRectFill(rect)
		
	}
	
}
