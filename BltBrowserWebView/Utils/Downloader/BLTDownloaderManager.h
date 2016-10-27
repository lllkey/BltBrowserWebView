//
//  BLTDownloaderManager.h
//  TSG-Phone
//
//  Created by lsq on 16/9/6.
//  Copyright © 2016年 tsg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLTDownloader.h"

@interface BLTDownloaderManager : NSObject

+ (instancetype)sharedDownloaderManager;

- (void)newDownLoadWithURL:(NSURL *)url andCookie:(NSString*)cookieStr andHeaderFields:(NSDictionary*)allHeaderFields progress:(void (^)(float))progress completion:(void (^)(NSString *))completion failed:(void (^)(NSString *))failed;
- (void)downLoadWithURL:(NSURL *)url andCookie:(NSString*)cookieStr andHeaderFields:(NSDictionary*)allHeaderFields andName:(NSString*)name progress:(void (^)(float))progress completion:(void (^)(NSString *))completion failed:(void (^)(NSString *))failed;

- (void)pauseWithURL:(NSString *)url andName:(NSString*)name;
- (BOOL)isDownloadingWithURL:(NSString *)url andName:(NSString*)name;

@end
