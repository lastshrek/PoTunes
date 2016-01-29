//
//  DMCAccountTool.h
//  DMCDevelopment
//
//  Created by Purchas on 11/10/15.
//  Copyright © 2015 TOPDMC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DMCTrack;

@interface DMCAccountTool : NSObject
/**
 *  返回单例
 *
 *  @return 账号单例
 */
+ (DMCAccountTool *)sharedTool;


/**
 *  注册APPKey以及ClientID
 *
 *  @param key      APPKey
 *  @param clientID ClientID
 */
+ (void)registerApp:(NSString *)key clientID:(NSString *)clientID;


@end
