//
//  PCLabel.m
//  PoTunes
//
//  Created by Purchas on 15/9/1.
//  Copyright © 2015年 Purchas. All rights reserved.
//

#import "PCLabel.h"
#import "Common.h"
@implementation PCLabel

- (instancetype)init {
    if (self = [super init]) {
        self.font = [UIFont fontWithName:@"BebasNeue" size:14];
        self.textColor = [UIColor whiteColor];
        self.textAlignment = NSTextAlignmentCenter;
//        self.shadowColor = [UIColor blackColor];
//        self.shadowOffset = CGSizeMake(-2, 3);
    }
    return self;
}


- (void)drawTextInRect:(CGRect)rect {
    
    CGSize shadowOffset = self.shadowOffset;
    UIColor *textColor = self.textColor;
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(c, 1);
    CGContextSetLineJoin(c, kCGLineJoinRound);
    
    CGContextSetTextDrawingMode(c, kCGTextStroke);
    self.textColor = [UIColor whiteColor];
    [super drawTextInRect:rect];
    
    CGContextSetTextDrawingMode(c, kCGTextFill);
    self.textColor = textColor;
    self.shadowOffset = CGSizeMake(0, 0);
    [super drawTextInRect:rect];
    
    self.shadowOffset = shadowOffset;
    
}

@end
