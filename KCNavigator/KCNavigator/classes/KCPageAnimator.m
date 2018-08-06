
#import "KCPageAnimator.h"
#import "KCURLNavigator.h"

@implementation KCPageAnimator

+ (instancetype)shareAnimator {
    static KCPageAnimator *animator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (animator == nil) {
            animator = [[KCPageAnimator alloc] init];
        }
    });
    return animator;
}

- (void)transitionFromTimingTransitionType:(NSString *)type SubType:(NSString *)subType {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;/* 间隔时间*/
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];/* 动画的开始与结束的快慢*/
    transition.type = type;/* 各种动画效果*/
    transition.subtype = subType;/* 动画方向*/
    transition.delegate = self;
    //将定制好的动画添加到当前控制器的layer层
    [[[KCURLNavigator globalNavigator] rootNavigationController].view.layer addAnimation:transition forKey:nil];
    
}

@end
