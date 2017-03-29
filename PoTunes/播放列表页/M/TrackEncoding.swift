//
//  TrackEncoding.swift
//  破音万里
//
//  Created by Purchas on 2016/11/27.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class TrackEncoding: NSObject, NSCoding {
	
	let ID: Int
	let name: String
	let artist: String
	let cover: String
	let url: String
	
	required init(ID: Int, name: String, artist: String, cover: String, url: String) {
		self.ID = ID
		self.name = name
		self.artist = artist
		self.cover = cover
		self.url = url
	}
	
	
	required init(coder decoder: NSCoder) {
		self.ID = decoder.decodeInteger(forKey: "ID")
		self.name = decoder.decodeObject(forKey: "name") as! String
		self.artist = decoder.decodeObject(forKey: "artist") as! String
		self.cover = decoder.decodeObject(forKey: "cover") as! String
		self.url = decoder.decodeObject(forKey: "url") as! String
	}
	
	func encode(with coder: NSCoder) {
		coder.encode(ID, forKey: "ID")
		coder.encode(name, forKey: "name")
		coder.encode(artist, forKey: "artist")
		coder.encode(cover, forKey: "cover")
		coder.encode(url, forKey: "url")
	}
}
