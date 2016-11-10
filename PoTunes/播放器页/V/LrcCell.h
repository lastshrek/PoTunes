

#import <UIKit/UIKit.h>
@class lrcLine;

@interface LrcCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property (nonatomic, strong) lrcLine *lrcLine;
@end
