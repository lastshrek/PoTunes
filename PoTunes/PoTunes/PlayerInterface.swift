
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
    var artist: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //播放器背景
        let backgroundView = UIView()
        backgroundView.backgroundColor = .blackColor()
        self.backgroundView = backgroundView
        self.addSubview(backgroundView)
        //专辑封面
        let cover: UIImageView = UIImageView()
        cover.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        cover.image = UIImage(named: "noArtwork.jpg")
        self.cover = cover
        self.backgroundView?.addSubview(cover)
        //倒影封面
        let reflection: UIImageView = UIImageView()
        reflection.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        reflection.image = cover.image!.reflectionWithAlpha(0.4)
        self.backgroundView?.addSubview(reflection)
        self.backgroundView?.sendSubviewToBack(reflection)
        self.reflection = reflection
        //缓冲条
        let bufferingIndicator: LDProgressView = createProgressView(false, progress: 0, animate: false, showText: false, showStroke: false, progressInset: 0, showBackground: false, outerStrokeWidth: 0, type: LDProgressSolid, autoresizingMask: [.FlexibleWidth, .FlexibleTopMargin], borderRadius: 0, backgroundColor: .lightTextColor())
        self.bufferingIndicator = bufferingIndicator
        self.backgroundView?.addSubview(bufferingIndicator)
        //进度条
        let progress: LDProgressView = createProgressView(false, progress: 0, animate: false, showText: false, showStroke: false, progressInset: 0, showBackground: false, outerStrokeWidth: 0, type: LDProgressSolid, autoresizingMask: [.FlexibleWidth, .FlexibleTopMargin], borderRadius: 0, backgroundColor: .clearColor())
        self.progress = progress
        self.backgroundView?.addSubview(progress)
        //开始时间和剩余时间
        let timeView: UIView = UIView()
        timeView.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
        self.backgroundView?.addSubview(timeView)
        self.timeView = timeView
        //当前播放时间
        let currentTime = createLabel([.FlexibleHeight, .FlexibleWidth], shadowOffset: CGSizeMake(0, 0), textColor: .whiteColor(), text: nil, textAlignment: .Left)
        self.currentTime = currentTime
        self.timeView?.addSubview(currentTime)
        //剩余时间
        let leftTime = createLabel([.FlexibleHeight, .FlexibleWidth, .FlexibleLeftMargin], shadowOffset: CGSizeMake(0, 0), textColor: .whiteColor(), text: "123", textAlignment: .Right)
        self.timeView?.addSubview(leftTime)
        self.leftTime = leftTime
        //歌曲名
        let songName = createLabel([.FlexibleWidth, .FlexibleTopMargin], shadowOffset: nil, textColor: .whiteColor(), text: "尚未播放歌曲", textAlignment: .Center)
        self.backgroundView?.addSubview(songName)
        self.songName = songName
        //歌手名
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        width = self.bounds.size.width
        height = self.bounds.size.height
        self.backgroundView?.frame = self.bounds
        self.cover?.frame = CGRectMake(0, 0, width!, width!)
        self.reflection?.frame = CGRectMake(0, height! - width!, width!, width!)
        self.bufferingIndicator?.frame = CGRectMake(0, CGRectGetMaxY(self.cover!.frame), width!, 12)
        self.progress?.frame = CGRectMake(0, CGRectGetMaxY(self.cover!.frame), width!, 12)
        self.timeView?.frame = CGRectMake(0, CGRectGetMaxY(self.progress!.frame), width!, 25)
        self.currentTime?.frame = CGRectMake(2, 0, width! / 2, (self.timeView?.bounds.size.height)!)
        self.leftTime?.frame = CGRectMake(width! / 2 - 2, 0, width! / 2, (self.timeView?.bounds.size.height)!)
    }
    
    func createProgressView(flat: Bool, progress: CGFloat, animate: Bool, showText: Bool, showStroke: Bool, progressInset: NSNumber, showBackground: Bool, outerStrokeWidth: NSNumber, type: LDProgressType, autoresizingMask: UIViewAutoresizing, borderRadius: NSNumber, backgroundColor: UIColor) -> LDProgressView {
        let buffer: LDProgressView = LDProgressView()
        buffer.flat = flat
        buffer.progress = progress
        buffer.animate = animate
        buffer.showText = showText
        buffer.showStroke = showStroke
        buffer.progressInset = progressInset
        buffer.showBackground = showBackground
        buffer.outerStrokeWidth = outerStrokeWidth
        buffer.type = type
        buffer.borderRadius = borderRadius
        buffer.backgroundColor = backgroundColor
        buffer.autoresizingMask = autoresizingMask
        return buffer
    }
    
    func createLabel(autoresizingMask: UIViewAutoresizing, shadowOffset: CGSize?, textColor: UIColor, text: String?, textAlignment: NSTextAlignment) -> UILabel {
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
