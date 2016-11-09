//
//  PCDownloadViewController.h
//  PoTunes
//
//  Created by Purchas on 15/9/11.
//  Copyright © 2015年 Purchas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PCSong.h"
#import "PCSongListTableViewCell.h"
#import "AFNetworking.h"

@class PCDownloadViewController,PCSong;

@protocol PCDownloadViewControllerDelegate <NSObject>

@optional

- (void)PCDownloadViewController:(PCDownloadViewController *)controller didDeletedSong:(PCSong *)song;

@end


@interface PCDownloadViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *songs;

@property (nonatomic, weak) id<PCDownloadViewControllerDelegate> delegate;



@property (nonatomic, weak) UITableView *shareTable;

@property (nonatomic, weak) UIView *coverView;

@property (nonatomic, strong) PCSong *sharedSong;

- (NSString *)dirDoc;

- (void)shareToWeixin:(UIGestureRecognizer *)recognizer;

@end
