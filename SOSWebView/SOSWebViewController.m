//
//  SOSWebViewController.m
//  Onstar
//
//  Created by Joshua on 16/3/2.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "SOSWebViewController.h"

@interface SOSWebViewController ()
{
    NSString *_url;
    NSString *_htmlStr;
    WEB_CONTENT_TYPE _contetnType;
}
@end

@implementation SOSWebViewController

- (id)initWithURL:(NSString *)url
{
    self = [super init];
    _url = url;
    _contetnType = WEB_CONTENT_URL;
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
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    [self loadContent];
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
        default:
            break;
    }
}

- (void)loadURL:(NSString *)strURL
{
    NSURL *url = [NSURL URLWithString:strURL];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
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
    [self.webView reload];
}

- (IBAction)webViewRefresh:(id)sender
{
    if ([self.webView canGoForward]) {
        [self.webView goForward];
    }
}

- (IBAction)systemGoBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
