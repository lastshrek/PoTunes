//
//  DMCPlayback.h
//  DMCDevelopment
//
//  Created by Purchas on 16/1/18.
//  Copyright © 2016年 TOPDMC. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "DMCTrack.h"

typedef void (^feedbackBlock)(DMCTrack *item);
typedef void (^finishedBlock)(void);

@interface DMCPlayback : NSObject

typedef NS_ENUM(NSInteger, DMCTrackRate) {
    DMCTrackRate128  = 128,
    DMCTrackRate320  = 320
};


/**
 *  播放器单例
 *
 *  @return DMC播放器
 */
+ (DMCPlayback *)SharedPlayback;

/**
 *  根据TrackID播放音乐，默认请求320码率，没有则请求128码率
 *
 *  @param trackID 歌曲ID
 */
+ (void)playWithTrackID:(NSString *)trackID;

/**
 *  根据TrackID和比特率播放歌曲
 *
 *  @param trackID 歌曲ID
 *  @param rate    歌曲的比特率『参考上方DMCTrackRate，目前只提供128和320两种』
 */
+ (void)playWithTrackID:(NSString *)trackID byRate:(DMCTrackRate)rate;

/**
 *  暂停播放/继续播放
 */
+ (void)pause;

/**
 *  停止播放
 */
+ (void)stop;

/**
 *  快进至多少秒
 *
 *  @param second 秒
 */
+ (void)playAtSecond:(int)second;

/**
 *  用于返回播放信息诸如当前播放时长，歌曲总时长
 *
 *  @param block         播放过程中回调
 *  @param finishedBlock 播放完成回调
 */
+ (void)listenFeedbackUpdatesWithBlock:(feedbackBlock)block andFinishedBlock:(finishedBlock)finishedBlock;


/**
 *  根据歌曲ID获取歌曲信息
 *
 *  @param trackID 歌曲ID
 *  @param success 获取成功返回信息
 *  @param failure 获取失败返回信息
 */
+ (void)getTrackInfoWithTrackID:(NSString *)trackID
                        success:(void (^)(DMCTrack *track))success
                        failure:(void (^)(NSString *error))failure;

/**
 *  清空缓存
 */
+ (void)clearCache;

@end
