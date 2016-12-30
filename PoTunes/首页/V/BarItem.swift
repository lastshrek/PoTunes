//
//  TabBarItem.swift
//  破音万里
//
//  Created by Purchas on 16/8/17.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class BarItem: UIButton {
	
	override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		self.imageView?.contentMode = .scaleToFill
		
		let patternImage: UIImage = (UIImage(named: "barBg-pink")?.resizableImage(withCapInsets: UIEdgeInsetsMake(0.5, 0, 0, 0), resizingMode: .stretch))!
		
		self.titleLabel?.font = UIFont.fontAwesome(ofSize: 35)

		self.setImage(patternImage, for: .selected)
		
		self.backgroundColor = UIColor.white
		
		self.setTitleColor(UIColor.colorByRGB(red: 17, green: 133, blue: 117, alpha: 0.8), for: .normal)
		
		self.setTitleColor(UIColor.colorByRGB(red: 225, green: 49, blue: 114, alpha: 1), for: .selected)

	}
	
	override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
		
		let imageW = contentRect.size.width
		
		let imageH = contentRect.size.height * 0.1
		
		return CGRect(x: 0, y: 0, width: imageW, height: imageH)
		
	}
	
//	override var isHighlighted: Bool {
//		
//		didSet {
//			
//			super.isSelected = true
//			super.isHighlighted = false
//
//		}
//		
//	}


	required init?(coder aDecoder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	
	}
}
