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
	let playing: UIImageView = UIImageView(image: UIImage.fontAwesomeIcon(name: .volumeUp,
	                                                                      textColor: UIColor.colorByRGB(red: 225, green: 49, blue: 114, alpha: 1),
	                                                                      size: CGSize(width: 20, height: 20)))
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
		imageView?.contentMode = .scaleAspectFit
		textLabel?.textAlignment = .left
		textLabel?.adjustsFontSizeToFitWidth = true
		textLabel?.textColor = UIColor.colorByRGB(red: 224, green: 0, blue: 81, alpha: 0.8)
		textLabel?.font = UIFont(name: "BebasNeue", size: 18)
		detailTextLabel?.textColor = UIColor.colorByRGB(red: 224, green: 0, blue: 81, alpha: 0.8)
		detailTextLabel?.textAlignment = .left
		detailTextLabel?.font = UIFont(name: "BebasNeue", size: 12)
		detailTextLabel?.adjustsFontSizeToFitWidth = true
		// 分割线
		divider.backgroundColor = UIColor.lightGray
		accessoryView = playing
		accessoryView?.isHidden = true
		addSubview(divider)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()

		let width: CGFloat = self.frame.size.width
		let height: CGFloat = self.frame.size.height
		
		imageView?.frame = CGRect(x: 10, y: 3, width: height - 20, height: height - 6)
		textLabel?.frame = CGRect(x: ((self.imageView?.frame)?.maxX)! + 10, y: 5, width: width - ((self.imageView?.frame)!).maxX - 15, height: height * 0.6)
		detailTextLabel?.frame = CGRect(x: ((self.imageView?.frame)?.maxX)! + 10, y: height * 0.6, width: width - ((self.imageView?.frame)!).maxX - 15, height: height * 0.3)
		divider.frame = CGRect(x: ((self.imageView?.frame)?.maxX)! + 10, y: height - 0.3, width: width, height: 0.3)
	}
	
	@objc func refreshPlayingStatus () {
		
	}

}
