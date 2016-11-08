//
//  PCSongDownloadingCell.h
//  PoTunes
//
//  Created by Purchas on 10/29/15.
//  Copyright © 2015 Purchas. All rights reserved.
//

#import "PCSongListTableViewCell.h"

@interface PCSongDownloadingCell : UITableViewCell

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) EVCircularProgressView *progressView;
@property (nonatomic, weak) UIView *divider;

+ (instancetype)cellWithTableView:(UITableView *)tableView;


@end
