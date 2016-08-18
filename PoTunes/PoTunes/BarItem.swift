//
//  TabBarItem.swift
//  破音万里
//
//  Created by Purchas on 16/8/17.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class BarItem: UIButton {
	var normalImage: UIImageView?

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.titleLabel?.font = UIFont(name: "BebasNeue", size: 12)
		self.imageView?.contentMode = .ScaleToFill
		let patternImage: UIImage = (UIImage(named: "barBg")?.resizableImageWithCapInsets(UIEdgeInsetsMake(0.5, 0, 0, 0), resizingMode: .Stretch))!
		self.setImage(patternImage, forState: .Selected)
		
	}
	
	override func imageRectForContentRect(contentRect: CGRect) -> CGRect {
		let imageW = contentRect.size.width
		let imageH = contentRect.size.height * 0.1
		return CGRectMake(0, 0, imageW, imageH)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.normalImage?.frame = CGRectMake((self.bounds.size.width - 25) / 2, 20, 30, 30)
	}
	
	override var highlighted: Bool {
		didSet {
			
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
