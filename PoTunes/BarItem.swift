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
		self.imageView?.contentMode = .scaleToFill
		let patternImage: UIImage = (UIImage(named: "barBg")?.resizableImage(withCapInsets: UIEdgeInsetsMake(0.5, 0, 0, 0), resizingMode: .stretch))!
		self.setImage(patternImage, for: .selected)
		self.backgroundColor = UIColor.black
		//添加背景图片
		let bgImage = UIImageView()
		bgImage.image = self.imageView?.image
		bgImage.contentMode = .scaleToFill
		self.normalImage = bgImage
		self.addSubview(bgImage)
	}
	
	override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
		let imageW = contentRect.size.width
		let imageH = contentRect.size.height * 0.1
		return CGRect(x: 0, y: 0, width: imageW, height: imageH)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.normalImage?.frame = CGRect(x: (self.bounds.size.width - 25) / 2, y: 20, width: 30, height: 30)
	}
	// MARK: - 点击
	override var isHighlighted: Bool {
		didSet {
			
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
