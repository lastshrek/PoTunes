//
//  PCArticleCell.m
//  
//
//  Created by Purchas on 15/9/2.
//
//

#import "PCArticleCell.h"
#import "Common.h"
@implementation PCArticleCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"Article";
    PCArticleCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[PCArticleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont fontWithName:@"BebasNeue" size:18];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.contentView.layer.borderColor = PCColor(207, 22, 232, 1.0).CGColor;
        cell.contentView.layer.borderWidth = 2;
        cell.contentView.layer.cornerRadius = 5;
        cell.contentView.layer.masksToBounds = YES;
        cell.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentView.frame = CGRectMake(30, 20, self.frame.size.width - 60, self.frame.size.height - 40);
    self.imageView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height * 0.8);
    self.textLabel.frame = CGRectMake(0, self.contentView.frame.size.height * 0.8, self.contentView.frame.size.width, self.contentView.frame.size.height * 0.2);
}

@end
