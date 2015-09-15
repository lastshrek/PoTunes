//
//  PCDownloadViewController.h
//  PoTunes
//
//  Created by Purchas on 15/9/11.
//  Copyright © 2015年 Purchas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PCDownloadViewController : UITableViewController

/** 该页面的所有歌曲名称 */
@property (nonatomic, strong) NSMutableArray *songName;
/** 该页面的所有歌曲图片 */
@property (nonatomic, strong) NSMutableArray *songCover;
/** 该页面的所有歌曲地址 */
@property (nonatomic, strong) NSMutableArray *songURL;
/** 该页面的所有歌曲歌手名 */
@property (nonatomic, strong) NSMutableArray *artists;
/** 该页面所有歌曲所在专辑索引 */
@property (nonatomic, strong) NSMutableArray *indexes;

@property (nonatomic, strong) NSMutableArray *songs;

@end
