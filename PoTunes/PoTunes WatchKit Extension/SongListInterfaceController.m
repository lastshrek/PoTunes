//
//  SongListInterfaceController.m
//  PoTunes
//
//  Created by Purchas on 15/9/24.
//  Copyright © 2015年 Purchas. All rights reserved.
//

#import "SongListInterfaceController.h"
#import "AlbumRowController.h"
#import "PCSong.h"
#import "DarwinNotificationHelper.h"
@interface SongListInterfaceController ()
@property (nonatomic, strong) NSArray *songs;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceTable *table;
@end

@implementation SongListInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    // Configure interface objects here.
    self.songs = context;
    [self configureTableWithData:self.songs];
    [self registerForNotifications];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)configureTableWithData:(NSArray*)dataObjects {
    [self.table setNumberOfRows:dataObjects.count withRowType:@"AlbumRowType"];
    for (NSInteger i = 0; i < self.table.numberOfRows; i++) {
        AlbumRowController *controller = [self.table rowControllerAtIndex:i];
        PCSong *song = dataObjects[i];
        if (i == 0) {
            self.title = song.album;
        }
        controller.songTitle.text = [NSString stringWithFormat:@"%@ - %@",song.artist, song.songName];
    }
}

- (void)registerForNotifications {
    DarwinNotificationHelper *helper = [DarwinNotificationHelper sharedHelper];
    [helper registerForNotificationName:@"watchSelected" callback:^{
        NSLog(@"watch123");
    }];
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier inTable:(WKInterfaceTable *)table rowIndex:(NSInteger)rowIndex {
    NSMutableArray *songArray = [NSMutableArray array];
    for (PCSong *song in self.songs) {
        NSMutableDictionary *songDic = [NSMutableDictionary dictionary];
        [songDic setObject:song.album forKey:@"title"];
        [songDic setObject:song.cover forKey:@"cover"];
        [songDic setObject:song.URL forKey:@"URL"];
        [songDic setObject:song.artist forKey:@"artist"];
        [songDic setObject:song.songName forKey:@"songName"];
        [songArray addObject:songDic];
    }
    // 写入共享数据
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.fm.poche.potunes"];
    if ([shared objectForKey:@"songs"]) {
        [shared removeObjectForKey:@"songs"];
    }
    if ([shared objectForKey:@"index"]) {
        [shared removeObjectForKey:@"index"];
    }
    [shared setObject:songArray forKey:@"songs"];
    [shared setObject:[NSNumber numberWithInteger:rowIndex] forKey:@"index"];
    [shared synchronize];
    
    DarwinNotificationHelper *helper = [DarwinNotificationHelper sharedHelper];
    [helper postNotificationWithName:@"watchSelected"];
    
//    NSDictionary *songDic = @{@"songs":songArray,
//                              @"index":[NSNumber numberWithInteger:rowIndex]};
    int isPlaying = 1;

    return @(isPlaying);

}
@end



