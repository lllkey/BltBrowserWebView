//
//  LocalPages.h
//  BltBrowser
//
//  Created by lsq on 16/9/21.
//  Copyright © 2016年 blt. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WKWebView;

@interface LocalPages : NSObject

+(void)showErrorPage:(NSError*)error webView:(WKWebView*)webView;

+(void)showDownloadingPage:(NSURLResponse*)response webView:(WKWebView*)webView;

+(void)showPageByTitle:(NSString*)title reason:(NSString*)reason webView:(WKWebView*)webView;
@end
