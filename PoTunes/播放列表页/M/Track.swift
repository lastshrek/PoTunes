//
//  Track.swift
//  破音万里
//
//  Created by Purchas on 2016/11/10.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class Track: NSObject {
	@objc var ID: Int = 0
	@objc var name: String = ""
	@objc var artist: String = ""
	@objc var cover: String = ""
	@objc var url: String = ""

	@objc func setupMappingReplaceProperty() -> [String : String] {
		return ["ID": "id"]
	}
}




