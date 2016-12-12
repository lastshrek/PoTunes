//
//  NaviController.swift
//  破音万里
//
//  Created by Purchas on 2016/11/10.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit
import PKHUD

class NaviController: UIViewController, MAMapViewDelegate, AMapSearchDelegate {
	
	enum TravelTypes: Int {
		
		case car = 0
		
		case walk
	
	}
	
	let backgroundView = UIImageView(image: UIImage(named: "outtake_mid"))
	
	let routeSeletcion = Routes()
	
	let width = UIScreen.main.bounds.size.width
	
	var mapView = MAMapView()
	
	var annotations = [MAPointAnnotation]()
	
	var driveManager: AMapNaviDriveManager!


    override func viewDidLoad() {
		
        super.viewDidLoad()
		
		backgroundView.frame = self.view.bounds
		
		self.view.addSubview(backgroundView)
		
		AMapServices.shared().apiKey = "62443358a250ee522aba69dfa3c1d247"
		
		initRoutesSelection()
		
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		
		super.viewWillDisappear(animated)
		
		clearMapView()
		
	}
	
	func initRoutesSelection() {
		
		routeSeletcion.frame = CGRect(x: 10, y: 200, width: width - 20, height: 130)
		
		routeSeletcion.start.text.delegate = self
		
		routeSeletcion.end.text.delegate = self
		
		routeSeletcion.switcher.addTarget(self, action: #selector(switchRoutes), for: .touchUpInside)
		
		self.view.addSubview(routeSeletcion)
		
	}
	
	func switchRoutes() {
		
		if routeSeletcion.start.text.text?.characters.count == 0 || routeSeletcion.end.text.text?.characters.count == 0 {
			
			HUD.flash(.labeledError(title: "请选择线路", subtitle: nil), delay: 0.7)
			
			return
			
		}
		
	}
	
	
	func initialSubviews() {
		
		
		
	}
	
	func initMapView() {
		
		mapView.frame = view.bounds
		
		mapView.delegate = self
		
		view.addSubview(mapView)
		
	}
	
	func clearMapView() {
		
		mapView.showsUserLocation = false
		
		mapView.removeAnnotations(annotations)
		
		mapView.removeOverlays(mapView.overlays)
		
		mapView.delegate = nil
		
		mapView.showsUserLocation = true
		
	}
	
	func initDriveManager() {
		
		driveManager = AMapNaviDriveManager()
		
		driveManager.delegate = self
	
	}
	
}

extension NaviController: UITextFieldDelegate, MapControllerDelegate {
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		
		textField.endEditing(true)
		
		let mapController = MapController()
		
		mapController.delegate = self
		
		mapController.title = textField.text
		
		mapController.view.tag = textField.tag
		
		self.navigationController?.pushViewController(mapController, animated: true)
		
	}
	
	func mapController(didClickTheAnnotationBySending destinationLocation: CLLocationCoordinate2D, destinationTitle: String, userlocation: CLLocationCoordinate2D) {
		
		debugPrint(destinationTitle)
		
		routeSeletcion.end.text.text = destinationTitle
	}
	
	func mapController(didClickTheAnnotationBySendingCustomUserLocation userlocation: CLLocationCoordinate2D, title: String) {
		debugPrint(title)
		
		routeSeletcion.start.text.text = title
	}
	
}

extension NaviController: AMapNaviDriveManagerDelegate {
	
	func driveManager(_ driveManager: AMapNaviDriveManager, error: Error) {
		let error = error as NSError
		NSLog("error:{%d - %@}", error.code, error.localizedDescription)
	}
	
	func driveManager(onCalculateRouteSuccess driveManager: AMapNaviDriveManager) {
		NSLog("CalculateRouteSuccess")
		
		//算路成功后显示路径
		showNaviRoutes()
	}
	
	func showNaviRoutes() {
		
//		guard let allRoutes = driveManager.naviRoutes else {
//			return
//		}
		
//		mapView.removeOverlays(mapView.overlays)
//		routeIndicatorInfoArray.removeAll()
//		
//		//将路径显示到地图上
//		for (aNumber, aRoute) in allRoutes {
//			
//			//添加路径Polyline
//			var coords = [CLLocationCoordinate2D]()
//			for coordinate in aRoute.routeCoordinates {
//				coords.append(CLLocationCoordinate2D(latitude: Double(coordinate.latitude), longitude: Double(coordinate.longitude)))
//			}
//			
//			let polyline = MAPolyline(coordinates: &coords, count: UInt(aRoute.routeCoordinates.count))!
//			let selectablePolyline = SelectableOverlay(aOverlay: polyline)
//			selectablePolyline.routeID = Int(aNumber)
//			
//			mapView.add(selectablePolyline)
//			
//			//更新CollectonView的信息
//			let title = String(format: "路径ID:%d | 路径计算策略:%d", Int(aNumber), preferenceView.strategy(isMultiple: isMultipleRoutePlan).rawValue)
//			let subtitle = String(format: "长度:%d米 | 预估时间:%d秒 | 分段数:%d", aRoute.routeLength, aRoute.routeTime, aRoute.routeSegments.count)
//			let info = RouteCollectionViewInfo(routeID: Int(aNumber), title: title, subTitle: subtitle)
//			
//			routeIndicatorInfoArray.append(info)
//		}
//		
//		mapView.showAnnotations(mapView.annotations, animated: false)
//		routeIndicatorView.reloadData()
//		
//		if let first = routeIndicatorInfoArray.first {
//			selectNaviRouteWithID(routeID: first.routeID)
//		}
	}
	
	func driveManager(_ driveManager: AMapNaviDriveManager, onCalculateRouteFailure error: Error) {
		let error = error as NSError
		NSLog("CalculateRouteFailure:{%d - %@}", error.code, error.localizedDescription)
	}
	
	func driveManager(_ driveManager: AMapNaviDriveManager, didStartNavi naviMode: AMapNaviMode) {
		NSLog("didStartNavi");
	}
	
	func driveManagerNeedRecalculateRoute(forYaw driveManager: AMapNaviDriveManager) {
		NSLog("needRecalculateRouteForYaw");
	}
	
	func driveManagerNeedRecalculateRoute(forTrafficJam driveManager: AMapNaviDriveManager) {
		NSLog("needRecalculateRouteForTrafficJam");
	}
	
	func driveManager(_ driveManager: AMapNaviDriveManager, onArrivedWayPoint wayPointIndex: Int32) {
		NSLog("ArrivedWayPoint:\(wayPointIndex)");
	}
	
	func driveManager(_ driveManager: AMapNaviDriveManager, playNaviSound soundString: String, soundStringType: AMapNaviSoundType) {
		NSLog("playNaviSoundString:{%d:%@}", soundStringType.rawValue, soundString);
	}
	
	func driveManagerDidEndEmulatorNavi(_ driveManager: AMapNaviDriveManager) {
		NSLog("didEndEmulatorNavi");
	}
	
	func driveManager(onArrivedDestination driveManager: AMapNaviDriveManager) {
		NSLog("onArrivedDestination");
	}

}
