//
//  OperationButton.swift
//  破音万里
//
//  Created by Purchas on 2016/11/25.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class OperationButton: UIButton {
	
	
	override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		self.backgroundColor = UIColor.clear
		
		self.setTitleColor(UIColor.colorByRGB(red: 17, green: 133, blue: 117, alpha: 0.8), for: .normal)
		
		self.titleLabel?.textAlignment = .left
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	
	}

	override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
		
		return CGRect(x: (contentRect.size.width * 0.7 + 30) / 2 - 30, y: 5, width: 30, height: 30)
		
	}
	
	override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
		
		let titleW = contentRect.size.width * 0.7
		
		let titleH = contentRect.size.height
		
		let x = (contentRect.size.width * 0.7 + 30) / 2
		
		return CGRect(x: x, y: 0, width: titleW, height: titleH)
		
	}

}
