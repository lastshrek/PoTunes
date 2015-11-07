//
//  PCSongDetailViewController.m
//  PoTunes
//
//  Created by Purchas on 11/1/15.
//  Copyright © 2015 Purchas. All rights reserved.
//

#import "PCSongDetailViewController.h"
#import "FMDB.h"
@interface PCSongDetailViewController ()



/** 下载歌曲数据库 */
@property (nonatomic, strong) FMDatabase *downloadedSongDB;

@end

@implementation PCSongDetailViewController

- (FMDatabase *)downloadedSongDB {
    
    if (_downloadedSongDB == nil) {
        
        //打开数据库
        NSString *path = [[self dirDoc] stringByAppendingPathComponent:@"downloadingSong.db"];
        
        _downloadedSongDB = [FMDatabase databaseWithPath:path];
        
        [_downloadedSongDB open];
        
        //创表
        
        
        [_downloadedSongDB executeUpdate:@"CREATE TABLE IF NOT EXISTS t_downloading (id integer PRIMARY KEY, author text, title text, sourceURL text,indexPath integer,thumb text,album text,downloaded bool);"];
        
        _downloadedSongDB.shouldCacheStatements = YES;
        
    }
    
    return _downloadedSongDB;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (tableView.tag != 2) {
        
        PCSongListTableViewCell *cell = [PCSongListTableViewCell cellWithTableView:tableView];
        
        PCSong *song = self.songs[indexPath.row];
        
        cell.textLabel.text = song.title;
        
        cell.detailTextLabel.text = song.author;
        
        NSURL *imageURL = [NSURL URLWithString:song.thumb];
        
        [cell.imageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"defaultCover"]];
        
        cell.progressView.hidden = YES;
        
        //添加下载手势
        UISwipeGestureRecognizer *downloadSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(download:)];
        
        [downloadSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
        
        downloadSwipe.numberOfTouchesRequired = 1;
        
        [cell addGestureRecognizer:downloadSwipe];
        
        //添加分享手势
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(shareToWeixin:)];
        
        [cell addGestureRecognizer:longPress];
        
        return cell;
        
    } else {
        
        static NSString *ID = @"weixin";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
        
        if (cell == nil) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
            
            if (indexPath.row == 0) {
                
                cell.textLabel.text = @"分享给微信好友";
                
                cell.imageView.image = [UIImage imageNamed:@"cm2_mlogo_weixin"];
                
            } else {
                
                cell.textLabel.text = @"分享到微信朋友圈";
                
                cell.imageView.image = [UIImage imageNamed:@"cm2_mlogo_pyq"];
                
            }
            
        }
        
        return cell;
        
    }
}

#pragma mark - 下载
- (void)download:(UIGestureRecognizer *)recognizer {
    
    CGPoint position = [recognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:position];
    
    PCSong *song = self.songs[indexPath.row];
    
    song.position = [NSNumber numberWithInteger:indexPath.row];
    
    NSString *author = [song.author stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    NSString *title = [song.title stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM t_downloading WHERE author = '%@' and title = '%@';", author, title];
    
    FMResultSet *s = [self.downloadedSongDB executeQuery:query];
    
    if (s.next) {
        
        BOOL downloaded = [s stringForColumn:@"downloaded"];
        
        if (downloaded) {
            
            [MBProgressHUD showError:@"歌曲已下载"];
            
            return;
            
        } else {
            
            [MBProgressHUD showError:@"歌曲正在下载中"];
            
        }
    
    } else {
        
        NSString *identifier = [NSString stringWithFormat:@"%@ - %@",song.author,song.title];

        
        NSNotification *download = [NSNotification notificationWithName:@"download" object:nil userInfo:
                                    @{@"indexPath":[NSNumber numberWithInteger:indexPath.row],
                                      @"songs":self.songs,
                                      @"title":self.title,
                                      @"identifier":identifier}];
        
        [[NSNotificationCenter defaultCenter] postNotification:download];
        
        [MBProgressHUD showSuccess:@"开始下载"];

    }
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
    
}

@end
