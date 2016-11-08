//
//  PCGuideController.m
//  PoTunes
//
//  Created by Purchas on 10/31/15.
//  Copyright © 2015 Purchas. All rights reserved.
//

#import "PCGuideController.h"
#import "PCSongDownloadingCell.h"
#import "Common.h"

@interface PCGuideController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *guides;

@end

@implementation PCGuideController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView.backgroundColor = [UIColor blackColor];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"guide.plist" ofType:nil];
    
    self.guides = [NSArray arrayWithContentsOfFile:path];
    
    
}



#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.guides.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[self.guides[section] objectForKey:@"guide"] count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PCSongDownloadingCell *cell = [PCSongDownloadingCell cellWithTableView:tableView];
    
        
    cell.textLabel.text = [self.guides[indexPath.section] objectForKey:@"guide"][indexPath.row];
    
    cell.progressView.hidden = YES;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [self.guides[section] objectForKey:@"title"];

}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    header.contentView.backgroundColor = [UIColor blackColor];
    
    [header.textLabel setTextColor:PCColor(207, 22, 232, 1.0)];

}


@end
