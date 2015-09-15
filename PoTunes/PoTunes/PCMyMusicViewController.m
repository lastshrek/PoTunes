//
//  PCMyMusicViewController.m
//  PoTunes
//
//  Created by Purchas on 15/9/9.
//  Copyright © 2015年 Purchas. All rights reserved.
//

#import "PCMyMusicViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD+MJ.h"
#import "UIImageView+WebCache.h"
#import "PCSong.h"
#import "PCDownloadViewController.h"
@interface PCMyMusicViewController()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *downloadAlbums;

@end

@implementation PCMyMusicViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.downloadAlbums == nil) {
        NSString *rootPath = [self dirDoc];
        NSString *filePath = [rootPath  stringByAppendingPathComponent:[NSString stringWithFormat:@"albumdownloaded.plist"]];
        NSArray * dictArray= [NSArray arrayWithContentsOfFile:filePath];
        if (dictArray == nil) {
            self.downloadAlbums = [NSMutableArray array];
        } else {
            NSMutableArray *contentArray = [NSMutableArray array];
            for (NSDictionary *dict in dictArray) {
                [contentArray addObject:dict];
            }
            self.downloadAlbums = contentArray;
        }
        
    }
    /** 初始化CollectionView */
    [self setupCollectionView];
    /** 注册通知 */
    [self getNotification];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.collectionView reloadData];
}
#pragma mark - 初始化CollectionView
- (void)setupCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.headerReferenceSize = CGSizeMake(300.0f, 50.0f);
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView setBackgroundColor:[UIColor blackColor]];
    //注册Cell，必须要有
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"myMusicCell"];
    [self.view addSubview:self.collectionView];
}

#pragma mark - 获取通知
- (void)getNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(download:) name:@"download" object:nil];
    [center addObserver:self selector:@selector(delete:) name:@"delete" object:nil];
}



- (void)download:(NSNotification *)sender {
    NSString *doc = [self dirDoc];
    
    NSNumber *index = sender.userInfo[@"indexPath"];
    NSArray *songArray = sender.userInfo[@"songs"];
    PCSong *song = songArray[[index intValue]];
    song.index = index;
    //创建album字典
    NSMutableDictionary *songDic = [NSMutableDictionary dictionary];
    songDic[@"title"] = song.album;
    songDic[@"artists"] = [NSMutableArray arrayWithObject:song.artist];
    songDic[@"songCover"] = [NSMutableArray arrayWithObject:song.cover];
    songDic[@"songName"] = [NSMutableArray arrayWithObject:song.songName];
    NSString *curPath = [doc stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ - %@.mp3",song.artist,song.songName]];
    songDic[@"songURL"] = [NSMutableArray arrayWithObject:curPath];
    songDic[@"row"] = [NSMutableArray arrayWithObject:index];
    songDic[@"count"] = [NSNumber numberWithInteger:songArray.count];
    //初始化专辑表
    if (self.downloadAlbums.count == 0) {
        [self.downloadAlbums addObject:songDic];
    } else {
        int count = 0;
        for (NSDictionary *dict in self.downloadAlbums) {
            if ([dict[@"title"] isEqualToString:song.album]) {
                [dict[@"artists"] addObject:song.artist];
                [dict[@"songCover"] addObject:song.cover];
                [dict[@"songName"] addObject:song.songName];
                [dict[@"songURL"]addObject:song.URL];
                [dict[@"row"] addObject:index];
                
            } else {
                count++;
            }
        }
        if (count == self.downloadAlbums.count) {
            [self.downloadAlbums addObject:songDic];
        }
    }
    NSString *path = [doc stringByAppendingPathComponent:@"albumdownloaded.plist"];
    // 3. 写入数组
    [self.downloadAlbums writeToFile:path atomically:YES];
    
    [self.collectionView reloadData];
}
- (void)delete:(NSNotification *)sender {
    PCSong *song = sender.userInfo[@"song"];
    int index = [sender.userInfo[@"indexPath"] intValue];

    
    for (int i = 0; i < self.downloadAlbums.count; i++) {
        NSMutableDictionary *dict = self.downloadAlbums[i];
        if ([song.album isEqualToString:dict[@"title"]]) {
            [dict[@"artists"] removeObjectAtIndex:index];
            [dict[@"row"] removeObjectAtIndex:index];
            [dict[@"songCover"] removeObjectAtIndex:index];
            [dict[@"songURL"] removeObjectAtIndex:index];
            [dict[@"songName"] removeObjectAtIndex:index];
            NSMutableArray *array = dict[@"artists"];
            if (array.count == 0) {
                [self.downloadAlbums removeObjectAtIndex:i];
            }
            NSString *doc = [self dirDoc];
            NSString *path = [doc stringByAppendingPathComponent:@"albumdownloaded.plist"];
            [self.downloadAlbums writeToFile:path atomically:YES];
            break;
        }

    }
    [self.collectionView reloadData];
}




#pragma mark - 移除通知
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"download" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"delete" object:nil];
}
#pragma mark - 获取文件主路径
- (NSString *)dirDoc {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.downloadAlbums.count;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * CellIdentifier = @"myMusicCell";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UICollectionViewCell alloc] init];
    }
    cell.backgroundColor = [UIColor clearColor];
    
    NSMutableDictionary *songDic = self.downloadAlbums[indexPath.row];
    //专辑封面
    UIImageView *cover = [[UIImageView alloc] init];
    cover.frame = cell.bounds;
    NSArray *coverArray = songDic[@"songCover"];
    [cover sd_setImageWithURL:[NSURL URLWithString:coverArray[0]] placeholderImage:[UIImage imageNamed:@"defaultCover"]];
    [cell.contentView addSubview:cover];
    //添加title
    UILabel *albumTitle = [[UILabel alloc] init];
    albumTitle.frame = CGRectMake(0, 70, 96, 30);
    albumTitle.textAlignment = NSTextAlignmentCenter;
    albumTitle.text = songDic[@"title"];
    albumTitle.numberOfLines = 0;
    albumTitle.textColor = [UIColor cyanColor];
    [cell.contentView addSubview:albumTitle];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(96, 100);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PCDownloadViewController *download = [[PCDownloadViewController alloc] init];
    NSMutableDictionary *dic = self.downloadAlbums[indexPath.row];
    download.songName = dic[@"songName"];
    download.songCover = dic[@"songCover"];
    download.songURL = dic[@"songURL"];
    download.artists = dic[@"artists"];
    download.indexes = dic[@"row"];
    download.title = dic[@"title"];
    [self.navigationController pushViewController:download animated:YES];
}

@end
