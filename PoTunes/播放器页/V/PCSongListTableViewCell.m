//
//  PCSongListTableViewCell.m
//  PoTunes
//
//  Created by Purchas on 15/9/28.
//  Copyright © 2015年 Purchas. All rights reserved.
//

#import "PCSongListTableViewCell.h"
#import "AFNetworking.h"

@interface PCSongListTableViewCell()


@end

@implementation PCSongListTableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"Song";
    
    PCSongListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[PCSongListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.backgroundColor = [UIColor blackColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.detailTextLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        cell.textLabel.font = [UIFont fontWithName:@"BebasNeue" size:26];
        cell.detailTextLabel.font = [UIFont fontWithName:@"BebasNeue" size:12];
        //添加divider
        UIView *divider = [[UIView alloc] init];
//        divider.backgroundColor = PCColor(207, 22, 232, 1.0);
        cell.divider = divider;
        [cell.contentView addSubview:divider];
        //button
        EVCircularProgressView *progressView = [[EVCircularProgressView alloc] init];
        cell.accessoryView = progressView;
//        progressView.tintColor = PCColor(207, 22, 232, 1.0);
        cell.progressView = progressView;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    return cell;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    self.contentView.frame = self.bounds;
    self.progressView.frame = self.accessoryView.frame;
    self.imageView.frame = CGRectMake(10, 0, height, height);
    self.textLabel.frame = CGRectMake(height + 15, 10, CGRectGetMinX(self.progressView.frame) - height - 15, height * 0.6);
    self.detailTextLabel.frame = CGRectMake(height + 15, height * 0.6,  width - height - 15, height * 0.3);
    self.divider.frame = CGRectMake(height + 15, 0, width - height - 15, 1);
}

- (void)updateProgressCircle:(CGFloat)progress {
    self.progress = progress;
}



- (NSString *)dirDoc{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}
@end
