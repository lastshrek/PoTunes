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
	
	var lyricLabel: UILabel?
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		backgroundColor = UIColor.clear
		selectionStyle = .none
		lyricLabel = UILabel()
		lyricLabel?.textColor = UIColor.gray
		lyricLabel?.lineBreakMode = .byWordWrapping
		lyricLabel?.textAlignment = .center
		lyricLabel?.numberOfLines = 0
		lyricLabel?.font = UIFont(name: "BebasNeue", size: 13)
		contentView.addSubview(self.lyricLabel!)
	}
	
	
	required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	
	override func layoutSubviews() {
	
		super.layoutSubviews()
		
		self.lyricLabel?.frame = CGRect(x: 0, y: self.bounds.size.height * 0.1, width: self.bounds.size.width, height: self.bounds.size.height * 0.8)
	
	}
}
