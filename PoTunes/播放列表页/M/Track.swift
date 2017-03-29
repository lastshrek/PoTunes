//
//  Track.swift
//  破音万里
//
//  Created by Purchas on 2016/11/10.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class Track: NSObject {
	var ID: Int = 0
	var name: String = ""
	var artist: String = ""
	var cover: String = ""
	var url: String = ""

	func setupMappingReplaceProperty() -> [String : String] {
		return ["ID": "id"]
	}
}




