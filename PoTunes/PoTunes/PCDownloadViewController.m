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
#import "PCSongListTableViewCell.h"
#import "AFNetworking.h"
#import "MBProgressHUD+MJ.h"

@interface PCDownloadViewController()<NSURLSessionDelegate>

@end


@implementation PCDownloadViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.backgroundColor = [UIColor blackColor];
    
    self.tableView.rowHeight = 80;

    [self getNotification];
    
//    NSLog(@"%@",self.title);
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
    
    [center addObserver:self selector:@selector(pop) name:@"pop" object:nil];

}

- (void)pop {
    
    [self.navigationController popToRootViewControllerAnimated:YES];

}
#pragma mark - 移除通知
- (void)dealloc {
        
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pop" object:nil];

}

#pragma mark - TableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.songs.count;

}

#pragma mark - TableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PCSongListTableViewCell *cell = [PCSongListTableViewCell cellWithTableView:tableView];
    
    PCSong *song = self.songs[indexPath.row];
    
    cell.textLabel.text = song.title;
    
    NSURL *imageURL = [NSURL URLWithString:song.thumb];
    
    [cell.imageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"songsButton"]];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",song.author];
    
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
        //发送删除消息给代理
        
        if ([self.delegate respondsToSelector:@selector(PCDownloadViewController:didDeletedSong:)]) {
           
            [self.delegate PCDownloadViewController:self didDeletedSong:song];
            
        }

        //删除tableView数据
        [self.songs removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
        
        //删除本地数据
        //检查文件是否已存在并删除之
        NSString *rootPath = [self dirDoc];
        
        NSString *filePath = [rootPath  stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ - %@.mp3",song.author,song.title]];

        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:filePath]) {
            
            [fileManager removeItemAtPath:filePath error:nil];
            
        }
        
        if (self.songs.count == 0) {
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        }
        
        
        
#warning 同时删除该专辑plist identifier;
//        //删除缓存
//        for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self dirDoc] error:nil]) {
//            if ([file hasPrefix:@"FSCache-"]) {
//                NSString *fullPath = [rootPath stringByAppendingPathComponent:file];
//                [fileManager removeItemAtPath:fullPath error:nil];
//            }
//        }

    }
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return @"你真要删呐？";
    
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
