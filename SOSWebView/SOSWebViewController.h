//
//  SOSWebViewController.h
//  Onstar
//
//  Created by Joshua on 16/3/2.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SafariServices/SafariServices.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "LoadingView.h"

typedef enum {
    WEB_CONTENT_URL     =   1,
    WEB_CONTENT_HTML    =   2,
    WEB_CONTENT_SAFARI  =   3,
} WEB_CONTENT_TYPE;

typedef enum {
    WEB_DEFAULT         =   0,
    WEB_HELP_FEEDBACK   =   1,
} WEB_VIEW_CATEGORY;

@interface SOSWebViewController : UIViewController <SFSafariViewControllerDelegate, UIWebViewDelegate, LoadingDelegate>

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@property (nonatomic, weak) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (strong, nonatomic) IBOutlet UIButton *buttonRight;
@property (assign, nonatomic) WEB_VIEW_CATEGORY category;
- (id)initWithURL:(NSString *)url;
- (void)loadContent;
- (IBAction)bacKButtonTapped:(id)sender;
- (IBAction)buttonRightTapped:(id)sender;

- (void)hideTopBottomBar;
- (void)hideRightButton;
@end
