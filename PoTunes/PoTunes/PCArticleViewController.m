//
//  PCArticleViewController.m
//  
//
//  Created by Purchas on 15/9/2.
//
//

#import "PCArticleViewController.h"
#import "PCArticleCell.h"
#import "MJRefresh.h"
#import "AFNetworking.h"
#import "MBProgressHUD+MJ.h"
#import "UIImageView+WebCache.h"
#import "PCPlaylist.h"
#import "PCSong.h"
#import "FMDB.h"
#import "PCSongDetailViewController.h"
#import "FMDB.h"

@interface PCArticleViewController ()

@property (nonatomic, strong) NSMutableArray *articles;

/** 下载歌曲数据库 */
@property (nonatomic, strong) FMDatabase *downloadedSongDB;



@end

@implementation PCArticleViewController

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
    
    [self.tableView addHeaderWithTarget:self action:@selector(loadNewArticle)];
    
    CGFloat width = self.view.bounds.size.width;
    
    if (width == 414) {
       
        self.tableView.rowHeight = width * 300 / 640;

    } else {
        
        self.tableView.rowHeight = width * 300 / 640;
        
    }

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.backgroundColor = [UIColor blackColor];
    
    if (self.articles == nil) {
        
        NSString *rootPath = [self dirDoc];
        
        NSString *filePath = [rootPath  stringByAppendingPathComponent:[NSString stringWithFormat:@"article.plist"]];
        
        NSArray * dictArray= [NSArray arrayWithContentsOfFile:filePath];
        
        if (dictArray == nil) {
        
            [self.tableView headerBeginRefreshing];
        
        } else {
        
            NSMutableArray *contentArray = [NSMutableArray array];
            
            for (NSDictionary *dict in dictArray) {
            
                [contentArray addObject:dict];
            }
            
            self.articles = contentArray;
        }
    }

    [self getNotification];
    
//    NSLog(@"%f",self.view.bounds.size.width);
}
#pragma mark - 获取通知
- (void)getNotification {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(pop) name:@"pop" object:nil];
    
}
- (void)pop {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pop" object:nil];
    
}
#pragma mark - 获取文件主路径
- (NSString *)dirDoc {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
}
#pragma mark - 获取新内容
- (void)loadNewArticle {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [MBProgressHUD showMessage:@"正在获取" toView:self.view];
   
    [manager GET:@"http://121.41.121.87:3000/api/list" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
        [MBProgressHUD hideHUDForView:self.view];
        
        [MBProgressHUD showSuccess:@"加载完成" toView:self.view];
        
        [self.tableView headerEndRefreshing];
        
        
        NSMutableArray *result = (NSMutableArray *)responseObject;
        
        NSMutableArray *addArray = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < result.count; i++) {
        
            NSDictionary *newDic = result[i];
            
            NSDictionary *firstDic = self.articles[0];
            
            if ([newDic[@"id"] integerValue] > [firstDic[@"id"] integerValue]) {
        
                [addArray addObject:newDic];
            
            }
            
            if ([newDic[@"id"] integerValue] == [firstDic[@"id"] integerValue]) {
                
                self.articles[0] = newDic;
            }
        }
        
        [addArray addObjectsFromArray:self.articles];

        
        self.articles = addArray;
        
        
        NSString *doc = [self dirDoc];
        
        NSString *path = [doc stringByAppendingPathComponent:@"article.plist"];
        
        // 写入数组
        [self.articles writeToFile:path atomically:YES];
        
        // 写入共享数据
        NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.fm.poche.potunes"];
        
        [shared setObject:self.articles forKey:@"articles"];
        
        [shared synchronize];
        
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

#pragma mark - TableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  
    return self.articles.count;

}
#pragma mark - TableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PCArticleCell *cell = [PCArticleCell cellWithTableView:tableView];
    
    cell.textLabel.text = [NSString stringWithFormat:@"『%@』",[self.articles[indexPath.row] objectForKey:@"title"]];
    
    NSString *imageURL = [self.articles[indexPath.row] objectForKey:@"contentImage"];
    
    NSURL *downloadURL = [NSURL URLWithString:imageURL];
    
    [cell.imageView sd_setImageWithURL:downloadURL placeholderImage:[UIImage imageNamed:@"defaultCover"]];
    
    //添加下载手势
    UISwipeGestureRecognizer *downloadSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(download:)];
    
    [downloadSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    
    downloadSwipe.numberOfTouchesRequired = 1;
    
    [cell addGestureRecognizer:downloadSwipe];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    /** 专辑名称 */
    NSString *albumTitle = [[[self.articles[indexPath.row] objectForKey:@"title"] componentsSeparatedByString:@" – "] lastObject];
    
    PCSongDetailViewController *detail = [[PCSongDetailViewController alloc] init];
    /** 歌曲名称 */
    NSArray *songArray = [self.articles[indexPath.row] objectForKey:@"mp3_list"];
    
    NSMutableArray *tempArray = [NSMutableArray array];
    
    for (NSDictionary *dic in songArray) {
      
        PCSong *song = [PCSong songWithDict:dic];
        
        song.album = albumTitle;
        
        [tempArray addObject:song];
    }

    detail.songs = tempArray;
    
    detail.title = albumTitle;
    
    [self.navigationController pushViewController:detail animated:YES];
    
}

#pragma mark - 下载
- (void)download:(UIGestureRecognizer *)recognizer {
    
    CGPoint position = [recognizer locationInView:self.tableView];
    
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:position];
    
    //获得专辑名称
    NSString *fullName = [self.articles[indexPath.row] objectForKey:@"title"];
    
    NSArray *separatedArray = [fullName componentsSeparatedByString:@" - "];
    
    NSString *album = [separatedArray lastObject];
    
    NSMutableArray *tempArray = [self.articles[indexPath.row] objectForKey:@"mp3_list"];
    
    NSMutableArray *songArray = [NSMutableArray array];
    
    for (NSDictionary *dict in tempArray) {
        
        PCSong *song = [PCSong songWithDict:dict];
        
        NSInteger position = [dict[@"index"] integerValue];
        
        song.position = [NSNumber numberWithInteger:position];
        
        song.album = album;
        
        [songArray addObject:song];
    }
    
    NSMutableArray *downloadArray = [NSMutableArray array];
    
    for (int i = 0; i < songArray.count; i++) {
        
        PCSong *song = songArray[i];
        
        NSString *author = [song.author stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        
        NSString *title = [song.title stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
        
        NSString *query = [NSString stringWithFormat:@"SELECT * FROM t_downloading WHERE author = '%@' and title = '%@';", author, title];
        
        FMResultSet *s = [self.downloadedSongDB executeQuery:query];
        
        
        if (!s.next) {
            
            [downloadArray addObject:song];
            
        }
    }
    
    if (downloadArray.count == 0) {
        
        [MBProgressHUD showSuccess:@"专辑已下载"];

    } else {
        
        NSNotification *fullAlbum = [NSNotification notificationWithName:@"fullAlbum" object:nil userInfo:
                                     @{@"songs":downloadArray,
                                       @"title":[separatedArray lastObject]}];
        
        [[NSNotificationCenter defaultCenter] postNotification:fullAlbum];
        
        [MBProgressHUD showSuccess:@"开始下载"];


    }

}

@end
