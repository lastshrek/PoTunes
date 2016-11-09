//
//  PCSettingViewController.m
//  PoTunes
//
//  Created by Purchas on 10/29/15.
//  Copyright © 2015 Purchas. All rights reserved.
//

#import "PCSettingViewController.h"
#import "PCSongDownloadingCell.h"
#import "Common.h"
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
    footerView.frame = CGRectMake(0, 0, 300, self.view.bounds.size.height - 176);
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
    
    [self checkUserDefaults];
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
    
//    [MBProgressHUD showSuccess:@"缓存清理成功"];
}

- (void)checkUserDefaults {
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    
    NSString *yes = [user objectForKey:@"wwanPlay"];
    
    if (yes == nil) {
        
        [self storeDefaultPlayandDownloadRules];
        
    }
}

- (void)storeDefaultPlayandDownloadRules {
    
    [self storeObject:[NSNumber numberWithInt:0] forKey:@"wwanPlay"];
    
    [self storeObject:[NSNumber numberWithInt:0] forKey:@"wwanDownload"];

}

#pragma mark - 获取通知
- (void)getNotification {
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserver:self selector:@selector(pop) name:@"pop" object:nil];
    
    [center addObserver:self selector:@selector(switchOn) name:@"wwanPlay" object:nil];
    
    [center addObserver:self selector:@selector(switchOn) name:@"wwanDownload" object:nil];
    
}

- (void)pop {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)switchOn {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView reloadData];

    });

}
#pragma mark - 移除通知
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pop" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"wwanPlay" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"wwanDownload" object:nil];


}

- (NSString *)dirDoc{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
}
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PCSongDownloadingCell *cell = [PCSongDownloadingCell cellWithTableView:tableView];
    
    if (indexPath.row == 0) {
        
        cell.textLabel.text = @"废人操作说明书";
        
        UIButton *button = [[UIButton alloc] initWithFrame:cell.accessoryView.frame];
        
        [button setImage:[UIImage imageNamed:@"cm2_search_icn_arr_prs"] forState:UIControlStateNormal];
        
        cell.accessoryView = button;
    }
    
    NSArray *array = @[@"使用2G/3G/4G网络播放", @"使用2G/3G/4G网络缓存", @"wwanPlay", @"wwanDownload"];
    
    if (indexPath.row != 0) {
        
        cell.textLabel.text = array[indexPath.row - 1];
        
        UISwitch *switchView = [[UISwitch alloc] initWithFrame:cell.accessoryView.frame];
        
        switchView.tintColor = PCColor(207, 22, 232, 1.0);
        
        switchView.onTintColor = PCColor(207, 22, 232, 1.0);
        
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        
        NSString *queryKey = array[indexPath.row + 1];
        
        BOOL yes = [[user objectForKey:queryKey] boolValue];
        
        switchView.on = yes;
        
        switchView.tag = indexPath.row - 1;
        
        [switchView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        
        cell.accessoryView = switchView;
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0 ) {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        PCGuideController *guide = [[PCGuideController alloc] init];
        
        [self.navigationController pushViewController:guide animated:YES];
    
    }
}

- (void)switchAction:(UISwitch *)switchView {
    
    if (switchView.on == YES) {
        
        if (switchView.tag == 0) {
            
            [self storeObject:[NSNumber numberWithInt:1] forKey:@"wwanPlay"];
        
        }
        
        if (switchView.tag == 1) {
           
            [self storeObject:[NSNumber numberWithInt:1] forKey:@"wwanDownload"];
        
        }
    }
    
    if (switchView.on == NO) {
        
        if (switchView.tag == 0) {
            
            [self storeObject:[NSNumber numberWithInt:0] forKey:@"wwanPlay"];
        
        }
        
        if (switchView.tag == 1) {
            
            [self storeObject:[NSNumber numberWithInt:0] forKey:@"wwanDownload"];
        
        }
    }
}

- (void)storeObject:(nullable id)value forKey:(NSString *)defaultName {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:value forKey:defaultName];
}

@end
