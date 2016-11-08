//
//  PCPlaylist.m
//  PoTunes
//
//  Created by Purchas on 15/9/10.
//  Copyright © 2015年 Purchas. All rights reserved.
//

#import "PCPlaylist.h"
#import "PCSong.h"
@implementation PCPlaylist

+ (instancetype)playlistWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        /** 1.注入所有属性 */
        self.count = dict[@"songCount"];
        /** 2.特殊处理stops属性 */
        NSMutableArray * songArray = [NSMutableArray array];
        for (NSDictionary *dict in self.songs) {
            PCSong *song = [PCSong songWithDict:dict];
            [songArray addObject:song];
        }
        self.songs = songArray;
    }
    return self;
}

@end
