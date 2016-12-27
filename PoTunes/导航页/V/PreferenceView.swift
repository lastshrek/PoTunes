//
//  PreferenceView.swift
//  破音万里
//
//  Created by Purchas on 2016/12/21.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class PreferenceView: UIView {
	
	private var avoidCongestion: UIButton!
	private var avoidCost: UIButton!
	private var avoidHighway: UIButton!
	private var prioritiseHighway: UIButton!
	
	//MARK: Life Cycle
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		buildPreferenceView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	public func strategy(isMultiple: Bool) -> AMapNaviDrivingStrategy {
		return ConvertDrivingPreferenceToDrivingStrategy(isMultiple,
		                                                 true,
		                                                 false,
		                                                 false,
		                                                 true)
	}
	
	private func buildPreferenceView() {
		let singleWidth = (bounds.width - 50.0) / 4.0
		
		avoidCongestion = buttonForTitle("躲避拥堵")
		avoidCongestion.addTarget(self, action: #selector(self.avoidCongestionAction(sender:)), for: .touchUpInside)
		avoidCongestion.frame = CGRect(x: 10, y: 0, width: singleWidth, height: bounds.height)
		addSubview(avoidCongestion)
		
		avoidCost = buttonForTitle("避免收费")
		avoidCost.addTarget(self, action: #selector(self.avoidCostAction(sender:)), for: .touchUpInside)
		avoidCost.frame = CGRect(x: 20 + singleWidth, y: 0, width: singleWidth, height: bounds.height)
		addSubview(avoidCost)
		
		avoidHighway = buttonForTitle("不走高速")
		avoidHighway.addTarget(self, action: #selector(self.avoidHighwayAction(sender:)), for: .touchUpInside)
		avoidHighway.frame = CGRect(x: 30 + singleWidth * 2, y: 0, width: singleWidth, height: bounds.height)
		addSubview(avoidHighway)
		
		prioritiseHighway = buttonForTitle("高速优先")
		prioritiseHighway.addTarget(self, action: #selector(self.prioritiseHighwayAction(sender:)), for: .touchUpInside)
		prioritiseHighway.frame = CGRect(x: 40 + singleWidth * 3, y: 0, width: singleWidth, height: bounds.height)
		addSubview(prioritiseHighway)
	}
	
	func avoidCongestionAction(sender: UIButton) {
		changeButtonState(sender, selected: !sender.isSelected)
	}
	
	func avoidCostAction(sender: UIButton) {
		changeButtonState(sender, selected: !sender.isSelected)
		
		if sender.isSelected {
			changeButtonState(prioritiseHighway, selected: false)
		}
	}
	
	func avoidHighwayAction(sender: UIButton) {
		changeButtonState(sender, selected: !sender.isSelected)
		
		if sender.isSelected {
			changeButtonState(prioritiseHighway, selected: false)
		}
	}
	
	func prioritiseHighwayAction(sender: UIButton) {
		changeButtonState(sender, selected: !sender.isSelected)
		
		if sender.isSelected {
			changeButtonState(avoidCost, selected: false)
			changeButtonState(avoidHighway, selected: false)
		}
	}
	
	private func buttonForTitle(_ title: String) -> UIButton {
		let reBtn = UIButton(type: .custom)
		
		reBtn.layer.borderColor = UIColor.lightGray.cgColor
		reBtn.layer.borderWidth = 1.0
		reBtn.layer.cornerRadius = 5
		
		reBtn.bounds = CGRect(x: 0, y: 0, width: 80, height: 30)
		reBtn.setTitle(title, for: .normal)
		reBtn.setTitleColor(UIColor.black, for: .normal)
		reBtn.setTitleColor(UIColor.red, for: .selected)
		reBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
		
		return reBtn
	}
	
	private func changeButtonState(_ button: UIButton, selected: Bool) {
		button.isSelected = selected
		button.layer.borderColor = button.isSelected ? UIColor.red.cgColor : UIColor.lightGray.cgColor
	}
	
}

