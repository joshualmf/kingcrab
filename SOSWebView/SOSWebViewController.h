//
//  SOSWebViewController.h
//  Onstar
//
//  Created by Joshua on 16/3/2.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    WEB_CONTENT_URL     =   1,
    WEB_CONTENT_HTML    =   2,
} WEB_CONTENT_TYPE;

@interface SOSWebViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIWebView *webView;

- (id)initWithURL:(NSString *)url;
- (void)loadContent;
@end
