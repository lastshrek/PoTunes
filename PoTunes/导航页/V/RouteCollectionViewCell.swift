//
//  RouteCollectionViewCell.swift
//  破音万里
//
//  Created by Purchas on 2016/12/21.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

struct RouteCollectionViewInfo {
	var routeID: Int
	var subTitle: String
}

class RouteCollectionViewCell: UICollectionViewCell {
	
	private let routeCellLeftMargin: CGFloat = 10
	private let routeCellTopMargin: CGFloat = 3
	private let subtitleLabel = UILabel()
	private let prevImageView = UIImageView(image: UIImage.fontAwesomeIcon(name: .handOLeft, textColor: UIColor.black, size: CGSize(width: 30, height: 30)))
	private let nextImageView = UIImageView(image: UIImage.fontAwesomeIcon(name: .handORight, textColor: UIColor.black, size: CGSize(width: 30, height: 30)))
	
	public var shouldShowPrevIndicator: Bool {
		didSet {
			prevImageView.isHidden = !shouldShowPrevIndicator
		}
	}
	
	public var shouldShowNextIndicator: Bool {
		didSet {
			nextImageView.isHidden = !shouldShowNextIndicator
		}
	}
	
	public var info: RouteCollectionViewInfo? {
		didSet {
			subtitleLabel.text = info?.subTitle
		}
	}
	
	override init(frame: CGRect) {
		shouldShowNextIndicator = false;
		shouldShowPrevIndicator = false;
		super.init(frame: frame)
		configSubviews()
	}
	
	required init?(coder aDecoder: NSCoder) {
		shouldShowNextIndicator = false
		shouldShowPrevIndicator = false
		super.init(coder: aDecoder)
		configSubviews()
	}
	
	private func configSubviews() {
		backgroundColor = UIColor.white
		contentView.clipsToBounds = true
		prevImageView.center = CGPoint(x: routeCellLeftMargin + prevImageView.bounds.width / 2.0, y: frame.height / 2.0)
		prevImageView.isHidden = true
		contentView.addSubview(prevImageView)
		nextImageView.center = CGPoint(x: frame.width - routeCellLeftMargin - nextImageView.bounds.width / 2.0, y: frame.height / 2.0)
		nextImageView.isHidden = true
		contentView.addSubview(nextImageView)
		let labelWidth = frame.width - prevImageView.bounds.width * 2.0 - routeCellLeftMargin * 4.0
		subtitleLabel.frame = CGRect(x: routeCellLeftMargin * 2 + prevImageView.frame.width, y: 0, width: labelWidth, height: frame.height)
		subtitleLabel.font = UIFont.boldSystemFont(ofSize: 15)
		subtitleLabel.numberOfLines = 2
		contentView.addSubview(subtitleLabel)
	}

}
