//
//  NSURLRequest+ForSSL.m
//  TSG-Phone
//
//  Created by lsq on 16/7/27.
//  Copyright © 2016年 tsg. All rights reserved.
//

#import "NSURLRequest+ForSSL.h"

@implementation NSURLRequest (ForSSL)
+(BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host
{
    return YES;
}

+(void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host
{
    
}
@end
