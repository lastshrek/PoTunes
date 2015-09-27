//
//  NowPlayingInterfaceController.m
//  PoTunes
//
//  Created by Purchas on 15/9/25.
//  Copyright © 2015年 Purchas. All rights reserved.
//

#import "NowPlayingInterfaceController.h"
#import "PCSong.h"
#import "DarwinNotificationHelper.h"
@interface NowPlayingInterfaceController ()
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceImage *cover;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *previousBtn;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *playOrPauseBtn;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceImage *nextBtn;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceGroup *coverGroup;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceGroup *progressGroup;
@property (nonatomic, assign) CGRect screenBounds;
- (IBAction)previous;
- (IBAction)playOrPause;
- (IBAction)next;



@property (nonatomic, strong) NSMutableDictionary *songDic;
@end

@implementation NowPlayingInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    // 获取当前设备宽度来设置图片.
    WKInterfaceDevice *device = [WKInterfaceDevice currentDevice];
    self.screenBounds = device.screenBounds;
    [self registerForNotifications];

    
    if (context) {
        if (self.screenBounds.size.width == 156) {
            [self.playOrPauseBtn setBackgroundImageNamed:@"cm2_watch_btn_pause_42"];
        } else {
            [self.playOrPauseBtn setBackgroundImageNamed:@"cm2_watch_btn_pause_38"];
        }
        
    } else {
        NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.fm.poche.potunes"];
        NSString *isPlaying = [shared objectForKey:@"isPlaying"];
        if ([isPlaying isEqualToString:@"0"]) {
            if (self.screenBounds.size.width == 156) {
                [self.playOrPauseBtn setBackgroundImageNamed:@"cm2_watch_btn_pause_42"];
            } else {
                [self.playOrPauseBtn setBackgroundImageNamed:@"cm2_watch_btn_pause_38"];
            }
        } else {
            if (self.screenBounds.size.width == 156) {
                [self.playOrPauseBtn setBackgroundImageNamed:@"cm2_watch_btn_play_42"];
            } else {
                [self.playOrPauseBtn setBackgroundImageNamed:@"cm2_watch_btn_play_38"];
            }
        }

    }
    
    
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    
    
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)registerForNotifications {
    DarwinNotificationHelper *helper = [DarwinNotificationHelper sharedHelper];
    NSUserDefaults *shared = [[NSUserDefaults alloc] initWithSuiteName:@"group.fm.poche.potunes"];
    //展示播放或者暂停按钮
    [helper registerForNotificationName:@"isPlaying" callback:^{
        NSString *isPlaying = [shared objectForKey:@"isPlaying"];
        if ([isPlaying isEqualToString:@"0"]) {
            if (self.screenBounds.size.width == 156) {
                [self.playOrPauseBtn setBackgroundImageNamed:@"cm2_watch_btn_pause_42"];
            } else {
                [self.playOrPauseBtn setBackgroundImageNamed:@"cm2_watch_btn_pause_38"];
            }
        } else {
            if (self.screenBounds.size.width == 156) {
                [self.playOrPauseBtn setBackgroundImageNamed:@"cm2_watch_btn_play_42"];
            } else {
                [self.playOrPauseBtn setBackgroundImageNamed:@"cm2_watch_btn_play_38"];
            }
        }
    }];
    [helper registerForNotificationName:@"imageData" callback:^{
        NSData *imageData = [shared objectForKey:@"imageData"];
        [self.cover setImageData:imageData];
    }];
    //进度条走起
    [helper registerForNotificationName:@"progress" callback:^{
        float progress = [[shared objectForKey:@"progress"] floatValue];
        int rangeProgress = (int)(progress * 100);
        int leftTime = [[shared objectForKey:@"leftTime"] intValue];
        [self.progressGroup setBackgroundImageNamed:@"progress"];
        [self.progressGroup startAnimatingWithImagesInRange:NSMakeRange(rangeProgress, 100) duration:leftTime repeatCount:1];
    }];

}
- (IBAction)previous {
    DarwinNotificationHelper *helper = [DarwinNotificationHelper sharedHelper];
    [helper postNotificationWithName:@"previous"];}

- (IBAction)playOrPause {
    DarwinNotificationHelper *helper = [DarwinNotificationHelper sharedHelper];
    [helper postNotificationWithName:@"playOrPause"];
}

- (IBAction)next {
    DarwinNotificationHelper *helper = [DarwinNotificationHelper sharedHelper];
    [helper postNotificationWithName:@"next"];
}
@end



