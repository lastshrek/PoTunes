//
//  DBHelper.h
//  破音万里
//
//  Created by Purchas on 11/2/15.
//  Copyright © 2015 Purchas. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMDatabaseQueue,FMDatabase;

@interface DBHelper : NSObject

@property (nonatomic, strong) FMDatabaseQueue *queue;

+ (DBHelper *)getSharedInstance;

- (void)inDatabase:(void(^)(FMDatabase *db))block;

@end
