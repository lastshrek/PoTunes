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
    cell.textLabel.text = [self.articles[indexPath.row] objectForKey:@"title"];
    NSArray *songArray = [self.articles[indexPath.row] objectForKey:@"mp3_list"];
    NSDictionary *song = songArray[0];
    NSString *imageURL = song[@"thumb"];
    NSURL *downloadURL = [NSURL URLWithString:imageURL];
    [cell.imageView sd_setImageWithURL:downloadURL placeholderImage:[UIImage imageNamed:@"defaultCover"]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    PCArticleDetailViewController *detail = [[PCArticleDetailViewController alloc] init];
    /** 歌曲名称 */
    NSArray *songArray = [self.articles[indexPath.row] objectForKey:@"mp3_list"];
    NSMutableArray *sourceUrlArray = [NSMutableArray array];
    NSMutableArray *thumbArray = [NSMutableArray array];
    NSMutableArray *titleArray = [NSMutableArray array];
    NSMutableArray *authorArray = [NSMutableArray array];

    for (NSDictionary *songDic in songArray) {
        NSString *sourceUrl = songDic[@"sourceUrl"];
        NSString *thumb = songDic[@"thumb"];
        NSString *title = songDic[@"title"];
        NSString *author = songDic[@"author"];
        if (title != nil) {
            [sourceUrlArray addObject:sourceUrl];
            [titleArray addObject:title];
            [thumbArray addObject:thumb];
            [authorArray addObject:author];
        }
    }
    detail.songName = titleArray;
    detail.songURL = sourceUrlArray;
    detail.songCover = thumbArray;
    detail.artists = authorArray;


    /** 专辑名称 */
    NSString *albumTitle = [self.articles[indexPath.row] objectForKey:@"title"];
    detail.title = albumTitle;
    [self.navigationController pushViewController:detail animated:YES];
    

    
}


@end
