//
//  PCMyMusicViewController.h
//  PoTunes
//
//  Created by Purchas on 15/9/9.
//  Copyright © 2015年 Purchas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PCMyMusicViewController;

@protocol PCMyMusicViewControllerdelegate <NSObject>

@optional

- (void)PCMyMusicViewController:(PCMyMusicViewController *)controller isDownloadingMusic:(int)progress;

@end

@interface PCMyMusicViewController : UITableViewController

@property (nonatomic, weak) id<PCMyMusicViewControllerdelegate> delegate;

@end
