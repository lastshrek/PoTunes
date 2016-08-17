//
//  LrcView.swift
//  破音万里
//
//  Created by Purchas on 16/8/14.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class LrcView: DRNRealTimeBlurView, UITableViewDelegate, UITableViewDataSource{
  var _lrcName: String?
	var lrcName: String? {
		didSet {
			guard let `lrcName` = lrcName else { return }
			self.lyricsLines.removeAllObjects()
			dirDoc(lrcName, array: self.lyricsLines)
			self.tableView?.reloadData()
		}
	}
	var chLrcName: String? {
		didSet {
			guard let `chLrcName` = chLrcName else { return }
			dirDoc(chLrcName, array: self.chLrcArray)
			for i in 0..<self.lyricsLines.count {
				let lrc = self.lyricsLines[i] as! LrcLine
				var lrcTime = lrc.time
				if lrcTime?.length == 0 {
					continue
				}
				lrcTime = lrcTime?.substringToIndex(5)
				for j in 0..<self.chLrcArray.count {
					let chLrc = self.chLrcArray[j] as! LrcLine
					let chLrcTime = chLrc.time?.substringToIndex(5)
					if  chLrcTime == lrcTime {
						lrc.lyrics = String(format: "%@\r%@", lrc.lyrics!, chLrc.lyrics!)
					}
					continue
				}
			}
			self.tableView?.reloadData()
		}
	}
	var currentTime: NSTimeInterval? {
		didSet {
			guard let `currentTime` = currentTime else { return }
			if currentTime < oldValue {
				currentindex = -1
			}
			self.currentTime = currentTime
			
			let minute: Int = (Int)(currentTime / 60)
			let second: Int = (Int)(currentTime) % 60
			
			let currentTimeStr = String(format: "%02d:%02d", minute, second)
			
			let count = self.lyricsLines.count
			let idx = self.currentindex! + 1
			for idx in idx..<count {
				let currentLine = self.lyricsLines[idx] as! LrcLine
				//当前模型时间
				let currentLineTime = currentLine.time as! String
				//下一个模型时间
				var nextLineTime: String? = nil
				
				let nextIdx = idx + 1
				if nextIdx < self.lyricsLines.count {
					let nextLine = self.lyricsLines[nextIdx] as! LrcLine
					nextLineTime = nextLine.time! as String
				}
				
				// 判断是否为正在播放的歌词
				if currentTimeStr.compare(currentLineTime) != .OrderedAscending && currentTimeStr.compare(nextLineTime!) == .OrderedAscending && self.currentindex != idx {
					//刷新tableVies
					let reloadRows: Array = [NSIndexPath(forRow: self.currentindex!, inSection: 0), NSIndexPath(forRow: idx	, inSection: 0)]
					self.currentindex = idx
					tableView?.reloadRowsAtIndexPaths(reloadRows, withRowAnimation: .None)
					//滚动到对应的
					let indexPath = NSIndexPath(forRow: idx, inSection: 0)
					tableView?.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
				}
			}
		}
	}
	var noLrcLabel: UILabel?
	lazy var chLrcArray: NSMutableArray = {[]}()

	private var tableView: UITableView?
	private var currentindex: Int?
	private lazy var lyricsLines: NSMutableArray = { [] }()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setup() {
		let noLrcLabel: UILabel = UILabel()
		noLrcLabel.backgroundColor = .clearColor()
		noLrcLabel.textAlignment = .Center
		noLrcLabel.text = "暂无歌词"
		noLrcLabel.textColor = .grayColor()
		self.noLrcLabel = noLrcLabel
		self.addSubview(noLrcLabel)

		let tableView: UITableView = UITableView()
		tableView.dataSource = self
		tableView.delegate = self
		tableView.separatorStyle = .None
		tableView.showsVerticalScrollIndicator = false
		tableView.backgroundColor = .clearColor()
		self.tableView = tableView
		self.addSubview(tableView)
		self.renderStatic = true
	}
	override func layoutSubviews() {
		super.layoutSubviews()
		self.tableView?.frame = self.bounds
		self.tableView?.contentInset = UIEdgeInsetsMake(self.bounds.size.height * 0.5, 0, self.bounds.size.height * 0.5, 0)
		self.noLrcLabel?.frame = self.bounds
	}
    
	func dirDoc(lrcName: String, array: NSMutableArray) {
		let paths: NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
		let documentsDirectory: String = paths.objectAtIndex(0) as! String
		let path = (documentsDirectory as NSString).stringByAppendingPathComponent(lrcName)
		do {
			let lrcStr: NSString = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
			let lrcComponents: NSArray = lrcStr.componentsSeparatedByString(" [")
			//输出每一行歌词
			for line in lrcComponents {
					let lrc: LrcLine = LrcLine()
					//如果是歌名的头部信息
					let tempArray: NSArray = line.componentsSeparatedByString("]")
					lrc.time = tempArray.firstObject?.stringByReplacingOccurrencesOfString("[", withString: "")
					lrc.lyrics = tempArray.lastObject as! String
					array.addObject(lrc)
			}
		}
		catch let error as NSError {
			print(error.localizedDescription)
		}
	}
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.lyricsLines.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("lrc", forIndexPath: indexPath) as! LrcCell
		cell.lrcLine = (self.lyricsLines[indexPath.row] as! LrcLine)
		if self.currentindex == indexPath.row {
			cell.textLabel?.textColor = .whiteColor()
		} else {
			cell.textLabel?.textColor = .grayColor()
		}
		
		return cell
	}

}
