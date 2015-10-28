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
        self.title = dict[@"title"];
        self.thumb = dict[@"thumb"];
        self.author = dict[@"author"];
        self.sourceURL = dict[@"sourceUrl"];
        self.index = dict[@"index"];
        self.album = dict[@"album"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.thumb forKey:@"thumb"];
    [aCoder encodeObject:self.author forKey:@"author"];
    [aCoder encodeObject:self.sourceURL forKey:@"sourceUrl"];
    [aCoder encodeObject:self.index forKey:@"index"];
    [aCoder encodeObject:self.album forKey:@"album"];

}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.thumb = [aDecoder decodeObjectForKey:@"thumb"];
        self.author = [aDecoder decodeObjectForKey:@"author"];
        self.sourceURL = [aDecoder decodeObjectForKey:@"sourceUrl"];
        self.index = [aDecoder decodeObjectForKey:@"index"];
        self.album = [aDecoder decodeObjectForKey:@"album"];
    }
    return self;
}

@end
