//
//  BLTDownloaderManager.m
//  TSG-Phone
//
//  Created by lsq on 16/9/6.
//  Copyright © 2016年 tsg. All rights reserved.
//

#import "BLTDownloaderManager.h"

#define KEY_PARSE @"---"

@interface BLTDownloaderManager ()

@property(nonatomic,strong) NSMutableDictionary *downLoadCache;

@property(nonatomic,copy) void (^failed)(NSString *failed);

@end
@implementation BLTDownloaderManager

+ (instancetype)sharedDownloaderManager
{
    static id obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[self alloc]init];
    });
    return obj;
}

- (NSMutableDictionary *)downLoadCache
{
    if (_downLoadCache == nil) {
        _downLoadCache = [[NSMutableDictionary alloc]init];
    }
    return _downLoadCache;
}

- (void)newDownLoadWithURL:(NSURL *)url andCookie:(NSString*)cookieStr andHeaderFields:(NSDictionary*)allHeaderFields progress:(void (^)(float))progress completion:(void (^)(NSString *))completion failed:(void (^)(NSString *))failed
{
    [self downLoadWithURL:url andCookie:cookieStr andHeaderFields:allHeaderFields andName:nil progress:progress completion:completion failed:failed];
}
- (void)downLoadWithURL:(NSURL *)url andCookie:(NSString*)cookieStr andHeaderFields:(NSDictionary*)allHeaderFields andName:(NSString*)name progress:(void (^)(float))progress completion:(void (^)(NSString *))completion failed:(void (^)(NSString *))failed
{
    self.failed = failed;
    NSString *identify = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    NSString *key = [self getCacheKeyByIdenty:identify andPath:url.absoluteString];
    
    BLTDownloader *download = self.downLoadCache[key];
    
    //    if (download != nil) {
    //        if (failed) {
    //            failed(@"已经在下载队列了 请勿重复点击");
    //        }
    //        return;
    //    }
    
    download = [[BLTDownloader alloc]init];
    
    [self.downLoadCache setObject:download forKey:key];
    
    //    NSLogD(@"下载后往哪放 %@",url.path);
    
    __weak BLTDownloader *weakDownloader = download;
    [download downLoadWithURL:url andCookie:cookieStr andHeaderFields:allHeaderFields  andName:name andIdentify:identify progress:progress completion:^(NSString *filePath) {
        NSString *key = [self getCacheKeyByIdenty:weakDownloader.identify andPath:url.path];
        [self.downLoadCache removeObjectForKey:key];
        if (completion) {
            completion(filePath);
        }
    } failed:failed];
}

- (BOOL)isDownloadingWithURL:(NSString *)url andName:(NSString*)name
{
    NSArray *arr = [self.downLoadCache allKeys];
    for(int i = 0;i<[arr count];i++){
        BLTDownloader *b = self.downLoadCache[arr[i]];
        if(b!=nil && [b.fileName isEqualToString:name]){
            return YES;
        }
    }
    return NO;
}

- (void)pauseWithURL:(NSString *)url andName:(NSString*)name
{
    NSString *identify = @"";
    NSEnumerator *allKeys = [self.downLoadCache keyEnumerator];
    for(NSString *key in allKeys) {
        BLTDownloader *b = self.downLoadCache[key];
        if(b!=nil && [b.fileName isEqualToString:name]){
            identify = b.identify;
            break;
        }
    }
    NSString *key = [self getCacheKeyByIdenty:identify andPath:url];
    
    BLTDownloader *download = self.downLoadCache[key];
    
    if (download == nil) {
        if (self.failed) {
            self.failed(@"无效操作");
        }
        //        return;
    }
    if (download != nil)
        [download pause];
    [self.downLoadCache removeObjectForKey:key];
}

-(NSString*)getCacheKeyByIdenty:(NSString*)identify andPath:(NSString*)path{
    return [NSString stringWithFormat:@"%@%@%@",identify,KEY_PARSE, path];
}
@end
