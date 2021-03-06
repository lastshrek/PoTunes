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
	let backgroundView = UIImageView(image: UIImage(named: "outtake_mid"))
	let routeSeletcion = Routes()
	let width = UIScreen.main.bounds.size.width
	var mapView = MAMapView()
	var annotations = [MAPointAnnotation]()
	var driveManager: AMapNaviDriveManager?
	var walkManager: AMapNaviWalkManager?
	var segmentedDrivingStrategy: SegmentControl?
	var navBtn: NavButton?
	var startLocation: CLLocationCoordinate2D?
	var endLocation: CLLocationCoordinate2D?
	var naviView: DriveNaviViewController?
	var speecher: AVSpeechSynthesizer?


    override func viewDidLoad() {
		super.viewDidLoad()
		AMapServices.shared().apiKey = "62443358a250ee522aba69dfa3c1d247"
		backgroundView.frame = view.bounds
		backgroundView.isUserInteractionEnabled = true
		view.addSubview(backgroundView)
		navigationController?.modalPresentationStyle = .none
		initRoutesSelection()
	}
	
	// MARK: - initialization
	func initRoutesSelection() {
		if UIScreen.main.bounds.size.height == 812 {
			routeSeletcion.frame = CGRect(x: 10, y: 64, width: width - 20, height: 130)
		} else {
			routeSeletcion.frame = CGRect(x: 10, y: 84, width: width - 20, height: 130)
		}
		routeSeletcion.start.text.delegate = self
		routeSeletcion.end.text.delegate = self
		routeSeletcion.switcher.addTarget(self, action: #selector(switchRoutes), for: .touchUpInside)
		view.addSubview(routeSeletcion)
		// button
		navBtn = NavButton(type: .custom).then({
			$0.frame = CGRect(x: 20, y: self.view.bounds.size.height - 180, width: width - 40, height: 50)
			$0.addTarget(self, action: #selector(btnClick(_:)), for: .touchUpInside)
			$0.setTitle("开始导航", for: .normal)
			view.addSubview($0)
		})
	}
	
	@objc func btnClick(_: NavButton) {
		if navBtn?.titleLabel?.text == "路径规划" {
			let driving = DrivingCalculateController().then({
				$0.startPoint = AMapNaviPoint.location(withLatitude: CGFloat((startLocation?.latitude)!), longitude: CGFloat((startLocation?.longitude)!))
				$0.endPoint = AMapNaviPoint.location(withLatitude: CGFloat((endLocation?.latitude)!), longitude: CGFloat((endLocation?.longitude)!))
				$0.delegate = self
			})
			navigationController?.pushViewController(driving, animated: true)
		}
		if navBtn?.titleLabel?.text == "继续导航" {
			self.present(naviView!, animated: true, completion: nil)
		}
	}
	
	@objc func switchRoutes() {
		if routeSeletcion.start.text.text?.count == 0 || routeSeletcion.end.text.text?.count == 0 {
			HUD.flash(.labeledError(title: "请选择线路", subtitle: nil), delay: 0.7)
			return
		}
		let temp = routeSeletcion.start.text.text
		let location = startLocation
        routeSeletcion.start.text.text = routeSeletcion.end.text.text
        routeSeletcion.end.text.text = temp
        startLocation = endLocation
        endLocation = location
	}
}

// MARK: - UITextFieldDelegate, MapControllerDelegate
extension NaviController: UITextFieldDelegate, MapControllerDelegate {
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		textField.endEditing(true)
		let mapController = MapController().then({
			$0.delegate = self
			$0.title = textField.text
			$0.view.tag = textField.tag
		})
		self.navigationController?.pushViewController(mapController, animated: true)
	}
	
	
	func mapController(didClickTheAnnotationBySending destinationLocation: CLLocationCoordinate2D, destinationTitle: String, userlocation: CLLocationCoordinate2D) {
		routeSeletcion.end.text.text = destinationTitle
		endLocation = destinationLocation

		if startLocation == nil {
			startLocation = userlocation
		}
		navBtn?.setTitle("路径规划", for: .normal)
		driveManager = nil
	}
	
	func mapController(didClickTheAnnotationBySendingCustomUserLocation userlocation: CLLocationCoordinate2D, title: String) {
		routeSeletcion.start.text.text = title
		startLocation = userlocation
		driveManager = nil
	}
	
}

// MARK: - AMapNaviDriveManagerDelegate
extension NaviController: AMapNaviDriveManagerDelegate {
	
	func driveManager(_ driveManager: AMapNaviDriveManager, error: Error) {
		let error = error as NSError
		debugPrint("error: \(error.code), \(error.localizedDescription)")
	}

	
	func driveManager(_ driveManager: AMapNaviDriveManager, onCalculateRouteFailure error: Error) {
		let error = error as NSError
		debugPrint("error: \(error.code), \(error.localizedDescription)")
	}
	
	func driveManager(_ driveManager: AMapNaviDriveManager, didStartNavi naviMode: AMapNaviMode) {
		debugPrint("didStartNavi");
	}
	
	func driveManagerNeedRecalculateRoute(forYaw driveManager: AMapNaviDriveManager) {
		debugPrint("needRecalculateRouteForYaw");
	}
	
	func driveManagerNeedRecalculateRoute(forTrafficJam driveManager: AMapNaviDriveManager) {
		debugPrint("needRecalculateRouteForTrafficJam");
	}
	
	func driveManager(_ driveManager: AMapNaviDriveManager, onArrivedWayPoint wayPointIndex: Int32) {
		debugPrint("ArrivedWayPoint:\(wayPointIndex)");
	}
	// MARK: - 语音播报
	func driveManager(_ driveManager: AMapNaviDriveManager, playNaviSound soundString: String, soundStringType: AMapNaviSoundType) {
		let utterance = AVSpeechUtterance(string: soundString).then({
			$0.voice = AVSpeechSynthesisVoice(language: "zh-TW")
			$0.volume = 1.0
			$0.rate = 0.5
		})
		speecher = AVSpeechSynthesizer().then({
			$0.delegate = self
			$0.speak(utterance)
		})
	}
	
	func driveManagerDidEndEmulatorNavi(_ driveManager: AMapNaviDriveManager) {
		debugPrint("didEndEmulatorNavi");
	}
	
	func driveManager(onArrivedDestination driveManager: AMapNaviDriveManager) {
		debugPrint("onArrivedDestination");
	}

}

// MARK: - AVSpeechSynthesizerDelegate
extension NaviController: AVSpeechSynthesizerDelegate {
	
	func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
		postSpeekNotification(name: "speaking")
	}
	
	func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
		postSpeekNotification(name: "nonspeaking")
	}

	func postSpeekNotification(name: String) {
		let speaking = Notification.Name(name)
		let notify: Notification = Notification.init(name: speaking, object: nil, userInfo: nil)
		NotificationCenter.default.post(notify)
	}
}

// MARK: - DrivingCalculateControllerDelegate 
extension NaviController: DrivingCalculateControllerDelegate {
	
	func drivingCalculateController(manager: AMapNaviDriveManager, controller: DrivingCalculateController) {
		driveManager = manager
		driveManager?.delegate = self
		naviView = DriveNaviViewController()
		naviView?.delegate = self
		//将driveView添加为导航数据的Representative，使其可以接收到导航诱导数据
		driveManager?.addDataRepresentative((naviView?.driveView)!)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
			self.present(self.naviView!, animated: false, completion: nil)
			self.driveManager?.startGPSNavi()
//			self.driveManager?.startEmulatorNavi()
		}
	}
		
}

// MARK: - DriveNaviViewControllerDelegate
extension NaviController: DriveNaviViewControllerDelegate {
	
	func driveNaviViewCloseButtonClicked() {
		driveManager?.stopNavi()
		navBtn?.setTitle("路径规划", for: .normal)
		speecher?.stopSpeaking(at: .immediate)
		self.dismiss(animated: true, completion: nil)
		driveManager = nil
	}
	
	func driveNaviViewMoreButtonClicked() {
        self.dismiss(animated: true, completion: nil)
		navBtn?.setTitle("继续导航", for: .normal)
	}
}
