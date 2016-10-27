//
//  BLTWebViewViewController.m
//  TSG-Phone
//
//  Created by lsq on 16/9/21.
//  Copyright © 2016年 tsg. All rights reserved.
//

#import "BLTWebViewViewController.h"
#import "WebKit/WebKit.h"
#import "BLTDownloaderManager.h"
#import "LocalPages.h"
#import "RegExCategories.h"


static NSString* BLTWebViewLoading = @"loading";
static NSString* BLTWebViewEstimatedProgress = @"estimatedProgress";
static NSString* BLTWebViewURL = @"URL";
static NSString* BLTWebViewCanGoBack = @"canGoBack";
static NSString* BLTWebViewCanGoForward = @"canGoForward";
static NSString* BLTWebViewContentSize = @"contentSize";
static NSString* BLTWebViewTitle = @"title";

static NSMutableDictionary *credentialDict;

static WKProcessPool *processPool;

@interface BLTWebViewViewController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>

@property (nonatomic,retain) WKWebView *webView;
@property (nonatomic,retain) UIView *tipView;
@property (nonatomic,retain) UILabel *tipViewLabel;


@property (nonatomic, strong)  NSMutableString *cookieStr;
@property (nonatomic, strong)  NSMutableString *cookieStr1;
@property (nonatomic, strong)  NSMutableString *cookieJSStr;
@property (nonatomic, strong)  NSURL *url;
@property (nonatomic,strong)  NSMutableURLRequest *urlRequest;
@property (nonatomic) NSDictionary* curAllHeaderFields;

@property (nonatomic,strong) UIBarButtonItem *backButton;
@property (nonatomic,strong) UIBarButtonItem *forwardButton;
@property (nonatomic,strong) UIBarButtonItem *reloadStopButton;
@property (nonatomic,strong) UIBarButtonItem *actionButton;
@property (nonatomic,strong) UIBarButtonItem *doneButton;
@property (nonatomic,strong) UIBarButtonItem *downloadButton;

@property (nonatomic,strong) UIImage *reloadIcon;
@property (nonatomic,strong) UIImage *stopIcon;

@property (nonatomic,strong) UIProgressView *progressView;


@end

@implementation BLTWebViewViewController
-(instancetype)initWithUrlStr:(NSString*)urlStr{
    self = [super init];
    if(self){
        self.url = [NSURL URLWithString:urlStr];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addSubLayout];
    
    [_webView setUserInteractionEnabled:YES];//是否支持交互
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    [_webView addObserver:self forKeyPath:BLTWebViewEstimatedProgress options:NSKeyValueObservingOptionNew context:nil];
    [_webView addObserver:self forKeyPath:BLTWebViewLoading options:NSKeyValueObservingOptionNew context:nil];
    [_webView addObserver:self forKeyPath:BLTWebViewCanGoBack options:NSKeyValueObservingOptionNew context:nil];
    [_webView addObserver:self forKeyPath:BLTWebViewCanGoForward options:NSKeyValueObservingOptionNew context:nil];
    [_webView addObserver:self forKeyPath:BLTWebViewURL options:NSKeyValueObservingOptionNew context:nil];
    [_webView addObserver:self forKeyPath:BLTWebViewTitle options:NSKeyValueObservingOptionNew context:nil];
    
    [_webView.scrollView addObserver:self forKeyPath:BLTWebViewContentSize options:NSKeyValueObservingOptionNew context:nil];
    
    self.title = @"首页";
    
    [self.delegate didWebViewInit];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
    
    NSLog(@"cookieStr   %@",self.cookieStr);
    NSLog(@"[self.url absoluteString]%@",[self.url absoluteString]);
    
    self.cookieStr1=[NSMutableString stringWithString:[BLTWebViewViewController readCurrentCookie:self.url.absoluteString]];
    NSLog(@"cookieStr1  %@",self.cookieStr1);
    if(self.cookieStr && ![self.cookieStr isEqualToString:@""])
        [request addValue:self.cookieStr forHTTPHeaderField:@"Cookie"];
    
    //    WKUserScript *wk = [[WKUserScript alloc] initWithSource:self.cookieJSStr injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    //    [self.webView.configuration.userContentController addUserScript:wk];
    
    //    [[BLTDownloaderManager sharedDownloaderManager]newDownLoadWithURL:self.url andCookie:self.cookieStr progress:nil completion:nil failed:nil];
    //    [self showTipViewByText:@"开始下载" afterDelay:1];
    //[request setTimeoutInterval:20];
    
    self.urlRequest = request;
    
    [_webView loadRequest: self.urlRequest];
    
    if(![self.url absoluteString]){
        [LocalPages showPageByTitle:@"失败" reason:@"网址不识别" webView:_webView];
    }
//    NSLog(@"processPool%@",processPool);
//    NSLog(@"processPool2%@",self.webView.configuration.processPool);
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    NSLog(@"readCurrentCookie       %@",[BLTWebViewViewController readCurrentCookie:self.url.absoluteString]);
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"readCurrentCookie       %@",[BLTWebViewViewController readCurrentCookie:self.url.absoluteString]);
    self.navigationController.toolbarHidden=NO;
}
-(void)dealloc{
    NSLog(@"dealloc");
    [_webView removeObserver:self forKeyPath:BLTWebViewEstimatedProgress];
    [_webView removeObserver:self forKeyPath:BLTWebViewLoading];
    [_webView removeObserver:self forKeyPath:BLTWebViewCanGoBack];
    [_webView removeObserver:self forKeyPath:BLTWebViewCanGoForward];
    [_webView removeObserver:self forKeyPath:BLTWebViewURL];
    [_webView removeObserver:self forKeyPath:BLTWebViewTitle];
    [_webView.scrollView removeObserver:self forKeyPath:BLTWebViewContentSize];
}
-(void)setCookie:(NSArray*)cookies baseUrl:(NSString*)baseUrl{
    NSMutableString *cookieString = [[NSMutableString alloc] init];
    NSMutableString *cookieJSString = [[NSMutableString alloc] init];
    NSString* domainString = [BLTWebViewViewController getDomainStrByUrlStr:baseUrl];
    for (NSHTTPCookie*cookie in cookies) {
        NSLog(@"cookie:%@", cookie);
        // 如果不是同一个domin，就不设置cookie
        if(![cookie.domain isEqualToString:domainString])
            continue;
        //多个字段之间用“；”隔开
        [cookieString appendFormat:@"%@=%@;",cookie.name,cookie.value];
        [cookieJSString appendFormat:@"document.cookie ='%@=%@';",cookie.name,cookie.value];
    }
    if(cookieString.length>0){
        //删除最后一个“；”
        [cookieString deleteCharactersInRange:NSMakeRange(cookieString.length - 1, 1)];
        [cookieJSString deleteCharactersInRange:NSMakeRange(cookieString.length - 1, 1)];
    }
    self.cookieStr =  cookieString;
    self.cookieJSStr =  cookieJSString;
}
+(NSString *)readCurrentCookie:(NSString*)baseUrl{
    if(!baseUrl) return @"";
    NSHTTPCookieStorage*cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSMutableString *cookieString = [[NSMutableString alloc] init];
    NSString* domainString = [self getDomainStrByUrlStr:baseUrl];
    NSLog(@"readCurrentCookie   domainString:%@", domainString);
    
    //    NSHTTPCookie *currentCookie= [[NSHTTPCookie alloc] init];
    for (NSHTTPCookie*cookie in [cookieJar cookies]) {
        if ([cookie.domain isEqualToString:domainString]) {
            NSLog(@"readCurrentCookie   cookie:%@", cookie);
            //            currentCookie = cookie;
            //多个字段之间用“；”隔开
            [cookieString appendFormat:@"%@=%@;",cookie.name,cookie.value];
        }
        
    }
    //删除最后一个“；”
    if(cookieString.length>0)
        [cookieString deleteCharactersInRange:NSMakeRange(cookieString.length - 1, 1)];
    return cookieString;
}
-(void)addSubLayout{
    if(!processPool)
        processPool = [[WKProcessPool alloc] init];
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.processPool = processPool;
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    //    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.contentMode = UIViewContentModeRedraw;
    self.webView.opaque = YES;
    [self.view addSubview:self.webView];
    [self refreshProgressView:0];
    
    self.toolbarItems = nil;
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.rightBarButtonItems = nil;
    self.navigationItem.leftItemsSupplementBackButton = NO;
    
    //    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(pressedDone)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(pressedDone)];
    
    NSMutableArray *items = [NSMutableArray array];
    [self setUpNavigationButtons];
    if (self.backButton)        { [items addObject:self.backButton]; }
    if (self.forwardButton)     { [items addObject:self.forwardButton]; }
    if (self.reloadStopButton)  { [items addObject:self.reloadStopButton]; }
    
    if (self.actionButton)      { [items addObject:self.actionButton]; }
    if(self.downloadButton)     { [items addObject:self.downloadButton];}
    
    UIBarButtonItem *(^flexibleSpace)() = ^{
        return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    };
    
    BOOL lessThanFiveItems = items.count < 5;
    
    NSInteger index = 1;
    NSInteger itemsCount = items.count-1;
    for (NSInteger i = 0; i < itemsCount; i++) {
        [items insertObject:flexibleSpace() atIndex:index];
        index += 2;
    }
    
    if (lessThanFiveItems) {
        [items insertObject:flexibleSpace() atIndex:0];
        [items addObject:flexibleSpace()];
    }
    self.toolbarItems = items;
    self.navigationController.toolbarHidden=NO;
    [self refreshButtonsState];
}

- (void)setUpNavigationButtons
{
    //set up the back button
    if (self.backButton == nil) {
        
        UIImage *backButtonImage = [UIImage imageNamed:@"btn_browser_back"];
        self.backButton = [[UIBarButtonItem alloc] initWithImage:backButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(backButtonTapped:)];
    }
    
    //set up the forward button
    if (self.forwardButton == nil) {
        UIImage *forwardButtonImage = [UIImage imageNamed:@"btn_browser_next"];
        self.forwardButton  = [[UIBarButtonItem alloc] initWithImage:forwardButtonImage style:UIBarButtonItemStylePlain target:self action:@selector(forwardButtonTapped:)];
    }
    
    //set up the reload button
    if (self.reloadStopButton == nil) {
        self.reloadIcon = [UIImage imageNamed:@"btn_browser_fresh"];
        self.stopIcon   = [UIImage imageNamed:@"btn_browser_fresh"];
        
        self.reloadStopButton = [[UIBarButtonItem alloc] initWithImage:self.reloadIcon style:UIBarButtonItemStylePlain target:self action:@selector(reloadStopButtonTapped:)];
    }
    
    if( self.downloadButton == nil){
        self.downloadButton  = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"btn_browser_download"] style:UIBarButtonItemStylePlain target:self action:@selector(downloadButtonTapped:)];
        
    }
}
-(void)showTipViewByText:(NSString*)text afterDelay:(float)delay{
    if(!self.tipView){
        self.tipView = [[UIView alloc]initWithFrame:self.view.bounds];
        [self.view addSubview:self.tipView];
        self.tipViewLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 125, 30)];
        [self.tipView addSubview:self.tipViewLabel];
        self.tipViewLabel.center = self.tipView.center;
        self.tipViewLabel.textAlignment = NSTextAlignmentCenter;
        self.tipViewLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5f];
        self.tipViewLabel.textColor = [UIColor whiteColor];
    }
    self.tipView.alpha = 1.f;
    self.tipViewLabel.text = text;
    [UIView animateWithDuration:delay animations:^{
        self.tipView.alpha = 0.f;
    }];
}
-(void)pressedDone{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    //    WKWebView *webView = object;
    if(!keyPath) return;
    NSString* path = keyPath;
    if([path isEqualToString:BLTWebViewEstimatedProgress]){
        float progress = [change[NSKeyValueChangeNewKey] floatValue];
        //        NSLog(@"progress  %f",progress);
        [self refreshProgressView:progress];
    }else if([path isEqualToString:BLTWebViewLoading]){
        //        NSLog(@"BLTWebViewLoading  %@",change);
        BOOL isLoading = [change[NSKeyValueChangeNewKey] boolValue];
        [self refreshReloadButtonState:isLoading];
    }else if([path isEqualToString:BLTWebViewURL]){
        
    }else if([path isEqualToString:BLTWebViewCanGoBack]){
        //        NSLog(@"BLTWebViewCanGoBack  %@",change);
        [self refreshButtonsState];
    }else if([path isEqualToString:BLTWebViewCanGoForward]){
        [self refreshButtonsState];
    }else if([path isEqualToString:BLTWebViewTitle]){
        [self showPlaceholderTitle];
    }else{
        
    }
}

#pragma mark - WKScriptMessageHandler
-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSLog(@"方法名:%@", message.name);
    NSLog(@"参数:%@", message.body);
    // 方法名
    NSString *methods = [NSString stringWithFormat:@"%@:", message.name];
    SEL selector = NSSelectorFromString(methods);
    // 调用方法
    if ([self respondsToSelector:selector]) {
        //        [self performSelector:selector withObject:message.body];
    } else {
        NSLog(@"未实行方法：%@", methods);
    }
}

#pragma mark    -   webview delegate
-(void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    NSLog(@"runJavaScriptAlertPanelWithMessage %@",message);
    completionHandler();
}
-(void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    NSLog(@"runJavaScriptConfirmPanelWithMessage %@",message);
    completionHandler(YES);
}
-(void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    NSLog(@"runJavaScriptTextInputPanelWithPrompt %@",prompt);
    completionHandler(prompt);
    
}
-(BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo{
    NSLog(@"shouldPreviewElement %@",webView.URL);
    return NO;
}
//-(UIViewController *)webView:(WKWebView *)webView previewingViewControllerForElement:(WKPreviewElementInfo *)elementInfo defaultActions:(NSArray<id<WKPreviewActionItem>> *)previewActions{
//    NSLog(@"previewingViewControllerForElement %@",webView.URL);
//    return self;
//}
-(void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController{
    NSLog(@"commitPreviewingViewController %@",webView.URL);
}
-(void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"didReceiveServerRedirectForProvisionalNavigation %@",webView.URL);
    
}
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    NSLog(@"didCommitNavigation %@",navigation);
    
}
-(void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"didFailNavigation %@",navigation);
    
}

-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    NSLog(@"createWebViewWithConfiguration  request     %@",navigationAction.request);
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSLog(@"decidePolicyForNavigationAction     request     %@",navigationAction.request);
    NSMutableURLRequest *request  = (NSMutableURLRequest*)navigationAction.request;
    NSLog(@"allHTTPHeaderFields     %@",request.allHTTPHeaderFields) ;
    NSLog(@"mainDocumentURL     %@",request.mainDocumentURL) ;
    self.curAllHeaderFields = [NSDictionary dictionaryWithDictionary:request.allHTTPHeaderFields];
    
//    if (!navigationAction.targetFrame.isMainFrame) {
//        [webView evaluateJavaScript:@"var a = document.getElementsByTagName('a');for(var i=0;i<a.length;i++){a[i].setAttribute('target','');}" completionHandler:nil];
//    }
    
    //    if ([webView.URL.absoluteString hasPrefix:@"https://itunes.apple.com"]) {
    //        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
    //        decisionHandler(WKNavigationActionPolicyCancel);
    //    }else {
    //        decisionHandler(WKNavigationActionPolicyAllow);
    //    }
    
    NSURL *url = navigationAction.request.URL;
    NSString *urlString = (url) ? url.absoluteString : @"";
    if([urlString containsString:@"about:blank"]){
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    // iTunes: App Store link
    if (url && [urlString isMatch:RX(@"\\/\\/itunes\\.apple\\.com\\/")]) {
        [[UIApplication sharedApplication] openURL:url];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    // Protocol/URL-Scheme without http(s)
    else if (url && ![urlString isMatch:[@"^https?:\\/\\/." toRxIgnoreCase:YES]]) {
        [[UIApplication sharedApplication] openURL:url];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"didStartProvisionalNavigation %@",webView.URL.absoluteString);
    if ([webView.URL.absoluteString hasPrefix:@"https://itunes.apple.com"]) {
        [[UIApplication sharedApplication] openURL:webView.URL];
    }else {
    }
    [self refreshReloadButtonState:YES];
    [self refreshButtonsState];
}
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"didFinishNavigation");
    // make javascript cookie
    //    [webView evaluateJavaScript:self.cookieStr completionHandler:nil];
    
    [self refreshReloadButtonState:NO];
    [self refreshButtonsState];
}

-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    NSLog(@"didFailProvisionalNavigation");
    if([error.domain isEqualToString:@"WebKitErrorDomain"] && error.code == 102){
        return;
    }
    if([self checkIfWebContentProcessHasCrashed:webView error:error]){
        return;
    }
    if(error.code == kCFURLErrorCancelled){
        return;
    }
    NSLog(@"show LocalPages");
    [LocalPages showErrorPage:error webView:webView];
}
-(BOOL)checkIfWebContentProcessHasCrashed:(WKWebView*)webView error:(NSError*)error{
    if(error.code == WKErrorWebContentProcessTerminated && [error.domain isEqualToString:@"WebKitErrorDomain"])
        return YES;
    return NO;
}
// 在收到响应后，决定是否跳转
-(void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    NSLog(@"decidePolicyForNavigationResponse %@",navigationResponse);
    
    if ([webView.URL.absoluteString hasPrefix:@"https://itunes.apple.com"]) {
        [[UIApplication sharedApplication] openURL:webView.URL];
        decisionHandler(WKNavigationResponsePolicyCancel);
        return;
    }
    
    if(![navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]]){
        decisionHandler(WKNavigationResponsePolicyAllow);
        return;
    }
    
    NSHTTPURLResponse *response = (NSHTTPURLResponse*)navigationResponse.response;
    NSLog(@"response.allHeaderFields    %@",response.allHeaderFields);
    
    //    decisionHandler(WKNavigationResponsePolicyAllow);
    //    NSArray *aaa = [webView.configuration.userContentController userScripts];
    //    for (WKUserScript *wk in aaa) {
    //        NSLog(@"wk.source   %@ ",wk.source);
    //    }
    //    NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
    //    NSLog(@"websiteDataTypes   %@ ",websiteDataTypes);
    
    //self.webView.configuration.websiteDataStore
    
    NSDictionary *dic = [response allHeaderFields];
    NSString *strValue = (NSString*)[dic objectForKey:@"Content-Type"];// (有时需要通过判断 description 字段)
    NSString *desValue = (NSString*)[dic objectForKey:@"Content-Disposition"];
    NSArray *DownloadFileTypeArray = @[@"download",@"octet-stream",@"archive",@"attachment"];
    BOOL isHas = NO;
    for(int i = 0;i<DownloadFileTypeArray.count;i++){
        if([strValue containsString:DownloadFileTypeArray[i]]||[desValue containsString:DownloadFileTypeArray[i]]){
            isHas = YES;
            break;
        }
    }
    //    for(int i = 0;i<DownloadFileTypeArray.count;i++){
    //        if([desValue containsString:DownloadFileTypeArray[i]]){
    //            isHas = YES;
    //            break;
    //        }
    //    }
    if(isHas){
        self.cookieStr1=[NSMutableString stringWithString:[BLTWebViewViewController readCurrentCookie:self.url.absoluteString]];
        
        [[BLTDownloaderManager sharedDownloaderManager]newDownLoadWithURL:response.URL andCookie:self.cookieStr1 andHeaderFields:self.curAllHeaderFields progress:nil completion:nil failed:nil];
        [self showTipViewByText:@"开始下载" afterDelay:1];
        //        [LocalPages showDownloadingPage:response webView:webView];
        [self downloadButtonTapped:nil];
        decisionHandler(WKNavigationResponsePolicyCancel);
    }else
        decisionHandler(WKNavigationResponsePolicyAllow);
}

-(void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    NSString *authenticationMethod = [[challenge protectionSpace] authenticationMethod];
    NSLog(@"authenticationMethod  %@",authenticationMethod);
    
    SecTrustRef trust = challenge.protectionSpace.serverTrust;
    //    NSString *origin = [NSString stringWithFormat:@"%@:%ld",challenge.protectionSpace.host,(long)challenge.protectionSpace.port];
    if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust){
        
        completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:trust]);
        
    }
    //    if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic ||
    //       challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPDigest ||
    //       challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodNTLM){
    //        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    //        return;
    //    }
    
    //    if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodDefault]
    if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic]
        || [authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPDigest]) {
        NSURLCredential *cre = [self getCredentialByUrl:webView.URL];
        if(cre){
            //如果已经存储 则使用已经存储的
            completionHandler(NSURLSessionAuthChallengeUseCredential, cre);
            return;
        }
        UIAlertController *alert;
        NSString *title = NSLocalizedString(@"Authentication required", @"Authentication prompt title");
        if(!challenge.protectionSpace.realm || [challenge.protectionSpace.realm isEqualToString:@""]){
            NSString *msg = NSLocalizedString(@"A username and password are being requested by %@. The site says: %@", @"Authentication prompt message with a realm. First parameter is the hostname. Second is the realm string");
            NSString *formatted = [NSString stringWithFormat:msg,challenge.protectionSpace.host,challenge.protectionSpace.realm];
            alert = [UIAlertController alertControllerWithTitle:title message:formatted preferredStyle:UIAlertControllerStyleAlert];
        }else{
            NSString *msg = NSLocalizedString(@"A username and password are being requested by %@.", @"Authentication prompt message with no realm. Parameter is the hostname of the site");
            NSString *formatted = [NSString stringWithFormat:msg,challenge.protectionSpace.host ];
            alert = [UIAlertController alertControllerWithTitle:title message:formatted preferredStyle:UIAlertControllerStyleAlert];
        }
        NSString *LogInButtonTitle  = NSLocalizedString(@"Log in", @"Authentication prompt log in button");
        NSString *CancelButtonTitle  = NSLocalizedString(@"Cancel", @"Label for Cancel button");
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:LogInButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString *user = alert.textFields[0].text;
            NSString *pwd = alert.textFields[1].text;
            
            //            NSURLCredential *credential = [[NSURLCredential alloc] initWithUser:user password:pwd persistence:NSURLCredentialPersistenceForSession];
            NSURLCredential *credential = [[NSURLCredential alloc] initWithUser:user password:pwd persistence:NSURLCredentialPersistenceNone];
            [self saveCredentialByUrl:webView.URL andCredential:credential];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        }];
        [alert addAction:action];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:CancelButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
            completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:trust]);
        }];
        [alert addAction:cancel];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = NSLocalizedString(@"Username", @"Username textbox in Authentication prompt");
            // textField.text= @"liusq";
        }];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = NSLocalizedString(@"Password", @"Password textbox in Authentication prompt");
            textField.secureTextEntry = YES;
            //  textField.text= @"123%abc";
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:alert animated:YES completion:^{    }];
        });
        
    }
    else if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        // needs this handling on iOS 9
        //        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
        // or, see also http://qiita.com/niwatako/items/9ae602cb173625b4530a#%E3%82%B5%E3%83%B3%E3%83%97%E3%83%AB%E3%82%B3%E3%83%BC%E3%83%89
        completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:trust]);
    }
    else {
        //        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        completionHandler(NSURLSessionAuthChallengeUseCredential, nil);
    }
}


#pragma mark -
#pragma mark Button Callbacks
- (void)backButtonTapped:(id)sender
{
    [self.webView goBack];
    [self refreshButtonsState];
}

- (void)forwardButtonTapped:(id)sender
{
    [self.webView goForward];
    [self refreshButtonsState];
}

- (void)reloadStopButtonTapped:(id)sender
{
    //regardless of reloading, or stopping, halt the webview
    [self.webView stopLoading];
    NSLog(@"self.webView.URL.absoluteString.  %@",self.webView.URL.absoluteString);
    if (self.webView.URL.absoluteString.length == 0 && self.url)
    {
        [self.webView loadRequest:self.urlRequest];
    }
    else if (self.url && [self.webView.URL.absoluteString isEqualToString:@"about:blank"])
    {
        [self.webView loadHTMLString:@"" baseURL:nil];
        [self.webView loadRequest:self.urlRequest];
    }
    else {
        [self.webView reload];
    }
    
    //refresh the buttons
    [self refreshButtonsState];
}

#pragma mark -
#pragma mark download Item Event Handlers
- (void)downloadButtonTapped:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DownloadListViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark -
#pragma mark UI State Handling
- (void)refreshButtonsState
{
    //update the state for the back button
    if (self.webView.canGoBack)
        [self.backButton setEnabled:YES];
    else
        [self.backButton setEnabled:NO];
    
    //Forward button
    if (self.webView.canGoForward)
        [self.forwardButton setEnabled:YES];
    else
        [self.forwardButton setEnabled:NO];
}
-(void)refreshReloadButtonState:(BOOL)isLoading{
    if(isLoading){
        [self.reloadStopButton setImage:self.stopIcon];
    }else{
        [self.reloadStopButton setImage:self.reloadIcon];
    }
    [self showPlaceholderTitle];
}
-(void)refreshProgressView:(float)progress{
    if(!self.progressView){
        self.progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        [self.view addSubview:self.progressView];
        float height = [[UIApplication sharedApplication] statusBarFrame].size.height+self.navigationController.navigationBar.frame.size.height;
        self.progressView.frame =CGRectMake(0, height, self.view.bounds.size.width, 10);
    }
    [self.progressView setProgress:progress];
    if(progress>=1){
        [self.progressView setHidden:YES];
    }else{
        [self.progressView setHidden:NO];
    }
}

- (void)showPlaceholderTitle
{
    if(self.webView.title && ![self.webView.title isEqualToString:@""]){
        self.title = self.webView.title;
        return;
    }
    NSString *url = [_url absoluteString];
    url = [url stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    url = [url stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    self.title = url;
}

-(NSURLCredential *)getCredentialByUrl:(NSURL*)url{
    if(!credentialDict){
        credentialDict = [NSMutableDictionary dictionary];
        return nil;
    }
    NSEnumerator *keys = [credentialDict keyEnumerator];
    for (NSString *key in keys) {
        if([url.absoluteString containsString:key]){
            return credentialDict[key];
        }
    }
    return nil;
}
-(void)saveCredentialByUrl:(NSURL*)url andCredential:(NSURLCredential*)credential{
    if(!credentialDict){
        credentialDict = [NSMutableDictionary dictionary];
    }
    [credentialDict setObject:credential forKey:[BLTWebViewViewController getDomainStrByUrlStr:url.absoluteString]];
}
+(NSString*)getDomainStrByUrlStr:(NSString*)baseUrl{
    NSMutableString *domain = [[NSMutableString alloc] initWithString:baseUrl];
    NSArray *domainArr = [domain componentsSeparatedByString:@":"];
    NSMutableString *domainString = [NSMutableString stringWithString:domainArr[1]];
    [domainString deleteCharactersInRange:NSMakeRange(0, 2)];
    NSArray *domainArr1 = [domainString componentsSeparatedByString:@"?"];
    domainString = [NSMutableString stringWithString:domainArr1[0]];
    NSLog(@"domainString  %@",domainString);
    return domainString;
}
@end
