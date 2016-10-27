//
//  BltDownloaderDatabaseManager.h
//  TSG-Phone
//
//  Created by lsq on 16/9/7.
//  Copyright © 2016年 tsg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BltDownloadItem+CoreDataProperties.h"
#import "BLTDownloader.h"

#define TableName_Downloader @"BltDownloadItem"


@interface BltDownloaderDatabaseManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+(void)saveContext;
/**
 *  主的 NSManagedObjectContext，由于操作比较简单所以只暴露一个主的 NSManagedObjectContext，用于查询和检测 DownloadItem 的变化
 *
 *  @return mainManagedObjectContext
 */
+ (NSManagedObjectContext *)mainManagedObjectContext;

/**
 *  用作更新
 *
 *  @param block 更新时执行的 block，不会阻碍线程
 */
- (void)performBlock:(void (^)(NSManagedObjectContext *context))block
        onCompletion:(void (^)(BOOL success, NSError *error))completionBlock;

/**
 *  用作插入
 *
 *  @param block 插入时执行的 block，会阻碍线程，插入后在主的 NSManagedObjectContext 能立即得到插入的对象，用 performBlock:onCompletion: 会有延时
 */
- (void)performBlockAndWait:(void(^)(NSManagedObjectContext *context))block;

/**
 *
 *
 *  @param dict
 */
-(void) insertCoreDataByDict:(NSMutableDictionary*)dict;
- (NSArray *)fetchAllDownloadItemsForStatus:(BLTURLDownloadStatus)status andUserId:(NSString*)userId;

- (void)fetchAllDownloadItemsForStatus:(BLTURLDownloadStatus)status  andUserId:(NSString*)userId
                             withBlock:(void (^)(NSArray *fetchedItems))completionBlock;

- (void)updateDownloadItemWithDownloadObject:(NSMutableDictionary*)dict;


- (void)deleteDownloadItemWithIdentifier:(NSMutableDictionary*)dict;

- (void)deleteDownloadItem:(BltDownloadItem *)downloadItem;
@end
