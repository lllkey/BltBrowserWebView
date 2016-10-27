//
//  MainViewController.m
//  BltBrowser
//
//  Created by lsq on 16/7/29.
//  Copyright © 2016年 blt. All rights reserved.
//

#import "MainViewController.h"
#import "Utils.h"
#import "BLTWebViewViewController.h"

@interface MainViewController() <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *centerView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, retain) NSMutableArray *webViewArray;

@property (nonatomic, strong) NSNumber *curIndex;
@end
@implementation MainViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.webViewArray = [NSMutableArray new];
    
    UIWebView *webView=[self addWebView];
    
    NSString *strUrl = [NSString stringWithFormat:@"http://weibo.com/"];
    
    
    NSURL *url = [NSURL URLWithString:strUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    //[webView loadRequest:request];

    
    
}

- (UIWebView*)addWebView {
    UIWebView *webView;
    webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    webView.delegate = self;
    webView.scalesPageToFit = YES;
    [_webViewArray addObject:webView];
    [_centerView addSubview:webView];
    [webView mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(_centerView);
        make.right.equalTo(_centerView);
        make.top.equalTo(_centerView);
        make.bottom.equalTo(_centerView);
    }];
    return webView;
}
@end
