
#import <Foundation/Foundation.h>
/** 各种动画效果
 @"cube" @"moveIn" @"reveal" @"fade"(default) @"pageCurl" @"pageUnCurl" @"suckEffect" @"rippleEffect" @"oglFlip" @"twist"
 
 NSString * const kCATransitionFade
 NSString * const kCATransitionMoveIn
 NSString * const kCATransitionPush
 NSString * const kCATransitionReveal
 **/

/** Common transition subtypes.
 
 NSString * const kCATransitionFromRight
 NSString * const kCATransitionFromLeft
 NSString * const kCATransitionFromTop
 NSString * const kCATransitionFromBottom
 **/
@interface KCPageAnimator : NSObject

+ (instancetype)shareAnimator;

- (void)transitionFromTimingTransitionType:(NSString *)type SubType:(NSString *)subType;
@end
