//
//  AppDelegate.h
//  PoTunes
//
//  Created by Purchas on 15/9/1.
//  Copyright © 2015年 Purchas. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^PlayerRemoteEventBlock)(UIEvent *event);//播放器远程事件block

@interface AppDelegate : UIResponder

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, copy) PlayerRemoteEventBlock remoteEventBlock;
@end

