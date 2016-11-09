//
//  PlaylistCell.swift
//  破音万里
//
//  Created by Purchas on 2016/11/9.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class PlaylistCell: UITableViewCell {
	
	var foregroundView: UIView?
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.imageView?.contentMode = .scaleAspectFit
		self.backgroundColor = UIColor.clear
		// 前景
		let foregroundView = UIView()
		foregroundView.backgroundColor = UIColor.black
		foregroundView.alpha = 0.4
		self.foregroundView = foregroundView
		self.contentView.addSubview(foregroundView)
		self.bringSubview(toFront: self.textLabel!)
		self.selectionStyle = .none
		self.textLabel?.textAlignment = .center
		self.textLabel?.textColor = UIColor.white
		self.textLabel?.font = UIFont(name: "BebasNeue", size: 18)

	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.contentView.frame = self.bounds
		self.imageView?.frame = self.bounds
		self.textLabel?.frame = self.bounds;
		self.foregroundView?.frame = self.bounds
	}

}
