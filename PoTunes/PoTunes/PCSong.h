//
//  PCSong.h
//  PoTunes
//
//  Created by Purchas on 15/9/10.
//  Copyright © 2015年 Purchas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCSong : NSObject


/** 所属专辑 */
@property (nonatomic, copy) NSString *album;
/** 艺人 */
@property (nonatomic, copy) NSString *artist;
/** 歌曲名 */
@property (nonatomic, copy) NSString *songName;
/** 专辑封面 */
@property (nonatomic, copy) NSString *cover;
/** 下载地址 */
@property (nonatomic, copy) NSString *URL;
/** 所在专辑suoyin */
@property (nonatomic, assign) NSNumber *index;

+ (instancetype)songWithDict:(NSDictionary *)dict;
- (instancetype)initWithDict:(NSDictionary *)dict;

@end
