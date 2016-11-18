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
	
	class func cachesDir() -> String {
		
		let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
		
		return paths[0]
	
	}
	
}
