//  KCNavigationController.m
//  RouterComponent
//
//  Created by Joshua on 2017/2/17.
//

#import "KCNavigationController.h"

@interface KCNavigationController ()
@end

@implementation KCNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        _isInContinuousProcess = NO;
        _canDirectlyBack = YES;
        _needAnimation = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)moduleName {
    NSString *name = _moduleName;
    if ([name length] == 0) {
        name = NSStringFromClass([[self topViewController] class]);
    }
    return name;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

// 框架的方法
- (void)moduleWillClose:(id)args {
    if (self.closeBlock) {
        self.closeBlock(nil);
    }
    
    [self saveRedirectionURL];
}

- (void)moduleWillReAppear:(id)args {
    UIViewController *topVC = [self topViewController];
    
    if ([topVC respondsToSelector:NSSelectorFromString(@"viewWillReAppearWithObject:")]) {
        [topVC performSelector:NSSelectorFromString(@"viewWillReAppearWithObject:") withObject:args];
    }
}

- (void)saveRedirectionURL {
    // 如果该模块成功，并且有redirection
    if (self.redirection) {
        //暂时注释
        // [[KCURLPageJumpManager manager] pushNextJump:self.redirection];
    }
}

- (void)dealloc {
    //    NSLog(@"!!!!! KC NavigationController [%@] 已经释放 !!!!!", self.moduleName);
}

@end

