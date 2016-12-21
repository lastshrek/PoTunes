//
//  DrivingCalculateController.swift
//  破音万里
//
//  Created by Purchas on 2016/12/21.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class

DrivingCalculateController: UIViewController {
	
	var mapView: MAMapView!
	
	var startLocation: CLLocationCoordinate2D!
	
	var endLocation: CLLocationCoordinate2D!
	
	var startPoint: AMapNaviPoint?
	
	var endPoint: AMapNaviPoint?
	
	var routeIndicatorView: UICollectionView!
	
	let routePlanInfoViewHeight: CGFloat = 130.0
	
	let routeIndicatorViewHeight: CGFloat = 64.0
	
	let collectionCellIdentifier = "kCollectionCellIdentifier"
	
	var routeIndicatorInfoArray = [RouteCollectionViewInfo]()
	
	var driverManager = AMapNaviDriveManager()
	
	var preferenceView: PreferenceView!



    override func viewDidLoad() {
		
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.white
		
		initMapView()
		
		addAnnotations()
		
		initRouteIndicatorView()
		
		preferenceView = PreferenceView(frame: CGRect(x: 0, y: 60, width: view.bounds.width, height: 30))
		view.addSubview(preferenceView)

		initDriveManager()
		
    }
	
	func initMapView() {
		
		AMapServices.shared().apiKey = "62443358a250ee522aba69dfa3c1d247"
		
		mapView = MAMapView(frame: view.bounds)
		
		mapView.delegate = self
		
		view.addSubview(mapView)
		
	}

	func addAnnotations() {
		
		let beginAnnotation = NaviPointAnnotation()
		
		beginAnnotation.coordinate = CLLocationCoordinate2D(latitude: Double((startLocation?.latitude)!), longitude: Double((startLocation?.longitude)!))
		
		beginAnnotation.title = "起始点"
		
		beginAnnotation.naviPointType = .start
		
		mapView.addAnnotation(beginAnnotation)
		
		let endAnnotation = NaviPointAnnotation()
		
		endAnnotation.coordinate = CLLocationCoordinate2D(latitude: Double((endLocation?.latitude)!), longitude: Double((endLocation?.longitude)!))
		
		endAnnotation.title = "终点"
		
		endAnnotation.naviPointType = .end
		
		mapView.addAnnotation(endAnnotation)
		
	}
	
	func initRouteIndicatorView() {
		
		let layout = UICollectionViewFlowLayout()
		
		layout.scrollDirection = .horizontal
		
		routeIndicatorView = UICollectionView(frame: CGRect(x: 0, y: view.bounds.height - routeIndicatorViewHeight, width: view.bounds.width, height: routeIndicatorViewHeight), collectionViewLayout: layout)
		
		guard let routeIndicatorView = routeIndicatorView else {
			return
		}
		
		routeIndicatorView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
		
		routeIndicatorView.backgroundColor = UIColor.clear
		
		routeIndicatorView.isPagingEnabled = true
		
		routeIndicatorView.showsVerticalScrollIndicator = false
		
		routeIndicatorView.showsHorizontalScrollIndicator = false
		
		routeIndicatorView.delegate = self
		
		routeIndicatorView.dataSource = self
		
		routeIndicatorView.register(RouteCollectionViewCell.self, forCellWithReuseIdentifier: collectionCellIdentifier)
		
		view.addSubview(routeIndicatorView)
	}
	
	func initDriveManager() {
		
		driverManager.delegate = self
		
		driverManager.allowsBackgroundLocationUpdates = true
		
		driverManager.pausesLocationUpdatesAutomatically = false
		
		startPoint = AMapNaviPoint.location(withLatitude: CGFloat(startLocation.latitude), longitude: CGFloat(startLocation.longitude))
		
		endPoint = AMapNaviPoint.location(withLatitude: CGFloat(endLocation.latitude), longitude: CGFloat(endLocation.longitude))
		
		
		driverManager.calculateDriveRoute(withStart: [startPoint!],
		                                 end: [endPoint!],
		                                 wayPoints: nil,
		                                 drivingStrategy: preferenceView.strategy(isMultiple: true))
		
		
	}
	
}

extension DrivingCalculateController: MAMapViewDelegate {
	
	
	
}

extension DrivingCalculateController: UICollectionViewDelegate {
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
	}
	
	func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		guard let cell = routeIndicatorView.visibleCells.first as? RouteCollectionViewCell else {
			return;
		}
		
		if let info = cell.info {
			
		}
	}
	
}

extension DrivingCalculateController: UICollectionViewDataSource {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return routeIndicatorInfoArray.count
	}
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellIdentifier, for: indexPath) as! RouteCollectionViewCell
		cell.shouldShowPrevIndicator = (indexPath.row > 0 && indexPath.row < routeIndicatorInfoArray.count)
		cell.shouldShowNextIndicator = (indexPath.row >= 0 && indexPath.row < routeIndicatorInfoArray.count-1)
		cell.info = routeIndicatorInfoArray[indexPath.row]
		
		return cell
	}
	
	//MARK: - UICollectionViewDelegateFlowLayout
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: collectionView.bounds.width - 10, height: collectionView.bounds.height - 5)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsetsMake(0, 5, 5, 5)
	}
	
}

extension DrivingCalculateController: AMapNaviDriveManagerDelegate {
	
	func driveManager(_ driveManager: AMapNaviDriveManager, error: Error) {
		let error = error as NSError
		NSLog("error:{%d - %@}", error.code, error.localizedDescription)
	}
	
	func driveManager(onCalculateRouteSuccess driveManager: AMapNaviDriveManager) {
		debugPrint("CalculateRouteSuccess")
		
		showNaviRoutes()
	}
	
	func showNaviRoutes() {
		
		guard let allRoutes = driverManager.naviRoutes else {
			return
		}
		
		mapView.removeOverlays(mapView.overlays)
		
		routeIndicatorInfoArray.removeAll()
		
		//将路径显示到地图上
		for (aNumber, aRoute) in allRoutes {
			
			debugPrint(aNumber)
			//添加路径Polyline
			var coords = [CLLocationCoordinate2D]()
			
			for coordinate in aRoute.routeCoordinates {
				
				coords.append(CLLocationCoordinate2D(latitude: Double(coordinate.latitude), longitude: Double(coordinate.longitude)))
			
			}
			
			let polyline = MAPolyline(coordinates: &coords, count: UInt(aRoute.routeCoordinates.count))!
			
			let selectablePolyline = SelectableOverlay(aOverlay: polyline)
			
			selectablePolyline.routeID = Int(aNumber)
			
			mapView.add(selectablePolyline)
			
			//更新CollectonView的信息
			let title = String(format: "路径ID:%d | 路径计算策略:%d", Int(aNumber), preferenceView.strategy(isMultiple: true).rawValue)
			
			let subtitle = String(format: "长度:%d米 | 预估时间:%d秒 | 分段数:%d", aRoute.routeLength, aRoute.routeTime, aRoute.routeSegments.count)
			
			let info = RouteCollectionViewInfo(routeID: Int(aNumber), title: title, subTitle: subtitle)
			
			routeIndicatorInfoArray.append(info)
			
		}
		
		mapView.showAnnotations(mapView.annotations, animated: true)
		
		routeIndicatorView.reloadData()
		
		if let first = routeIndicatorInfoArray.first {
			
			selectNaviRouteWithID(routeID: first.routeID)
		
		}
		
		debugPrint(mapView.annotations)

	}
	
	func selectNaviRouteWithID(routeID: Int) {
		//在开始导航前进行路径选择
		if driverManager.selectNaviRoute(withRouteID: routeID) {
			
			selecteOverlayWithRouteID(routeID: routeID)
		
		}
		else {
		
			NSLog("路径选择失败!")
		
		}
	}
	
	func selecteOverlayWithRouteID(routeID: Int) {
		
		guard let allOverlays = mapView.overlays else {
		
			return
		
		}
		
		for (index, aOverlay) in allOverlays.enumerated() {
			
			if let selectableOverlay = aOverlay as? SelectableOverlay {
				
				guard let overlayRenderer = mapView.renderer(for: selectableOverlay) as? MAPolylineRenderer else {
					return
				}
				
				if selectableOverlay.routeID == routeID {
					
					selectableOverlay.selected = true
					
					overlayRenderer.fillColor = selectableOverlay.selectedColor
					
					overlayRenderer.strokeColor = selectableOverlay.selectedColor
					
					mapView.exchangeOverlay(at: UInt(index), withOverlayAt: UInt(allOverlays.count - 1))
				}
				else {
					selectableOverlay.selected = false
					
					overlayRenderer.fillColor = selectableOverlay.reguarColor
					overlayRenderer.strokeColor = selectableOverlay.reguarColor
				}
				
				overlayRenderer.glRender()
			}
		}
	}
	
	func driveManager(_ driveManager: AMapNaviDriveManager, onCalculateRouteFailure error: Error) {
		let error = error as NSError
		NSLog("CalculateRouteFailure:{%d - %@}", error.code, error.localizedDescription)
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
	
	
	func driveManager(onArrivedDestination driveManager: AMapNaviDriveManager) {
		NSLog("onArrivedDestination");
	}

	
}
