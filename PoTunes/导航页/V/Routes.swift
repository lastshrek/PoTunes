//
//  Routes.swift
//  破音万里
//
//  Created by Purchas on 2016/12/3.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class Routes: UIView {
	
	var start: SingleRoute = SingleRoute()
	
	var end: SingleRoute = SingleRoute()
	
	override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		self.layer.shadowRadius = 3
		
		self.layer.shadowOpacity = 0.2
		
		self.layer.shadowOffset = CGSize(width: 1, height: 1)
		
		start.icon.image = UIImage.fontAwesomeIcon(name: .arrowCircleORight, textColor: UIColor.black, size: CGSize(width: 20, height: 20))
		
		start.text.text = "当前位置"
				
		end.icon.image = UIImage.fontAwesomeIcon(name: .arrowCircleOLeft, textColor: UIColor.black, size: CGSize(width: 20, height: 20))
		
		end.text.placeholder = "目的位置"
				
		self.addSubview(start)
		
		self.addSubview(end)
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
		
	}
	
	override var canBecomeFirstResponder: Bool {
		
		return true
		
	}
	

	
	override func layoutSubviews() {

		super.layoutSubviews()
		
		let width = self.bounds.size.width
		
		let height = self.bounds.size.height
		
		start.frame = CGRect(x: 5, y: 0, width: width - 10, height: height / 2 - 2)
		
		end.frame = CGRect(x: 5, y: height / 2 + 2, width: width - 10, height: height / 2 - 2)

	
	}

}




