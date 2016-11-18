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
	
	var noLrcLabel = UILabel()
	lazy var chLrcArray: NSMutableArray = {[]}()
	fileprivate var tableView = UITableView()
	fileprivate var currentIndex: Int?
	fileprivate lazy var lyricsLines: NSMutableArray = {[]}()
	
	var currentTime: TimeInterval? {
		

	
		didSet {
		
			guard let `currentTime` = currentTime else { return }
			
			let minute: Int = (Int)(currentTime / 60)
			let second: Int = (Int)(currentTime) % 60
			let currentTimeStr = String(format: "%02d:%02d", minute, second)
			let count = self.lyricsLines.count
			let idx = self.currentIndex! + 1
			
			for idx in idx..<count {
			
				let currentLine = self.lyricsLines[idx] as! LrcLine
				//当前模型时间
				let currentLineTime = currentLine.time
				//下一个模型时间
				var nextLineTime: String? = nil
				
				let nextIdx = idx + 1
				
				if nextIdx < self.lyricsLines.count {
				
					let nextLine = self.lyricsLines[nextIdx] as! LrcLine
					
					nextLineTime = nextLine.time!
				
				}
				
				// 判断是否为正在播放的歌词
				if currentTimeStr.compare(currentLineTime!) != .orderedAscending
					&& currentTimeStr.compare(nextLineTime!) == .orderedAscending
					&& currentIndex != idx {
					//刷新tableView
					let reloadRows: Array = [IndexPath(row: currentIndex!, section: 0), IndexPath(row: idx	, section: 0)]
					
					
					
					self.currentIndex = idx
					
					
					self.tableView.reloadRows(at: reloadRows, with: .none)
					//滚动到对应的
					let indexPath = IndexPath(row: idx, section: 0)
					
					tableView.scrollToRow(at: indexPath, at: .top, animated: true)
				}
			}
		}
	}
	
	var lyricStr: String? {
		
		didSet {
			
			guard let `lyricStr` = lyricStr else { return }
			
			self.lyricStr = lyricStr
			
			let lrcComponents = lyricStr.components(separatedBy: "[")
			
			for line: String in lrcComponents {
				
				let lrc = LrcLine()
				//如果是歌名的头部信息
				let array = line.components(separatedBy: "]")
				
				lrc.time = array.first?.replacingOccurrences(of: "[", with: "")
				
				lrc.lyrics = array.last
				
				self.lyricsLines.add(lrc)
				
			}
			
			self.tableView.reloadData()
			
		}
		
	}


	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setup() {
		// 暂无歌词页面
		noLrcLabel.backgroundColor = UIColor.clear
		
		noLrcLabel.textAlignment = .center
		
		noLrcLabel.text = "暂无歌词"
		
		noLrcLabel.textColor = UIColor.gray
		
		self.addSubview(noLrcLabel)
		// 歌词
		tableView.delegate = self
		
		tableView.dataSource = self
		
		tableView.separatorStyle = .none
		
		tableView.showsVerticalScrollIndicator = false
		
		tableView.backgroundColor = UIColor.clear
		
		tableView.register(LrcCell.self, forCellReuseIdentifier: "lrc")
		
		self.addSubview(tableView)
	}
	override func layoutSubviews() {
		
		super.layoutSubviews()
		
		tableView.frame = self.bounds
		
		self.tableView.contentInset = UIEdgeInsetsMake(self.bounds.size.height * 0.5, 0, self.bounds.size.height * 0.5, 0)
		
		noLrcLabel.frame = self.bounds
	
	}
	

	

	


}

extension LrcView: UITableViewDataSource {
	
	private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		
		return 1
		
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return self.lyricsLines.count
		
	}
}

extension LrcView: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "lrc", for: indexPath) as! LrcCell
		
		cell.lrcLine = self.lyricsLines[indexPath.row] as? LrcLine
		
		if self.currentIndex == indexPath.row {
			
			cell.textLabel?.textColor = UIColor.white
			
			print(indexPath.row)
			
		} else {
			
			cell.textLabel?.textColor = UIColor.gray
			
		}
		
		return cell
	}
}
