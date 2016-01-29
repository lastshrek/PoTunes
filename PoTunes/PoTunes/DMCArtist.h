//
//  DMCArtist.h
//  DMCDevelopment
//
//  Created by Purchas on 11/11/15.
//  Copyright © 2015 TOPDMC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMCArtist : NSObject
/**
 *  艺人ID
 */
@property (nonatomic, copy) NSString *ID;
/**
 *  艺人图片
 */
@property (nonatomic, copy) NSString *photo;
/**
 *  性别
 */
@property (nonatomic, copy) NSString *gender;
/**
 *  艺人名称
 */
@property (nonatomic, copy) NSString *name;

/**
 *  艺人国籍
 */
@property (nonatomic, copy) NSString *country;

/**
 *  所属公司ID
 */
@property (nonatomic, copy) NSString *companyID;

/**
 *  所属唱片公司名称
 */
@property (nonatomic, copy) NSString *companyName;

/**
 *  歌手简介
 */
@property (nonatomic, copy) NSString *desc;

@end
