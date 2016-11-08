
//
//  PlayerInterface.swift
//  破音万里
//
//  Created by Purchas on 16/8/12.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class PlayerInterface: UIView {
    
    var width: CGFloat?
    var height: CGFloat?
    var backgroundView: UIView?
    var cover: UIImageView?
    var reflection: UIImageView?
    var bufferingIndicator: LDProgressView?
    var progress: LDProgressView?
    var timeView: UIView?
    var currentTime: UILabel?
    var leftTime: UILabel?
    var songName: UILabel?
    var artist: PCLabel?
    var album: PCLabel?
    var playModeView: UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //播放器背景
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black
        self.backgroundView = backgroundView
        self.addSubview(backgroundView)
        //专辑封面
        let cover: UIImageView = UIImageView()
        cover.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        cover.image = UIImage(named: "noArtwork.jpg")
        self.cover = cover
        self.backgroundView?.addSubview(cover)
        //倒影封面
        let reflection: UIImageView = UIImageView()
        reflection.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        reflection.image = cover.image!.reflection(withAlpha: 0.4)
        self.backgroundView?.addSubview(reflection)
        self.backgroundView?.sendSubview(toBack: reflection)
        self.reflection = reflection
        //缓冲条
        let bufferingIndicator: LDProgressView = createProgressView(false, progress: 0, animate: false, showText: false, showStroke: false, progressInset: 0, showBackground: false, outerStrokeWidth: 0, type: LDProgressSolid, autoresizingMask: [.flexibleWidth, .flexibleTopMargin], borderRadius: 0, backgroundColor: UIColor.lightText)
        self.bufferingIndicator = bufferingIndicator
        self.backgroundView?.addSubview(bufferingIndicator)
        //进度条
        let progress: LDProgressView = createProgressView(false, progress: 0, animate: false, showText: false, showStroke: false, progressInset: 0, showBackground: false, outerStrokeWidth: 0, type: LDProgressSolid, autoresizingMask: [.flexibleWidth, .flexibleTopMargin], borderRadius: 0, backgroundColor: UIColor.clear)
        self.progress = progress
        self.backgroundView?.addSubview(progress)
        //开始时间和剩余时间
        let timeView: UIView = UIView()
        timeView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        self.backgroundView?.addSubview(timeView)
        self.timeView = timeView
        //当前播放时间
        let currentTime = createLabel([.flexibleHeight, .flexibleWidth], shadowOffset: CGSize(width: 0, height: 0), textColor: UIColor.white, text: nil, textAlignment: .left)
        self.currentTime = currentTime
        self.timeView?.addSubview(currentTime)
        //剩余时间
        let leftTime = createLabel([.flexibleHeight, .flexibleWidth, .flexibleLeftMargin], shadowOffset: CGSize(width: 0, height: 0), textColor: UIColor.white, text: nil, textAlignment: .right)
        self.timeView?.addSubview(leftTime)
        self.leftTime = leftTime
        //歌曲名
        let songName: UILabel = createLabel([.flexibleWidth, .flexibleTopMargin], shadowOffset: nil, textColor: UIColor.white, text: "尚未播放歌曲", textAlignment: .center)
        self.backgroundView?.addSubview(songName)
        self.songName = songName
        //歌手名
        let artist: PCLabel = PCLabel()
        artist.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        self.backgroundView?.addSubview(artist)
        self.artist = artist
        //专辑名
        let album: PCLabel = PCLabel()
        album.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        self.backgroundView?.addSubview(album)
        self.album = album
        //播放模式
        let playModeView: UIImageView = UIImageView()
        playModeView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        playModeView.image = UIImage(named: "repeatOnB.png")
        playModeView.contentMode = .scaleAspectFit
        self.playModeView = playModeView
        self.backgroundView?.addSubview(playModeView)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        width = self.bounds.size.width
        height = self.bounds.size.height
        self.backgroundView?.frame = self.bounds
        self.cover?.frame = CGRect(x: 0, y: 0, width: width!, height: width!)
        self.reflection?.frame = CGRect(x: 0, y: height! - width!, width: width!, height: width!)
        self.bufferingIndicator?.frame = CGRect(x: 0, y: self.cover!.frame.maxY, width: width!, height: 12)
        self.progress?.frame = CGRect(x: 0, y: self.cover!.frame.maxY, width: width!, height: 12)
        self.timeView?.frame = CGRect(x: 0, y: self.progress!.frame.maxY, width: width!, height: 25)
        self.currentTime?.frame = CGRect(x: 2, y: 0, width: width! / 2, height: (self.timeView?.bounds.size.height)!)
        self.leftTime?.frame = CGRect(x: width! / 2 - 2, y: 0, width: width! / 2, height: (self.timeView?.bounds.size.height)!)
        
        switch Int(height!) {
        case 480:
            self.songName?.frame = CGRect(x: 0, y: (self.timeView?.frame)!.maxY + 15, width: width!, height: 40)
            self.songName?.font = UIFont(name: "BebasNeue", size: 30)
            self.artist?.frame = CGRect(x: 0, y: (self.songName?.frame)!.maxY, width: width!, height: 20)
            self.album?.frame = CGRect(x: 0, y: (self.artist?.frame)!.maxY, width: width!, height: 20)
            break
        case 568:
            self.songName?.frame = CGRect(x: 0, y: (self.timeView?.frame)!.maxY + 40, width: width!, height: 40)
            self.songName?.font = UIFont(name: "BebasNeue", size: 30)
            self.artist?.frame = CGRect(x: 0, y: (self.songName?.frame)!.maxY + 15, width: width!, height: 20)
            self.album?.frame = CGRect(x: 0, y: (self.artist?.frame)!.maxY + 15, width: width!, height: 20)
            break
        case 667:
            self.songName?.frame = CGRect(x: 0, y: (self.timeView?.frame)!.maxY + 40, width: width!, height: 40)
            self.songName?.font = UIFont(name: "BebasNeue", size: 40)
            self.artist?.frame = CGRect(x: 0, y: (self.songName?.frame)!.maxY + 20, width: width!, height: 25)
            self.artist?.font = UIFont(name: "BebasNeue", size: 25)
            self.album?.frame = CGRect(x: 0, y: (self.artist?.frame)!.maxY + 20, width: width!, height: 25)
            self.album?.font = UIFont(name: "BebasNeue", size: 23)
            break
        default:
            self.songName?.frame = CGRect(x: 0, y: (self.timeView?.frame)!.maxY + 60, width: width!, height: 42)
            self.songName?.font = UIFont(name: "BebasNeue", size: 40)
            self.artist?.frame = CGRect(x: 0, y: (self.songName?.frame)!.maxY + 20, width: width!, height: 27)
            self.artist?.font = UIFont(name: "BebasNeue", size: 25)
            self.album?.frame = CGRect(x: 0, y: (self.artist?.frame)!.maxY + 20, width: width!, height: 27)
            self.album?.font = UIFont(name: "BebasNeue", size: 25)
            break
        }
        self.playModeView?.frame = CGRect(x: width! / 2 - 10, y: height! - 20, width: 20, height: 20)
    }
    
    func createProgressView(_ flat: Bool, progress: CGFloat, animate: Bool, showText: Bool, showStroke: Bool, progressInset: NSNumber, showBackground: Bool, outerStrokeWidth: NSNumber, type: LDProgressType, autoresizingMask: UIViewAutoresizing, borderRadius: NSNumber, backgroundColor: UIColor) -> LDProgressView {
        let buffer: LDProgressView = LDProgressView()
        buffer.flat = flat as NSNumber!
        buffer.progress = progress
        buffer.animate = animate as NSNumber!
        buffer.showText = showText as NSNumber!
        buffer.showStroke = showStroke as NSNumber!
        buffer.progressInset = progressInset
        buffer.showBackground = showBackground as NSNumber!
        buffer.outerStrokeWidth = outerStrokeWidth
        buffer.type = type
        buffer.borderRadius = borderRadius
        buffer.backgroundColor = backgroundColor
        buffer.autoresizingMask = autoresizingMask
        return buffer
    }
    
    func createLabel(_ autoresizingMask: UIViewAutoresizing, shadowOffset: CGSize?, textColor: UIColor, text: String?, textAlignment: NSTextAlignment) -> UILabel {
        let label: UILabel = UILabel()
        label.autoresizingMask = autoresizingMask
        label.textColor = textColor
        label.textAlignment = textAlignment
        if let unwrappedOffset = shadowOffset {
            label.shadowOffset = unwrappedOffset
        }
        if let unwrappedText = text {
            label.text = unwrappedText
        }
        return label
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
