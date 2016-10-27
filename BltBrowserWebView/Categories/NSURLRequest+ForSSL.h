//
//  NSURLRequest+ForSSL.h
//  TSG-Phone
//
//  Created by lsq on 16/7/27.
//  Copyright © 2016年 tsg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (ForSSL)

+(BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;

+(void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;

@end
