//
//  BltDownloadItem+CoreDataProperties.h
//  TSG-Phone
//
//  Created by lsq on 16/9/7.
//  Copyright © 2016年 tsg. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "BltDownloadItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface BltDownloadItem (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *averageSpeed;
@property (nullable, nonatomic, retain) NSString *category;
@property (nullable, nonatomic, retain) NSDate *categoryCreatedTime;
@property (nullable, nonatomic, retain) NSString *categoryId;
@property (nullable, nonatomic, retain) NSDate *createdTime;
@property (nullable, nonatomic, retain) NSNumber *downloadedSize;
@property (nullable, nonatomic, retain) NSString *downloadURL;
@property (nullable, nonatomic, retain) NSDate *finishTime;
@property (nullable, nonatomic, retain) NSString *identifier;
@property (nullable, nonatomic, retain) NSNumber *isNewDownload;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *progress;
@property (nullable, nonatomic, retain) NSData *resumeData;
@property (nullable, nonatomic, retain) NSNumber *searchPathDirectory;
@property (nullable, nonatomic, retain) NSString *sessionIdentifier;
@property (nullable, nonatomic, retain) NSNumber *sortIndex;
@property (nullable, nonatomic, retain) NSDate *startTime;
@property (nullable, nonatomic, retain) NSNumber *state;
@property (nullable, nonatomic, retain) NSString *targetPath;
@property (nullable, nonatomic, retain) NSString *taskDescription;
@property (nullable, nonatomic, retain) NSNumber *taskIdentifier;
@property (nullable, nonatomic, retain) NSNumber *totalSize;
@property (nullable, nonatomic, retain) NSDate *updatedTime;
@property (nullable, nonatomic, retain) NSString *userId;

@end

NS_ASSUME_NONNULL_END
