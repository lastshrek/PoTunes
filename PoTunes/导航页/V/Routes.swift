//
//  Routes.swift
//  破音万里
//
//  Created by Purchas on 2016/12/3.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit
import PKHUD

class Routes: UIView {
	var start: SingleRoute = SingleRoute().then({
		$0.icon.image = UIImage.fontAwesomeIcon(name: .arrowCircleORight, textColor: UIColor.black, size: CGSize(width: 20, height: 20))
		$0.text.text = "当前位置"
		$0.text.tag = 1
	})
	var end: SingleRoute = SingleRoute().then({
		$0.icon.image = UIImage.fontAwesomeIcon(name: .arrowCircleOLeft, textColor: UIColor.black, size: CGSize(width: 20, height: 20))
		$0.text.placeholder = "目的位置"
		$0.text.tag = 2
	})
	let switcher = UIButton().then({
		$0.backgroundColor = UIColor.white
		$0.layer.borderColor = UIColor.black.cgColor
		$0.layer.borderWidth = 2
		$0.titleLabel?.font = UIFont.fontAwesome(ofSize: 30)
		$0.setTitle(String.fontAwesomeIcon(name: .refresh), for: .normal)
		$0.setTitleColor(UIColor.black, for: .normal)
	})
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		layer.shadowRadius = 3
		layer.shadowOpacity = 0.2
		layer.shadowOffset = CGSize(width: 1, height: 1)
		self.addSubview(start)
		self.addSubview(end)
		self.addSubview(switcher)
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
		switcher.frame = CGRect(x: width - 20 - height * 0.4, y: height * 0.3, width: height * 0.4, height: height * 0.4)
		switcher.layer.cornerRadius = height * 0.2
	}
}




