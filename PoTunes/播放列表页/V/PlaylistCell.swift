//
//  PlaylistCell.swift
//  破音万里
//
//  Created by Purchas on 2016/11/9.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class PlaylistCell: UITableViewCell {

    var foregroundView: UIView?

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        imageView?.contentMode = .scaleAspectFit
        backgroundColor = UIColor.clear
        // 前景
        foregroundView = UIView().then({
            $0.backgroundColor = UIColor.black
            $0.alpha = 0.4
            contentView.addSubview($0)
        })
        bringSubview(toFront: self.textLabel!)
        selectionStyle = .none
        textLabel?.textAlignment = .center
        textLabel?.textColor = UIColor.white
        textLabel?.font = UIFont(name: "BebasNeue", size: 18)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = self.bounds
        imageView?.frame = self.bounds
        textLabel?.frame = self.bounds;
        foregroundView?.frame = self.bounds
    }
}



