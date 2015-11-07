//
//  DBHelper.m
//  破音万里
//
//  Created by Purchas on 11/2/15.
//  Copyright © 2015 Purchas. All rights reserved.
//

#import "DBHelper.h"
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"
@implementation DBHelper


- (id)init {
    
    self = [super init];
    
    if (self) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"downloadingSong.db"];
        
        self.queue = [FMDatabaseQueue databaseQueueWithPath:path];
    }
    
    return self;
}

+ (DBHelper *)getSharedInstance {
    
    static dispatch_once_t onceToken;
    
    __strong static id _sharedObject = nil;
    
    dispatch_once(&onceToken, ^{
        
        _sharedObject = [[self alloc] init];
    });
    
    return _sharedObject;
}



- (void)inDatabase:(void(^)(FMDatabase *db))block {
    
    [self.queue inDatabase:^(FMDatabase *db){
            
        block(db);
    
    }];
}

@end
