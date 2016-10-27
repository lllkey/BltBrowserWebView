//
//  BLTOperation.m
//  BltBrowser
//
//  Created by lsq on 16/9/22.
//  Copyright © 2016年 blt. All rights reserved.
//

#import "BLTOperation.h"

static NSOperationQueue *tsgOperationQueue;

@implementation BLTOperation
+(void)addOperationWithBlockInQuene:(void(^)(void))block{
    //    [[TSGOperation getMainOperationQueue] addOperationWithBlock:block];
    [[BLTOperation getTsgOperationQueue] addOperationWithBlock:block];
    //    [[TSGOperation getTsgOperationQueue] waitUntilAllOperationsAreFinished];
}
+(void)addMainOperationWithBlockInQuene:(void (^)(void))block{
    [[BLTOperation getMainOperationQueue] addOperationWithBlock:block];
}

+(NSOperationQueue*) getMainOperationQueue{
    return [NSOperationQueue mainQueue];
}

+(NSOperationQueue*) getTsgOperationQueue{
    if(!tsgOperationQueue){
        tsgOperationQueue  = [[NSOperationQueue alloc]init];
        tsgOperationQueue.maxConcurrentOperationCount=5;//设置最大并发线程数
    }
    return tsgOperationQueue;
}

@end
