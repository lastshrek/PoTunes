//
//  LrcLabel.swift
//  破音万里
//
//  Created by Purchas on 2016/12/29.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class LrcLabel: UILabel {

	override init(frame: CGRect) {
		super.init(frame: frame)
		textColor = UIColor.white
		textAlignment = .center
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func drawText(in rect: CGRect) {
		let shadowOffset: CGSize = self.shadowOffset
		let textColor = self.textColor
		let c: CGContext = UIGraphicsGetCurrentContext()!
		
		c.setLineWidth(1)
		c.setLineJoin(.round)
		c.setTextDrawingMode(.stroke)
		self.textColor = UIColor.black
		super.drawText(in: rect)

		c.setTextDrawingMode(.fill)
		self.textColor = textColor
		self.shadowOffset = CGSize(width: 0, height: 0)
		super.drawText(in: rect)
		self.shadowOffset = shadowOffset
	}
}
