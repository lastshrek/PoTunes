//
//  AlbumRowController.h
//  PoTunes
//
//  Created by Purchas on 15/9/24.
//  Copyright © 2015年 Purchas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WatchKit/WatchKit.h>

@interface AlbumRowController : NSObject

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *albumTitle;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *songTitle;
@property (weak, nonatomic) IBOutlet WKInterfaceImage *albumImage;

@end
