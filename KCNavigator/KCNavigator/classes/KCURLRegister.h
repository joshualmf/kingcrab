#ifndef __KCURLRegister_h__
#define __KCURLRegister_h__

#import <Foundation/Foundation.h>

extern NSString * const KCModuleName;

extern NSString * const KCModuleClassNameKey;

extern NSString * const KCModuleInvokeCustomBlockKey; // 该值为YES并且存在自定义的block，则需要调用，默认为YES

extern NSString * const KCModuleCallbackKey;     //添加支持注册block模式

extern NSString * const KCModuleDependency;

extern NSString * const KCModuleTransparent;

extern NSString * const KCModuleInContinuousProcess;

extern NSString * const KCModuleCanDirectlyBack;

extern NSString * const KCModuleGroupNameKey;

extern NSString * const KCModuleSingleModuleKey;

extern NSString * const KCModuleNeedAnimation;

typedef void(^KCURLNavigationCallback)(BOOL success, id result, id obj);

typedef void(^KCURLDependBlock)(KCURLNavigationCallback callback);

typedef void(^KCURLCustomBlock)(BOOL success, id result, id obj);

@interface KCURLRegister : NSObject

+ (instancetype)sharedURLRegister;

/**
 @brief 注册模块
 
 @param module 模块信息
 @param completeHander 注册结果
 */
- (void)registerModule:(NSDictionary *)module completeHander:(void(^)(BOOL successfulFlag , NSDictionary *outputInfo))completeHander;

/**
 @brief 遵循rfc 1808标准的路由协议解析，这个方法是遵循URLencoding方法
 如果不需要遵循URLencoding方法，请调用下面方法
 
 @param string 路由协议
 @return 解析出来的参数
 */
- (NSMutableDictionary*)parseString:(NSString *)string;

/**
 @brief 遵循rfc 1808标准的路由协议解析
 
 @param  standardURL 路由协议
 @return 解析参数
 */
- (NSMutableDictionary*)parseURL:(NSURL *)standardURL;

/**
 @brief 通过注册信息查找到对应的模块信息
 
 @param   moduleName 模块名
 @return  moduleInfo 模块信息
 */
- (NSDictionary *)findModuleInfo:(NSString *)moduleName;

@end
#endif
