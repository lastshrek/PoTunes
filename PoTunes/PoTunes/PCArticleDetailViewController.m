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
@interface PCArticleDetailViewController ()

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation PCArticleDetailViewController



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
        [tempArray addObject:song];
    }
    self.songs = tempArray;
}



#pragma mark - Table view data source

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
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [cell.imageView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"defaultCover"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        
    }];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",song.album];
    cell.backgroundColor = [UIColor blackColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"BebasNeue" size:26];
    cell.detailTextLabel.font = [UIFont fontWithName:@"BebasNeue" size:12];
    //添加手势识别
    UISwipeGestureRecognizer *downloadSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(download:)];
    [downloadSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    downloadSwipe.numberOfTouchesRequired = 1;
    [cell addGestureRecognizer:downloadSwipe];
    return cell;
}
#pragma mark - 下载
- (void)download:(UIGestureRecognizer *)recognizer{
    CGPoint position = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:position];
    
    PCSong *song = self.songs[indexPath.row];
    song.index = [NSNumber numberWithInteger:indexPath.row];
    //保存路径
    NSString *rootPath = [self dirDoc];
    NSString *filePath = [rootPath  stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ - %@.mp3",song.artist,song.songName]];
    NSString *selectedSong = song.URL;
    NSURL *downloadURL = [NSURL URLWithString:selectedSong];
    //检查文件是否存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //初始化队列
    NSOperationQueue *queue = [[NSOperationQueue alloc ]init];
    if ([fileManager fileExistsAtPath:filePath]) {
        [MBProgressHUD showError:@"文件已存在"];
    } else {
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc]initWithRequest:[NSURLRequest requestWithURL:downloadURL]];
        op.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
        // 根据下载量设置进度条的百分比
        [op setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
            //            CGFloat precent = (CGFloat)totalBytesRead / totalBytesExpectedToRead;
        }];
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            //发送通知
            NSNotification *download = [NSNotification notificationWithName:@"download" object:nil userInfo:
                                                                                                @{@"indexPath":[NSNumber numberWithInteger:indexPath.row],
                                                                                                  @"songs":self.songs}];
            [[NSNotificationCenter defaultCenter] postNotification:download];
            
//            //修改歌曲的url
//            song.URL = filePath;

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error);
        }];
        [MBProgressHUD showSuccess:@"开始下载"];
        //开始下载
        [queue addOperation:op];
    }
    
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
