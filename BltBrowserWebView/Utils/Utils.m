//
//  Utils.m
//  TSG-Phone
//
//  Created by lsq on 16/7/22.
//  Copyright © 2016年 tsg. All rights reserved.
//

#import "Utils.h"
#define DATE_FORMAT         @"yyyy-MM-dd HH:mm:ss"

@implementation Utils

//+ (MBProgressHUD *)createHUD
//{
//    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
//    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithWindow:window];
//    HUD.detailsLabelFont = [UIFont boldSystemFontOfSize:16];
//    [window addSubview:HUD];
//    [HUD show:YES];
//    HUD.removeFromSuperViewOnHide = YES;
//    //[HUD addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:HUD action:@selector(hide:)]];
//    
//    return HUD;
//}

+ (void)popToViewController:(UINavigationController*)nav cls:(Class)cls animated:(BOOL)isAnimated{
    for (UIViewController *temp in nav.viewControllers) {
        if ([temp isKindOfClass:cls]) {
            [nav popToViewController:temp animated:isAnimated];
        }
    }
}
/**
 @brief     获取当前时间的String格式
 */
+(NSString *)getCurrentTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:DATE_FORMAT];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    return dateTime;
}
/**
 @brief     获取时间间隔
 */
+(NSTimeInterval)getIntervalByTime:(NSString*)startTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:DATE_FORMAT];
    NSDate *date1 = [formatter dateFromString:startTime];
    NSDate *date2 = [NSDate date];
    NSTimeInterval aTimer = [date2 timeIntervalSinceDate:date1];
    
    //    int hour = (int)(aTimer/3600);
    //    int minute = (int)(aTimer - hour*3600)/60;
    //    int second = aTimer - hour*3600 - minute*60;
    //    NSString *dural = [NSString stringWithFormat:@"%d时%d分%d秒", hour, minute,second];
    return aTimer;
}


@end
