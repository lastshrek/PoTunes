//
//  PCHomeResultBtn.h
//  TicketExchange
//
//  Created by Purchas on 14/11/28.
//  Copyright (c) 2014年 Purchas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCButton : UIButton
@property (nonatomic, weak) UIImageView *normalImage;
- (instancetype)initWithFrame:(CGRect)frame image:(NSString *)image;
@end
