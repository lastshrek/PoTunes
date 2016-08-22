//
//  DarwinNotificationHelper.m
//  MeatCooker
//
//  Created by Jack Wu on 2015-02-02.
//  Copyright (c) 2015 Ray Wenderlich. All rights reserved.
//

#import "DarwinNotificationHelper.h"

@implementation DarwinNotificationHelper {
    NSMutableDictionary * handlers;
}

+ (instancetype)sharedHelper {
    static id instance = NULL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        handlers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)registerForNotificationName:(NSString *)name callback:(void (^)(void))callback {
    handlers[name] = callback;
    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterAddObserver(center, (__bridge const void *)(self), darwinNotificationCallback, (__bridge CFStringRef)name, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}

- (void)postNotificationWithName:(NSString *)name {
    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterPostNotification(center, (__bridge CFStringRef)name, NULL, NULL, YES);
}

- (void)notificationCallbackReceivedWithName:(NSString *)name {
    void (^callback)(void) = handlers[name];
    callback();
}

void darwinNotificationCallback(CFNotificationCenterRef center,
                                  void * observer,
                                  CFStringRef name,
                                  void const * object,
                                  CFDictionaryRef userInfo) {
    NSString *identifier = (__bridge NSString *)name;
    [[DarwinNotificationHelper sharedHelper] notificationCallbackReceivedWithName:identifier];
}

- (void)dealloc {
    CFNotificationCenterRef center = CFNotificationCenterGetDarwinNotifyCenter();
    CFNotificationCenterRemoveEveryObserver(center, (__bridge const void *)(self));
}

@end
