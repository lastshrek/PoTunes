//
//  PCArticleCell.m
//  
//
//  Created by Purchas on 15/9/2.
//
//

#import "PCArticleCell.h"
#import "Common.h"

@interface PCArticleCell ()

@property (nonatomic, weak) UIView *foregroundView;

@end

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
        
        cell.backgroundColor = [UIColor clearColor];
        
        //前景
        UIView *foregroundView = [[UIView alloc] init];
        
        foregroundView.backgroundColor = [UIColor blackColor];
        
        foregroundView.alpha = 0.4;
        
        cell.foregroundView = foregroundView;
        
        [cell.contentView addSubview:foregroundView];
        
        [cell.contentView bringSubviewToFront:cell.textLabel];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    }
    
    return cell;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
    
    self.imageView.frame = self.bounds;
    
    self.foregroundView.frame = self.bounds;
    
    self.textLabel.frame = self.contentView.bounds;
}

@end
