//
//  PCArticleDetailViewController.m
//  
//
//  Created by Purchas on 15/9/3.
//
//

#import "PCArticleDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"
#import "PCSong.h"
#import "MBProgressHUD+MJ.h"
#import "SDWebImageManager.h"
#import "DarwinNotificationHelper.h"
#import "PCSongListTableViewCell.h"

@interface PCArticleDetailViewController ()

@property (nonatomic, strong) NSMutableArray *operationsArray;

@end

@implementation PCArticleDetailViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.backgroundColor = [UIColor blackColor];
    
    //创建该页面的歌曲下载标识符
    NSString *rootPath = [self dirDoc];
    
    NSString *filePath = [rootPath  stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",self.title]];
    
    //检查文件是否存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:filePath]) {
    
        self.operationsArray = [NSMutableArray arrayWithContentsOfFile:filePath];
        
    } else {
        
        self.operationsArray = [NSMutableArray array];
    
    }
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.songs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PCSongListTableViewCell *cell = [PCSongListTableViewCell cellWithTableView:tableView];
    
    PCSong *song = self.songs[indexPath.row];
    
    cell.textLabel.text = song.title;
    
    cell.detailTextLabel.text = song.author;
    
    NSURL *imageURL = [NSURL URLWithString:song.thumb];
    
    [cell.imageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"defaultCover"]];
    
    cell.progressView.hidden = YES;
    //添加手势识别
    
    UISwipeGestureRecognizer *downloadSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(download:)];
    
    [downloadSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    
    downloadSwipe.numberOfTouchesRequired = 1;
    
    [cell addGestureRecognizer:downloadSwipe];
    
    return cell;
}
#pragma mark - 下载
- (void)download:(UIGestureRecognizer *)recognizer {
    
    CGPoint position = [recognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:position];
    
    PCSong *song = self.songs[indexPath.row];
    
    song.index = [NSNumber numberWithInteger:indexPath.row];
    
    //保存路径
    NSString *rootPath = [self dirDoc];
    
    NSString *filePath = [rootPath  stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ - %@.mp3",song.author,song.title]];
    
    
    //检查文件是否存在
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if ([fileManager fileExistsAtPath:filePath]) {
        
        [MBProgressHUD showError:@"歌曲已下载"];
    
    } else {
        
        NSString *identifier = [NSString stringWithFormat:@"%@ - %@",song.author,song.title];
        
        NSString *songName = [NSString stringWithFormat:@"%@.mp3",identifier];
        
        if (self.operationsArray.count == 0) {
          
            [self.operationsArray addObject:songName];
            
            NSNotification *download = [NSNotification notificationWithName:@"download" object:nil userInfo:
                                        @{@"indexPath":[NSNumber numberWithInteger:indexPath.row],
                                          @"songs":self.songs,
                                          @"title":self.title,
                                          @"identifier":identifier}];
            
            [[NSNotificationCenter defaultCenter] postNotification:download];
            
            [MBProgressHUD showSuccess:@"开始下载"];

        
        } else {
            
            if ([self.operationsArray indexOfObject:identifier] != NSNotFound) {
                
                [MBProgressHUD showError:@"文件正在下载中"];

            } else {
                
                NSNotification *download = [NSNotification notificationWithName:@"download" object:nil userInfo:
                                            @{@"indexPath":[NSNumber numberWithInteger:indexPath.row],
                                              @"songs":self.songs,
                                              @"title":self.title,
                                              @"identifier":identifier}];
                
                [[NSNotificationCenter defaultCenter] postNotification:download];
                
                [MBProgressHUD showSuccess:@"开始下载"];
                
                [self.operationsArray addObject:songName];
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 80;

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
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

#pragma mark - 立即播放
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSNotification *select = [NSNotification notificationWithName:@"selected" object:nil userInfo:
                              @{@"indexPath":[NSNumber numberWithInteger:indexPath.row],
                                @"songs":self.songs}];
    
    [[NSNotificationCenter defaultCenter] postNotification:select];

}
#pragma mark - 获取文件主路径
- (NSString *)dirDoc{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
}
@end
