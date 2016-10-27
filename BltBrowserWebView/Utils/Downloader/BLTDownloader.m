//
//  BLTDownloader.m
//  TSG-Phone
//
//  Created by lsq on 16/9/6.
//  Copyright © 2016年 tsg. All rights reserved.
//

#import "BLTDownloader.h"
#import "BltDownloaderDatabaseManager.h"
#import "DownloaderUtils.h"
#import "Utils.h"

@interface BLTDownloader() <NSURLConnectionDataDelegate>

/**
 预计文件大小
 */
@property (nonatomic,assign) long long  expectedContentLength;

/**
 当前文件大小
 */
@property (nonatomic,assign) long long  currentLength;

/**
 文件路径，包括fileName
 */
@property(nonatomic,copy) NSString *filePath;

/**
 下载的url
 */
@property(nonatomic,strong) NSURL *downLoadUrl;

/**
 下载的connection
 */
@property(nonatomic,strong) NSURLConnection *downLoadURLConnection;

/**
 loop
 */
@property (nonatomic,assign) CFRunLoopRef downLoadRunLoop;

/**
 file stream
 */
@property(nonatomic,strong) NSOutputStream *fileStrem;

/**
 下载进度的回调
 */
@property(nonatomic,copy) void (^progress)(float);

/**
 下载完成的回调
 */
@property(nonatomic,copy) void (^completion)(NSString *);

/**
 下载失败的回调
 */
@property(nonatomic,copy) void (^failed)(NSString *);

/**
 core data管理
 */
@property (strong, nonatomic) BltDownloaderDatabaseManager *coreDataManager;

/**
 存储下载链接、下载文件名、创建时间等
 */
@property (nonatomic) NSMutableDictionary *dict;

/**
 是否已经暂停，如果已经暂停则不接受任何数据
 */
@property (nonatomic) BOOL isPaused;

/**
 cookie
 */
@property (nonatomic) NSString* cookieStr;

/**
 请求头
 */
@property (nonatomic) NSDictionary* allHeaderFields;
@end

@implementation BLTDownloader

- (void)pause
{
    self.isPaused = YES;
    [self.downLoadURLConnection cancel];
}
- (void)downLoadWithURL:(NSURL *)url andCookie:(NSString*)cookieStr andHeaderFields:(NSDictionary*)allHeaderFields andName:(NSString*)name andIdentify:(NSString *)identify progress:(void (^)(float))progress completion:(void (^)(NSString *))completion failed:(void (^)(NSString *))failed
{
    self.downLoadUrl = url;
    self.progress = progress;
    self.completion = completion;
    self.failed = failed;
    self.identify = identify;
    self.fileName = name;
    self.cookieStr = cookieStr;
    self.allHeaderFields = allHeaderFields;
    
    dispatch_async(dispatch_queue_create("blt.concurrent.queue", DISPATCH_QUEUE_CONCURRENT), ^{
        [self checkServerFileInfo: self.downLoadUrl];
        NSLog(@"大小是%lld",self.expectedContentLength);
        if([self.dict[@"state"] intValue] == BLTURLDownloadStatusDownloadFailed){
            // 如果之前判断下载失败就不做后续的事情
            return;
        }
        if (name) {
            [self checkLocalFile];
        }
        
        self.isPaused = NO;
        NSLog(@"总大小是%lld\n需要从%lld开始下载",self.expectedContentLength,self.currentLength);
        //    NSString *show = [NSString stringWithFormat:@"总大小是%lld\n需要从%lld开始下载",self.expectedContentLength,self.currentLength];
        //    [SVProgressHUD showInfoWithStatus:show maskType:SVProgressHUDMaskTypeBlack];
        [self downLoadFile];
        
    });
    //    [BLTOperation addOperationWithBlockInQuene:^{
    //
    //    }];
}

#pragma mark - /************************* 下载文件 ***************************/
- (void)downLoadFile
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.downLoadUrl cachePolicy:1 timeoutInterval:100.0f];
        
        if(self.allHeaderFields){
            NSEnumerator *keys = [_allHeaderFields keyEnumerator];
            for (NSString *key in keys) {
                [request setValue:_allHeaderFields[key] forHTTPHeaderField:key];
            }
        }
        
        NSString *rangStr = [NSString stringWithFormat:@"bytes=%lld-",self.currentLength];
        
        [request setValue:rangStr forHTTPHeaderField:@"Range"];
        
        
        self.downLoadURLConnection = [NSURLConnection connectionWithRequest:request delegate:self];
        
        [self.downLoadURLConnection start];
        
        self.downLoadRunLoop = CFRunLoopGetCurrent();
        
        CFRunLoopRun();
    });
    
}

#pragma mark - /************************* NSURLConnection代理方法 ***************************/
#pragma mark 接受到响应
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLogD(@"didReceiveResponse");
    if(self.isPaused) return;
    self.fileStrem = [[NSOutputStream alloc]initToFileAtPath:self.filePath append:YES];
    NSLog(@"temp --- %@",self.filePath);
    if(!self.fileStrem) return;
    [self.fileStrem open];
    
    [self.dict setObject:[NSNumber numberWithInt:BLTURLDownloadStatusDownloading] forKey:@"state"];
    [self.coreDataManager updateDownloadItemWithDownloadObject:self.dict];
    
}
#pragma mark 接受到数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //    NSLogD(@"didReceiveData");
    if(self.isPaused){
        [self.fileStrem close];
        CFRunLoopStop(self.downLoadRunLoop);
        return;
    }
    [self.fileStrem write:data.bytes maxLength:data.length];
    self.currentLength += data.length;
    
    float progress = (float)self.currentLength/self.expectedContentLength;
    
    NSLog(@"=====>%.4f  currentLength: %.2lld",progress,self.currentLength);
    if (self.progress) {
        self.progress(progress);
    }
    
    [self.dict setObject:[NSDate date] forKey:@"updatedTime"];
    [self.dict setObject:[NSNumber numberWithLongLong:self.currentLength] forKey:@"downloadedSize"];
    if (self.progress)
        [self.dict setObject:[NSNumber numberWithFloat:progress] forKey:@"progress"];
    [self.dict setObject:[NSNumber numberWithInt:BLTURLDownloadStatusDownloading] forKey:@"state"];
    [self.coreDataManager updateDownloadItemWithDownloadObject:self.dict];
}
#pragma mark 结束下载
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLogD(@"connectionDidFinishLoading");
    if(self.isPaused) return;
    [self.fileStrem close];
    CFRunLoopStop(self.downLoadRunLoop);
    
    if (self.completion) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completion(self.filePath);
        }) ;
    }
    
    [self.dict setObject:[NSDate date] forKey:@"updatedTime"];
    [self.dict setObject:[NSDate date] forKey:@"finishTime"];
    [self.dict setObject:[NSNumber numberWithLongLong:self.currentLength] forKey:@"downloadedSize"];
    [self.dict setObject:[NSNumber numberWithInt:BLTURLDownloadStatusSucceeded] forKey:@"state"];
    if (self.progress)
        [self.dict setObject:[NSNumber numberWithFloat:1.0] forKey:@"progress"];
    [self.coreDataManager updateDownloadItemWithDownloadObject:self.dict];
    
    // 需要再次保存，不然会有如果当前下载完成文件立即重启App则下载状态不保存的问题
    dispatch_time_t delayInSeconds = dispatch_time(DISPATCH_TIME_NOW, (int64_t)10);
    dispatch_after(delayInSeconds, dispatch_get_main_queue(), ^(void){
        [self.coreDataManager updateDownloadItemWithDownloadObject:self.dict];
    });
}
#pragma mark 遇到错误
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLogD(@"didFailWithError %@ %@",self.fileName,error);
    if(self.isPaused) return;
    [self.fileStrem close];
    CFRunLoopStop(self.downLoadRunLoop);
    
    if (self.failed) {
        self.failed([NSString stringWithFormat:@"%@",error.localizedDescription]);
        
    }
    [self.dict setObject:[NSNumber numberWithInt:BLTURLDownloadStatusDownloadFailed] forKey:@"state"];
    [self.coreDataManager updateDownloadItemWithDownloadObject:self.dict];
}


#pragma mark - /************************* 检测服务器文件信息 ***************************/
- (void)checkServerFileInfo:(NSURL *)url
{
    if(!url)    return;
    NSLogD(@"checkServerFileInfo");
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:100.0f];
    if(self.cookieStr)
        [request addValue:self.cookieStr forHTTPHeaderField:@"Cookie"];
    NSLog(@"url download  %@",url);
    NSLog(@"cookieStr download  %@",_cookieStr);
    
    request.HTTPMethod = @"HEAD";
    
    if(self.allHeaderFields){
        NSEnumerator *keys = [_allHeaderFields keyEnumerator];
        for (NSString *key in keys) {
            [request addValue:_allHeaderFields[key] forHTTPHeaderField:key];
        }
        [request setMainDocumentURL:[NSURL URLWithString:_allHeaderFields[@"Referer"]]];
    }
    NSLog(@"checkServerFileInfo allHeaderFields %@",request.allHTTPHeaderFields);
    //    [request setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
    
    NSURLResponse *response = nil;
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    
    if(!response){
        //失败的时候，如果已经下载过的，则修改状态，防止为空
        if(self.fileName!=nil && [self isFileNameInCoreData:self.fileName]){
            NSLog(@"aaaa   response%@",response);
            self.filePath = [DownloaderUtils getPathStrByFileName:self.fileName andUserId:[Config getAccountId]];
            [self.dict setObject:self.fileName forKey:@"name"];
            
            [self.dict setObject:[NSNumber numberWithInt:BLTURLDownloadStatusDownloading] forKey:@"state"];
            [self.coreDataManager updateDownloadItemWithDownloadObject:self.dict];
        }
        return;
    }
    self.expectedContentLength = response.expectedContentLength;
    if(self.expectedContentLength == NSURLResponseUnknownLength){
        //        NSMutableURLRequest *request2 = [NSMutableURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:20.0f];
        //        request2.HTTPMethod = @"HEAD";
        //        [request2 setValue:@"" forHTTPHeaderField:@"Accept-Encoding"];
        //        NSURLResponse *response2 = nil;
        //
        //        [NSURLConnection sendSynchronousRequest:request2 returningResponse:&response2 error:NULL];
        //        self.expectedContentLength = response2.expectedContentLength;
        //        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    }
    
    if(self.fileName!=nil && [self isFileNameInCoreData:self.fileName]){
        NSLog(@"aa   response%@",response);
        self.filePath = [DownloaderUtils getPathStrByFileName:self.fileName andUserId:[Config getAccountId]];
        [self.dict setObject:self.fileName forKey:@"name"];
        
        [self.dict setObject:[NSNumber numberWithInt:BLTURLDownloadStatusDownloading] forKey:@"state"];
        [self.coreDataManager updateDownloadItemWithDownloadObject:self.dict];
        NSString* tmpName = [self getFileNameByResponse:response];
        if(![[self.fileName stringByDeletingPathExtension] containsString:[tmpName stringByDeletingPathExtension]] && ![[self.fileName stringByDeletingPathExtension] isEqualToString:[tmpName stringByDeletingPathExtension]]){
            NSLog(@"aa   tmpName %@  fileName %@",tmpName,self.fileName);
            // 当时下载的东西已经不是之前下载的了，可能需要登录之类的
            [self.dict setObject:[NSNumber numberWithInt:BLTURLDownloadStatusDownloadFailed] forKey:@"state"];
            [self.coreDataManager updateDownloadItemWithDownloadObject:self.dict];
        }
    }else {
        NSLog(@"bb   response%@",response);
        self.fileName = [self getFileNameByResponse:response];
        
        self.fileName = [self getNewName:self.fileName];
        self.filePath = [DownloaderUtils getPathStrByFileName:self.fileName andUserId:[Config getAccountId]];
        
        [self.dict setObject:[NSDate date] forKey:@"createdTime"];
        [self.dict setObject:[NSDate date] forKey:@"updatedTime"];
        [self.dict setObject:[NSNumber numberWithLongLong:self.currentLength] forKey:@"downloadedSize"];
        if(self.expectedContentLength != NSURLResponseUnknownLength)
            [self.dict setObject:[NSNumber numberWithLongLong:self.expectedContentLength] forKey:@"totalSize"];
        [self.dict setObject: self.fileName forKey:@"name"];
        [self.dict setObject:self.filePath forKey:@"targetPath"];
        [self.dict setObject:[NSNumber numberWithInt:BLTURLDownloadStatusWaiting] forKey:@"state"];
        [self.dict setObject:[url absoluteString]  forKey:@"downloadURL"];
        [self.dict setObject:[Config getAccountId] forKey:@"userId"];
        [self.coreDataManager insertCoreDataByDict:self.dict];
    }
    return;
}

-(NSMutableDictionary*)dict{
    if(_dict==nil){
        _dict = [NSMutableDictionary dictionary];
    }
    return _dict;
}

#pragma mark - /************************* 检查本地是否存在文件 ***************************/
- (BOOL)checkLocalFile
{
    long long fileSize = 0;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
        
        NSDictionary *attributes = [[NSFileManager defaultManager]attributesOfItemAtPath:self.filePath error:NULL];
        //        fileSize = [attributes[NSFileSize] longLongValue];
        fileSize = [attributes fileSize];
    }
    
    if (self.expectedContentLength>0 && fileSize > self.expectedContentLength) {
        [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:NULL];
        fileSize = 0;
    }
    
    self.currentLength = fileSize;
    
    NSLog(@"checkLocalFile  %@  %lld",self.filePath,fileSize);
    
    //    if (fileSize == self.expectedContentLength) {
    //        NSLog(@"文件已经存在");
    //        self.progress(1.0);
    //        //        [SVProgressHUD showInfoWithStatus:@"文件已经存在" maskType:SVProgressHUDMaskTypeBlack];
    //
    //        return NO ;
    //    }
    
    return YES;
}

- (NSString *)getFileNameByResponse:(NSURLResponse *)response
{
    NSString *fileName =  response.suggestedFilename;
    const char *byte = NULL;
    byte = [fileName cStringUsingEncoding:NSISOLatin1StringEncoding];
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    fileName = [[NSString alloc] initWithCString:byte encoding: enc];
    //        if(fileName == nil)
    fileName = [[NSString alloc] initWithCString:byte encoding: NSUTF8StringEncoding];
    return fileName;
}
-(BOOL)isFileNameInCoreData:(NSString*)name{
    NSArray *fetchedItems=  [self.coreDataManager fetchAllDownloadItemsForStatus:-1 andUserId:[Config getAccountId]];
    for(int i = 0; i<[fetchedItems count]; i++){
        BltDownloadItem *item = fetchedItems[i];
        if([item.name isEqualToString:name]){
            return YES;
        }
    }
    return NO;
}

-(NSString*)getNewName:(NSString*)orName{
    NSString *name = [orName copy];
    NSArray *fetchedItems=  [self.coreDataManager fetchAllDownloadItemsForStatus:-1 andUserId:[Config getAccountId]];
    int i;
    NSMutableArray *strArray = [NSMutableArray array];
    for(i = 0; i<[fetchedItems count]; i++){
        BltDownloadItem *item = fetchedItems[i];
        [strArray addObject:item.name];
    }
    i=0;
    while (true) {
        if(![strArray containsObject:name]){
            break;
        }
        i++;
        name = [NSString stringWithFormat:@"%@ (%d).%@ ",[orName stringByDeletingPathExtension] ,i,[orName pathExtension]];
    }
    return name;
}
- (BltDownloaderDatabaseManager *)coreDataManager {
    //    if (!self.backgroundMode) {
    //        return nil;
    //    }
    if (!_coreDataManager) {
        _coreDataManager = [[BltDownloaderDatabaseManager alloc] init];
    }
    return _coreDataManager;
}

@end
