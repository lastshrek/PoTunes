//
//  PCDownLoadedCell.m
//  PoTunes
//
//  Created by Purchas on 10/29/15.
//  Copyright © 2015 Purchas. All rights reserved.
//

#import "PCDownLoadedCell.h"
#import "Common.h"

@interface PCDownLoadedCell()


@end

@implementation PCDownLoadedCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    PCDownLoadedCell *cell = [super cellWithTableView:tableView];
    
    cell.textLabel.font = [UIFont fontWithName:@"BebasNeue" size:18];
            
    return cell;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    self.contentView.frame = self.bounds;
    self.imageView.frame = CGRectMake(10, 0, height, height);
    self.textLabel.frame = CGRectMake(height + 15, 0, width - height - 15, height);
    self.divider.frame = CGRectMake(height + 15, 0, width - height - 15, 1);
}
@end
