//
//  TrackCell.swift
//  破音万里
//
//  Created by Purchas on 2016/11/13.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit
import FontAwesome_swift

class TrackCell: UITableViewCell {
	
	let divider: UIView = UIView()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
	
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
		
		self.imageView?.contentMode = .scaleAspectFit
		
		self.textLabel?.textAlignment = .left
		
		self.textLabel?.textColor = UIColor.colorByRGB(red: 224, green: 0, blue: 81, alpha: 0.8)
		
		self.textLabel?.font = UIFont(name: "BebasNeue", size: 18)
		
		self.detailTextLabel?.textColor = UIColor.colorByRGB(red: 224, green: 0, blue: 81, alpha: 0.8)
		
		self.detailTextLabel?.textAlignment = .left
		
		self.detailTextLabel?.font = UIFont(name: "BebasNeue", size: 12)
		
		// 分割线
		divider.backgroundColor = UIColor.lightGray
		
		self.addSubview(divider)
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		
		fatalError("init(coder:) has not been implemented")
	
	}
	
	override func layoutSubviews() {
		
		super.layoutSubviews()
		
		let width: CGFloat = self.frame.size.width
		
		let height: CGFloat = self.frame.size.height
		
		self.imageView?.frame = CGRect(x: 10, y: 3, width: height - 20, height: height - 6)
		
		self.textLabel?.frame = CGRect(x: ((self.imageView?.frame)?.maxX)! + 10, y: 5, width: width - ((self.imageView?.frame)!).maxX - 15, height: height * 0.6)
		
		self.detailTextLabel?.frame = CGRect(x: ((self.imageView?.frame)?.maxX)! + 10, y: height * 0.6, width: width - ((self.imageView?.frame)!).maxX - 15, height: height * 0.3)
		
		self.divider.frame = CGRect(x: ((self.imageView?.frame)?.maxX)! + 10, y: height - 0.3, width: width, height: 0.3)
		
	}

}
