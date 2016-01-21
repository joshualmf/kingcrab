//
//  SOSNotificationView.h
//  Onstar
//
//  Created by Joshua on 16/1/21.
//  Copyright © 2016年 Shanghai Onstar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOSNotificationView : UIViewController

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;

+ (SOSNotificationView *)sharedInstance;
- (void)showMessage:(NSString *)notiMessage;
@end
