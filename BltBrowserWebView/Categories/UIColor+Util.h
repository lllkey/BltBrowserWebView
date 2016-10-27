//
//  UIColor+Util.h
//  TSG-Phone
//
//  Created by lsq on 16/7/22.
//  Copyright © 2016年 tsg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Util)

+ (UIColor *)colorWithHex:(int)hexValue alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHex:(int)hexValue;

+ (UIColor *)themeColor;
+ (UIColor *)lineColor;
+ (UIColor *)viewBackgroundColor;
+ (UIColor *)nameColor;
+ (UIColor *)tabBarColor;
+ (UIColor *)titleBarColor;
+ (UIColor *)selectCellSColor;
+ (UIColor *)sideMenuTextSColor;
+ (UIColor *)screenLockColor;

@end
