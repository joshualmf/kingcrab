//  KCURLRouter.h
//  KCNavigator
//
//  Created by MAC008 on 2017/12/12.
//  Copyright © 2017年 Mac001. All rights reserved.
//

#ifndef __KCURLRouter_h__
#define __KCURLRouter_h__

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString * KCURLRouterModuleName = @"moduleName";

//协议解析相关 遵循rfc 1808标准
static NSString * KCURLHost = @"host";

static NSString * KCURLUser = @"user";

static NSString * KCURLPassword = @"password";

static NSString * KCURLPath = @"path";

static NSString * KCURLQueryString = @"query";

static NSString * KCURLFragment = @"fragment";

static NSString * KCURLParameterString = @"parameterString";

static NSString * KCURLRelativePath = @"relativePath";

static NSString * KCURLResourceSpecifier = @"resourceSpecifier";


@interface KCURLRouter : NSObject <UINavigationControllerDelegate>

+ (instancetype)sharedRouter;

/**
 Description 注册模块，只关注name - className的最小注册

 @param module 模块信息
 @param completeHander 注册结果
 */
- (void)registerModule:(NSDictionary *)module withCompleteHander:(void(^)(BOOL successfulFlag , NSDictionary* outputInfo))completeHander;

/**
 Description 遵循rfc 1808标准的路由协议解析，这个方法是遵循KCLIFE的URLencoding方法
             如果不需要遵循KCLIFE的URLencoding方法，请调用下面方法

 @param String 路由协议
 @return 解析出来的参数
 */
- (NSMutableDictionary *)parseString:(NSString *)String;

/**
 Description 遵循rfc 1808标准的路由协议解析

 @param  standardURL 路由协议
 @return 解析参数
 */
- (NSMutableDictionary *)parseURL:(NSURL *)standardURL;

/**
 Description 通过注册信息查找到对应的模块信息

 @param   moduleName 模块名
 @return  moduleInfo 模块信息
 */
- (NSDictionary *)findModuleInfo:(NSString *)moduleName;

@end

extern NSString * const KCModuleName;

#endif
