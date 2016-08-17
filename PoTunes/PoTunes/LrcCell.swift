//
//  LrcCell.swift
//  破音万里
//
//  Created by Purchas on 16/8/16.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class LrcCell: UITableViewCell {
	var lrcLine: LrcLine? {
		didSet {
			guard let `lrcLine` = lrcLine else { return }
			self.textLabel?.text = lrcLine.lyrics as? String
		}
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.backgroundColor = .clearColor()
		self.selectionStyle = .None
		self.textLabel?.textColor = .grayColor()
		self.textLabel?.lineBreakMode = .ByWordWrapping
		self.textLabel?.textAlignment = .Center
		self.textLabel?.font = UIFont(name: "BebasNeue", size: 13)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	override func layoutSubviews() {
		super.layoutSubviews()
		self.textLabel?.frame = CGRectMake(0, self.bounds.size.height * 0.1, self.bounds.size.width, self.bounds.size.height * 0.8)
	}
}
