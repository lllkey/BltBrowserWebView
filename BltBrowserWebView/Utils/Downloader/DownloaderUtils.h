//
//  DownloaderUtils.h
//  BltBrowser
//
//  Created by lsq on 16/9/27.
//  Copyright © 2016年 blt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloaderUtils : NSObject

+(void)deleteFileByPath:(NSString*)fileFullPath;
+(NSString*)getPathStrByFileName:(NSString*)fileName andUserId:(NSString*)userId;
+(NSArray*)getFilesByUserId:(NSString*)userId;

@end
