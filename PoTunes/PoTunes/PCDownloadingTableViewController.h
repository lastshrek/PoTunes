//
//  PCDownloadingTableViewController.h
//  PoTunes
//
//  Created by Purchas on 10/26/15.
//  Copyright © 2015 Purchas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCDownloadingTableViewController;

@protocol PCDownloadingTableViewControllerDelegate <NSObject>

@optional

- (void)PCDownloadingTableViewController:(PCDownloadingTableViewController *)controller didClickThePauseButton:(UIButton *)button;

- (void)PCDownloadingTableViewController:(PCDownloadingTableViewController *)controller didClickTheDeleteAllButton:(UIButton *)button;

@end

@interface PCDownloadingTableViewController : UIViewController

@property (nonatomic, weak) id<PCDownloadingTableViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL paused;

@property (nonatomic, strong) NSMutableArray *downloadingArray;

@end
