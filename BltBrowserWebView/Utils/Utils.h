//
//  Utils.h
//  TSG-Phone
//
//  Created by lsq on 16/7/22.
//  Copyright © 2016年 tsg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIColor+Util.h"
#import "UIView+Util.h"
#import "NSString+STRegex.h"
#import "NSString+DTFormatNumbers.h"
#import "NSURLRequest+ForSSL.h"
#import "Config.h"
#import "TSGConstant.h"
#import "Masonry.h"
#import "ZYKeyboardUtil.h"
#import "RegExCategories.h"

#import "BLTOperation.h"

#define IS_IPHONE_6 ([[UIScreen mainScreen] bounds].size.height == 667.0f)
#define IS_IPHONE_6_PLUS ([[UIScreen mainScreen] bounds].size.height == 736.0f)

#ifdef _NOLOG
#define LOGD(...)
#else
#define LOGD(...) {printf(__VA_ARGS__);}
#endif

#ifdef _NOLOG
#define NSLogD(...)
#else
#define NSLogD(...){NSLog(__VA_ARGS__);}
#endif

@interface Utils : NSObject
//+ (MBProgressHUD *)createHUD;
+ (void)popToViewController:(UINavigationController*)nav cls:(Class)cls animated:(BOOL)isAnimated;

/**
 @brief     获取当前时间的String格式
 */
+(NSString *)getCurrentTime;

/**
 @brief     获取时间间隔
 */
+(NSTimeInterval)getIntervalByTime:(NSString*)startTime;
@end
