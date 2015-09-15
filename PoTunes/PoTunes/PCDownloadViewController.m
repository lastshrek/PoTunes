//
//  PCDownloadViewController.m
//  PoTunes
//
//  Created by Purchas on 15/9/11.
//  Copyright © 2015年 Purchas. All rights reserved.
//

#import "PCDownloadViewController.h"
#import "PCSong.h"
#import "UIImageView+WebCache.h"
@implementation PCDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.rowHeight = 80;

    //创建歌曲模型！
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i = 0; i < self.songName.count; i++) {
        
        PCSong *song = [[PCSong alloc] init];
        song.album = self.title;
        song.artist = self.artists[i];
        song.songName = self.songName[i];
        song.cover = self.songCover[i];
        song.URL = self.songURL[i];
        song.index = self.indexes[i];
        [tempArray addObject:song];
    }
    self.songs = tempArray;
    /** 获取通知 */
    [self getNotification];
}
#pragma mark - 获取文件主路径
- (NSString *)dirDoc{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}
#pragma mark - 获取通知
- (void)getNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(download:) name:@"download" object:nil];
    
}

- (void)download:(NSNotification *)sender {
    NSNumber *index = sender.userInfo[@"indexPath"];
    NSArray *songArray = sender.userInfo[@"songs"];
    PCSong *song = songArray[[index intValue]];
    song.index = index;

    PCSong *existSong = self.songs[0];
    if ([song.album isEqualToString:existSong.album]) {
        [self.songs addObject:song];
        [self.tableView reloadData];
    }
    
}

#pragma mark - 移除通知
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"download" object:nil];
}


#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"Song";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    PCSong *song = self.songs[indexPath.row];
    cell.textLabel.text = song.songName;
    NSURL *imageURL = [NSURL URLWithString:song.cover];
    cell.imageView.frame = CGRectMake(0, 0, cell.frame.size.height, cell.frame.size.height);
    [cell.imageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"defaultCover"]];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",song.album];
    cell.backgroundColor = [UIColor blackColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"BebasNeue" size:26];
    cell.detailTextLabel.font = [UIFont fontWithName:@"BebasNeue" size:12];

    return cell;
}

/** 删除 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

/**
 *  删除歌曲
 *
 *  @param tableView    歌曲列表
 *  @param editingStyle 修改类型
 *  @param indexPath    所在行号
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PCSong *song = self.songs[indexPath.row];
        //发送删除通知
        NSNotification *delete = [NSNotification notificationWithName:@"delete" object:nil userInfo:
                                  @{@"song":song,@"indexPath":[NSNumber numberWithInteger:indexPath.row]}];
        [[NSNotificationCenter defaultCenter] postNotification:delete];
        //删除tableView数据
        [self.songs removeObjectAtIndex:[indexPath row]];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
        //删除本地数据
        //检查文件是否已存在并删除之
        NSString *rootPath = [self dirDoc];
        NSString *filePath = [rootPath  stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ - %@.mp3",song.artist,song.songName]];

        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:filePath]) {
            [fileManager removeItemAtPath:filePath error:nil];
        }
        
        //删除缓存
        for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self dirDoc] error:nil]) {
            if ([file hasPrefix:@"FSCache-"]) {
                NSString *fullPath = [rootPath stringByAppendingPathComponent:file];
                [fileManager removeItemAtPath:fullPath error:nil];
            }
        }

    }
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
#pragma mark - 立即播放
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSNotification *select = [NSNotification notificationWithName:@"selected" object:nil userInfo:
                              @{@"indexPath":[NSNumber numberWithInteger:indexPath.row],
                                @"songs":self.songs}];
    [[NSNotificationCenter defaultCenter] postNotification:select];
    
}

@end
