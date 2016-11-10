//
//  PCArticleViewController.m
//  
//
//  Created by Purchas on 15/9/2.
//
//

#import "PCArticleViewController.h"
#import "MJRefresh.h"
#import "AFNetworking.h"
//#import "MBProgressHUD+MJ.h"
#import "UIImageView+WebCache.h"
#import "PCPlaylist.h"
#import "PCSong.h"
//#import "FMDB.h"
#import "PCSongDetailViewController.h"
#import "Reachability.h"
@interface PCArticleViewController ()<UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableArray *articles;

/** 下载歌曲数据库 */
//@property (nonatomic, strong) FMDatabase *downloadedSongDB;

/** 检测网络状态 */
@property (nonatomic, strong) Reachability *conn;

/** 当前网络状态 */
@property (nonatomic, assign) int reachable;

/** 手势 */
@property (nonatomic, strong) UIGestureRecognizer *recognizer;


@end

@implementation PCArticleViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.tableView addHeaderWithTarget:self action:@selector(loadNewArticle)];
    
	

	
	
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
    
}
#pragma mark - 获取通知
- (void)getNotification {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(pop) name:@"pop" object:nil];
    
    [center addObserver:self selector:@selector(networkStateChange) name:kReachabilityChangedNotification object:nil];
    
    self.conn = [Reachability reachabilityForInternetConnection];
    
    [self.conn startNotifier];
    
    self.reachable = [self.conn currentReachabilityStatus];
    
}
- (void)pop {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}
- (void)networkStateChange {
    // 1.检测wifi状态
    Reachability *wifi = [Reachability reachabilityForLocalWiFi];
    // 2.检测手机是否能上网络(WIFI\3G\2.5G)
    Reachability *conn = [Reachability reachabilityForInternetConnection];
    
    // 3.判断网络状态
    if ([wifi currentReachabilityStatus] != NotReachable) { // 有wifi
        self.reachable = 2;
    } else if ([conn currentReachabilityStatus] != NotReachable) { // 没有使用wifi, 使用手机自带网络进行上网
        self.reachable = 1;
    } else { // 没有网络
        self.reachable = 0;
    }
}
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pop" object:nil];
    
    [self.conn stopNotifier];
    
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
    
//    [MBProgressHUD showMessage:@"正在获取" toView:self.view];
	
    //获取系统版本号
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSString *getAlbums = [NSString stringWithFormat:@"http://121.41.121.87:3000/api/v1/lists?v=%@", version];
   
    [manager GET:getAlbums parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
//        [MBProgressHUD hideHUDForView:self.view];
//        
//        [MBProgressHUD showSuccess:@"加载完成" toView:self.view];
			
        [self.tableView headerEndRefreshing];
        
        NSMutableArray *result = (NSMutableArray *)responseObject;
        
        if (result.count > 3) {
            //发送通知重设tabBar个数
            NSNotification *finishLoading = [NSNotification notificationWithName:@"finishLoading" object:nil userInfo:nil];
            
            [[NSNotificationCenter defaultCenter] postNotification:finishLoading];
            
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            
            [user setObject:@"online" forKey:@"online"];
        }
        
        self.articles = result;
        
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
        
//        [MBProgressHUD hideHUDForView:self.view];
//        
//        [MBProgressHUD showError:@"请检查网络" toView:self.view];
			
    }];
}




#pragma mark - TableViewDelegate
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {


//    
//    NSString *imageURL = [self.articles[indexPath.row] objectForKey:@"coverImage"];
//    
//    NSURL *downloadURL = [NSURL URLWithString:imageURL];
	
//    if (self.articles.count == 3) {

//        cell.imageView.image = [UIImage imageNamed:@"defaultArtCover"];
			
//    }
//    if (self.articles.count != 3) {

//        [cell.imageView sd_setImageWithURL:downloadURL placeholderImage:[UIImage imageNamed:@"defaultArtCover"]];
			
//    }

	
//    return cell;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
//    [MBProgressHUD showMessage:@"加载歌曲" toView:self.view];
	
    NSDictionary *articleDic = self.articles[indexPath.row];
    
    NSString *index = articleDic[@"id"];
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    NSString *urlString = [NSString stringWithFormat:@"http://121.41.121.87:3000/api/v1/list-mp3s?id=%@&v=%@", index, version];
    
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
//        [MBProgressHUD hideHUDForView:self.view];
			
        PCSongDetailViewController *detail = [[PCSongDetailViewController alloc] init];
        
        NSMutableArray *tempArray = [NSMutableArray array];
        
        for (NSDictionary *dic in responseObject) {
            
            PCSong *song = [PCSong songWithDict:dic];
            
            song.album = self.articles[indexPath.row][@"title"];
            
            NSString *lrc = dic[@"sourceUrl"];
            
            song.lrc = [lrc stringByReplacingOccurrencesOfString:@".mp3" withString:@".lrc"];
                        
            [tempArray addObject:song];
            
        }
        
        detail.songs = tempArray;
        
        detail.title = [self.articles[indexPath.row] objectForKey:@"title"];
        
        [self.navigationController pushViewController:detail animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
//        [MBProgressHUD hideHUDForView:self.view];
//
//        [MBProgressHUD showError:@"加载失败" toView:self.view];
        
    }];
  
}

#pragma mark - 下载
- (void)download:(UIGestureRecognizer *)recognizer {
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    NSString *online = [user objectForKey:@"online"];
    
    if (online == nil) return;
    
    //获取下载状态
    
    BOOL yes = [[user objectForKey:@"wwanDownload"] boolValue];
    
    self.recognizer = recognizer;

    
    if (!yes && self.conn.currentReachabilityStatus != 2) {
        //初始化AlertView
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                        message:@"您当前处于运营商网络中，是否继续下载"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确认",nil];
        [alert show];
        
        
        return;
    }
    
    if (self.conn.currentReachabilityStatus == 2 || yes) {
        
        [self startDownloadAlbum:recognizer];
    
    }
}

- (void)startDownloadAlbum:(UIGestureRecognizer *)recognizer {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        CGPoint position = [recognizer locationInView:self.tableView];
        
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:position];
        
        //获得专辑名称
        NSString *fullName = [self.articles[indexPath.row] objectForKey:@"title"];
        
        //专辑ID
        NSString *index = [self.articles[indexPath.row] objectForKey:@"id"];
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        
        NSString *urlString = [NSString stringWithFormat:@"http://121.41.121.87:3000/api/v1/list-mp3s?id=%@", index];
        
//        [MBProgressHUD showMessage:@"开始下载" toView:self.view];
			
        [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
//            [MBProgressHUD hideHUDForView:self.view];
					
            NSMutableArray *songArray = [NSMutableArray array];
            
            NSMutableArray *downloadArray = [NSMutableArray array];
            
            for (NSDictionary *dict in responseObject) {
                
                PCSong *song = [PCSong songWithDict:dict];
                
                NSInteger position = [dict[@"index"] integerValue];
                
                song.position = [NSNumber numberWithInteger:position];
                
                song.album = fullName;
                
                NSString *lrc = dict[@"sourceUrl"];
                
                song.lrc = [lrc stringByReplacingOccurrencesOfString:@".mp3" withString:@".lrc"];
                
                [songArray addObject:song];
                
            }
            
            for (int i = 0; i < songArray.count; i++) {
                
                PCSong *song = songArray[i];
                
                NSString *author = [song.author stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                
                NSString *title = [song.title stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
                
                NSString *query = [NSString stringWithFormat:@"SELECT * FROM t_downloading WHERE author = '%@' and title = '%@';", author, title];
                
//                FMResultSet *s = [self.downloadedSongDB executeQuery:query];
//                
//                if (!(s.next)) {
//                    
//                    [downloadArray addObject:song];
//                    
//                }
            }
            
            if (downloadArray.count == 0) {
                
//                [MBProgressHUD showSuccess:@"专辑已下载"];
							
            } else {
                
                NSNotification *fullAlbum = [NSNotification notificationWithName:@"fullAlbum" object:nil userInfo:
                                             @{@"songs":downloadArray,
                                               @"title":fullName}];
                
                [[NSNotificationCenter defaultCenter] postNotification:fullAlbum];
                
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
        
    });

}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            
            NSUserDefaults *users = [NSUserDefaults standardUserDefaults];
            
            [users setObject:[NSNumber numberWithInt:1] forKey:@"wwanDownload"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"wwanDownload" object:nil userInfo:nil];
            
            [self startDownloadAlbum:self.recognizer];
            
            
        });
        
        return;
        
    }
    
    if (buttonIndex == 0) {
        
//        [MBProgressHUD showError:@"取消下载"];
        
    }
}



@end
