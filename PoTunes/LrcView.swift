//
//  LrcView.swift
//  破音万里
//
//  Created by Purchas on 16/8/14.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

//MARK: - 代理
class LrcView: DRNRealTimeBlurView {
	@available(iOS 2.0, *)
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 10
	}

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
				lrcTime = lrcTime?.substring(to: 5) as NSString?

			}
			self.tableView?.reloadData()
		}
	}
	var currentTime: TimeInterval? {
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
				if currentTimeStr.compare(currentLineTime) != .orderedAscending && currentTimeStr.compare(nextLineTime!) == .orderedAscending && self.currentindex != idx {
					//刷新tableVies
					let reloadRows: Array = [IndexPath(row: self.currentindex!, section: 0), IndexPath(row: idx	, section: 0)]
					self.currentindex = idx
					tableView?.reloadRows(at: reloadRows, with: .none)
					//滚动到对应的
					let indexPath = IndexPath(row: idx, section: 0)
					tableView?.scrollToRow(at: indexPath, at: .top, animated: true)
				}
			}
		}
	}
	var noLrcLabel: UILabel?
	lazy var chLrcArray: NSMutableArray = {[]}()

	fileprivate var tableView: UITableView?
	fileprivate var currentindex: Int?
	fileprivate lazy var lyricsLines: NSMutableArray = { [] }()

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setup() {
		let noLrcLabel: UILabel = UILabel()
		noLrcLabel.backgroundColor = UIColor.clear
		noLrcLabel.textAlignment = .center
		noLrcLabel.text = "暂无歌词"
		noLrcLabel.textColor = UIColor.gray
		self.noLrcLabel = noLrcLabel
		self.addSubview(noLrcLabel)
//MARK: - dataSource & delegate - TODO
		let tableView: UITableView = UITableView()
		tableView.separatorStyle = .none
		tableView.showsVerticalScrollIndicator = false
		tableView.backgroundColor = UIColor.clear
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
    
	func dirDoc(_ lrcName: String, array: NSMutableArray) {
		let paths: NSArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
		let documentsDirectory: String = paths.object(at: 0) as! String
		_ = (documentsDirectory as NSString).appendingPathComponent(lrcName)
		do {

			}
		}
	}
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 10
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "lrc", for: indexPath) as! LrcCell
		
		return cell
	}


