//
//  AlbumInterfaceController.m
//  PoTunes
//
//  Created by Purchas on 15/9/24.
//  Copyright © 2015年 Purchas. All rights reserved.
//

#import "AlbumInterfaceController.h"
#import "AlbumRowController.h"
#import "SongListInterfaceController.h"
#import "PCSong.h"
@interface AlbumInterfaceController ()

@property (weak, nonatomic) IBOutlet WKInterfaceTable *albumTable;
@property (nonatomic, strong) NSArray *articles;

@end

@implementation AlbumInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    //获取手机共享数据
    NSString *identifier = @"group.fm.poche.potunes";
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:identifier];
    NSArray *articles = [defaults valueForKey:@"articles"];
    self.articles = articles;
    //配置table中的行
    [self configureTableWithData:self.articles];
    
   
//    NSString *imageURL = [[self.articles[indexPath.row] objectForKey:@"custom_fields"] objectForKey:@"mp3_thumb"][0];
//    NSArray *covers = [imageURL componentsSeparatedByString:@";"];
//    NSURL *downloadURL = [NSURL URLWithString:covers[indexPath.row]];
//    [cell.imageView sd_setImageWithURL:downloadURL placeholderImage:[UIImage imageNamed:@"defaultCover"]];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}
//配置table中的行
- (void)configureTableWithData:(NSArray*)dataObjects {
    [self.albumTable setNumberOfRows:[dataObjects count] withRowType:@"AlbumRowType"];
    for (NSInteger i = 0; i < self.albumTable.numberOfRows; i++) {
        AlbumRowController *controller = [self.albumTable rowControllerAtIndex:i];
        
        controller.albumTitle.text = [dataObjects[i] objectForKey:@"title"];

//        [theRow.albumTitle setText:dataObj.text];
//        [theRow.albumImage setImage:dataObj.image];
    }
}


- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier inTable:(WKInterfaceTable *)table rowIndex:(NSInteger)rowIndex {

    /** 歌曲名称 */
    NSString *songNames = [[self.articles[rowIndex] objectForKey:@"custom_fields"] objectForKey:@"mp3_title"][0];
    NSMutableArray *songName = (NSMutableArray *)[songNames componentsSeparatedByString:@";"];
    /** 歌曲封面 */
    NSString *songCovers = [[self.articles[rowIndex] objectForKey:@"custom_fields"] objectForKey:@"mp3_thumb"][0];
    NSMutableArray *songCover = (NSMutableArray *)[songCovers componentsSeparatedByString:@";"];
    /** 歌手名称 */
    NSString *songArtists = [[self.articles[rowIndex] objectForKey:@"custom_fields"] objectForKey:@"mp3_author"][0];
    NSMutableArray *artists = (NSMutableArray *)[songArtists componentsSeparatedByString:@";"];
    /** 歌曲地址 */
    NSString *songAddress = [[self.articles[rowIndex] objectForKey:@"custom_fields"] objectForKey:@"mp3_address"][0];
    NSMutableArray *songURL = (NSMutableArray *)[songAddress componentsSeparatedByString:@";"];
    /** 专辑名称 */
    NSString *albumTitle = [self.articles[rowIndex] objectForKey:@"title"];
    NSString *title = albumTitle;
    
    //创建歌曲模型！
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i = 0; i < songName.count; i++) {
        PCSong *song = [[PCSong alloc] init];
        song.album = title;
        song.artist = artists[i];
        song.songName = songName[i];
        song.cover = songCover[i];
        song.URL = songURL[i];
        [tempArray addObject:song];

    }
    return tempArray;
}
@end



