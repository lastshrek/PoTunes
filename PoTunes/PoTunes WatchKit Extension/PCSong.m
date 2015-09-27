//
//  PCSong.m
//  PoTunes
//
//  Created by Purchas on 15/9/10.
//  Copyright © 2015年 Purchas. All rights reserved.
//

#import "PCSong.h"

@implementation PCSong

+ (instancetype)songWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}
- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.songName = dict[@"songName"];
        self.cover = dict[@"songCover"];
        self.artist = dict[@"artists"];
        self.album = dict[@"title"];
        self.URL = dict[@"songURL"];
        self.index = dict[@"indexPath"];
    }
    return self;
}

@end
