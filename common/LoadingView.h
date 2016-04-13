//
//  LoadingView.h
//  Onstar
//
//  Created by Joshua on 7/2/14.
//  Copyright (c) 2014 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol LoadingDelegate <NSObject>
@optional
-(void) backAct;

@end

@interface LoadingView : UIViewController
{
    IBOutlet UIImageView *indicatorImage;
    IBOutlet UILabel *labelLoading;
    
    IBOutlet UIImageView *navigationImage;
}

@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@property (nonatomic, assign) CGFloat offset;
@property (strong, nonatomic) IBOutlet UILabel *labelTitle;
@property (nonatomic,weak) id <LoadingDelegate>loadingDelegate;


+ (LoadingView *)sharedInstance;
- (void)startIn:(UIView *)view;
- (void)startIn:(UIView *)view withNavigationBar:(BOOL)showNavBar;
- (IBAction)backButtonTapped:(id)sender;
- (void)stop;
@end
