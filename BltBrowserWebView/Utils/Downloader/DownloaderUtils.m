//
//  DownloaderUtils.m
//  BltBrowser
//
//  Created by lsq on 16/9/27.
//  Copyright © 2016年 blt. All rights reserved.
//

#import "DownloaderUtils.h"

@implementation DownloaderUtils

+(NSString*)getPathStrByFileName:(NSString*)fileName andUserId:(NSString*)userId{
    NSString *rootDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *path = [[[rootDir stringByAppendingPathComponent:[NSString stringWithFormat:@"account_%@",userId]]stringByAppendingPathComponent:@"DownloadFile"]stringByAppendingPathComponent:fileName];
    [self createFileDir:path];
    return path;
}

//-(void)deleteFileByFileName:(NSString*)path andUserId:(NSString*)userId{
//    NSString *rootDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//
//}
+(void)deleteFileByPath:(NSString*)fileFullPath{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString *FileDir = [fileFullPath stringByDeletingLastPathComponent];
    NSError *err;
    [fileMgr createDirectoryAtPath:FileDir withIntermediateDirectories:YES attributes:nil error:&err];
    BOOL bRet = [fileMgr fileExistsAtPath:fileFullPath];
    if (bRet) {
        //
        NSError *err;
        [fileMgr removeItemAtPath:fileFullPath error:&err];
    }
}
+(NSArray*)getFilesByUserId:(NSString*)userId{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *array = [[NSArray alloc] init];
    NSString* path = [[self getPathStrByFileName:@"tmp" andUserId:userId] stringByDeletingLastPathComponent];
    array = [fileManager contentsOfDirectoryAtPath:path error:&error];
    return array;
}

+(void)createFileDir:(NSString*)filePath{
    NSString *path = filePath;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isDirExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if(!isDir){
        path = [path stringByDeletingLastPathComponent];
        isDirExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    }
    if(!(isDirExist&&isDir)) {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"Create Directory Failed.");
        }
        NSLog(@"Create Directory Success.");
    }
}

@end
