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
	func mapController(didClickTheAnnotationBySending destinationLocation: CLLocationCoordinate2D, destinationTitle: String, userlocation: CLLocationCoordinate2D)
	func mapController(didClickTheAnnotationBySendingCustomUserLocation userlocation:  CLLocationCoordinate2D, title: String)
}

class MapController: UIViewController {
	let backgroundView = UIImageView(image: UIImage(named: "outtake_mid"))
	var mapView: MAMapView?
	var searchBar: UISearchBar?
	var search: AMapSearchAPI?
	var tableView: UITableView?
	// user location
	var user: CLLocationCoordinate2D?
	// 用户选择的起始位置
	var selectedstartLocation: CLLocationCoordinate2D?
	var isSelected: Bool?
	// 目的位置
	var destinationLocation: CLLocationCoordinate2D?
	var destinationTitle: String?
	var annotations = [MAPointAnnotation]()

	lazy var tips: Array<AMapTip> = {[]}()
	weak var delegate: MapControllerDelegate?

	override func viewDidLoad() {
		super.viewDidLoad()
		backgroundView.frame = self.view.bounds
		view.addSubview(backgroundView)
		initMapView()
		initSearchBar()
		initTableView()
		HUD.show(.systemActivity)
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		mapView?.removeAnnotations(mapView?.annotations)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		clearMapView()
		view.endEditing(true)
	}
		
	
	// MARK: - Initialization
	func initMapView() {
		AMapServices.shared().apiKey = "62443358a250ee522aba69dfa3c1d247"
		mapView = MAMapView(frame: self.view.bounds).then({
			$0.delegate = self
			$0.userTrackingMode = .follow
			$0.showsUserLocation = true
			view.addSubview($0)
		})
		// initialize searchapi
		search = AMapSearchAPI()
		search?.delegate = self
	}
	
	func clearMapView() {
		mapView = nil
		mapView?.delegate = nil
		searchBar = nil
		tableView = nil
	}
	
	func initSearchBar() {
		searchBar = UISearchBar.init().then({
			$0.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44)
			$0.barStyle = .black
			$0.isTranslucent = false
			$0.delegate = self
			$0.placeholder = "请输入要查询的地点"
			$0.keyboardType = .default
			$0.becomeFirstResponder()
			view.addSubview($0)
		})
	}

	func initTableView() {
		tableView = UITableView.init().then({
			$0.frame = CGRect(x: 0, y: 44, width: self.view.bounds.size.width, height: self.view.bounds.size.height - 44)
			$0.register(UITableViewCell.self, forCellReuseIdentifier: "tip")
			$0.delegate = self
			$0.dataSource = self
			$0.isHidden = true
			view.addSubview($0)
		})
	}
}

// MARK: - UITableViewDataSource

extension MapController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tips.count
	}
}

// MARK: - UITableViewDelegate

extension MapController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCell(withIdentifier: "tip")
		let tip: AMapTip = self.tips[indexPath.row]

		if cell == nil {
			cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "tip")
		}
		cell?.textLabel?.text = tip.name
		return cell!
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let tip = tips[indexPath.row]
		
		if tip.location == nil {
			HUD.flash(.labeledError(title: "请输入相对精确的位置", subtitle: nil), delay: 0.7)
			return
		}
		
		let annotation = MAPointAnnotation().then({
			$0.coordinate = CLLocationCoordinate2D(latitude:Double(tip.location.latitude), longitude: Double(tip.location.longitude))
			$0.title = tip.name
			$0.subtitle = tip.address
		})
		annotations.removeAll()
		annotations.append(annotation)
		showPOIAnnotations()
		tableView.isHidden = true
		searchBar?.endEditing(true)
	}
	
	func showPOIAnnotations() {
		mapView?.addAnnotations(annotations)
		mapView?.centerCoordinate = (annotations.first?.coordinate)!
	}
}

// MARK: - MAMapViewDelegate

extension MapController: MAMapViewDelegate {
	
	func mapView(_ mapView: MAMapView!, didUpdate userLocation: MAUserLocation!, updatingLocation: Bool) {
		HUD.hide()
		
		if updatingLocation {
			if user != nil { return }
			user = CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude)
		}
	}
	
	func mapView(_ mapView: MAMapView!, annotationView view: MAAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
		
		if view.annotation is MAPointAnnotation {
			let annotation = view.annotation
			
			if self.view.tag == 1 {
				user = CLLocationCoordinate2DMake((annotation?.coordinate.latitude)!, (annotation?.coordinate.longitude)!)
				self.delegate?.mapController(didClickTheAnnotationBySendingCustomUserLocation: user!, title: (annotation?.title)!)
			} else {
				destinationLocation = CLLocationCoordinate2DMake((annotation?.coordinate.latitude)!, (annotation?.coordinate.longitude)!)
				self.delegate?.mapController(didClickTheAnnotationBySending: destinationLocation!, destinationTitle: (annotation?.title)!, userlocation: user!)
			}
			
			destinationTitle = annotation?.title
			navigationController!.popToRootViewController(animated: true)
			mapView.removeAnnotations(annotations)
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


// MARK: - AMapSearchDelegate

extension MapController: AMapSearchDelegate {
	// 地理编码回调
	func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
		let error = error as NSError
		debugPrint(error.localizedDescription)
	}
	
	// 输入提示回调
	func onInputTipsSearchDone(_ request: AMapInputTipsSearchRequest!, response: AMapInputTipsSearchResponse!) {
		tips = Array(response.tips)
		tableView?.reloadData()
	}
}

// MARK: - UISearchBarDelegate
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
		mapView?.removeAnnotations(mapView?.annotations)
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
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		
		if (searchBar.text?.characters.count)! > 0 {
			let key = searchBar.text

			tableView?.isHidden = false
			clearAndSearchGeocodeWithKey(key: key!)
			searchTipsWith(key: key!)
		}
		
		if searchBar.text?.characters.count == 0 {
			tableView?.isHidden = true
		}
	}
}





