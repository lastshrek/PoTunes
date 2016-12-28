//
//  UserGuideController.swift
//  破音万里
//
//  Created by Purchas on 2016/12/28.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class UserGuideController: UIViewController {
	
	var guides: NSArray!
	
	var tableView: UITableView!
	
	let color = UIColor.colorByRGB(red: 17, green: 133, blue: 117, alpha: 1)

    override func viewDidLoad() {
		
		super.viewDidLoad()
		
		initTableView()

        // Do any additional setup after loading the view.
    }

	func initTableView() {
		
		tableView = UITableView()
		
		tableView.frame = self.view.bounds
		
		tableView.dataSource = self
		
		tableView.delegate = self
		
		tableView.contentInset = UIEdgeInsetsMake(0, 0, 64, 0)
		
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "guide")

		self.view.addSubview(tableView)
		
		self.automaticallyAdjustsScrollViewInsets = false
		
		let path = Bundle.main.path(forResource: "guide.plist", ofType: nil)
		
		guides = NSArray.init(contentsOfFile: path!)
		
	}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UserGuideController: UITableViewDataSource {
	
	func numberOfSections(in tableView: UITableView) -> Int {
		
		return guides.count
	
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		let dic = guides?[section] as! NSDictionary
		
		let guide = dic.object(forKey: "guide") as! NSArray
		
		return guide.count
	}
	
}

extension UserGuideController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		var cell = tableView.dequeueReusableCell(withIdentifier: "guide")
		
		if cell == nil {
			
			cell = UITableViewCell(style: .default, reuseIdentifier: "guide")
			
		}
		
		let dic = self.guides[indexPath.section] as! NSDictionary
		
		let array = dic.object(forKey: "guide") as! NSArray
		
		cell?.textLabel?.text = (array[indexPath.row] as! NSString) as String
		
		cell?.textLabel?.textColor = color
		
		cell?.textLabel?.font = UIFont(name: "BebasNeue", size: 12)
		
		return cell!
		
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		
		let dic = guides[section] as! NSDictionary
		
		return (dic.object(forKey: "title") as! NSString) as String
		
	}
	
	func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		
		let header = view as! UITableViewHeaderFooterView
		
		header.textLabel?.textColor = UIColor.colorByRGB(red: 225, green: 49, blue: 114, alpha: 1)
		
	}
	
}
