//
//  DrivingCalculateController.swift
//  破音万里
//
//  Created by Purchas on 2016/12/21.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit
import PKHUD

protocol DrivingCalculateControllerDelegate: class {
	
	func drivingCalculateController(manager: AMapNaviDriveManager, controller: DrivingCalculateController)
	
}

class DrivingCalculateController: UIViewController, AMapNaviDriveManagerDelegate, UICollectionViewDelegateFlowLayout {
	
	let backgroundView = UIImageView(image: UIImage(named: "outtake_mid"))
	
	let routePlanInfoViewHeight: CGFloat = 130.0
	
	let routeIndicatorViewHeight: CGFloat = 64.0
	
	let collectionCellIdentifier = "kCollectionCellIdentifier"
	
	var mapView: MAMapView!
	
	var driverManager: AMapNaviDriveManager?
		
	var startPoint: AMapNaviPoint?
	
	var endPoint: AMapNaviPoint?
	
	var routeIndicatorInfoArray = [RouteCollectionViewInfo]()
	
	var routeIndicatorView: UICollectionView!
	
	var preferenceView: PreferenceView!
	
	weak var delegate: DrivingCalculateControllerDelegate?
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		backgroundView.frame = self.view.bounds
		
		self.view.addSubview(backgroundView)

		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)
		
		view.backgroundColor = UIColor.white
		
		initMapView()
		
		initDriveManager()
		
		configSubview()
		
		initRouteIndicatorView()
		
		HUD.show(.systemActivity)
		
		addAnnotations()
	}
	
	// MARK: - Initalization
	func initMapView() {
		
		mapView = MAMapView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height - routePlanInfoViewHeight))
		
		mapView.delegate = self
		
		view.addSubview(mapView)
	
	}
	
	func initDriveManager() {
		
		driverManager = AMapNaviDriveManager()
		
		driverManager?.delegate = self
		
		driverManager?.allowsBackgroundLocationUpdates = true
		
		driverManager?.pausesLocationUpdatesAutomatically = false
		
	}
	
	func initRouteIndicatorView() {
		
		let layout = UICollectionViewFlowLayout()
		
		layout.scrollDirection = .horizontal
		
		routeIndicatorView = UICollectionView(frame: CGRect(x: 0, y: view.bounds.size.height - routeIndicatorViewHeight - 64, width: view.bounds.width, height: routeIndicatorViewHeight), collectionViewLayout: layout)
		
		guard let routeIndicatorView = routeIndicatorView else {
			
			return
		
		}
		
		routeIndicatorView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
		
		routeIndicatorView.backgroundColor = UIColor.white
		
		routeIndicatorView.isPagingEnabled = true
		
		routeIndicatorView.showsVerticalScrollIndicator = false
		
		routeIndicatorView.showsHorizontalScrollIndicator = false
		
		routeIndicatorView.delegate = self
		
		routeIndicatorView.dataSource = self
		
		routeIndicatorView.register(RouteCollectionViewCell.self, forCellWithReuseIdentifier: collectionCellIdentifier)
		
		view.addSubview(routeIndicatorView)
	}
	
	func addAnnotations() {
		
		let beginAnnotation = NaviPointAnnotation()
		
		beginAnnotation.coordinate = CLLocationCoordinate2D(latitude: Double((startPoint?.latitude)!), longitude: Double((startPoint?.longitude)!))
		
		beginAnnotation.title = "起始点"
		
		beginAnnotation.naviPointType = .start
		
		mapView.addAnnotation(beginAnnotation)
		
		let endAnnotation = NaviPointAnnotation()
		
		endAnnotation.coordinate = CLLocationCoordinate2D(latitude: Double((endPoint?.latitude)!), longitude: Double((endPoint?.longitude)!))
		
		endAnnotation.title = "终点"
		
		endAnnotation.naviPointType = .end
		
		mapView.addAnnotation(endAnnotation)
	}
	
	//MARK: - Handle Navi Routes
	
	func showNaviRoutes() {
		
		guard let allRoutes = driverManager?.naviRoutes else {
			
			return
		
		}
		
		mapView.removeOverlays(mapView.overlays)
		
		routeIndicatorInfoArray.removeAll()
		
		for (aNumber, aRoute) in allRoutes {
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
			let subtitle = "长度: \(self.toKiloMeters(route: aRoute.routeLength)) | 预估时间:\(self.toHours(route: aRoute.routeTime))\r点击出发"
			
			let info = RouteCollectionViewInfo(routeID: Int(aNumber), subTitle: subtitle)
			
			routeIndicatorInfoArray.append(info)
		
		}
		
		mapView.showAnnotations(mapView.annotations, animated: false)
		
		routeIndicatorView.reloadData()
		
		if let first = routeIndicatorInfoArray.first {
		
			selectNaviRouteWithID(routeID: first.routeID)
		
		}
	
	}
	

	func selectNaviRouteWithID(routeID: Int) {
		//在开始导航前进行路径选择
		if (driverManager?.selectNaviRoute(withRouteID: routeID))! {
		
			selecteOverlayWithRouteID(routeID: routeID)
		
		} else {
		
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
				
				} else {
					
					selectableOverlay.selected = false
					
					overlayRenderer.fillColor = selectableOverlay.reguarColor
					
					overlayRenderer.strokeColor = selectableOverlay.reguarColor
				}
				
				overlayRenderer.glRender()
			}
		}
	}
	
	//MARK: - SubViews
	
	func configSubview() {
		
		preferenceView = PreferenceView(frame: CGRect(x: 0, y: 60, width: view.bounds.width, height: 30))
		
		preferenceView.isHidden = true
		
		view.addSubview(preferenceView)
		
		//进行多路径规划
		
		driverManager?.calculateDriveRoute(withStart: [startPoint!],
		                                   end: [endPoint!],
		                                   wayPoints: nil,
		                                   drivingStrategy: preferenceView.strategy(isMultiple: true))
		
	}
	
	private func buttonForTitle(_ title: String) -> UIButton {
		
		let reBtn = UIButton(type: .custom)
		
		reBtn.layer.borderColor = UIColor.lightGray.cgColor
		
		reBtn.layer.borderWidth = 1.0
		
		reBtn.layer.cornerRadius = 5
		
		reBtn.bounds = CGRect(x: 0, y: 0, width: 80, height: 30)
		
		reBtn.setTitle(title, for: .normal)
		
		reBtn.setTitleColor(UIColor.black, for: .normal)
		
		reBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
		
		return reBtn
	}
	
	//MARK: - AMapNaviDriveManager Delegate
	
	func driveManager(_ driveManager: AMapNaviDriveManager, error: Error) {
		
		HUD.flash(.labeledError(title: "路径规划失败", subtitle: nil), delay: 0.6)
		
		let error = error as NSError
		
		debugPrint("error: \(error.code), \(error.localizedDescription)")
	
	}
	
	func driveManager(onCalculateRouteSuccess driveManager: AMapNaviDriveManager) {
		
		HUD.hide()
		
		debugPrint("CalculateRouteSuccess")
		
		showNaviRoutes()
	}
	
	func driveManager(_ driveManager: AMapNaviDriveManager, onCalculateRouteFailure error: Error) {
		
		let error = error as NSError
		
		debugPrint("error: \(error.code), \(error.localizedDescription)")
	
	}

	
	//MARK: - UICollectionViewDelegateFlowLayout
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		return CGSize(width: collectionView.bounds.width - 10, height: collectionView.bounds.height - 5)
	
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
	
		return UIEdgeInsetsMake(0, 5, 5, 5)
	
	}
}

//MARK: - UICollectionViewDataSource
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
	
}

//MARK: - UICollectionViewDelegate
extension DrivingCalculateController: UICollectionViewDelegate {
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		_ = navigationController?.popToRootViewController(animated: true)
		
		self.delegate?.drivingCalculateController(manager: driverManager!, controller: self)
		
	}
	
	func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		
		return true
		
	}
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		
		guard let cell = routeIndicatorView.visibleCells.first as? RouteCollectionViewCell else {
			
			return
			
		}
		
		if let info = cell.info {
			
			selectNaviRouteWithID(routeID: info.routeID)
			
		}
	}
	
}

//MARK: - MAMapView Delegate
extension DrivingCalculateController: MAMapViewDelegate {
	
	func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
		
		if annotation is NaviPointAnnotation {
			
			let annotationIdentifier = "NaviPointAnnotationIdentifier"
			
			var pointAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MAPinAnnotationView
			
			if pointAnnotationView == nil {
				
				pointAnnotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
				
			}
			
			pointAnnotationView?.animatesDrop = false
			
			pointAnnotationView?.canShowCallout = true
			
			pointAnnotationView?.isDraggable = false
			
			let annotation = annotation as! NaviPointAnnotation
			
			if annotation.naviPointType == .start {
				
				pointAnnotationView?.pinColor = .green
				
			} else if annotation.naviPointType == .end {
				
				pointAnnotationView?.pinColor = .red
				
			}
			
			return pointAnnotationView
		}
		return nil
	}
	
	func mapView(_ mapView: MAMapView!, rendererFor overlay: MAOverlay!) -> MAOverlayRenderer! {
		
		if overlay is SelectableOverlay {
			
			let selectableOverlay = overlay as! SelectableOverlay
			
			
			let polylineRenderer = MAPolylineRenderer(overlay: selectableOverlay.overlay)
			
			polylineRenderer?.lineWidth = 8.0
			
			polylineRenderer?.strokeColor = selectableOverlay.selected ? selectableOverlay.selectedColor : selectableOverlay.reguarColor
			
			return polylineRenderer
		}
		
		return nil
	}

}


