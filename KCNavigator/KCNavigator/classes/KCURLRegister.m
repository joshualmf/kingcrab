//  KCURLRegister.m
//  RouterComponent
//
//  Created by zhaocy on 2018/1/31.
//

#import "KCURLRegister.h"
#import "KCURLRouter.h"

NSString * const KCModuleClassNameKey = @"class-name";

NSString * const KCModuleInvokeCustomBlockKey = @"invoke-custom-block";

NSString * const KCModuleCallbackKey = @"callback";      //添加支持注册block模式

NSString * const KCModuleTransparent = @"transparent";

NSString * const KCModuleInContinuousProcess = @"can-be-back";

NSString * const KCModuleDependency = @"module-dependency";

NSString * const KCModuleCanDirectlyBack = @"can-directly-back";

NSString * const KCModuleGroupNameKey = @"in-which-group";

NSString * const KCModuleSingleModuleKey = @"only-exist-once";

NSString * const KCModuleNeedAnimation = @"need-animation-push";

@implementation KCURLRegister

+ (instancetype)sharedURLRegister {
    static id URLRegister = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, (^{
        URLRegister = [[KCURLRegister alloc] init];
    }));
    return URLRegister;
}

- (void)registerModule:(NSDictionary*)module completeHander:(void(^)(BOOL successfulFlag , NSDictionary *outputInfo))completeHander {
    NSMutableDictionary *regModuleInfo = [NSMutableDictionary dictionaryWithDictionary:module];
    // 设置默认值
    if ([regModuleInfo[KCModuleInvokeCustomBlockKey] length] == 0) {
        // 如果没有设置，默认是YES
        regModuleInfo[KCModuleInvokeCustomBlockKey] = @"YES";
    }
    
    [[KCURLRouter sharedRouter] registerModule:regModuleInfo withCompleteHander:completeHander];
}

- (NSMutableDictionary*)parseString:(NSString *)string {
    NSMutableDictionary *mutDict = nil;
    mutDict = [[KCURLRouter sharedRouter] parseString:string];
    return mutDict;
}

- (NSMutableDictionary*)parseURL:(NSURL *)standardURL {
    NSMutableDictionary *mutDict = nil;
    mutDict = [[KCURLRouter sharedRouter] parseURL:standardURL];
    return mutDict;
}

- (NSDictionary *)findModuleInfo:(NSString *)moduleName {
    NSDictionary *dict = nil;
    dict = [[KCURLRouter sharedRouter] findModuleInfo:moduleName];
    return dict;
}

@end
