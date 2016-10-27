//
//  BLTWebViewViewController.h
//  TSG-Phone
//
//  Created by lsq on 16/9/21.
//  Copyright © 2016年 tsg. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WebViewInitDelegate

- (void)didWebViewInit;

@end
@interface BLTWebViewViewController : UIViewController

-(instancetype)initWithUrlStr:(NSString*)urlStr;
-(void)setCookie:(NSArray*)cookies;

@property (nonatomic, assign) id <WebViewInitDelegate> delegate;
@end
