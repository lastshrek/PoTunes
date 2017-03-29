//
//  DriveNaviViewController.swift
//  破音万里
//
//  Created by Purchas on 2016/12/26.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

protocol DriveNaviViewControllerDelegate: NSObjectProtocol {
    func driveNaviViewCloseButtonClicked()
    func driveNaviViewMoreButtonClicked()
}

class DriveNaviViewController: UIViewController, AMapNaviDriveViewDelegate, AMapNaviWalkViewDelegate {
	public var delegate: DriveNaviViewControllerDelegate?
	public var driveView = AMapNaviDriveView()
	//MARK: Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		configSubviews()
		driveView.frame = view.frame
		view.addSubview(driveView)
	}
		
	override func viewWillLayoutSubviews() {
		let interfaceOrientation = UIApplication.shared.statusBarOrientation
		
		if UIInterfaceOrientationIsPortrait(interfaceOrientation) {
			driveView.isLandscape = false
		} else if UIInterfaceOrientationIsLandscape(interfaceOrientation) {
			driveView.isLandscape = true
		}
	}
	

	
	private func configSubviews() {
		driveView.delegate = self
	}
	
	//MARK: DriveView Delegate
	func driveViewCloseButtonClicked(_ driveView: AMapNaviDriveView) {
		delegate?.driveNaviViewCloseButtonClicked()
	}
	
	func driveViewMoreButtonClicked(_ driveView: AMapNaviDriveView) {
		delegate?.driveNaviViewMoreButtonClicked()
	}
	
	func driveViewTrunIndicatorViewTapped(_ driveView: AMapNaviDriveView) {
		switch driveView.showMode {
		case .carPositionLocked:
			self.driveView.showMode = .normal
		case .normal:
			self.driveView.showMode = .overview
		case .overview:
			self.driveView.showMode = .carPositionLocked
		}
	}
	
	func driveView(_ driveView: AMapNaviDriveView, didChange showMode: AMapNaviDriveViewShowMode) {
		debugPrint("didChangeShowMode:%d", showMode.rawValue)
	}
}

