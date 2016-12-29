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
			
			self.lyricLabel?.text = lrcLine.lyrics
	
		}
	
	}
	
	var lyricLabel: LrcLabel?
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
	
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		self.backgroundColor = UIColor.clear
		
		self.selectionStyle = .none
		
		self.lyricLabel = LrcLabel()
		
		self.lyricLabel?.textColor = UIColor.gray
		
		self.lyricLabel?.lineBreakMode = .byWordWrapping
		
		self.lyricLabel?.textAlignment = .center
		
		self.lyricLabel?.numberOfLines = 0
		
		self.lyricLabel?.font = UIFont(name: "BebasNeue", size: 13)
		
		self.contentView.addSubview(self.lyricLabel!)
	
	}
	
	
	required init?(coder aDecoder: NSCoder) {
	
		fatalError("init(coder:) has not been implemented")
	
	}
	
	override func layoutSubviews() {
	
		super.layoutSubviews()
		
		self.lyricLabel?.frame = CGRect(x: 0, y: self.bounds.size.height * 0.1, width: self.bounds.size.width, height: self.bounds.size.height * 0.8)
	
	}
}
