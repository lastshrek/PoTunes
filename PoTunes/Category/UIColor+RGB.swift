//
//  UIColor+RGB.swift
//  破音万里
//
//  Created by Purchas on 2016/11/13.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import Foundation


extension UIColor {
	
	class func colorByRGB(red: CGFloat, green: CGFloat, blue: CGFloat , alpha: CGFloat) -> UIColor {
		
		return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
	
	}
}
