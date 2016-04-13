
//  LoadingView.m
//  Onstar
//
//  Created by Joshua on 7/2/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import "LoadingView.h"

@interface LoadingView ()
{
    BOOL _showNavBar;
}
@end

static LoadingView *instance = nil;
@implementation LoadingView

+ (LoadingView *)sharedInstance
{
//    if (instance == nil) {
//        instance = [[LoadingView alloc] initWithNibName:@"LoadingView" bundle:nil];
//    }
    //    return instance;
    static LoadingView *sharedOBJ = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedOBJ = [[self alloc] initWithNibName:@"LoadingView" bundle:nil];
    });
    return sharedOBJ;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _offset = 0.0f;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray *imageLoadingArray = @[[UIImage imageNamed:@"loading_1.png"],
                                   [UIImage imageNamed:@"loading_2.png"],
                                   [UIImage imageNamed:@"loading_3.png"],
                                   [UIImage imageNamed:@"loading_4.png"],
                                   [UIImage imageNamed:@"loading_5.png"],
                                   [UIImage imageNamed:@"loading_6.png"],
                                   [UIImage imageNamed:@"loading_7.png"],
                                   [UIImage imageNamed:@"loading_8.png"],
                                   [UIImage imageNamed:@"loading_9.png"],
                                   [UIImage imageNamed:@"loading_10.png"],
                                   [UIImage imageNamed:@"loading_11.png"],
                                   [UIImage imageNamed:@"loading_12.png"],
                                   [UIImage imageNamed:@"loading_13.png"],
                                   [UIImage imageNamed:@"loading_14.png"],
                                   [UIImage imageNamed:@"loading_15.png"],
                                   [UIImage imageNamed:@"loading_16.png"],
                                   [UIImage imageNamed:@"loading_17.png"],
                                   [UIImage imageNamed:@"loading_18.png"],
                                   [UIImage imageNamed:@"loading_19.png"],
                                   [UIImage imageNamed:@"loading_20.png"],
                                   [UIImage imageNamed:@"loading_21.png"],
                                   [UIImage imageNamed:@"loading_22.png"],
                                   [UIImage imageNamed:@"loading_23.png"],
                                   [UIImage imageNamed:@"loading_24.png"],
                                   [UIImage imageNamed:@"loading_25.png"],
                                   [UIImage imageNamed:@"loading_26.png"]];
    indicatorImage.animationImages = imageLoadingArray;
    indicatorImage.animationDuration = 1.5;
    
    labelLoading.text = NSLocalizedString(@"page_loading", nil);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
//    [self stop];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [navigationImage setHidden:!_showNavBar];
    [self.backBtn setHidden:!_showNavBar];
    /*
    if (!_showNavBar) {
        NSLayoutConstraint *constraintBottom = [NSLayoutConstraint constraintWithItem:navigationImage
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:navigationImage
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:0.0f
                                                                             constant:0];
        [navigationImage addConstraint:constraintBottom];
    } else {
        NSLayoutConstraint *constraintBottom = [NSLayoutConstraint constraintWithItem:navigationImage
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:navigationImage
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:44.0f
                                                                             constant:0];
        [navigationImage addConstraint:constraintBottom];

    }
     */
}
- (void)startIn:(UIView *)view
{
    [self startIn:view withNavigationBar:YES];
}

- (void)startIn:(UIView *)view withNavigationBar:(BOOL)showNavBar
{
    _showNavBar = showNavBar;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!indicatorImage.isAnimating) {
            [self updateFrameWithOffset:_offset];
            [view addSubview:self.view];
            [self.view setCenterX:view.centerX];
            [self.view setCenterY:view.centerY];
            [self.view setBounds:view.bounds];
            [view bringSubviewToFront:self.view];
            [indicatorImage startAnimating];
            [self.view setNeedsDisplay];
        }
    });
}


- (IBAction)backButtonTapped:(id)sender {
    [self stop];
    if (self.loadingDelegate && [self.loadingDelegate respondsToSelector:@selector(backAct)]) {
        [self.loadingDelegate backAct];
    }
}

- (void)updateFrameWithOffset:(CGFloat)delta
{
    CGRect frame = [self.view frame];
    frame.origin.y = delta;
    self.view.frame = frame;
    //indicatorImage.center = self.view.center;
}

- (void)stop
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _offset = 0;
        [indicatorImage stopAnimating];
        _labelTitle.text = @"";
        [self.view removeFromSuperview];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
