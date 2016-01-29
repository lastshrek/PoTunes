//
//  DMCAlbum.h
//  DMCDevelopment
//
//  Created by Purchas on 11/16/15.
//  Copyright © 2015 TOPDMC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMCAlbum : NSObject

/**
 *  专辑ID
 */
@property (nonatomic, copy) NSString *ID;

/**
 *  专辑封面
 */
@property (nonatomic, copy) NSString *photo;

/**
 *  专辑名称
 */
@property (nonatomic, copy) NSString *name;

/**
 *  专辑简介
 */
@property (nonatomic, copy) NSString *desc;

/**
 *  专辑语种
 */
@property (nonatomic, copy) NSString *language;

/**
 *  专辑类型
 */
@property (nonatomic, copy) NSString *albumType;

/**
 *  唱片公司ID
 */
@property (nonatomic, copy) NSString *companyID;

/**
 *  唱片公司名称
 */
@property (nonatomic, copy) NSString *companyName;

/**
 *  专辑艺人『DMCArtist』
 */
@property (nonatomic, strong) NSArray *artists;

/**
 *  专辑中包含的歌曲『DMCTrack』
 */
@property (nonatomic, strong) NSArray *tracks;

/**
 *  版本号
 */
@property (nonatomic, copy) NSString *version;
@end
