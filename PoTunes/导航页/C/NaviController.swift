//
//  NaviController.swift
//  破音万里
//
//  Created by Purchas on 2016/11/10.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit


class NaviController: UIViewController, MAMapViewDelegate, AMapSearchDelegate {
	
	enum TravelTypes: Int {
		
		case car = 0
		
		case walk
	
	}
	
	let backgroundView = UIImageView(image: UIImage(named: "outtake_mid"))
	
	var mapView: MAMapView?

    override func viewDidLoad() {
		
        super.viewDidLoad()
		
		backgroundView.frame = self.view.bounds
		
		self.view.addSubview(backgroundView)
		
		AMapServices.shared().apiKey = "62443358a250ee522aba69dfa3c1d247"
		
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		
		super.viewWillDisappear(animated)
		
		self.clearMapView()
		
	}
	
	
	func initialSubviews() {
		
		
		
	}
	
	func clearMapView() {
		
		
		
	}

	
}
