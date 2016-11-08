//
//  PCDownloadViewController.m
//  PoTunes
//
//  Created by Purchas on 15/9/11.
//  Copyright © 2015年 Purchas. All rights reserved.
//

#import "PCDownloadViewController.h"
#import "WXApiObject.h"
#import "WXApi.h"

@interface PCDownloadViewController()



@end


@implementation PCDownloadViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.backgroundColor = [UIColor blackColor];
    
    self.tableView.rowHeight = 66;

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
    
    [center addObserver:self selector:@selector(pop) name:@"pop" object:nil];

}

- (void)pop {
    
    [self.navigationController popToRootViewControllerAnimated:YES];

}
#pragma mark - 移除通知
- (void)dealloc {
        
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pop" object:nil];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView.tag == 2) {
        
        return 2;
        
    } else {
        
        return self.songs.count;
        
    }
    
}

#pragma mark - TableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.tag != 2) {
        
        PCSongListTableViewCell *cell = [PCSongListTableViewCell cellWithTableView:tableView];
        
        PCSong *song = self.songs[indexPath.row];
        
        cell.textLabel.text = song.title;
        
        cell.detailTextLabel.text = song.author;
        
        NSURL *imageURL = [NSURL URLWithString:song.thumb];
        
        [cell.imageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"defaultCover"]];
        
        cell.progressView.hidden = YES;
        
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

/** 删除 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
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
        
        //检查文件是否已存在并删除之
        NSString *rootPath = [self dirDoc];
        
        NSArray *urlComponent = [song.sourceURL componentsSeparatedByString:@"/"];
        
        NSInteger count = urlComponent.count;
        
        NSString *identifier = [NSString stringWithFormat:@"%@%@%@",urlComponent[count - 3], urlComponent[count - 2], urlComponent[count - 1]];
        
        NSString *filePath = [rootPath  stringByAppendingPathComponent:identifier];

        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        if ([fileManager fileExistsAtPath:filePath]) {
            
            [fileManager removeItemAtPath:filePath error:nil];
            
        }
        
        if (self.songs.count == 0) {
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        }
    }
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return @"你真要删呐？";
    
}
#pragma mark - 立即播放
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView.tag == 2) {
        
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = self.sharedSong.title;
        message.description = self.sharedSong.author;
        
        [message setThumbImage:[UIImage imageNamed:@"cm2_default_cover"]];
        
        WXMusicObject *ext = [WXMusicObject object];
        
        ext.musicUrl = @"http://poche.fm";
        
        ext.musicDataUrl = self.sharedSong.sourceURL;
        
        message.mediaObject = ext;
        
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        
        req.bText = NO;
        
        req.message = message;

        if (indexPath.row == 0) {
            
            req.scene = WXSceneSession;
            
        } else {
            
            req.scene = WXSceneTimeline;
        }
        
        [WXApi sendReq:req];
        
    } else {
        
        NSNotification *select = [NSNotification notificationWithName:@"selected" object:nil userInfo:
                                  @{@"indexPath":[NSNumber numberWithInteger:indexPath.row],
                                    @"songs":self.songs,
                                    @"type":@"local"}];
        
        [[NSNotificationCenter defaultCenter] postNotification:select];
        
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.tag != 2) {
        
        return 66;
        
    } else {
        
        return 44;
    }
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView.tag != 2) {
        
        CGFloat rotationAngleDegrees = 0;
        
        CGFloat rotationAngleRadians = rotationAngleDegrees * (M_PI/180);
        
        CGPoint offsetPositioning = CGPointMake(-200, -20);
        
        CATransform3D transform = CATransform3DIdentity;
        
        transform = CATransform3DRotate(transform, rotationAngleRadians, 0.0, 0.0, 1.0);
        
        transform = CATransform3DTranslate(transform, offsetPositioning.x, offsetPositioning.y, 0.0);
        
        UIView *card = [cell contentView];
        
        card.layer.transform = transform;
        
        card.layer.opacity = 0.8;
        
        [UIView animateWithDuration:0.2f animations:^{
            
            card.layer.transform = CATransform3DIdentity;
            
            card.layer.opacity = 1;
        }];
    }
    
}
#pragma mark - 分享至微信
- (void)shareToWeixin:(UIGestureRecognizer *)recognizer {
    
    if (recognizer.state == 1) {
        
        [self.coverView removeFromSuperview];
        
        [self.shareTable removeFromSuperview];
        
        self.sharedSong = nil;
        
        //创建coverView
        
        CGFloat height = self.view.bounds.size.height;
        
        CGFloat width = self.view.bounds.size.width;
        
        UIView *coverView = [[UIView alloc] init];
        
        coverView.frame = self.tableView.bounds;
        
        coverView.backgroundColor = [UIColor blackColor];
        
        coverView.alpha = 0;
        
        self.coverView = coverView;
        
        [self.view addSubview:coverView];
        
        self.tableView.scrollEnabled = NO;
        
        //添加手势
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCoverView:)];
        
        [self.coverView addGestureRecognizer:tap];
        
        //创建分享TableView
        UITableView *shareTable = [[UITableView alloc] initWithFrame:CGRectMake(0, height + 88, width, 88) style:UITableViewStylePlain];
        
        shareTable.tag = 2;
        
        self.shareTable = shareTable;
        
        shareTable.delegate = self;
        
        shareTable.dataSource = self;
        
        [self.tableView.superview addSubview:shareTable];
        
        [UIView animateWithDuration:0.2 animations:^{
            
            shareTable.frame = CGRectMake(0, height - 88, width, 88);
            
            coverView.alpha = 0.5;
            
        }];
        
        //确定要分享的歌曲
        
        CGPoint position = [recognizer locationInView:self.tableView];
        
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:position];
        
        PCSong *song = self.songs[indexPath.row];
        
        self.sharedSong = song;
    }
    
}
- (void)dismissCoverView:(UIGestureRecognizer *)recognizer {
    
    [self.coverView removeFromSuperview];
    
    [self.shareTable removeFromSuperview];
    
    self.tableView.scrollEnabled = YES;
    
}


@end
