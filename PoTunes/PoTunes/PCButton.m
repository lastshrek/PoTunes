//
//  PCHomeResultBtn.m
//  TicketExchange
//
//  Created by Purchas on 14/11/28.
//  Copyright (c) 2014年 Purchas. All rights reserved.
//
#define PCButtonImageRatio 0.3
#import "PCButton.h"
#import "Common.h"
@implementation PCButton

- (instancetype)initWithFrame:(CGRect)frame image:(NSString *)image{
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.font = [UIFont systemFontOfSize:12];
        self.backgroundColor = [UIColor blackColor];
        self.imageView.contentMode = UIViewContentModeScaleToFill;
        UIImage *patternImage = [[UIImage imageNamed:@"barBg"] stretchableImageWithLeftCapWidth:0.5 topCapHeight:0.5];
        [self setImage:patternImage forState:UIControlStateSelected];
        
        //添加背景图片
        UIImageView *bgImage = [[UIImageView alloc] init];
        [self addSubview:bgImage];
        bgImage.image = [UIImage imageNamed:image];
        bgImage.contentMode = UIViewContentModeScaleToFill;
        self.normalImage = bgImage;
    }
    return self;
}
- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGFloat imageW = contentRect.size.width;
    CGFloat imageH = contentRect.size.height * 0.1;
    return CGRectMake(0, 0, imageW, imageH);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.normalImage.frame = CGRectMake((self.bounds.size.width - 25) / 2, 20, 30, 30);
}
- (void)setHighlighted:(BOOL)highlighted {}
@end
