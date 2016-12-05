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
	
	let routeSeletcion = Routes()
	
	let width = UIScreen.main.bounds.size.width
	
	var mapView: MAMapView?

    override func viewDidLoad() {
		
        super.viewDidLoad()
		
		backgroundView.frame = self.view.bounds
		
		self.view.addSubview(backgroundView)
		
		AMapServices.shared().apiKey = "62443358a250ee522aba69dfa3c1d247"
		
		initRoutesSelection()
		
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		
		super.viewWillDisappear(animated)
		
		self.clearMapView()
		
	}
	
	func initRoutesSelection() {
		
		routeSeletcion.frame = CGRect(x: 10, y: 200, width: width - 20, height: 130)
		
		routeSeletcion.start.text.delegate = self
		
		routeSeletcion.end.text.delegate = self
		
		self.view.addSubview(routeSeletcion)
		
	}
	
	
	func initialSubviews() {
		
		
		
	}
	
	func clearMapView() {
		
		
		
	}
	
}

extension NaviController: UITextFieldDelegate {
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		debugPrint("123")
	}
	
}
