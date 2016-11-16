//
//  TrackEncoding.swift
//  破音万里
//
//  Created by Purchas on 2016/11/16.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class TrackEncoding: NSObject, NSCoding {
	
	var ID: Int?
	var name: String?
	var artist: String?
	var cover: String?
	var url: String?


	required init(coder aDecoder: NSCoder) {
		self.ID = aDecoder.decodeObject(forKey: "ID") as? Int
		self.name = aDecoder.decodeObject(forKey: "name") as? String
		self.artist = aDecoder.decodeObject(forKey: "artist") as? String
		self.cover = aDecoder.decodeObject(forKey: "cover") as? String
		self.url = aDecoder.decodeObject(forKey: "url") as? String
	}
	
	func encode(with _aCoder: NSCoder) {
		_aCoder.encode(self.ID, forKey: "ID")
		_aCoder.encode(self.name, forKey: "name")
		_aCoder.encode(self.artist, forKey: "artist")
		_aCoder.encode(self.cover, forKey: "cover")
		_aCoder.encode(self.url, forKey: "url")
	}
	
}
