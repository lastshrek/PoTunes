//
//  PCDownloadViewController.h
//  PoTunes
//
//  Created by Purchas on 15/9/11.
//  Copyright © 2015年 Purchas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCDownloadViewController,PCSong;

@protocol PCDownloadViewControllerDelegate <NSObject>

@optional

- (void)PCDownloadViewController:(PCDownloadViewController *)controller didDeletedSong:(PCSong *)song;

@end


@interface PCDownloadViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *songs;

@property (nonatomic, weak) id<PCDownloadViewControllerDelegate> delegate;



@end
