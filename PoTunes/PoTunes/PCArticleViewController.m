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
#import "PCArticleDetailViewController.h"
#import "PCPlaylist.h"
#import "PCSong.h"
#import "FMDB.h"
@interface PCArticleViewController ()

@property (nonatomic, strong) NSMutableArray *articles;

@end

@implementation PCArticleViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self.tableView addFooterWithTarget:self action:@selector(loadPreviousArticle)];
    [self.tableView addHeaderWithTarget:self action:@selector(loadNewArticle)];
    self.tableView.rowHeight = 160;

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

}

#pragma mark - 获取文件主路径
- (NSString *)dirDoc{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

- (void)loadNewArticle {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:@"http://simin.ren/?json=get_recent_posts" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [MBProgressHUD showMessage:@"正在获取" toView:self.view];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [MBProgressHUD hideHUDForView:self.view];
        [MBProgressHUD showSuccess:@"加载完成" toView:self.view];
        [self.tableView headerEndRefreshing];
        
        NSMutableArray *result = (NSMutableArray *)[responseObject objectForKey:@"posts"];
        NSMutableArray *addArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < result.count; i++) {
            NSDictionary *newDic = result[i];
            NSDictionary *firstDic = self.articles[0];
            if (newDic[@"id"] > firstDic[@"id"]) {
                [addArray addObject:newDic];
            }
        }
        [addArray addObjectsFromArray:self.articles];
        self.articles = addArray;
        
        NSString *doc = [self dirDoc];
        NSString *path = [doc stringByAppendingPathComponent:@"article.plist"];
        
        // 3. 写入数组
        [self.articles writeToFile:path atomically:YES];
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
    cell.textLabel.text = [self.articles[indexPath.row] objectForKey:@"title"];
    NSString *imageURL = [[self.articles[indexPath.row] objectForKey:@"custom_fields"] objectForKey:@"mp3_thumb"][0];
    NSArray *covers = [imageURL componentsSeparatedByString:@";"];
    NSURL *downloadURL = [NSURL URLWithString:covers[indexPath.row]];
    [cell.imageView sd_setImageWithURL:downloadURL placeholderImage:[UIImage imageNamed:@"defaultCover"]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    PCArticleDetailViewController *detail = [[PCArticleDetailViewController alloc] init];
    /** 歌曲名称 */
    NSString *songNames = [[self.articles[indexPath.row] objectForKey:@"custom_fields"] objectForKey:@"mp3_title"][0];
    detail.songName = (NSMutableArray *)[songNames componentsSeparatedByString:@";"];
    /** 歌曲封面 */
    NSString *songCovers = [[self.articles[indexPath.row] objectForKey:@"custom_fields"] objectForKey:@"mp3_thumb"][0];
    detail.songCover = (NSMutableArray *)[songCovers componentsSeparatedByString:@";"];
    /** 歌手名称 */
    NSString *songArtists = [[self.articles[indexPath.row] objectForKey:@"custom_fields"] objectForKey:@"mp3_author"][0];
    detail.artists = (NSMutableArray *)[songArtists componentsSeparatedByString:@";"];
    /** 歌曲地址 */
    NSString *songAddress = [[self.articles[indexPath.row] objectForKey:@"custom_fields"] objectForKey:@"mp3_address"][0];
    detail.songURL = (NSMutableArray *)[songAddress componentsSeparatedByString:@";"];
    /** 专辑名称 */
    NSString *albumTitle = [self.articles[indexPath.row] objectForKey:@"title"];
    detail.title = albumTitle;
    [self.navigationController pushViewController:detail animated:YES];
    

    
}


@end
