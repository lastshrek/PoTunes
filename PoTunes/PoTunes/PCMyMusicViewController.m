//
//  PCMyMusicViewController.m
//  PoTunes
//
//  Created by Purchas on 15/9/9.
//  Copyright © 2015年 Purchas. All rights reserved.
//

#import "PCMyMusicViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD+MJ.h"
#import "UIImageView+WebCache.h"
#import "PCSong.h"
#import "PCDownloadViewController.h"
#import "Common.h"
#import "PCDownLoadedCell.h"
#import "FMDB.h"
#import "PCDownloadingTableViewController.h"
#import "DBHelper.h"
@interface PCMyMusicViewController()<PCDownloadingTableViewControllerDelegate, PCDownloadViewControllerDelegate>
/** 下载专辑 */
@property (nonatomic, strong) NSMutableArray *downloadAlbums;
/** 正在下载的歌曲 */
@property (nonatomic, strong) NSMutableArray *downloadingArray;

/** 下载op */
@property (nonatomic, strong) AFHTTPRequestOperation *op;
/** 数据库Queue */
@property(nonatomic,strong) FMDatabaseQueue *queue;

@property (nonatomic, strong) DBHelper *helper;


@end

@implementation PCMyMusicViewController




- (FMDatabaseQueue *)queue {
    
    if (_queue == nil) {
        
        //打开数据库        
        DBHelper *helper = [DBHelper getSharedInstance];
        
        self.helper = helper;
        
        [helper inDatabase:^(FMDatabase *db) {
            
            [db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_downloading (id integer PRIMARY KEY, author text, title text, sourceURL text,indexPath integer,thumb text,album text,downloaded bool);"];
            
        }];
        
        _queue = helper.queue;
    }
    
    return _queue;
}

- (NSMutableArray *)downloadAlbums {
    
    if (_downloadAlbums == nil) {
        
        _downloadAlbums = [NSMutableArray array];
        
        //查询专辑名称并去掉重复
        NSString *distinct = [NSString stringWithFormat:@"SELECT distinct album FROM t_downloading;"];
        
        NSMutableArray *tempArray = [NSMutableArray array];

        
        [self.queue inDatabase:^(FMDatabase *db) {
            
            FMResultSet *s = [db executeQuery:distinct];
            
            while (s.next) {

                NSString *album = [s stringForColumn:@"album"];
                
                [tempArray addObject:album];
            }
            
            _downloadAlbums = tempArray;
            
            [s close];
        }];
        
        
        
    }
    
    return _downloadAlbums;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor blackColor];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //初始化已下载专辑数组
//    self.downloadAlbums = [self setArrayWithPlistName:@"albumdownloaded.plist"];
    
    //去掉重复
    
    
    
    //初始化正在下载歌曲数组
    self.downloadingArray = [self setArrayWithPlistName:@"downloading.plist"];
    
    self.helper = [DBHelper getSharedInstance];

    /** 注册通知 */
    [self getNotification];
    
}

- (NSMutableArray *)setArrayWithPlistName:(NSString *)name {
    
    NSString *rootPath = [self dirDoc];
    
    NSString *filePath = [rootPath  stringByAppendingPathComponent:name];
    
    NSArray *dictArray= [NSArray arrayWithContentsOfFile:filePath];
    
    NSMutableArray *thisArray = [NSMutableArray array];
    
    if (dictArray == nil) {
        
        return thisArray;
        
    } else {
        
        NSMutableArray *contentArray = [NSMutableArray array];
        
        for (NSDictionary *dict in dictArray) {
            
            [contentArray addObject:dict];
            
        }
        
        return contentArray;
    }
}

#pragma mark - 获取通知
- (void)getNotification {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
   
    [center addObserver:self selector:@selector(download:) name:@"download" object:nil];
    
    [center addObserver:self selector:@selector(fullAlbum:) name:@"fullAlbum" object:nil];
    

}

- (void)download:(NSNotification *)sender {
    
    NSString *doc = [self dirDoc];
    
    //获取通知内容
    NSArray *songs = sender.userInfo[@"songs"];
    
    NSNumber *indexPath = sender.userInfo[@"indexPath"];
    
    NSString *identifier = sender.userInfo[@"identifier"];

    PCSong *song = songs[[indexPath integerValue]];
    
    //添加到下载歌曲队列
    
    [self.downloadingArray addObject:identifier];
    
    if (self.op == nil || self.op.isCancelled || self.op.isFinished || self.op.isPaused) {
        
        [self beginDownloadWithIdentifier:identifier URL:song.sourceURL];

    }

    [self beginDownloadLyricWithIdentifier:identifier URL:song.lrc];
    //写入正在下载歌曲plist
    [self writeToDownloadingPlist:self.downloadingArray WithName:@"downloading.plist"];

    //添加到下载队列 先处理带有单引号歌曲名称
    NSString *artist = [song.author stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    NSString *songName = [song.title stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    NSString *album = [[[sender.userInfo[@"title"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"] componentsSeparatedByString:@" - "] lastObject];
    
    NSString *sql = [NSString stringWithFormat: @"INSERT INTO t_downloading(author,title,sourceURL,indexPath,thumb,album,downloaded) VALUES('%@','%@','%@','%ld','%@','%@','0');",artist,songName,song.sourceURL,[indexPath integerValue],song.thumb,album];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:sql];

    }];
    


    //初始化专辑表

    if ([self.downloadAlbums indexOfObject:song.album] != NSNotFound) return;
       
    [self.downloadAlbums addObject:album];
    
    NSString *path = [doc stringByAppendingPathComponent:@"albumdownloaded.plist"];
    
     //3. 写入数组
    
    [self.downloadAlbums writeToFile:path atomically:YES];
    
    
    [self.tableView reloadData];
        
    
}

- (void)fullAlbum:(NSNotification *)sender {
    
    NSString *doc = [self dirDoc];

    //获取通知内容
    
    NSMutableArray *songArray = sender.userInfo[@"songs"];
    
    NSString *album = sender.userInfo[@"title"];
    
    if ([self.downloadAlbums indexOfObject:album] == NSNotFound) {
        
        [self.downloadAlbums addObject:album];
        
        NSString *path = [doc stringByAppendingPathComponent:@"albumdownloaded.plist"];
        
        //3. 写入数组
        
        [self.downloadAlbums writeToFile:path atomically:YES];
        
        [self.tableView reloadData];


    }
    
    for (PCSong *song in songArray) {
        
        NSString *identifier = [NSString stringWithFormat:@"%@ - %@",song.author, song.title];
        
        if ([self.downloadingArray indexOfObject:identifier] == NSNotFound) {
            
            [self.downloadingArray addObject:identifier];
        }
        
        if (self.op == nil || self.op.isCancelled || self.op.isFinished || self.op.isPaused) {
            
            [self beginDownloadWithIdentifier:identifier URL:song.sourceURL];
            
        }
        
        //写入正在下载歌曲plist
        [self writeToDownloadingPlist:self.downloadingArray WithName:@"downloading.plist"];
        
        //添加到下载队列 先处理带有单引号歌曲名称
        NSString *artist = [song.author stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        
        NSString *songName = [song.title stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        
        NSString *album = [sender.userInfo[@"title"] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        

        
        NSString *sql = [NSString stringWithFormat: @"INSERT INTO t_downloading(author,title,sourceURL,indexPath,thumb,album,downloaded) VALUES('%@','%@','%@','%ld','%@','%@','0');",artist,songName,song.sourceURL,[song.position integerValue],song.thumb,album];
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            
                [db executeUpdate:sql];
                
            }];
        });
        
        [self beginDownloadLyricWithIdentifier:identifier URL:song.lrc];
    }
}
/** 下载歌曲 */
- (void)beginDownloadWithIdentifier:(NSString *)identifier URL:(NSString *)URLString{
    
    NSString *rootPath = [self dirDoc];
    
    //保存路径
    NSString *filePath = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", identifier]];
    
    filePath = [filePath stringByReplacingOccurrencesOfString:@" / " withString:@" "];
    
    //初始化队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSURL *URL = [NSURL URLWithString:URLString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    self.op = op;
    
    op.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    dict[@"identifier"] = identifier;
    
    for (int i = 0; i < self.downloadingArray.count; i++) {
        
        if ([identifier isEqualToString:self.downloadingArray[i]]) {
            
            dict[@"index"] = [NSNumber numberWithInt:i];
            
        }
    }

    
    [op setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        
        double downloadProgress = totalBytesRead / (double)totalBytesExpectedToRead;
        
        int progress = downloadProgress * 100;
        
        if (progress % 10 == 0) {
            NSNotification *percent = [NSNotification notificationWithName:@"percent"
                                                                    object:nil
                                                                  userInfo:@{@"percent":@(downloadProgress),@"index":dict[@"index"]}];
            
            [[NSNotificationCenter defaultCenter] postNotification:percent];

        }
    }];
    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //改变歌曲下载状态
        NSArray *separatedArray = [identifier componentsSeparatedByString:@" - "];
        
        [self.helper.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            
            [db executeUpdate:@"UPDATE t_downloading SET downloaded = 1 WHERE author = ? and title = ?",separatedArray[0], separatedArray[1]];
            
        }];



        //删除已下载完歌曲的identifier及相关信息
        
        [self.downloadingArray removeObjectAtIndex:[dict[@"index"] integerValue]];
        
        [self writeToDownloadingPlist:self.downloadingArray WithName:@"downloading.plist"];
        
        //发送下载完成通知
        
        NSNotification *downloadComplete = [NSNotification notificationWithName:@"downloadComplete" object:nil userInfo:dict];
        
        [[NSNotificationCenter defaultCenter] postNotification:downloadComplete];
        
        //继续下载未完成歌曲
        if (self.downloadingArray.count != 0) {
            
            NSString *identifier;
            
            if (self.downloadingArray.count > [dict[@"index"] integerValue]) {
                
                identifier = self.downloadingArray[[dict[@"index"] integerValue]];
            
            } else {
                
                identifier = self.downloadingArray[0];
                
            }
            
            
            NSArray *separatedArray = [identifier componentsSeparatedByString:@" - "];
            
            NSString *author = [separatedArray[0] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            
            NSString *title = [separatedArray[1] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            
            NSString *query = [NSString stringWithFormat:@"SELECT * FROM t_downloading WHERE author = '%@' and title = '%@';", author, title];
            
            [self.queue inDatabase:^(FMDatabase *db) {
                
                FMResultSet *s = [db executeQuery:query];
                
                if (s.next) {
                    
                    NSString *URLStr = [s stringForColumn:@"sourceURL"];
                    
                    [self beginDownloadWithIdentifier:identifier URL:URLStr];
                    
                }
                
                [s close];

            }];
            
            
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"%@",error);
        
    }];
    
    //开始下载
    [queue addOperation:op];
}

- (void)beginDownloadLyricWithIdentifier:(NSString *)identifier URL:(NSString *)URLString {
    
    NSString *rootPath = [self dirDoc];
    
    //保存路径
    NSString *filePath = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.lrc", identifier]];
    
    filePath = [filePath stringByReplacingOccurrencesOfString:@" / " withString:@" "];
    
    //初始化队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSURL *URL = [NSURL URLWithString:URLString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    op.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
    //开始下载
    [queue addOperation:op];
}

- (void)writeToDownloadingPlist:(NSArray *)array WithName:(NSString *)name {
    
    NSString *doc = [self dirDoc];

    NSString *path = [doc stringByAppendingPathComponent:name];
    
    [array writeToFile:path atomically:YES];

}

#pragma mark - 移除通知
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"download" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"fullAlbum" object:nil];

    
}
#pragma mark - 获取文件主路径
- (NSString *)dirDoc {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
   
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    if (section == 0) {
    
        return 1;
        
    } else {
        
        return self.downloadAlbums.count;
    }
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PCDownLoadedCell *cell = [PCDownLoadedCell cellWithTableView:tableView];
    
    if (indexPath.section == 0) {
       
        cell.imageView.image = [UIImage imageNamed:@"noArtwork.jpg"];
        
        cell.textLabel.text = @"正在下载";
        
    } else {
        
        NSString *album = self.downloadAlbums[indexPath.row];
        
        cell.textLabel.text = album;
        
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM t_downloading WHERE album = '%@';",album];
        
        [self.queue inDatabase:^(FMDatabase *db) {
            
            FMResultSet *s = [db executeQuery:query];
            
            if ([s next]) {
                
                NSString *URLStr = [s stringForColumn:@"thumb"];
                
                NSURL *URL = [NSURL URLWithString:URLStr];
                
                [cell.imageView sd_setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"defaultCover"]];
                
            }
            
            [s close];

        }];

        
    }
    
    cell.progressView.hidden = YES;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}
//跳转至已下载歌曲页面
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        
        PCDownloadViewController *download = [[PCDownloadViewController alloc] init];
        
        NSMutableArray *songArray = [NSMutableArray array];
        
        NSString *title = self.downloadAlbums[indexPath.row];
        
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM t_downloading WHERE album = '%@' and downloaded = 1;",title];
        
        [self.queue inDatabase:^(FMDatabase *db) {
        
            FMResultSet *s = [db executeQuery:query];

            PCSongListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            NSString *album = [[cell.textLabel.text componentsSeparatedByString:@" – "] lastObject];
            
            while ([s next]) {
                
                PCSong *song = [[PCSong alloc] init];
                
                song.author = [s stringForColumn:@"author"];
                
                song.title = [s stringForColumn:@"title"];
                
                song.sourceURL = [s stringForColumn:@"sourceURL"];
                
                NSInteger index = [[s stringForColumn:@"indexPath"] integerValue];
                
                song.position = [NSNumber numberWithInteger:index];
                
                song.thumb = [s stringForColumn:@"thumb"];
                
                song.album = album;
                
                [songArray addObject:song];
                
            }
            
            [s close];
        }];
        
        
        
        
        //根据歌曲序号进行排序
        
        download.songs = [self sort:songArray];
        
        download.delegate = self;
        
        [self.navigationController pushViewController:download animated:YES];
        
    } else {
        
        PCDownloadingTableViewController *downloading = [[PCDownloadingTableViewController alloc] init];
        
        downloading.downloadingArray = self.downloadingArray;
        
        if (self.op == nil || self.op.isPaused == 1) {
            
            downloading.paused = 1;

        } else {
            
            downloading.paused = 0;
        }
        
        downloading.delegate = self;
        
        [self.navigationController pushViewController:downloading animated:YES];
    }
}

//选择排序
- (NSMutableArray *)sort:(NSMutableArray *)arr {
    for (int i = 0; i < arr.count; i ++) {
        
        for (int j = i + 1; j < arr.count; j ++) {
        
            PCSong *foreSong = arr[i];
            
            PCSong *backSong = arr[j];
            
            if (foreSong.position > backSong.position) {
                
                arr[i] = backSong;
                
                arr[j] = foreSong;
            }
        }
    }
    
    return arr;
}
#pragma mark - PCDownloadingTableViewControllerDelegate
- (void)PCDownloadingTableViewController:(PCDownloadingTableViewController *)controller didClickThePauseButton:(UIButton *)button {
    
    if (self.op == nil) {
        
        NSString *identifier = self.downloadingArray[0];
        
        NSArray *separatedArray = [identifier componentsSeparatedByString:@" - "];
        
        NSString *author = [separatedArray[0] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        
        NSString *title = [separatedArray[1] stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM t_downloading WHERE author = '%@' and title = '%@';", author, title];
        
        [self.queue inDatabase:^(FMDatabase *db) {
            
            FMResultSet *s = [db executeQuery:query];
            
            if (s.next) {
                
                NSString *URLStr = [s stringForColumn:@"sourceURL"];
                
                [self beginDownloadWithIdentifier:identifier URL:URLStr];
                
            }
            
            [s close];

        }];
        
        return;
    }
    
    if (self.op.isPaused) {
        
        [self.op resume];
        
    } else {
        
        [self.op pause];
    
    }
}

- (void)PCDownloadingTableViewController:(PCDownloadingTableViewController *)controller didClickTheDeleteAllButton:(UIButton *)button {
    
    [self.op cancel];
    
    //删除本地文件
    NSString *select = [NSString stringWithFormat:@"SELECT * FROM t_downloading WHERE downloaded = 0;"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *rootPath = [self dirDoc];
    
    
    [self.queue inDatabase:^(FMDatabase *db) {
       
        FMResultSet *s = [db executeQuery:select];
        
        while (s.next) {
            
            NSString *identifier = [NSString stringWithFormat:@"%@ - %@",[s stringForColumn:@"author"], [s stringForColumn:@"title"]];
            
            NSString *filePath = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3", identifier]];
            
            filePath = [filePath stringByReplacingOccurrencesOfString:@" / " withString:@" "];
            
            [fileManager removeItemAtPath:filePath error:nil];
            
        }
        
        [s close];

    }];
    
    

    //删除数据库中未下载文件
    NSString *delete = [NSString stringWithFormat:@"DELETE FROM t_downloading WHERE downloaded = 0;"];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:delete];
    
    }];
    
    //查询专辑名称并去掉重复
    NSString *distinct = [NSString stringWithFormat:@"SELECT distinct album FROM t_downloading;"];
    
    NSMutableArray *tempArray = [NSMutableArray array];
    
    
    [self.queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *s = [db executeQuery:distinct];
        
        while (s.next) {
            
            NSString *album = [s stringForColumn:@"album"];
            
            [tempArray addObject:album];
        }
        
        self.downloadAlbums = tempArray;
        
        [s close];
    }];
    
    [self.downloadingArray removeAllObjects];
    
    [self.tableView reloadData];
    

}

#pragma mark - PCDownloadViewControllerDelegate

- (void)PCDownloadViewController:(PCDownloadViewController *)controller didDeletedSong:(PCSong *)song {
    
    NSString *author = [song.author stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    NSString *title = [song.title stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    NSString *album = [song.album stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    NSString *delete = [NSString stringWithFormat:@"DELETE FROM t_downloading WHERE author = '%@' and title = '%@';", author, title];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        
        [db executeUpdate:delete];

    }];
    
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM t_downloading WHERE album = '%@';",album];
    
    [self.queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *s = [db executeQuery:query];
        
        if (!s.next) {
            
            for (int i = 0 ; i < self.downloadAlbums.count ; i++ ) {
                
                if ([song.album isEqualToString:self.downloadAlbums[i]]) {
                    
                    [self.downloadAlbums removeObjectAtIndex:i];
                    
                    [self writeToDownloadingPlist:self.downloadAlbums WithName:@"albumdownloaded.plist"];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.tableView reloadData];
                        
                    });
                    
                    break;
                }
            }
        }

        [s close];

    }];
    
}

@end
