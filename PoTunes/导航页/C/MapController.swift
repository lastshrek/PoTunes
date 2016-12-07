//
//  MapController.swift
//  破音万里
//
//  Created by Purchas on 2016/12/6.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit
import PKHUD

protocol MapControllerDelegate: class {
	func mapController(didClickTheAnnotationAccessoryControlBySendingUserLocation userlocation:  CLLocationCoordinate2D, andDestinationLocation destinationLocation: CLLocationCoordinate2D, mapView: MAMapView, title: String, destinationTitle: String)
}

class MapController: UIViewController {
	
	weak var delegate: MapControllerDelegate?
	
	var mapView = MAMapView()
	
	
	var searchBar: UISearchBar?
	
	var naviInfo: UILabel?
	
	var search: AMapSearchAPI?
	
	lazy var tips: Array<AMapTip> = {[]}()
	
	var tableView: UITableView?
	
	// user location
	var userLocation: CLLocationCoordinate2D?
	
	// 目的地
	var selectedstartLocation: CLLocationCoordinate2D?
	
	var isSelected: Bool?
	
	var destinationLocation: CLLocationCoordinate2D?
	
	var destinationTitle: String?
	
	var annotations = [MAPointAnnotation]()

    override func viewDidLoad() {
		
		super.viewDidLoad()
		
		initMapView()
		
		initSearchBar()
		
		initTableView()
    }

	func initMapView() {
		
		AMapServices.shared().apiKey = "62443358a250ee522aba69dfa3c1d247"
		
		mapView.frame = view.bounds
				
		mapView.delegate = self
		
		mapView.userTrackingMode = .none
		
		self.view.addSubview(mapView)
		
		// initialize searchapi
		
		search = AMapSearchAPI()
		
		search?.delegate = self
		
		
	}

	
	override func viewDidAppear(_ animated: Bool) {
		
		super.viewDidAppear(animated)
		
		mapView.showsUserLocation = true
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		
		super.viewWillDisappear(animated)
		
		clearMapView()
		
	}
	
	func initSearchBar() {
		
		searchBar = UISearchBar.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44))
		
		searchBar?.barStyle = .black
		
		searchBar?.isTranslucent = false
		
		searchBar?.delegate = self
		
		searchBar?.placeholder = "请输入要查询的地点"
		
		searchBar?.keyboardType = .default
		
		self.view.addSubview(searchBar!)
		
	}
	
	func initTableView() {
		
		tableView = UITableView.init(frame: CGRect(x: 0, y: 44, width: self.view.bounds.size.width, height: self.view.bounds.size.height - 44))
		
		tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "tip")
		
		tableView?.delegate = self
		
		tableView?.dataSource = self
		
		tableView?.isHidden = true
		
		self.view.addSubview(tableView!)
		
	}
	
	func clearMapView() {
		
		mapView.showsUserLocation = false
		
		mapView.removeAnnotations(annotations)
		
		mapView.removeOverlays(mapView.overlays)
		
		mapView.delegate = nil
				
	}
	
}

extension MapController: UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		
		return 1
	
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return tips.count
	
	}
}

extension MapController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		var cell = tableView.dequeueReusableCell(withIdentifier: "tip")
		
		if cell == nil {
			
			cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "tip")
			
		}
		
		let tip: AMapTip = self.tips[indexPath.row]
		
		cell?.textLabel?.text = tip.name
		
		return cell!
		
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		let tip = tips[indexPath.row]
		
		if tip.location == nil {
			
			HUD.flash(.labeledError(title: "请输入相对精确的位置", subtitle: nil), delay: 0.7)
			
			return
			
		}
		
		let annotation = MAPointAnnotation()
		
		annotation.coordinate = CLLocationCoordinate2D(latitude:Double(tip.location.latitude), longitude: Double(tip.location.longitude))
		
		annotation.title = tip.name
		
		annotation.subtitle = tip.address
		
		annotations.append(annotation)
		
		showPOIAnnotations()
		
		tableView.isHidden = true
		
		searchBar?.endEditing(true)
		
	}
	
}

extension MapController: MAMapViewDelegate {

	
	func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
		
		if updatingLocation {
			
			self.userLocation = CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude)
			
			mapView.centerCoordinate = self.userLocation!
			
			mapView.setZoomLevel(16.1, animated: true)
			
		}
		
	}
	
	func mapView(_ mapView: MAMapView!, annotationView view: MAAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
		
		if view.annotation is MAPointAnnotation {
			
			let annotation = view.annotation
			
			if self.view.tag == 1 && self.isSelected == true {
				
				self.userLocation = CLLocationCoordinate2DMake((annotation?.coordinate.latitude)!, (annotation?.coordinate.longitude)!)
				
			}
			
			self.delegate?.mapController(didClickTheAnnotationAccessoryControlBySendingUserLocation: self.userLocation!, andDestinationLocation: self.destinationLocation!, mapView: self.mapView, title: self.title!, destinationTitle: self.destinationTitle!)
			
			self.navigationController!.popToRootViewController(animated: true)
			
		}
		
	}
	
	func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
		
		if annotation is MAPointAnnotation {
			
			let annotationIdentifier = "geoCellIdentifier"
			
			var poiAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MAPinAnnotationView
			
			if poiAnnotationView == nil {
				
				poiAnnotationView = MAPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
				
			}
			
			poiAnnotationView?.canShowCallout = true
			
			poiAnnotationView?.rightCalloutAccessoryView = UIButton.init(type: .contactAdd)
			
			return poiAnnotationView
			
			
		}
		
		return nil
	}
	
}

extension MapController: AMapSearchDelegate {
	
	// 地理编码回调
	func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
		
		let error = error as NSError
		
		debugPrint(error.localizedDescription)
		
	}
	
	
	func showPOIAnnotations() {
		
		mapView.addAnnotations(annotations)
		
		if annotations.count == 1 {
			
			mapView.centerCoordinate = (annotations.first?.coordinate)!
			
		} else {
			
			mapView.showAnnotations(annotations, animated: true)
			
		}
		
	}
	
	// 输入提示回调
	func onInputTipsSearchDone(_ request: AMapInputTipsSearchRequest!, response: AMapInputTipsSearchResponse!) {
		
		tips = Array(response.tips)
		
		tableView?.reloadData()
	}
	
}

extension MapController: UISearchBarDelegate {
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		
		let key = searchBar.text
		
		clearAndSearchGeocodeWithKey(key: key!)
		
		searchTipsWith(key: key!)
		
	}
	
	func clearAndSearchGeocodeWithKey(key: String) {
		
		clear()
		
		searchGeocodeWithKey(key: key)
		
	}
	
	// delete annotation
	func clear() {
		
		mapView.removeAnnotations(mapView.annotations)
		
	}
	
	/* 地理编码 搜索 */
	func searchGeocodeWithKey(key: String) {
		
		if key.characters.count == 0 { return }
		
		let geo = AMapGeocodeSearchRequest()
		
		geo.address = key
		
		search?.aMapGeocodeSearch(geo)
		
	}
	
	/* 输入提示 搜索.*/
	func searchTipsWith(key: String) {
		
		if key.characters.count == 0 { return }
		
		let tip = AMapInputTipsSearchRequest()
		
		tip.keywords = key
		
		search?.aMapInputTipsSearch(tip)
		
//		let request = AMapPOIAroundSearchRequest()
//		
//		if let userLocation = userLocation {
//			
//			request.location = AMapGeoPoint.location(withLatitude: CGFloat(userLocation.latitude), longitude: CGFloat(userLocation.longitude))
//		
//		} else {
//		
//			request.location = AMapGeoPoint.location(withLatitude: 39.990459, longitude: 116.471476)
//		
//		}
//		
//		request.keywords = key
//		request.sortrule = 1
//		request.requireExtension = false
//		
//		search?.aMapPOIAroundSearch(request)
		
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		
		if (searchBar.text?.characters.count)! > 0 {
			
			tableView?.isHidden = false
			
			let key = searchBar.text
			
			clearAndSearchGeocodeWithKey(key: key!)
			
			searchTipsWith(key: key!)
			
		}
		
		if searchBar.text?.characters.count == 0 {
			
			tableView?.isHidden = true
			
		}
		
	}
}





