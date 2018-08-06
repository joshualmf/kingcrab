//  KCURLNavigator.m
//  RouterComponent
//
//  Created by Joshua on 2017/12/25.
//

#import "KCURLNavigator.h"
#import "KCURLUtility.h"
#import "KCPageAnimator.h"
#import "KCURLRouter.h"
#import "KCURLRegister.h"

const NSString *KCNavURLInfo = @"URLInfo";
const NSString *KCNavURLObj = @"Object";

@interface KCURLNavigator ()
{
    NSMutableArray *nextActionQueue;
}
@end

@implementation KCURLNavigator

+ (instancetype)globalNavigator {
    static KCURLNavigator *globalNavigator;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, (^{
        globalNavigator = [[KCURLNavigator alloc] init];
    }));
    return globalNavigator;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        nextActionQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (UINavigationController *)buildNavigatorWithRoot:(UIViewController *)rootVC {
    _rootNavigationController = [[KCNavigationController alloc] initWithRootViewController:rootVC];
    [_rootNavigationController setNavigationBarHidden:YES];
    _rootNavigationController.delegate = self;
    return _rootNavigationController;
}

- (BOOL)navigateToURL:(NSURL *)url object:(id)object callback:(KCNavigationCallback)callback {
    NSDictionary *urlInfo = [[KCURLRegister sharedURLRegister] parseURL:url];
    NSString *host = urlInfo[KCURLHost];
    if ([host length] == 0) {
        return NO;
    }
    
    NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
    paramDict[KCNavURLObj] = object;
    paramDict[KCNavURLInfo] = urlInfo;
    
    NSDictionary *moduleInfo = [[KCURLRegister sharedURLRegister] findModuleInfo:host];
    if ([moduleInfo count] == 0) {
        [self redirectToUnregisteredURL:urlInfo callback:callback];
    }
    else {
        KCNavigationCallback realBlock = ^(BOOL success, id result, id obj){
            KCURLCustomBlock customBlock = moduleInfo[KCModuleCallbackKey];
            if ([moduleInfo[KCModuleInvokeCustomBlockKey] isEqualToString:@"YES"] &&
                customBlock) {
                customBlock(success, result, obj);
            }
            else {
                [self showModule:moduleInfo parameters:paramDict callback:callback];
            }
        };
        
        KCURLDependBlock dependBlock = moduleInfo[KCModuleDependency];
        if (dependBlock) {
            dependBlock(realBlock);
        }
        else {
            if (realBlock) {
                realBlock(YES, [self topViewController], paramDict);
            }
        }
    }
    return YES;
}

- (void)redirectToUnregisteredURL:(NSDictionary *)urlInfo callback:(KCNavigationCallback)callback {
    // TODO
}

- (void)showModule:(NSDictionary *)moduleInfo
        parameters:(NSMutableDictionary *)paramDict
          callback:(KCNavigationCallback)callback {
    NSString *moduleClassName = [moduleInfo objectForKey:KCModuleClassNameKey];
    Class theClass = NSClassFromString(moduleClassName);
    if (theClass) {
        NSDictionary *queryDict = nil;
        UIViewController *viewController = [[theClass alloc] init];
        NSString *queryString = paramDict[KCNavURLInfo][KCURLQueryString];
        queryDict = [KCURLUtility queryStringToDict:queryString];
        [paramDict addEntriesFromDictionary:queryDict];
        [self show:viewController info:moduleInfo withArguments:paramDict callback:callback];
    }
}

- (void)show:(UIViewController *)viewController
        info:(NSDictionary *)moduleInfo
withArguments:(NSDictionary *)args
    callback:(KCNavigationCallback)callback {
    // 考虑以后present扩展
    [self pushViewController:viewController info:moduleInfo withArgs:args callback:callback];
}

- (void)pushViewController:(UIViewController *)viewController
                      info:(NSDictionary *)moduleInfo
                  withArgs:(NSDictionary *)args
                  callback:(KCNavigationCallback)callback {
    KCNavigationController* moduleNav = [[KCNavigationController alloc] initWithRootViewController: viewController];
    if ([viewController respondsToSelector:@selector(setNavigatorContext:callback:)]) {
        [viewController performSelector:@selector(setNavigatorContext:callback:) withObject:args withObject:callback];
    }
    
    [self prepareForNavigation:moduleNav info:moduleInfo withArgs:args];
    
    UITabBarController* tmpTab = [[UITabBarController alloc] init];
    [tmpTab setViewControllers:@[moduleNav]];
    [[tmpTab tabBar] setHidden:YES];
    
    //暂时transitionAnimated和animated保持一致
    NSString* needAnimation = [moduleInfo objectForKey:KCModuleNeedAnimation];
    BOOL transitionAnimated =  [needAnimation isEqualToString:@"YES"] ? YES : NO;
    BOOL animated = [moduleNav needAnimation];
    if (transitionAnimated) {
        [[KCPageAnimator shareAnimator] transitionFromTimingTransitionType:kCATransitionMoveIn
                                                                 SubType:kCATransitionFromBottom];
        [[self rootNavigationController] pushViewController:tmpTab animated:NO];
    }
    else {
        [[self rootNavigationController] pushViewController:tmpTab animated:animated];
    }
    
}

- (void)vanish:(BOOL)animated {
    [self popModuleViewControllerAnimated:animated];
}

- (void)popModuleViewControllerAnimated:(BOOL)animated {
    if ([[self rootNavigationController].viewControllers count] > 1) {
        NSInteger topIndex = [self topPopToPageIndex];
        [self doPopToPageIndex:topIndex withArgs:nil animated:animated];
    }
}

- (void)popToMainPage:(BOOL)animated {
    NSInteger mainPageIndex = 0;
    [self doPopToPageIndex:mainPageIndex withArgs:nil animated:animated];
}

- (BOOL)popToPage:(NSString *)pageName args:(NSDictionary *)args animated:(BOOL)animated {
    BOOL founded = NO;
    // 1. 倒序查找栈中是否存在page，找到index。
    NSInteger pageIndex = -1;
    NSInteger pageCount = [[[self rootNavigationController] viewControllers] count];
    for (NSInteger i = pageCount - 1; i > 0; i --) {
        UITabBarController *curTab = [[self rootNavigationController] viewControllers][i];
        if ([curTab isKindOfClass:[UITabBarController class]] &&
            [[curTab selectedViewController] isKindOfClass:[KCNavigationController class]]) {
            KCNavigationController *curNav = (KCNavigationController *)[curTab selectedViewController];
            if ([[[curNav moduleName] lowercaseString] isEqualToString:[pageName lowercaseString]]) {
                pageIndex = i;
                founded = YES;
                break;
            }
        }
    }
    
    // 2. popToIndex
    if (founded) {
        [self doPopToPageIndex:pageIndex withArgs:args animated:animated];
    }
    
    return founded;
}

- (NSString *)findTopGroup {
    NSString *topGroupName = nil;
    NSInteger pageCount = [[[self rootNavigationController] viewControllers] count];
    for (NSInteger i = pageCount - 1; i > 0; i --) {
        UITabBarController *curTab = [[self rootNavigationController] viewControllers][i];
        if ([curTab isKindOfClass:[UITabBarController class]] &&
            [[curTab selectedViewController] isKindOfClass:[KCNavigationController class]]) {
            KCNavigationController *curNav = (KCNavigationController *)[curTab selectedViewController];
            if ([curNav groupName]) {
                topGroupName = [curNav groupName];
                break;
            }
        }
    }
    return topGroupName;
}

- (void)popGroup:(id)args animated:(BOOL)animated {
    NSString *groupName = [self findTopGroup];
    if (groupName) {
        [self popGroup:groupName withArgs:args animated:animated];
    }
}

- (void)popGroup:(NSString *)groupName withArgs:(id)args animated:(BOOL)animated {
    // 从栈底开始查找groupName，找到index
    NSArray *vcArrays = [[self rootNavigationController] viewControllers];
    NSInteger firstGroupIndex = [vcArrays count] - 1;
    for (NSInteger i = 0; i < vcArrays.count; i++) {
        UITabBarController *curTab = vcArrays[i];
        if ([curTab isKindOfClass:[UITabBarController class]] &&
            [[curTab selectedViewController] isKindOfClass:[KCNavigationController class]] &&
            [[(KCNavigationController *)[curTab selectedViewController] groupName] isEqualToString:groupName]) {
            firstGroupIndex = i;
            break;
        }
    }
    
    NSInteger popToIndex = firstGroupIndex > 0 ? (firstGroupIndex - 1) : 0;
    
    // 检查group前是否有连续流程
    for (NSInteger i = popToIndex; i > 0; i --) {
        UITabBarController *curTab = vcArrays[i];
        if ([curTab isKindOfClass:[UITabBarController class]]) {
            KCNavigationController *curNav = [curTab selectedViewController];
            if ([curNav isKindOfClass:[KCNavigationController class]]) {
                if ([curNav isInContinuousProcess]) {
                    continue;
                }
                else {
                    popToIndex = i;
                    break;
                }
            }
        }
        break;
    }
    [self doPopToPageIndex:popToIndex withArgs:args animated:animated];
}

- (void)prepareForNavigation:(KCNavigationController *)moduleNav
                        info:(NSDictionary *)moduleInfo
                    withArgs:(NSDictionary *)args {
    BOOL isInContinuousProcess = NO;
    BOOL canDirectlyBack = NO;
    NSString *groupName;
    BOOL needAnimated = YES;
    BOOL transParent = [(NSNumber *)[moduleInfo objectForKey:KCModuleTransparent] boolValue];
    if (transParent) {
        moduleNav.modalPresentationStyle = UIModalPresentationOverFullScreen; // 去掉白色的背景
    }
    
    if ([moduleInfo objectForKey:KCModuleInContinuousProcess]) {
        isInContinuousProcess = [(NSNumber *)[moduleInfo objectForKey:KCModuleInContinuousProcess] boolValue];
    }
    if ([moduleInfo objectForKey:KCModuleCanDirectlyBack]) {
        canDirectlyBack = [(NSNumber *)[moduleInfo objectForKey:KCModuleCanDirectlyBack] boolValue];
    }
    if ([moduleInfo objectForKey:KCModuleGroupNameKey]) {
        groupName = [moduleInfo objectForKey:KCModuleGroupNameKey];
    }
    
    if ([moduleInfo objectForKey:KCModuleNeedAnimation]) {
        needAnimated = [(NSNumber *)[moduleInfo objectForKey:KCModuleNeedAnimation] boolValue];
    }
    
    [moduleNav setModuleName:[moduleInfo objectForKey:KCModuleName]];
    
    [moduleNav setIsInContinuousProcess:isInContinuousProcess];
    [moduleNav setCanDirectlyBack:canDirectlyBack];
    [moduleNav setGroupName:groupName];
    [moduleNav setNeedAnimation:needAnimated];
}

- (KCNavigationController *)rootNavigationController {
    return _rootNavigationController;
}

- (UIViewController *)topViewController {
    UIViewController<KCNavigatorProtocol> *topVC = nil;
    UIViewController *topOne = [[self rootNavigationController] topViewController];
    if ([topOne isKindOfClass:[UITabBarController class]]) {
        UIViewController *topNav = [(UITabBarController *)topOne selectedViewController];
        if ([topNav isKindOfClass:[UINavigationController class]]) {
            topVC = (UIViewController<KCNavigatorProtocol> *)[(KCNavigationController *)topNav topViewController];
        }
    }
    else if ([topOne respondsToSelector:@selector(setNavigatorContext:callback:)]) {
        topVC = (UIViewController<KCNavigatorProtocol> *)topOne;
    }
    else {
    }

    return topVC;
}

- (NSInteger)topPopToPageIndex {
    NSInteger vcCount = [[[self rootNavigationController] viewControllers] count];
    
    NSInteger topIndex = vcCount - 2;
    
    // 从倒数第二个VC开始查找
    for (NSInteger i = (vcCount - 2); i > 0; i --) {
        UITabBarController *curTab = [[self rootNavigationController] viewControllers][i];
        if ([curTab isKindOfClass:[UITabBarController class]]) {
            KCNavigationController *curNav = [curTab selectedViewController];
            if ([curNav isKindOfClass:[KCNavigationController class]]) {
                if ([curNav isInContinuousProcess]) {
                    continue;
                }
                else {
                    topIndex = i;
                    break;
                }
            }
        }
        
        topIndex = i;
        break;
    }
    
    return topIndex;
}

- (void)doPopToPageIndex:(NSInteger)pageIndex withArgs:(NSDictionary *)args animated:(BOOL)animated {
    // 调用moduleWillClose和moduleWillReAppear
    NSInteger pageCount = [[[self rootNavigationController] viewControllers] count];
    for (NSInteger i = pageCount - 1; i >= pageIndex; i --) {
        UITabBarController *curTab = [[self rootNavigationController] viewControllers][i];
        if ([curTab isKindOfClass:[UITabBarController class]] &&
            [[curTab selectedViewController] isKindOfClass:[KCNavigationController class]]) {
            KCNavigationController *curNav = (KCNavigationController *)[curTab selectedViewController];
            if (i == pageIndex) {
                [curNav moduleWillReAppear:args];
            }
            else {
                [curNav moduleWillClose:args];
            }
        }
    }
    
    if (pageIndex >= 0 && pageIndex < pageCount) {
        UIViewController *destVC = [[self rootNavigationController] viewControllers][pageIndex];
        [[self rootNavigationController] popToViewController:destVC animated:animated];
    }
}

- (void)addNextAction:(dispatch_block_t)actionBlock {
    @synchronized(self) {
        if (nextActionQueue && actionBlock) {
            [nextActionQueue addObject:actionBlock];
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    NSLog(@"View will show ...");
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    NSLog(@"ViewController did show ...");
    for (int i = 0; i < nextActionQueue.count; i ++) {
        dispatch_block_t block = [nextActionQueue objectAtIndex:i];
        dispatch_async(dispatch_get_main_queue(), block);
    }
    
    [nextActionQueue removeAllObjects];
}

@end
