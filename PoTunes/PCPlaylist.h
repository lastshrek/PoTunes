//
//  PCPlaylist.h
//  PoTunes
//
//  Created by Purchas on 15/9/10.
//  Copyright © 2015年 Purchas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCPlaylist : NSObject
/** 歌曲总数 */
@property (nonatomic, assign) NSNumber *count;
/** 数组中装的都是PCSong模型 */
@property (nonatomic, strong) NSMutableArray *songs;

+ (instancetype)playlistWithDict:(NSDictionary *)dict;
- (instancetype)initWithDict:(NSDictionary *)dict;


@end
