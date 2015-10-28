//
//  PCSongListTableViewCell.h
//  PoTunes
//
//  Created by Purchas on 15/9/28.
//  Copyright © 2015年 Purchas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EVCircularProgressView.h"

@interface PCSongListTableViewCell : UITableViewCell


@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) EVCircularProgressView *progressView;
@property (nonatomic, copy) NSString *identy;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
