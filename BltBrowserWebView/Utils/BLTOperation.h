//
//  BLTOperation.h
//  BltBrowser
//
//  Created by lsq on 16/9/22.
//  Copyright © 2016年 blt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BLTOperation : NSOperation

/**
 @brief     在线程中要做的事
 */
+(void)addOperationWithBlockInQuene:(void (^)(void))block;
/**
 @brief     在主线程中要做的事
 */
+(void)addMainOperationWithBlockInQuene:(void (^)(void))block;
@end
