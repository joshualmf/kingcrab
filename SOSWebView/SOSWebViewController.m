//
//  SOSWebViewController.m
//  Onstar
//
//  Created by Joshua on 16/3/2.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "SOSWebViewController.h"
#import "LoginManage.h"
#import "CustomerInfo.h"
#import "TFHpple.h"

@interface SOSWebViewController ()
{
    NSString *_url;
    NSString *_htmlStr;
    WEB_CONTENT_TYPE _contetnType;
    
    SFSafariViewController *_sfVC;
    
    BOOL _hiddenTopBottomBar;
    
    BOOL _hiddenRightButton;
    
    BOOL gotoFirstPage;
    BOOL isFirstPage;
}
@end

@implementation SOSWebViewController

- (id)initWithURL:(NSString *)url
{
    self = [super init];
    _url = url;
    _contetnType = WEB_CONTENT_URL;
    _category = WEB_DEFAULT;
//    if (OS_SYSTEM_VERSION >= 9.0) {
//        _sfVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url]];
//        _contetnType = WEB_CONTENT_SAFARI;
//        _sfVC.delegate = self;
//    }

    return self;
}

- (id)initWithHTMLString:(NSString *)htmlStr
{
    self = [super init];
    _htmlStr = htmlStr;
    _contetnType = WEB_CONTENT_HTML;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [_buttonRight.layer setMasksToBounds:YES];
    [_buttonRight.layer setCornerRadius:5.0f];
    [_buttonRight.layer setBorderWidth:1.0];
    [_buttonRight.layer setBorderColor:(__bridge CGColorRef _Nullable)([UIColor blueColor])];
    
    [_buttonRight setTitle:NSLocalizedString(@"SB024-05_Feedback", nil) forState:UIControlStateNormal];
    [_buttonRight setTitle:NSLocalizedString(@"SB024-05_Feedback", nil) forState:UIControlStateSelected];
    [_buttonRight setTitleColor:[UIColor whiteColor]  forState:UIControlStateNormal];
    [_buttonRight setTitleColor:[UIColor whiteColor]  forState:UIControlStateSelected];
    [_buttonRight setBackgroundImage:[UIImage imageNamed:@"button_blue_long"] forState:UIControlStateNormal];
    
    if (_hiddenRightButton) {
        [self.buttonRight setHidden:YES];
    }
    
    self.webView.delegate = self;
    [self loadContent];
    
    [[LoadingView sharedInstance] startIn:self.view];
    [[LoadingView sharedInstance] setLoadingDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];


    self.webView.backgroundColor = [Util colorFromHex:@"122237"];
    self.view.backgroundColor = [Util colorFromHex:@"122237"];

    if (_hiddenTopBottomBar) {
        [self.bottomView setHidden:YES];
        
        NSLayoutConstraint *constraintBottom = [NSLayoutConstraint constraintWithItem:self.bottomView
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.bottomView
                                                                         attribute:NSLayoutAttributeHeight
                                                                        multiplier:0.0f
                                                                          constant:0];
        [self.bottomView addConstraint:constraintBottom];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)buttonRightTapped:(id)sender {
    _hiddenRightButton = YES;
    [self loadURL:NEW_Feedback];
}

- (void)hideTopBottomBar
{
    _hiddenTopBottomBar = YES;
}
- (void)hideRightButton{
    
    _hiddenRightButton = YES;
}


- (void)loadContent
{
    switch (_contetnType) {
        case WEB_CONTENT_URL:
            if ([_url length] > 0) {
                [self loadURL:_url];
            }
            break;
            
        case WEB_CONTENT_HTML:
            if ([_htmlStr length] > 0) {
                [self loadHTML:_htmlStr];
            }
            break;
            
        case WEB_CONTENT_SAFARI:
            
            break;
        default:
            break;
    }
}

- (IBAction)bacKButtonTapped:(id)sender {
    if (gotoFirstPage) {
        [self loadURL:_url];
    }
    else if (isFirstPage) {
        [self systemGoBack:nil];
    }
    else if ([self.webView canGoBack]) {
        [self webViewGoBack:nil];
    }else {
        [self systemGoBack:nil];
    }
    
}

- (void)loadURL:(NSString *)strURL
{
    NSURL *url = [NSURL URLWithString:strURL];
//    NSURLRequestCachePolicy cachePolicy = NSURLRequestReloadIgnoringCacheData;
    
    /* Create request variable containing our immutable request
     * This could also be a paramter of your method */
    NSURLRequest *request = [NSURLRequest requestWithURL:url];// cachePolicy:cachePolicy timeoutInterval:1800.0f];
    
    // Create a mutable copy of the immutable request and add more headers
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
    [mutableRequest addValue:[LoginManage sharedInstance].accessToken forHTTPHeaderField:@"Authorization"];
    [mutableRequest addValue:[CustomerInfo sharedInstance].idpid forHTTPHeaderField:@"idpUserId"];
    
    // Now set our request variable with an (immutable) copy of the altered request
    request = [mutableRequest copy];
    
    [self.webView loadRequest:request];
}

- (void)loadHTML:(NSString *)html
{
    [self.webView loadHTMLString:html baseURL:nil];
}

- (IBAction)webViewGoBack:(id)sender
{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
}

- (IBAction)webViewGoForward:(id)sender
{
    if ([self.webView canGoForward]) {
        [self.webView goForward];
    }
}

- (IBAction)webViewRefresh:(id)sender
{
    [self.webView reload];
}

- (IBAction)systemGoBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - webview delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[LoadingView sharedInstance] stop];
    [[LoadingView sharedInstance] setLoadingDelegate:nil];
    // 重写javascript的方法，JS调用 OC
    JSContext *jscontext = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    jscontext[@"close"] = ^{
        [self systemGoBack:nil];
    };
    
    NSURLRequest *request = [webView request];
    NSString *url = [[request URL] absoluteString];
    
    //  每次加载完页面，重新获取title
    // Log the output to make sure our new headers are there
    NSLog(@"%@", request.allHTTPHeaderFields);
    NSString *dataString = [NSString stringWithContentsOfURL:[request URL] encoding:NSUTF8StringEncoding error:nil];  //htmlString是html网页的地址
    NSData *htmlData = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    // Create parser
    TFHpple *xpathParser = [[TFHpple alloc] initWithHTMLData:htmlData];
    
    //Get all the cells of the 2nd row of the 3rd table
    NSArray *elements  = [xpathParser searchWithXPathQuery:@"//title"];
    
    // Access the first cell
    if ([elements count]>0) {
        TFHppleElement *element = [elements objectAtIndex:0];
        
        // Get the text within the cell tag
        NSString *content = [element content];
        _labelTitle.text = content;
    }else{
        _labelTitle.text = @"";
    }
    
    if (self.category == WEB_HELP_FEEDBACK) {
        gotoFirstPage = [url hasSuffix:@"feedbackSuccess"];
        isFirstPage = [url hasSuffix:@"index"];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"==== webView load URL [%@]", request.URL.absoluteString);
    return YES;
}

// Loading View点击回退按钮
- (void)backAct
{
    [[LoadingView sharedInstance] setLoadingDelegate:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)dealloc
{
}
@end
