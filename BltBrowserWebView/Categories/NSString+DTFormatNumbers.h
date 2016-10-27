//
//  NSString+DTFormatNumbers.h
//  TSG-Phone
//
//  Created by lsq on 16/8/9.
//  Copyright © 2016年 tsg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DTFormatNumbers)

/**-------------------------------------------------------------------------------------
 @name Formatting File Sizes
 ---------------------------------------------------------------------------------------
 */


/** Formats the passed number as a byte value in a form that is pleasing to the user when displayed next to a progress bar.
 
 Output numbers are rounded to one decimal place. Bytes are not abbreviated because most users might not be used to B for that. Higher units are kB, MB, GB and TB.
 
 @param bytes The value of the bytes to be formatted
 @return Returns the formatted string.
 
 */
+ (NSString *)stringByFormattingBytes:(long long)bytes;
+ (NSString *)stringByFormattingBytesLength:(NSNumber*)bytesLength;

/**
 @brief 判断是否为整形：
 */
- (BOOL)isPureInt;

/**
 @brief 判断是否为long：
 */
- (BOOL)isPureLongLong;

/**
 @brief 判断是否为浮点形：
 */
- (BOOL)isPureFloat;
@end
