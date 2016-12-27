//
//  NSString+DirDoc.swift
//  破音万里
//
//  Created by Purchas on 16/8/17.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

extension NSObject {
	
	func dirDoc() -> String {
		
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
	
		return paths[0]
	
	}
	
	func cachesDir() -> String {
		
		let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
		
		return paths[0]
	
	}
	
	func doubleQuotation(single: String) -> String {
		
		let double = single.replacingOccurrences(of: "'", with: "''")
		
		return double
		
	}
	
	func getIdentifier(urlStr: String) -> String {
		
		let urlComponent: Array = urlStr.components(separatedBy: "/")
		
		let count = urlComponent.count
		
		let identifier: String = (urlComponent[count - 3]) + (urlComponent[count - 2]) + (urlComponent[count - 1])
		
		return identifier
		
	}
	
	func toKiloMeters(route: NSInteger) -> String {
		
		let routeInt = Int(route)
		
		if routeInt / 1000 == 0 {
			
			return "\(routeInt)米"
			
		}
		
		let kilo = routeInt / 1000
		
		
		let meter = routeInt % 1000
		
		return "\(kilo).\(meter)公里"
		
	}
	
	func toHours(route: NSInteger) -> String {
		
		let routeInt = Int(route)
		
		let hour = routeInt / 3600
		
		let minute = routeInt / 60 + 1

		if hour == 0 {
			
			return "\(minute)分"
			
		}
		return "\(hour)小时\(minute)分"

	}
}
