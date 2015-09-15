//
//  PCArticleDetailViewController.h
//  
//
//  Created by Purchas on 15/9/3.
//
//

#import <UIKit/UIKit.h>

@interface PCArticleDetailViewController : UITableViewController
/** 该页面的所有歌曲名称 */
@property (nonatomic, strong) NSMutableArray *songName;
/** 该页面的所有歌曲图片 */
@property (nonatomic, strong) NSMutableArray *songCover;
/** 该页面的所有歌曲地址 */
@property (nonatomic, strong) NSMutableArray *songURL;
/** 该页面的所有歌曲歌手名 */
@property (nonatomic, strong) NSMutableArray *artists;

@property (nonatomic, strong) NSMutableArray *songs;

@end
