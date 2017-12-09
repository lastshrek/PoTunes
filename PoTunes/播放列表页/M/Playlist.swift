//
//  Playlist.swift
//  破音万里
//
//  Created by Purchas on 2016/11/9.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

@objc class Playlist: NSObject {
	@objc var ID: Int = 0
	@objc var title: String = ""
	@objc var cover: String = ""

	@objc func setupMappingReplaceProperty() -> [String : String] {
		return ["ID": "id"]
	}
}


