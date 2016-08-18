//
//  ArticleController.swift
//  破音万里
//
//  Created by Purchas on 16/8/13.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class ArticleController: UITableViewController {
	var articles: NSArray?

	override func viewDidLoad() {
		super.viewDidLoad()

		let width = self.view.bounds.size.width

		self.tableView.rowHeight = width * 300 / 640
		self.tableView.separatorStyle = .None
		self.tableView.backgroundColor = .whiteColor()
		if self.articles == nil {
			let rootPath = self.dirDoc()
			let filePath: NSString = rootPath.stringByAppendingPathComponent("article.plist")
			let dictArray: NSArray = NSArray(contentsOfFile: filePath as String)!
			if dictArray.count == 0 {
				//下拉刷新
			} else {
				let contentArray: NSMutableArray = NSMutableArray()
				for dict in dictArray {
					contentArray.addObject(dict)
				}
				self.articles = contentArray
			}
		}
	}

	override func didReceiveMemoryWarning() {
			super.didReceiveMemoryWarning()
			// Dispose of any resources that can be recreated.
	}

	// MARK: - Table view data source

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
			// #warning Incomplete implementation, return the number of sections
			return 1
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
			// #warning Incomplete implementation, return the number of rows
//			return (self.articles?.count)!
		return 20
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell: UITableViewCell = UITableViewCell()
		return cell
	}

	/*
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
			let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

			// Configure the cell...

			return cell
	}
	*/

	/*
	// Override to support conditional editing of the table view.
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
			// Return false if you do not want the specified item to be editable.
			return true
	}
	*/

	/*
	// Override to support editing the table view.
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
			if editingStyle == .Delete {
					// Delete the row from the data source
					tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
			} else if editingStyle == .Insert {
					// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
			}    
	}
	*/

	/*
	// Override to support rearranging the table view.
	override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

	}
	*/

	/*
	// Override to support conditional rearranging of the table view.
	override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
			// Return false if you do not want the item to be re-orderable.
			return true
	}
	*/

	/*
	// MARK: - Navigation

	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
			// Get the new view controller using segue.destinationViewController.
			// Pass the selected object to the new view controller.
	}
	*/

}
