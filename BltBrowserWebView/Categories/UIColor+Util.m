//
//  UIColor+Util.m
//  TSG-Phone
//
//  Created by lsq on 16/7/22.
//  Copyright © 2016年 tsg. All rights reserved.
//

#import "UIColor+Util.h"

@implementation UIColor (Util)


#pragma mark - Hex

+ (UIColor *)colorWithHex:(int)hexValue alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0
                           alpha:alpha];
}

+ (UIColor *)colorWithHex:(int)hexValue
{
    return [UIColor colorWithHex:hexValue alpha:1.0];
}


#pragma mark - theme colors

+ (UIColor *)themeColor
{
    return [UIColor colorWithHex:0x2490EB];
}

#pragma mark - grey line colors

+ (UIColor *)lineColor
{
    return [UIColor colorWithHex:0xF2F2F2];
}

#pragma mark - view background colors

+ (UIColor *)viewBackgroundColor
{
    return [UIColor colorWithHex:0xF3F2F9];
}

#pragma mark - text colors

+ (UIColor *)nameColor
{
    return [UIColor colorWithHex:0x333333];
}

+ (UIColor *)titleBarColor{
    return [UIColor colorWithHex:0x5393E2];
}


+ (UIColor *)tabBarColor{
    return [UIColor colorWithHex:0x5393E2];
}

+ (UIColor *)selectCellSColor
{
    return [UIColor colorWithHex:0x2D363F];
}

+ (UIColor *)sideMenuTextSColor
{
    return [UIColor colorWithHex:0xCDD8E4];
}

+ (UIColor *)screenLockColor{
    return [UIColor colorWithHex:0x2A7DE8];
}
@end
