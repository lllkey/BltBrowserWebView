//
//  BltDownloaderDatabaseManager.m
//  TSG-Phone
//
//  Created by lsq on 16/9/7.
//  Copyright © 2016年 tsg. All rights reserved.
//

#import "BltDownloaderDatabaseManager.h"
#import "Utils.h"

static void * const kBLTCoreDataQueueContextKey = (void *)&kBLTCoreDataQueueContextKey;

dispatch_queue_t blt_coredata_queue() {
    static dispatch_queue_t blt_coredata_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundleIdentifier = [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey];
        blt_coredata_queue = dispatch_queue_create([[bundleIdentifier stringByAppendingString:@".bltdownloader-coredata-queue"] UTF8String], DISPATCH_QUEUE_SERIAL);
        void *nonNullValue = kBLTCoreDataQueueContextKey;
        dispatch_queue_set_specific(blt_coredata_queue, kBLTCoreDataQueueContextKey, nonNullValue, NULL);
    });
    return blt_coredata_queue;
}

@implementation BltDownloaderDatabaseManager

+ (NSManagedObjectContext *)mainManagedObjectContext {
    static NSManagedObjectContext *mainContext;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [mainContext performBlockAndWait:^{
            [mainContext setParentContext:[self rootManagedObjectContext]];
        }];
    });
    return mainContext;
}

+ (NSManagedObjectContext *)rootManagedObjectContext {
    static NSManagedObjectContext *rootContext;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void(^setRootManagedObjectContext)(void) = ^{
            rootContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            rootContext.mergePolicy = [[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyObjectTrumpMergePolicyType];
            [rootContext performBlockAndWait:^{
                rootContext.persistentStoreCoordinator = [self persistentStoreCoordinator];
            }];
        };
        if (dispatch_get_specific(kBLTCoreDataQueueContextKey) != NULL) {
            setRootManagedObjectContext();
        } else {
            dispatch_sync(blt_coredata_queue(), setRootManagedObjectContext);
        }
    });
    return rootContext;
}

+ (void)saveContext {
    NSManagedObjectContext *mainManagedObjectContext = [self mainManagedObjectContext];
    NSManagedObjectContext *rootContext = [self rootManagedObjectContext];
   // NSLog(@"saveContext---------------------save --------------------------");
    if (![mainManagedObjectContext hasChanges] && ![rootContext hasChanges]) {
       // NSLog(@"saveContext---------------------no changes --------------------------");

        return;
    }
    [mainManagedObjectContext performBlockAndWait:^{
        NSError * __block saveError;
        BOOL __block success = [mainManagedObjectContext save:&saveError];
        //NSLog(@"performBlockAndWait---------------------save --------------------------");

        if (!success) {
         //   NSLog(@"Main Manmanged Object Context Save Error: %@ - %@", saveError.localizedDescription, saveError.userInfo);
        }
        [rootContext performBlock:^{
          //  NSLog(@"performBlock---------------------save --------------------------");

            success = [rootContext save:&saveError];
            if (!success) {
                NSLog(@"Root Manmanged Object Context Save Error: %@ - %@", saveError.localizedDescription, saveError.userInfo);
            }
          //  NSLog(@"---------------------save success--------------------------");

        }];
    }];
}

- (NSManagedObjectContext *)createManagedObjectContextWithParent:(NSManagedObjectContext *)parentContext {
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.parentContext = parentContext;
    return context;
}

- (void)performBlock:(void (^)(NSManagedObjectContext *context))block
        onCompletion:(void (^)(BOOL success, NSError *error))completionBlock {
    
    NSManagedObjectContext *parentManagedObjectContext = [[self class] mainManagedObjectContext];
    NSManagedObjectContext *context = [self createManagedObjectContextWithParent:parentManagedObjectContext];
    [context performBlock:^{
        block(context);
        if ([context hasChanges]) {
            NSError *error;
            if ([context.insertedObjects count] > 0) {
                
                [context obtainPermanentIDsForObjects:[context.insertedObjects allObjects]
                                                error:nil];
            }
            BOOL success = [context save:&error];
            
            [parentManagedObjectContext performBlock:^{
                if ([parentManagedObjectContext hasChanges]) {
                    [parentManagedObjectContext save:nil];
                }
                if (completionBlock) {
                    completionBlock(success, error);
                }
            }];
        } else {
            if (completionBlock) {
                completionBlock(YES, nil);
            }
        }
    }];
}

- (void)performBlockAndWait:(void (^)(NSManagedObjectContext *context))block {
    
    NSManagedObjectContext *parentManagedObjectContext = [[self class] mainManagedObjectContext];
    NSManagedObjectContext *context = [self createManagedObjectContextWithParent:parentManagedObjectContext];
    [context performBlockAndWait:^{
        block(context);
        if ([context.insertedObjects count] > 0) {
            [context obtainPermanentIDsForObjects:[context.insertedObjects allObjects] error:nil];
        }
        if ([context hasChanges]) {
            [context save:nil];
        }
        if ([parentManagedObjectContext hasChanges]) {
            [parentManagedObjectContext performBlockAndWait:^{
                [parentManagedObjectContext save:nil];
            }];
        }
    }];
}

+ (NSURL *)storeURL {
    
    static NSURL *storeURL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storeURL = [[self downloaderDirectoryURL] URLByAppendingPathComponent:@"BltDownloader.sqlite"];
    });
    return storeURL;
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    static NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSURL *storeURL = [self storeURL];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *managedObjectModelURL = [bundle URLForResource:@"BltDownloader" withExtension:@"momd"];
    NSManagedObjectModel *MOM = [[NSManagedObjectModel alloc] initWithContentsOfURL:managedObjectModelURL];
    
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:MOM];
    NSDictionary *storeOptions = @{
                                   NSMigratePersistentStoresAutomaticallyOption: @YES,
                                   NSInferMappingModelAutomaticallyOption: @YES
                                   };
    NSError *addStoreError;
    NSPersistentStore *store = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                                        configuration:nil
                                                                                  URL:storeURL
                                                                              options:storeOptions
                                                                                error:&addStoreError];
    if (!store) {
        NSLog(@"Add Store Error - %@", addStoreError);
        abort();
    }
    
    return persistentStoreCoordinator;
}

+ (NSURL *)applicationSupportURL {
    static NSURL *applicationSupportURL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        applicationSupportURL = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory
                                                                       inDomain:NSUserDomainMask
                                                              appropriateForURL:nil
                                                                         create:YES
                                                                          error:nil];
        
    });
    return applicationSupportURL;
}

+ (NSURL *)downloaderDirectoryURL {
    static NSURL *downloaderDirectoryURL;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        downloaderDirectoryURL = [[self applicationSupportURL] URLByAppendingPathComponent:@"BltDownloader"];
        NSFileManager *fm = [NSFileManager defaultManager];
        BOOL isDir = YES;
        if (![fm fileExistsAtPath:[downloaderDirectoryURL path] isDirectory:&isDir] && isDir) {
            
            [fm createDirectoryAtURL:downloaderDirectoryURL
         withIntermediateDirectories:YES
                          attributes:nil
                               error:nil];
        }
        [downloaderDirectoryURL setResourceValue:@YES
                                          forKey:NSURLIsExcludedFromBackupKey
                                           error:nil];
    });
    return downloaderDirectoryURL;
}

#pragma mark - 数据库相关操作
- (void)getDownloadItemByDict:(NSMutableDictionary *)dict item:(BltDownloadItem *)item {
    if(dict[@"averageSpeed"])   item.averageSpeed = dict[@"averageSpeed"];
    if(dict[@"category"])   item.category = dict[@"category"];
    if(dict[@"categoryCreatedTime"])   item.categoryCreatedTime = dict[@"categoryCreatedTime"];
    if(dict[@"categoryId"])   item.categoryId = dict[@"categoryId"];
    if(dict[@"createdTime"])    item.createdTime = dict[@"createdTime"];
    if(dict[@"downloadedSize"])    item.downloadedSize = dict[@"downloadedSize"];
    if(dict[@"downloadURL"])    item.downloadURL = dict[@"downloadURL"];
    if(dict[@"finishTime"])    item.finishTime = dict[@"finishTime"];
    if(dict[@"identifier"])    item.identifier = dict[@"identifier"];
    if(dict[@"isNewDownload"])    item.isNewDownload = dict[@"isNewDownload"];
    if(dict[@"name"])   item.name = dict[@"name"];
    if(dict[@"progress"])   item.progress = dict[@"progress"];
    if(dict[@"resumeData"])    item.resumeData = dict[@"resumeData"];
    if(dict[@"searchPathDirectory"])    item.searchPathDirectory = dict[@"searchPathDirectory"];
    if(dict[@"sessionIdentifier"])    item.sessionIdentifier = dict[@"sessionIdentifier"];
    if(dict[@"sortIndex"])    item.sortIndex = dict[@"sortIndex"];
    if(dict[@"startTime"])    item.startTime = dict[@"startTime"];
    if(dict[@"state"])    item.state = dict[@"state"];
    if(dict[@"targetPath"])    item.targetPath = dict[@"targetPath"];
    if(dict[@"taskDescription"])    item.taskDescription = dict[@"taskDescription"];
    if(dict[@"taskIdentifier"])   item.taskIdentifier = dict[@"taskIdentifier"];
    if(dict[@"totalSize"])   item.totalSize = dict[@"totalSize"];
    if(dict[@"updatedTime"])    item.updatedTime = dict[@"updatedTime"];
    if(dict[@"userId"])    item.userId = dict[@"userId"];
}

/**
 @brief 插入数据：使用字典插入单个App
 */
-(void) insertCoreDataByDict:(NSMutableDictionary*)dict{
    [self performBlockAndWait:^(NSManagedObjectContext *context) {
        //防止同名文件，添加互斥锁
        @synchronized(context)
        {
            //        NSManagedObjectContext *context = [self managedObjectContext];
            BltDownloadItem *downloadItem = [BltDownloaderDatabaseManager findFirstByAttribute:@"name" withValue:dict[@"name"] inContext:context];
            if(downloadItem){
                // 如果已经有同名文件
                NSLogD(@"插入失败： 已经有文件%@",dict[@"name"]);
                return;
            }
            BltDownloadItem *item = [NSEntityDescription insertNewObjectForEntityForName:TableName_Downloader inManagedObjectContext:context];
            [self getDownloadItemByDict:dict item:item];
            NSError *error;
            if(![context save:&error]){
                NSLogD(@"插入失败： %@",[error localizedDescription]);
            }
            NSLogD(@"插入成功： %@",dict[@"name"]);
            [[self class] saveContext];
        }
    }];
}


- (NSArray *)fetchAllDownloadItemsForStatus:(BLTURLDownloadStatus)status andUserId:(NSString*)userId{
    
    NSManagedObjectContext *context = [[self class] mainManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:TableName_Downloader];
    fetchRequest.sortDescriptors = @[
                                     [NSSortDescriptor sortDescriptorWithKey:@"createdTime" ascending:YES]
                                     ];
    //            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"state = %d AND ((userID = 0 AND (isMultipleExistedWithAnonymous = NO OR isMultipleExistedWithAnonymous = nil)) OR userID = %d)", status, self.userID];
    if(status<0){
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"userId = %@",userId];
    }else{
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"userId = %@ AND state = %d",userId,status];
    }
    NSArray *results = [context executeFetchRequest:fetchRequest error:nil];
    return results;
}
- (void)fetchAllDownloadItemsForStatus:(BLTURLDownloadStatus)status  andUserId:(NSString*)userId
                    withBlock:(void (^)(NSArray *fetchedItems))completionBlock{
    
    NSManagedObjectContext *context = [[self class] mainManagedObjectContext];
    [context performBlock:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:TableName_Downloader];
        fetchRequest.sortDescriptors = @[
                                         [NSSortDescriptor sortDescriptorWithKey:@"createdTime" ascending:YES]
                                         ];
        if(status<0){
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"userId = %@",userId];
        }else{
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"userId = %@ AND state = %d",userId,status];
        }
        //        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"state = %d AND ((userID = 0 AND (isMultipleExistedWithAnonymous = NO OR isMultipleExistedWithAnonymous = nil)) OR userID = %d)", status, self.userID];
        NSArray *results = [context executeFetchRequest:fetchRequest error:nil];
        completionBlock(results);
    }];
}

+ (BltDownloadItem*)findFirstByAttribute:(NSString *)attribute
                               withValue:(id)value
                               inContext:(NSManagedObjectContext *)context {
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:TableName_Downloader];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", attribute, value];
    request.predicate = predicate;
    request.fetchLimit = 1;
    NSArray *results = [context executeFetchRequest:request error:nil];
    return [results lastObject];
}

- (void)updateDownloadItemWithDownloadObject:(NSMutableDictionary*)dict{
   // NSLog(@"updateDownloadItemWithDownloadObject    %@",dict);
    [self performBlockAndWait:^(NSManagedObjectContext *context) {
        BltDownloadItem *downloadItem;
        if (!dict[@"id"]) {
            downloadItem = [BltDownloaderDatabaseManager findFirstByAttribute:@"name" withValue:dict[@"name"] inContext:context];
            [dict setObject:downloadItem.objectID forKey:@"id"];
        } else {
            downloadItem = (BltDownloadItem *) [context existingObjectWithID:dict[@"id"] error:nil];
        }
        if(!downloadItem){
            downloadItem = [BltDownloaderDatabaseManager findFirstByAttribute:@"name" withValue:dict[@"name"] inContext:context];
            [dict setObject:downloadItem.objectID forKey:@"id"];
        }
        [self getDownloadItemByDict:dict item:downloadItem];
        
        [[self class] saveContext];
      //  NSLog(@"---------------------------------save-----------------------------------%@",downloadItem);
    }];
}
- (void)deleteDownloadItemWithIdentifier:(NSMutableDictionary*)dict {
    BltDownloadItem *downloadItem = [BltDownloaderDatabaseManager findFirstByAttribute:@"name" withValue:dict[@"name"] inContext:[[self class] mainManagedObjectContext]];
    NSLog(@"delete downloadItem     %@",downloadItem.name);
    [self deleteDownloadItem:downloadItem];
}

- (void)deleteDownloadItem:(BltDownloadItem *)downloadItem {
    if (downloadItem.objectID) {
        [self performBlock:^(NSManagedObjectContext *context) {
            BltDownloadItem *localDownloadItem = (BltDownloadItem *)[context existingObjectWithID:downloadItem.objectID error:nil];
            if(!localDownloadItem){
                localDownloadItem = [BltDownloaderDatabaseManager findFirstByAttribute:@"name" withValue:downloadItem.name inContext:context];
            }
            if (localDownloadItem) {
                [context deleteObject:localDownloadItem];
            }
        }     onCompletion:^(BOOL success, NSError *error) {
            [[self class] saveContext];
        }];
    }
}
@end
