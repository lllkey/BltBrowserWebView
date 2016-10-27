//
//  BLTDownloader.h
//  TSG-Phone
//
//  Created by lsq on 16/9/6.
//  Copyright © 2016年 tsg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BLTURLDownloadStatus) {
    BLTURLDownloadStatusWaiting = 0,
    BLTURLDownloadStatusDownloading,
    BLTURLDownloadStatusPaused,
    BLTURLDownloadStatusSucceeded,
    BLTURLDownloadStatusProcessing,
    BLTURLDownloadStatusDownloadFailed,
};

typedef NS_ENUM(NSInteger, BLTURLDownloadError) {
    BLTURLDownloadErrorInvalidURL = 0,
    BLTURLDownloadErrorHTTPError,
    BLTURLDownloadErrorNotEnoughFreeDiskSpace
};


@interface BLTDownloader : NSObject
@property (nonatomic) NSString *identify;
@property (nonatomic) NSString *fileName;

- (void)downLoadWithURL:(NSURL *)url andCookie:(NSString*)cookieStr andHeaderFields:(NSDictionary*)allHeaderFields andName:(NSString*)name andIdentify:(NSString *)identify progress:(void (^)(float))progress completion:(void (^)(NSString *))completion failed:(void (^)(NSString *))failed;

- (void)pause;
@end
