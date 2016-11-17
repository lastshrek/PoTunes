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
			self.textLabel?.text = lrcLine.lyrics
		}
	}
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.backgroundColor = UIColor.clear
		self.selectionStyle = .none
		self.textLabel?.textColor = UIColor.gray
		self.textLabel?.lineBreakMode = .byWordWrapping
		self.textLabel?.textAlignment = .center
		self.textLabel?.font = UIFont(name: "BebasNeue", size: 13)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	override func layoutSubviews() {
		super.layoutSubviews()
		self.textLabel?.frame = CGRect(x: 0, y: self.bounds.size.height * 0.1, width: self.bounds.size.width, height: self.bounds.size.height * 0.8)
	}
}
