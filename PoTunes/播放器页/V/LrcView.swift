//
//  LrcView.swift
//  破音万里
//
//  Created by Purchas on 16/8/14.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

//MARK: - 代理
class LrcView: DRNRealTimeBlurView {
	
	var noLrcLabel = UILabel().then({
		$0.backgroundColor = UIColor.clear
		$0.textAlignment = .center
		$0.text = "暂无歌词"
		$0.textColor = UIColor.lightText
	})
	var tableView = UITableView().then({
		$0.separatorStyle = .none
		$0.showsVerticalScrollIndicator = false
		$0.backgroundColor = UIColor.clear
		$0.register(LrcCell.self, forCellReuseIdentifier: "lrc")
	})
	let hover = UIView().then({
		$0.backgroundColor = UIColor.black
		$0.alpha = 0.5
	})
	lazy var lyricsLines: Array<LrcLine> = {[]}()
	lazy var chLrcArray: Array<LrcLine> = {[]}()

	fileprivate var currentIndex: Int = -1
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
	
	func setup() {
		addSubview(hover)
		// 暂无歌词页面
		addSubview(noLrcLabel)
		// 歌词
		tableView.delegate = self
		tableView.dataSource = self
		addSubview(tableView)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		tableView.frame = self.bounds
		tableView.contentInset = UIEdgeInsetsMake(self.bounds.size.height * 0.5, 0, self.bounds.size.height * 0.5, 0)
		noLrcLabel.frame = self.bounds
		hover.frame = self.bounds
	}
}

extension LrcView {
	func parseLyrics(lyrics: String) {
		if lyricsLines.count != 0 {
			lyricsLines.removeAll()
		}
		currentIndex = 0
		lyricsLines = divideArray(lyrics: lyrics)
		tableView.reloadData()
		if lyricsLines.count > 0 {
			tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
		} else {
			noLrcLabel.text = "暂无歌词"
			noLrcLabel.isHidden = false
		}
	}
	
	func parseChLyrics(lyrics: String) {
		chLrcArray.removeAll()
		chLrcArray = divideArray(lyrics: lyrics)

		for lrc in self.lyricsLines {
			let lrcTime = lrc.time
			if lrcTime?.characters.count == 0 { continue }
			for chlrc in self.chLrcArray {
				let chlrcTime = chlrc.time
				if chlrcTime?.characters.count == 0 { continue }
				if chlrcTime == lrcTime {
					if lrc.lyrics?.characters.count == 0 {
						continue
					}
					lrc.lyrics = lrc.lyrics! + "\r" + chlrc.lyrics!
				}
				continue
			}
		}
		self.tableView.reloadData()
	}
	
	func divideArray(lyrics: String) -> Array<LrcLine> {
		
		let sepArr = lyrics.components(separatedBy: "[")
		
		if sepArr.count <= 1 {
			self.tableView.reloadData()
			return []
		}
		
		self.noLrcLabel.isHidden = true

		var temp: Array<LrcLine> = []
		
		for lyric in sepArr {
			let lrc = LrcLine()
			//如果是歌名的头部信息
			let array = lyric.components(separatedBy: "]")
			
			lrc.time = array.first?.replacingOccurrences(of: "[", with: "")
			
			if lrc.time?.characters.count == 0 {
				continue
			}
			if ((lrc.time?.characters.count)! > 8) {
				let index = lrc.time?.index((lrc.time?.startIndex)!, offsetBy: 8)
				lrc.time = lrc.time?.substring(to: index!)
			}
			lrc.lyrics = array.last
			temp.append(lrc)
		}
		return temp
	}
	
	func currentTime(time:TimeInterval) {
		let minute: Int = (Int)(time / 60)
		let second: Int = (Int)(time) % 60
		let currentTimeStr = String(format: "%02d:%02d", minute, second)
		let count = lyricsLines.count

		if count == 0 { return }
		
		for index in 0...count-1 {
			let lyric = lyricsLines[index]
			// 当前模型时间
			let lyricTime = lyric.time!
			let nextIdx = index + 1
			var nextLine: LrcLine?
			
			if nextIdx < count {
				nextLine = lyricsLines[nextIdx]
				
				if (currentTimeStr > lyricTime && currentTimeStr < (nextLine?.time)! && (index != currentIndex || currentIndex == count - 2)) {
					//刷新tableView
					let reloadRows: Array = [IndexPath(row: index, section: 0), IndexPath(row: currentIndex, section: 0)]
					let indexPath = IndexPath(row: index, section: 0)

					currentIndex = index
					tableView.reloadRows(at: reloadRows, with: .none)
					//滚动到对应的
					tableView.scrollToRow(at: indexPath, at: .top, animated: true)
				}
			}
			
			if nextIdx == count && index != currentIndex {
				if (currentTimeStr > lyricTime && (index != currentIndex || currentIndex == count - 2)) {
					let indexPath = IndexPath(row: index, section: 0)
					//刷新tableView
					let reloadRows: Array = [IndexPath(row: index, section: 0), IndexPath(row: currentIndex, section: 0)]
					currentIndex = index
					tableView.reloadRows(at: reloadRows, with: .none)
					//滚动到对应的
					tableView.scrollToRow(at: indexPath, at: .top, animated: true)
				}
			}
		}
	}
}

extension LrcView: UITableViewDataSource {
	
	private func numberOfSectionsInTableView(tableView: UITableView) -> Int { return 1 }
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return self.lyricsLines.count
		
	}
	
}

extension LrcView: UITableViewDelegate {
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "lrc", for: indexPath) as! LrcCell
		
		cell.lrcLine = self.lyricsLines[indexPath.row]
		if self.currentIndex == indexPath.row {
			cell.lyricLabel?.textColor = UIColor.white
		} else {
			cell.lyricLabel?.textColor = UIColor.lightText
		}
		return cell
	}
	
}
