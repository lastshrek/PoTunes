//
//  DownloadedCellTableViewCell.swift
//  破音万里
//
//  Created by Purchas on 2016/11/10.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class DownloadedCell:  PlaylistCell {
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.textLabel?.font = UIFont(name: "BebasNeue", size: 18)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		let width = self.bounds.size.width
		let height = self.bounds.size.height
		self.contentView.frame = self.bounds
		self.imageView?.frame = CGRect(x: 10, y: 0, width: height, height: height)
		self.textLabel?.frame = CGRect(x: height + 15, y: 0, width: width - height - 15, height: height)
//		self.divider?.frame = CGRect(x: height + 15, y: 0, width: width - height - 15, height: 1)
	}
}
