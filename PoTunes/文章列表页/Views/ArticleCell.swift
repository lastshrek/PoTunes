//
//  ArticleCell.swift
//  破音万里
//
//  Created by Purchas on 16/8/22.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit



class ArticleCell: FoldingCell {

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		containerView = createContainerView()
		foregroundView = createForegroundView()
		
		// super class method configure views
		commonInit()
	}
	
	required internal init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func animationDuration(_ itemIndex: NSInteger, type: AnimationType) -> TimeInterval {
  
		// durations count equal it itemCount
		let durations = [0.33, 0.26, 0.26] // timing animation for each view
		return durations[itemIndex]
	}
}


extension ArticleCell {
	
	fileprivate func createForegroundView() -> RotatedView {
		let foregroundView = Init(RotatedView(frame: .zero)) {
			$0.backgroundColor = .red()
			$0.translatesAutoresizingMaskIntoConstraints = false
		}
		
		contentView.addSubview(foregroundView)
		
		// add constraints
		foregroundView <- [
			Height(75),
			Left(0),
			Right(0),
		]
		
		// add identifier
		let top = (foregroundView <- [Top(0)]).first
		top?.identifier = "ForegroundViewTop"

		foregroundView.layoutIfNeeded()
		
		return foregroundView
	}
	
	fileprivate func createContainerView() -> UIView {
		let containerView = Init(UIView(frame: .zero)) {
			$0.backgroundColor = .green()
			$0.translatesAutoresizingMaskIntoConstraints = false
		}
		
		contentView.addSubview(containerView)
		
		// add constraints
		containerView <- [
			Height(CGFloat(75 * itemCount)),
			Left(0),
			Right(0),
		]
		
		// add identifier
		let top = (containerView <- [Top(8)]).first
		top?.identifier = "ContainerViewTop"
		
		containerView.layoutIfNeeded()
		
		return containerView
	}
}
