//
//  DownloadedCellTableViewCell.swift
//  破音万里
//
//  Created by Purchas on 2016/11/10.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class DownloadedCell:  UITableViewCell {
	
	let divider: UIView = UIView()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		self.imageView?.contentMode = .scaleAspectFit
		
		self.textLabel?.textAlignment = .left
		
		self.textLabel?.adjustsFontSizeToFitWidth = true
		
		self.textLabel?.textColor = UIColor.colorByRGB(red: 17, green: 133, blue: 117, alpha: 0.8)
		
		self.textLabel?.font = UIFont(name: "BebasNeue", size: 18)

		// 分割线
		divider.backgroundColor = UIColor.lightGray
		
		self.addSubview(divider)
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
	
		super.layoutSubviews()
		
		let width = self.bounds.size.width
		
		let height = self.bounds.size.height
				
		self.imageView?.frame = CGRect(x: 10, y: 12.5, width: 30, height: 30)
		
		self.textLabel?.frame = CGRect(x: ((self.imageView?.frame)?.maxX)! + 10, y: 12.5, width: width - ((self.imageView?.frame)!).maxX - 15, height: 30)

		self.divider.frame = CGRect(x: ((self.imageView?.frame)?.maxX)! + 10, y: height - 0.3, width: width, height: 0.3)
	}
}
