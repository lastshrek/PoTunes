//
//  NSString+DirDoc.swift
//  破音万里
//
//  Created by Purchas on 16/8/17.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

extension NSObject {
	
	func dirDoc() -> NSString {
		
		let paths: NSArray = NSSearchPathForDirectoriesInDomains(
			.DocumentDirectory, .UserDomainMask, true)
		let documentsDirectory = paths.objectAtIndex(0) as! NSString
		
		return documentsDirectory
	}
}
