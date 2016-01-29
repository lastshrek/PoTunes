//
//  DMCTrack.h
//  DMCDevelopment
//
//  Created by Purchas on 11/11/15.
//  Copyright © 2015 TOPDMC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "DMCArtist.h"
#import "DMCAlbum.h"

@interface DMCTrack : NSObject

/**
 *  歌曲ID
 */
@property (nonatomic, copy) NSString *ID;
/**
 *  歌曲名称
 */
@property (nonatomic, copy) NSString *name;
/**
 *  作词
 */
@property (nonatomic, copy) NSString *lyricist;
/**
 *  作曲
 */
@property (nonatomic, copy) NSString *composer;
/**
 *  所属公司ID
 */
@property (nonatomic, copy) NSString *companyID;
/**
 *  所属公司名称
 */
@property (nonatomic, copy) NSString *companyName;
/**
 *  语种
 */
@property (nonatomic, copy) NSString *language;
/**
 *  发布时间
 */
@property (nonatomic, copy) NSString *pubTime;
/**
 *  艺人,包含DMCArtist模型
 */
@property (nonatomic, strong) NSMutableArray *artists;
/**
 *  专辑名称
 */
@property (nonatomic, strong) DMCAlbum *album;
/**
 *  当前数据版本号
 */
@property (nonatomic, copy) NSString *version;

/**
 *  歌曲所在专辑位置
 */
@property (nonatomic, copy) NSString *number;


/**
 *  歌曲时长
 */
@property (nonatomic, assign) float duration;
/**
 *  已播放时长
 */
@property (nonatomic, assign) float timePlayed;



@end
