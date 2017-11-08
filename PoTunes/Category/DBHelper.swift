//
//  DB.swift
//  破音万里
//
//  Created by Purchas on 2016/11/21.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit
import FMDB

class DBHelper: NSObject {
	
	var queue: FMDatabaseQueue?
	
	static let sharedInstance: DBHelper = {
	
		let instance = DBHelper()
		
		// setup code
		
		let path = instance.dirDoc() + "/downloadingSong.db"
		
		instance.queue = FMDatabaseQueue(path: path)

		return instance
	}()
	
	
	func inDatabase(complete : @escaping (FMDatabase) -> ()) {
		
		self.queue!.inDatabase({ (db) in
			
			complete(db)
		
		})
		
	}
	
}
