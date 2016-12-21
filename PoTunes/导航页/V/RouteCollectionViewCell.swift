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
	var title: String
	var subTitle: String
}

class RouteCollectionViewCell: UICollectionViewCell {
	private let routeCellLeftMargin: CGFloat = 10
	private let routeCellTopMargin: CGFloat = 3
	
	private let titleLabel = UILabel()
	private let subtitleLabel = UILabel()
	private let prevImageView = UIImageView(image: UIImage(named: "leftArrow"))
	private let nextImageView = UIImageView(image: UIImage(named: "rightArrow"))
	
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
			titleLabel.text = info?.title
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
		shouldShowNextIndicator = false;
		shouldShowPrevIndicator = false;
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
		
		titleLabel.frame = CGRect(x: routeCellLeftMargin * 2 + prevImageView.frame.width, y: routeCellTopMargin, width: labelWidth, height: 32)
		titleLabel.numberOfLines = 2
		titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
		contentView.addSubview(titleLabel)
		
		subtitleLabel.frame = CGRect(x: routeCellLeftMargin * 2 + prevImageView.frame.width, y: titleLabel.frame.maxY, width: labelWidth, height: 20)
		subtitleLabel.font = UIFont.boldSystemFont(ofSize: 12)
		contentView.addSubview(subtitleLabel)
	}

}
