//
//  SingleRoute.swift
//  破音万里
//
//  Created by Purchas on 2016/12/3.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class SingleRoute: UIView {
	
	let icon: UIImageView = UIImageView()
	
	let text: UITextField = UITextField()

	override init(frame: CGRect) {
		
		super.init(frame: frame)
		
		self.backgroundColor = UIColor.white
		
		self.layer.shadowRadius = 3
		
		self.layer.shadowOpacity = 0.2
		
		self.layer.shadowOffset = CGSize(width: 1, height: 1)
		
		self.addSubview(icon)
		
		self.addSubview(text)
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		
		super.layoutSubviews()
		
		let width = self.bounds.size.width
		
		let height = self.bounds.size.height
		
		icon.frame = CGRect(x: 5, y: (height - width * 0.1) * 0.5, width: width * 0.1, height: width * 0.1)
		
		text.frame = CGRect(x: width * 0.1 + 15, y: (height - width * 0.1) * 0.5, width: width * 0.9 - 30, height: width * 0.1)
		
	}
	
}




