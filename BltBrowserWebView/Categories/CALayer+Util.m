//
//  CALayer+Util.m
//  TSG-Phone
//
//  Created by lsq on 16/7/26.
//  Copyright © 2016年 tsg. All rights reserved.
//

#import "CALayer+Util.h"

@implementation CALayer (Util)
- (void)setBorderColorFromUIColor:(UIColor *)color
{
    self.borderColor = color.CGColor;
}
@end
