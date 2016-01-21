//
//  SOSNotificationView.m
//  Onstar
//
//  Created by Joshua on 16/1/21.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import "SOSNotificationView.h"

@interface SOSNotificationView ()
{
    CGFloat _appearTimeInterval;            // 通知栏从开始到完全出现的时间
    CGFloat _disappearTimeInterval;         // 通知栏从开始消失到完全消失的时间
    CGFloat _stayTimeInterVal;              // 通知栏停留的时间
}
@end

@implementation SOSNotificationView

+ (SOSNotificationView *)sharedInstance
{
    static SOSNotificationView *sharedOBJ = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedOBJ = [[self alloc] initWithNibName:@"SOSNotificationView" bundle:nil];
    });
    return sharedOBJ;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    _appearTimeInterval = 2.0f;
    _disappearTimeInterval = 1.0f;
    _stayTimeInterVal = 3.0f;
    
    return self;
}

- (void)setAppear:(CGFloat)appearTime disappearTime:(CGFloat)disappearTime stayTime:(CGFloat)stayTime
{
    _appearTimeInterval = appearTime;
    _disappearTimeInterval = disappearTime;
    _stayTimeInterVal = stayTime;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showMessage:(NSString *)notiMessage
{
    if (!self.view.superview) {
        UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
        [mainWindow addSubview:self.view];
    }

    self.messageLabel.text = notiMessage;
    [self displayAndAutoShade];
}

- (void)displayAndAutoShade
{

    CGRect frame = self.view.frame;
    // 初始化view的位置
    self.view.alpha = 1.0f;
    self.view.frame = CGRectMake(0, -frame.size.height, frame.size.width, frame.size.height);
    
    [UIView animateWithDuration:_appearTimeInterval animations:^{
        self.view.frame=CGRectMake(0, 0, frame.size.width, frame.size.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:_disappearTimeInterval delay:_stayTimeInterVal options:0 animations:^{
            self.view.alpha = 0.0f;
        } completion:^(BOOL finished) {
        }];
    }];
}

@end
