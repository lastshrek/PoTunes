//
//  DownloadedCellTableViewCell.swift
//  破音万里
//
//  Created by Purchas on 2016/11/10.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class DownloadedCell:  UITableViewCell {
	
	let divider = UIView().then({
		// 分割线
		$0.backgroundColor = UIColor.lightGray
	})
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		imageView?.contentMode = .scaleAspectFit
		textLabel?.textAlignment = .left
		textLabel?.adjustsFontSizeToFitWidth = true
		textLabel?.textColor = UIColor.colorByRGB(red: 17, green: 133, blue: 117, alpha: 0.8)
		textLabel?.font = UIFont(name: "BebasNeue", size: 18)
		addSubview(divider)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		let width = self.bounds.size.width
		let height = self.bounds.size.height
		imageView?.frame = CGRect(x: 10, y: 12.5, width: 30, height: 30)
		textLabel?.frame = CGRect(x: ((self.imageView?.frame)?.maxX)! + 10, y: 12.5, width: width - ((self.imageView?.frame)!).maxX - 15, height: 30)
		divider.frame = CGRect(x: ((self.imageView?.frame)?.maxX)! + 10, y: height - 0.3, width: width, height: 0.3)
	}
}
