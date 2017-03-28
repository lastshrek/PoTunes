//
//  NaviPointAnnotation.swift
//  破音万里
//
//  Created by Purchas on 2016/12/21.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

enum NaviPointAnnotationType: Int {
	case start
	case way
	case end
}

class NaviPointAnnotation: MAPointAnnotation {
	var naviPointType: NaviPointAnnotationType?
}
