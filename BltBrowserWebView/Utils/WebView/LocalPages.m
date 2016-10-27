//
//  LocalPages.m
//  BltBrowser
//
//  Created by lsq on 16/9/21.
//  Copyright © 2016年 blt. All rights reserved.
//

#import "LocalPages.h"
#import "WebKit/WebKit.h"

@implementation LocalPages

+(void)showErrorPage:(NSError*)error webView:(WKWebView*)webView{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //    [dict setObject:error.domain forKey:@"error_title"];
    [dict setObject:@"错误" forKey:@"error_title"];
    [dict setObject:error.localizedDescription forKey:@"short_description"];
    [dict setObject:[NSString stringWithFormat:@"code: %ld",(long)error.code] forKey:@"actions"];
    [self showPageByInfo:dict webView:webView];
}

+(void)showPageByTitle:(NSString*)title reason:(NSString*)reason webView:(WKWebView*)webView{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //    [dict setObject:error.domain forKey:@"error_title"];
    [dict setObject:title forKey:@"error_title"];
    [dict setObject:reason forKey:@"short_description"];
    //    [dict setObject:[NSString stringWithFormat:@"code: %ld",(long)error.code] forKey:@"actions"];
    [self showPageByInfo:dict webView:webView];
}

+(void)showDownloadingPage:(NSURLResponse*)response webView:(WKWebView*)webView{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"文件正在下载" forKey:@"error_title"];
    [dict setObject:response.URL.absoluteString forKey:@"short_description"];
    [self showPageByInfo:dict webView:webView];
}

+(void)showPageByInfo:(NSMutableDictionary*)dict webView:(WKWebView*)webView{
    NSString *templatePath = [[NSBundle mainBundle] pathForResource:@"error" ofType:@"html"];
    NSMutableString *html = [[NSMutableString alloc] initWithContentsOfFile:templatePath encoding:NSUTF8StringEncoding error:nil];
    [html replaceOccurrencesOfString:@"%error_title%" withString:dict[@"error_title"]?dict[@"error_title"]:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, html.length)];
    [html replaceOccurrencesOfString:@"%short_description%" withString:dict[@"short_description"]?dict[@"short_description"]:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, html.length)];
    [html replaceOccurrencesOfString:@"%actions%" withString:dict[@"actions"]?dict[@"actions"]:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, html.length)];
    if(webView)
        [webView loadHTMLString:html baseURL:nil];
}

@end
