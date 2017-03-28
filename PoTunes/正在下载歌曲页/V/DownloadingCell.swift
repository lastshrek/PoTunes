//
//  DownloadingCell.swift
//  破音万里
//
//  Created by Purchas on 2016/11/26.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit
import LDProgressView

class DownloadingCell: UITableViewCell {
	let progressView = M13ProgressViewBar()
		
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
		self.backgroundColor = UIColor.white
		self.textLabel?.textColor = UIColor.colorByRGB(red: 224, green: 0, blue: 81, alpha: 0.8)
		self.textLabel?.textAlignment = .left
		self.textLabel?.font = UIFont(name: "BebasNeue", size: 14)
		self.textLabel?.adjustsFontSizeToFitWidth = true
		progressView.setProgress(0.5, animated: true)
		progressView.isHidden = true
		contentView.addSubview(progressView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		let width = UIScreen.main.bounds.size.width
		let height = self.frame.size.height
		progressView.frame = CGRect(x: 0, y: height - 0.3, width: width, height: 0.3)
	}
}
