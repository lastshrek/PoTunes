//
//  TabBarItem.swift
//  破音万里
//
//  Created by Purchas on 16/8/17.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class BarItem: UIButton {
	var bgImage = UIImageView()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.imageView?.contentMode = .scaleAspectFit
		self.backgroundColor = UIColor.white
		bgImage.image = (UIImage(named: "barBg-pink")?.resizableImage(withCapInsets: UIEdgeInsetsMake(0.5, 0, 0, 0), resizingMode: .stretch))!
		bgImage.isHidden = true
		self.addSubview(bgImage)
		// disable highlighted
		self.showsTouchWhenHighlighted = true
	}
	
	override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
		let imageW = contentRect.size.width * 0.8
		let imageH = contentRect.size.height * 0.8
		return CGRect(x: 0, y: 0, width: imageW, height: imageH)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.bgImage.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: 5)
		self.imageView?.frame = CGRect(x: Int((self.bounds.size.width - 25) / 2), y: 20, width: 30, height: 30)
	}
	
}
