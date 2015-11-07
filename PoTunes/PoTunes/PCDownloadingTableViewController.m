//
//  PCDownloadingTableViewController.m
//  PoTunes
//
//  Created by Purchas on 10/26/15.
//  Copyright © 2015 Purchas. All rights reserved.
//

#import "PCDownloadingTableViewController.h"
#import "PCSongDownloadingCell.h"
#import "Common.h"
#import "PCButton.h"
#import "MBProgressHUD+MJ.h"
@interface PCDownloadingTableViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, weak) UIButton *startBtn;

@end

@implementation PCDownloadingTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    [self initSubviews];
    //接收通知
    [self getNotification];

}

- (void)initSubviews {
    
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
#warning 有空封装一发发
    //开始按钮
    UIButton *startBtn = [[PCButton alloc] init];
    startBtn.frame = CGRectMake((width / 2 - 100) / 2, 44 + 7, 100, 30);
    self.startBtn = startBtn;
    [self.view addSubview:startBtn];
    if (self.paused == 0) {
        
        [startBtn setTitle:@"全部暂停" forState:UIControlStateNormal];

    } else {
        
        [startBtn setTitle:@"全部开始" forState:UIControlStateNormal];

    }
    startBtn.layer.borderColor = PCColor(207, 22, 232, 1.0).CGColor;
    startBtn.layer.borderWidth = 1;
    startBtn.layer.cornerRadius = 5;
    startBtn.layer.masksToBounds = YES;
    [startBtn setBackgroundColor:[UIColor blackColor]];
    [startBtn setTitleColor:PCColor(207, 22, 232, 1.0) forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(pause:) forControlEvents:UIControlEventTouchUpInside];
    
    //删除按钮
    UIButton *deleteBtn = [[PCButton alloc] init];
    deleteBtn.frame = CGRectMake(width / 2 + CGRectGetMinX(startBtn.frame), 44 + 7, 100, 30);
    deleteBtn.layer.borderColor = PCColor(207, 22, 232, 1.0).CGColor;
    deleteBtn.layer.borderWidth = 1;
    deleteBtn.layer.cornerRadius = 5;
    deleteBtn.layer.masksToBounds = YES;
    [self.view addSubview:deleteBtn];
    [deleteBtn setTitle:@"全部删除" forState:UIControlStateNormal];
    [deleteBtn setBackgroundColor:[UIColor blackColor]];
    [deleteBtn setTitleColor:PCColor(207, 22, 232, 1.0) forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteAll) forControlEvents:UIControlEventTouchUpInside];

    //创建tableView
    UITableView *tableView= [[UITableView alloc] init];
    tableView.frame = CGRectMake(0, 88, width, height - 88);
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    self.view.backgroundColor = [UIColor blackColor];
}
#pragma mark - Button Actions
- (void)pause:(UIButton *)button {
    
    if (self.downloadingArray.count == 0) {
        
        [MBProgressHUD showError:@"当前并无下载歌曲"];
        
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(PCDownloadingTableViewController:didClickThePauseButton:)]) {
        
        [self.delegate PCDownloadingTableViewController:self didClickThePauseButton:nil];
        
    }
    if ([button.titleLabel.text isEqualToString:@"全部开始"]) {
        
        [button setTitle:@"全部暂停" forState:UIControlStateNormal];
        
    } else {
        
        [button setTitle:@"全部开始" forState:UIControlStateNormal];

    }
}

- (void)deleteAll {
    
    if (self.downloadingArray.count == 0) {
        
        [MBProgressHUD showError:@"当前并无下载歌曲"];
        
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(PCDownloadingTableViewController:didClickTheDeleteAllButton:)]) {
        
        [self.delegate PCDownloadingTableViewController:self didClickTheDeleteAllButton:nil];
    }
    
    [self.downloadingArray removeAllObjects];
    
    NSString *doc = [self dirDoc];
    
    NSString *path = [doc stringByAppendingPathComponent:@"downloading.plist"];
    
    [self.downloadingArray writeToFile:path atomically:YES];
    
    [self.tableView reloadData];
    
    if (self.downloadingArray.count == 0) {
        
        [self.startBtn setTitle:@"全部开始" forState:UIControlStateNormal];
        
    }
    
}

#pragma mark - Notifications
- (void)getNotification {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(percentChange:) name:@"percent" object:nil];
    
    [center addObserver:self selector:@selector(pop) name:@"pop" object:nil];
    
    [center addObserver:self selector:@selector(downloadComplete:) name:@"downloadComplete" object:nil];

}

- (void)percentChange:(NSNotification *)notification {
    
    NSInteger index = [notification.userInfo[@"index"] integerValue];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    PCSongListTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    cell.progressView.progress = [notification.userInfo[@"percent"] floatValue];
    
}

- (void)pop {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)downloadComplete:(NSNotification *)notification {
    
    NSString *doc = [self dirDoc];
    
    NSString *path = [doc stringByAppendingPathComponent:@"downloading.plist"];
    
    NSArray *dictArray= [NSArray arrayWithContentsOfFile:path];
    
    NSMutableArray *thisArray = [NSMutableArray array];
    
    if (dictArray == nil) {
        
        self.downloadingArray = thisArray;
        
    } else {
        
        NSMutableArray *contentArray = [NSMutableArray array];
        
        for (NSString *identifier in dictArray) {
            
            [contentArray addObject:identifier];
            
        }
        
        self.downloadingArray = contentArray;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView reloadData];

    });
    
    if (self.downloadingArray.count == 0) {
        
        [self.startBtn setTitle:@"全部开始" forState:UIControlStateNormal];
        
        [self pop];
        
    }

}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"percent" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pop" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"downloadComplete" object:nil];
    
}

#pragma mark - 获取文件主路径
- (NSString *)dirDoc {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
   
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.downloadingArray.count;
    
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    PCSongDownloadingCell *cell = [PCSongDownloadingCell cellWithTableView:tableView];
    
    cell.textLabel.text = self.downloadingArray[indexPath.row];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}



@end
