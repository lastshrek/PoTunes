//
//  PCBlurView.m
//  破音万里
//
//  Created by Purchas on 11/7/15.
//  Copyright © 2015 Purchas. All rights reserved.
//

#import "PCBlurView.h"
#import "lrcLine.h"
#import "LrcCell.h"

@interface PCBlurView()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *lyricsLines;

@property (nonatomic, assign) int currentIndex;


@end

@implementation PCBlurView

- (NSMutableArray *)lyricsLines {
    
    if (_lyricsLines == nil) {
        
        self.lyricsLines = [NSMutableArray array];
        
    }
    return _lyricsLines;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
    
        [self setup];
    
    }
    return self;
}

- (void)setLrcName:(NSString *)lrcName {
    
    _lrcName = [lrcName copy];
    
    [self.lyricsLines removeAllObjects];
    
    //1.加载歌词文件
    NSString *doc = [self dirDoc];
    
    NSString *path = [doc stringByAppendingPathComponent:lrcName];

    NSString *lrcStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *lrcComponets = [lrcStr componentsSeparatedByString:@"["];
    
    //输出每一行歌词
    
    for (NSString *line in lrcComponets) {
        
        lrcLine *lrc = [[lrcLine alloc] init];
        
        //如果是歌名的头部信息
        NSArray *array = [line componentsSeparatedByString:@"]"];
                
        lrc.time = [[array firstObject] stringByReplacingOccurrencesOfString:@"[" withString:@""];
        
        lrc.lyrics = [array lastObject];
        
        [self.lyricsLines addObject:lrc];
        
    }
    [self.tableView reloadData];
}

- (void)setChLrcName:(NSString *)chLrcName {
    
    _chLrcName = [chLrcName copy];
    
    //1.加载歌词文件
    NSString *doc = [self dirDoc];
    
    NSString *path = [doc stringByAppendingPathComponent:chLrcName];
    
    NSString *lrcStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSArray *lrcComponets = [lrcStr componentsSeparatedByString:@" ["];
    
    NSMutableArray *chArray = [NSMutableArray array];
    
    for (NSString *line in lrcComponets) {
        
        lrcLine *lrc = [[lrcLine alloc] init];
        
        //如果是歌名的头部信息
        NSArray *array = [line componentsSeparatedByString:@"]"];
        
        lrc.time = [[array firstObject] stringByReplacingOccurrencesOfString:@"[" withString:@""];
        
        lrc.lyrics = [array lastObject];
        
        [chArray addObject:lrc];
        
    }
    for (lrcLine *lrc in self.lyricsLines) {
        
        NSString *lrcTime = lrc.time;
        
        if (lrcTime.length == 0) continue;

        lrcTime = [lrcTime substringToIndex:5];
        
        for (lrcLine *chlrc in chArray) {
            
            NSString *chTime = [chlrc.time substringToIndex:5];
            
            if ([chTime isEqualToString:lrcTime]) {
               
                lrc.lyrics = [NSString stringWithFormat:@"%@\r%@",lrc.lyrics,chlrc.lyrics];
            
            }
            continue;
        }
    }
    [self.tableView reloadData];
}

- (void)setCurrentTime:(NSTimeInterval)currentTime {
    
    if (currentTime < _currentTime) {
        self.currentIndex = -1;
    }
    
    _currentTime = currentTime;
    
    int minute = currentTime / 60;
    int second = (int)currentTime % 60;
    
    NSString *currentTimeStr = [NSString stringWithFormat:@"%02d:%02d", minute, second];
    
    unsigned long count = self.lyricsLines.count;
    
    for (int idx = self.currentIndex + 1; idx < count; idx++) {
        
        lrcLine *currentLine = self.lyricsLines[idx];
        // 当前模型的时间
        NSString *currentLineTime = currentLine.time;
        
        // 下一个模型的时间
        NSString *nextLineTime = nil;
        
        NSUInteger nextIdx = idx + 1;
        
        if (nextIdx < self.lyricsLines.count) {
        
            lrcLine *nextLine = self.lyricsLines[nextIdx];
            
            nextLineTime = nextLine.time;
        }
        
        // 判断是否为正在播放的歌词
        if (([currentTimeStr compare:currentLineTime] != NSOrderedAscending)
            && ([currentTimeStr compare:nextLineTime] == NSOrderedAscending)
            && self.currentIndex != idx) {
            // 刷新tableView
            NSArray *reloadRows = @[[NSIndexPath indexPathForRow:self.currentIndex inSection:0],
                                    [NSIndexPath indexPathForRow:idx inSection:0]];
            
            self.currentIndex = idx;
            
            [self.tableView reloadRowsAtIndexPaths:reloadRows withRowAnimation:UITableViewRowAnimationNone];
            
            
            // 滚动到对应的行
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}

- (void)setup {
      
    UILabel *nolrcLabel = [[UILabel alloc] init];
    
    nolrcLabel.backgroundColor = [UIColor clearColor];
    
    nolrcLabel.textAlignment = NSTextAlignmentCenter;
    
    nolrcLabel.text = @"暂无歌词";
    
    nolrcLabel.textColor = [UIColor grayColor];
    
    self.noLrcLabel = nolrcLabel;
    
    [self addSubview:nolrcLabel];
    
    UITableView *tableView = [[UITableView alloc] init];
    
    tableView.dataSource = self;
    
    tableView.dataSource = self;
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    tableView.backgroundColor = [UIColor clearColor];
    
    tableView.showsVerticalScrollIndicator = NO;
    
    [self addSubview:tableView];
    
    self.tableView = tableView;
    
    self.renderStatic = YES;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.tableView.frame = self.bounds;
    
    self.tableView.contentInset = UIEdgeInsetsMake(self.bounds.size.height * 0.5, 0, self.bounds.size.height * 0.5, 0);
    
    self.noLrcLabel.frame = self.bounds;
          
}

- (NSString *)dirDoc {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    return documentsDirectory;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.lyricsLines.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LrcCell *cell = [LrcCell cellWithTableView:tableView];
    
    cell.lrcLine = self.lyricsLines[indexPath.row];
    
    if (self.currentIndex == indexPath.row) {
        
        cell.textLabel.textColor = [UIColor whiteColor];
    
    } else {
    
        cell.textLabel.textColor = [UIColor grayColor];
    
    }
    
    
    return cell;
}
@end
