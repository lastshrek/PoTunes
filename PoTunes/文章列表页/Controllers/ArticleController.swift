//
//  Article.swift
//  破音万里
//
//  Created by Purchas on 16/8/22.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class ArticleController: UITableViewController {
	
	var articles: NSArray?
	var refreshView: BreakOutToRefreshView!
	let closeHeight: CGFloat = 91
	let openHeight: CGFloat = 166
	var itemHeight = [CGFloat](repeating: 91.0, count: 100)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let width = self.view.bounds.size.width
		
		self.tableView.rowHeight = width * 300 / 640
		self.tableView.separatorStyle = .none
		self.tableView.backgroundColor = .white()
		self.tableView.register(ArticleCell.self, forCellReuseIdentifier: "Article")
		
		//下拉刷新
		refreshView = BreakOutToRefreshView(scrollView: tableView)
		refreshView.delegate = self
		//config刷新
//		refreshView.scenebackgroundColor = UIColor(hue: 0.68, saturation: 0.9, brightness: 0.3, alpha: 1.0)
//		refreshView.paddleColor = UIColor.lightGrayColor()
//		refreshView.ballColor = UIColor.whiteColor()
//		refreshView.blockColors = [UIColor(hue: 0.17, saturation: 0.9, brightness: 1.0, alpha: 1.0), UIColor(hue: 0.17, saturation: 0.7, brightness: 1.0, alpha: 1.0), UIColor(hue: 0.17, saturation: 0.5, brightness: 1.0, alpha: 1.0)]
		
		tableView.addSubview(refreshView)
		
		if self.articles == nil {
			let rootPath = self.dirDoc()
			let filePath: NSString = rootPath.appendingPathComponent("article.plist")
			var dicArray: NSArray?
			dicArray = NSArray(contentsOfFile: filePath as String)
			if let tempArray: NSArray = dicArray {
				let contentArray: NSMutableArray = NSMutableArray()
				for dict in tempArray {
					contentArray.add(dict)
				}
				self.articles = contentArray
			} else {
				//下拉刷新
			}
		}
	}
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		// #warning Incomplete implementation, return the number of sections
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		// #warning Incomplete implementation, return the number of rows
		return itemHeight.count
	}
	
//	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//		return itemHeight[indexPath.row]
//	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Article", for: indexPath)
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell = tableView.cellForRow(at: indexPath) as! ArticleCell
		
		var duration = 0.0
		if itemHeight[(indexPath as NSIndexPath).row] == closeHeight { // open cell
			itemHeight[(indexPath as NSIndexPath).row] = openHeight
			cell.selectedAnimation(true, animated: true, completion: nil)
			duration = 0.5
		} else {// close cell
			itemHeight[(indexPath as NSIndexPath).row] = closeHeight
			cell.selectedAnimation(false, animated: true, completion: nil)
			duration = 1.1
		}
		
		UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
			tableView.beginUpdates()
			tableView.endUpdates()
			}, completion: nil)
		
	}
}

extension ArticleController {
	
	override func scrollViewDidScroll(_ scrollView: UIScrollView) {
		refreshView.scrollViewDidScroll(scrollView)
	}
	
	override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		refreshView.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
		loadNewArticle()
	}
	
	override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		refreshView.scrollViewWillBeginDragging(scrollView)
	}
}

extension ArticleController: BreakOutToRefreshDelegate {
	
	func refreshViewDidRefresh(_ refreshView: BreakOutToRefreshView) {
		// load stuff from the internet
		
	}
	
}

extension ArticleController {
	fileprivate func loadNewArticle() {
		let manager: AFHTTPRequestOperationManager = AFHTTPRequestOperationManager()
		HUD.show(.labeledProgress(title: "Title", subtitle: "Subtitle"))
	}
}
