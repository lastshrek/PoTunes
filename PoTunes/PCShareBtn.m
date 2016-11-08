//
//  PCDayBtn.m
//  holdMinHand
//
//  Created by Purchas on 15/6/24.
//  Copyright (c) 2015年 Purchas. All rights reserved.
//

#import "PCShareBtn.h"
#import "Common.h"
@implementation PCShareBtn

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title {
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.font = [UIFont systemFontOfSize:12];
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        self.layer.borderColor = PCColor(207, 22, 232, 1.0).CGColor;
        self.layer.borderWidth = 2;
        self.backgroundColor = [UIColor blackColor];
        self.titleLabel.font = [UIFont systemFontOfSize:15];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setTitle:title forState:UIControlStateNormal];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}


- (void)setHighlighted:(BOOL)highlighted {}

@end
