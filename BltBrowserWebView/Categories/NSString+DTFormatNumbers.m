//
//  NSString+DTFormatNumbers.m
//  TSG-Phone
//
//  Created by lsq on 16/8/9.
//  Copyright © 2016年 tsg. All rights reserved.
//

#import "NSString+DTFormatNumbers.h"

@implementation NSString (DTFormatNumbers)

+ (NSString *)stringByFormattingBytes:(long long)bytes
{
    NSArray *units = @[@"%1.0f Bytes", @"%1.1f KB", @"%1.1f MB", @"%1.1f GB", @"%1.1f TB"];
    
    long long value = bytes * 10;
    for (NSUInteger i=0; i<[units count]; i++)
    {
        if (i > 0)
        {
            value = value/1024;
        }
        if (value < 10000)
        {
            return [NSString stringWithFormat:units[i], value/10.0];
        }
    }
    
    return [NSString stringWithFormat:units[[units count]-1], value/10.0];
}
+ (NSString *)stringByFormattingBytesLength:(NSNumber*)bytesLength
{
    NSArray *units = @[@"%1.0f Bytes", @"%1.1f KB", @"%1.1f MB", @"%1.1f GB", @"%1.1f TB"];
    
    long long value = bytesLength.longLongValue * 10;
    for (NSUInteger i=0; i<[units count]; i++)
    {
        if (i > 0)
        {
            value = value/1024;
        }
        if (value < 10000)
        {
            return [NSString stringWithFormat:units[i], value/10.0];
        }
    }
    
    return [NSString stringWithFormat:units[[units count]-1], value/10.0];
}

/**
 @brief 判断是否为整形：
 */
- (BOOL)isPureInt{
    NSScanner* scan = [NSScanner scannerWithString:self];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

/**
 @brief 判断是否为long：
 */
- (BOOL)isPureLongLong{
    NSScanner* scan = [NSScanner scannerWithString:self];
    long long val;
    return[scan scanLongLong:&val] && [scan isAtEnd];
}

/**
 @brief 判断是否为浮点形：
*/
- (BOOL)isPureFloat{
    NSScanner* scan = [NSScanner scannerWithString:self];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}
@end
