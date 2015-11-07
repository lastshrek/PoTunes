//
//  PCSongDownloadingCell.m
//  PoTunes
//
//  Created by Purchas on 10/29/15.
//  Copyright © 2015 Purchas. All rights reserved.
//

#import "PCSongDownloadingCell.h"
#import "Common.h"
@implementation PCSongDownloadingCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"Song";
    
    PCSongDownloadingCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[PCSongDownloadingCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.backgroundColor = [UIColor blackColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.font = [UIFont fontWithName:@"BebasNeue" size:14];
        //添加divider
        UIView *divider = [[UIView alloc] init];
        divider.backgroundColor = PCColor(207, 22, 232, 1.0);
        cell.divider = divider;
        [cell.contentView addSubview:divider];
        //button
        EVCircularProgressView *progressView = [[EVCircularProgressView alloc] init];
        cell.accessoryView = progressView;
        progressView.tintColor = PCColor(207, 22, 232, 1.0);
        cell.progressView = progressView;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return cell;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    self.textLabel.frame = CGRectMake(15, 0, width, height);
    self.divider.frame = CGRectMake(0, 0, width, 1);
}

@end
