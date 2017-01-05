//
//  Debug.h
//  破音万里
//
//  Created by Purchas on 2017/1/4.
//  Copyright © 2017年 Purchas. All rights reserved.
//

#ifndef Debug_h
#define Debug_h

#define NSSLog(FORMAT, ...) fprintf(stderr,"%s:%d\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

#else

#define NSSLog(...)


#endif /* Debug_h */
