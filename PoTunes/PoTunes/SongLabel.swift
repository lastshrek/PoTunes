//
//  SongLabel.swift
//  破音万里
//
//  Created by Purchas on 16/8/14.
//  Copyright © 2016年 Purchas. All rights reserved.
//

import UIKit

class SongLabel: UILabel {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.font = UIFont(name: "BebasNeue", size: 14)
        self.textColor = .whiteColor()
        self.textAlignment = .Center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawTextInRect(rect: CGRect) {
        let shadowOffset: CGSize = self.shadowOffset
        let textColor = self.textColor
        
        let c: CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSetLineWidth(c, 1)
        CGContextSetLineJoin(c, .Round)
        
        CGContextSetTextDrawingMode(c, .Stroke)
        self.textColor = .whiteColor()
        super.drawTextInRect(rect)
        
        CGContextSetTextDrawingMode(c, .Fill)
        self.textColor = textColor
        self.shadowOffset = CGSizeMake(0, 0)
        super.drawTextInRect(rect)
        
        self.shadowOffset = shadowOffset
    }

}
