//
//  DarwinNotificationHelper.h
//  MeatCooker
//
//  Created by Jack Wu on 2015-02-02.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DarwinNotificationHelper : NSObject

+ (instancetype)sharedHelper;

- (void)registerForNotificationName:(NSString *)name callback:(void (^)(void))callback;
- (void)postNotificationWithName:(NSString *)name;


@end
