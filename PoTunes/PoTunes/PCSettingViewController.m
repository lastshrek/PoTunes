//
//  PCSettingViewController.m
//  PoTunes
//
//  Created by Purchas on 10/29/15.
//  Copyright © 2015 Purchas. All rights reserved.
//

#import "PCSettingViewController.h"
#import "PCDownLoadedCell.h"
#import "Common.h"
#import "MBProgressHUD+MJ.h"
#import "PCWebViewController.h"
#import "PCGuideController.h"
@interface PCSettingViewController ()

@end

@implementation PCSettingViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor blackColor];
    footerView.frame = CGRectMake(0, 0, 300, self.view.bounds.size.height - 88);
    self.tableView.tableFooterView = footerView;

    UIButton *clearCacheBtn = [[UIButton alloc] init];
    clearCacheBtn.frame = CGRectMake(20, footerView.bounds.size.height - 120, self.view.bounds.size.width - 40, 50);
    [clearCacheBtn setTitle:@"清空缓存" forState:UIControlStateNormal];
    [clearCacheBtn setTitleColor:PCColor(207, 22, 232, 1.0) forState:UIControlStateNormal];
    clearCacheBtn.layer.borderColor = PCColor(207, 22, 232, 1.0).CGColor;
    clearCacheBtn.layer.borderWidth = 1;
    clearCacheBtn.layer.cornerRadius = 5;
    clearCacheBtn.layer.masksToBounds = YES;
    [clearCacheBtn addTarget:self action:@selector(clearCaches) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:clearCacheBtn];
    
    [self getNotification];
    
}

- (void)clearCaches {
    //删除缓存
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *rootPath = [self dirDoc];
    
    for (NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rootPath error:nil]) {
        
        if ([file hasPrefix:@"FSCache-"]) {
        
            NSString *fullPath = [rootPath stringByAppendingPathComponent:file];
            
            [fileManager removeItemAtPath:fullPath error:nil];
        }
    }
    
    [MBProgressHUD showSuccess:@"缓存清理成功"];
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

- (NSString *)dirDoc{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PCDownLoadedCell *cell = [PCDownLoadedCell cellWithTableView:tableView];
    cell.imageView.image = [UIImage imageNamed:@"cm2_discover_cover_norecmt"];

    cell.textLabel.text = @"废人操作说明书";

    UIButton *button = [[UIButton alloc] initWithFrame:cell.accessoryView.frame];
    
    [button setImage:[UIImage imageNamed:@"cm2_search_icn_arr_prs"] forState:UIControlStateNormal];
    
    cell.accessoryView = button;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    PCWebViewController *web = [[PCWebViewController alloc] init];
//    
//    [self.navigationController pushViewController:web animated:YES];
    PCGuideController *guide = [[PCGuideController alloc] init];
    
    [self.navigationController pushViewController:guide animated:YES];
    
}

@end
