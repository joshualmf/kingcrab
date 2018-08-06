//-------------------------------------------------------------------------------------
// KC Confidential
//
// Copyright (C) 2016 China Merchants Bank Co., Ltd. All rights reserved.
//
// No part of this file may be reproduced or transmitted in any form or by any means,
// electronic, mechanical, photocopying, recording, or otherwise, without prior
// written permission of China Merchants Bank Co., Ltd.
//
//-------------------------------------------------------------------------------------

//  KCURLRouter.m
//  RouterComponent
//
//  Created by MAC008 on 2017/12/12.
//  Copyright © 2017年 Mac001. All rights reserved.
//

#import "KCURLRouter.h"
#import "KCURLUtility.h"

static NSString* const KCURLRouterObject = @"Object";
static NSString* const KCURLRouterNextJump = @"nextJump";

@interface KCURLRouter()
@property (nonatomic, strong) NSMutableDictionary *nameMap;
@property (nonatomic, strong) NSMutableDictionary *modules;
@end

@implementation KCURLRouter

+ (instancetype)sharedRouter {
    static id globalURLRouter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, (^{
                       globalURLRouter = [[self alloc] init];
                   }));
    return globalURLRouter;
}

- (id)init {
    if ((self = [super init])) {
        _nameMap = [[NSMutableDictionary alloc] init];
        _modules = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)registerModule:(NSDictionary*)module withCompleteHander:(void(^)(BOOL successfulFlag , NSDictionary *outputInfo))completeHander {
    if ([KCURLUtility isValidDict:module]) {
        NSString *moduleName = [module objectForKey:KCModuleName];
        if ([KCURLUtility isValidString:moduleName]) {
         [self setModuleInfo:module
                     forName:moduleName
          withCompleteHander:^(BOOL successfulFlag, NSDictionary *outputInfo) {
              if (completeHander) {
                  completeHander(successfulFlag , outputInfo);
              }
          }];
        }
        else {
            if (completeHander) {
                completeHander(NO , nil);
            }
        }
    }
    else {
        if (completeHander) {
            completeHander(NO , nil);
        }
    }
}

- (void)setModuleInfo:(NSDictionary *)module
              forName:(NSString *)name
   withCompleteHander:(void(^)(BOOL successfulFlag , NSDictionary* outputInfo))completeHander
{
  NSDictionary *registeredModule = [self.modules objectForKey:name.lowercaseString];
    if ([registeredModule count] > 0) {
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        dict[KCURLRouterModuleName] = [name lowercaseString];
        completeHander(NO , dict);
    } else {
        [self.nameMap setObject:name
                     forKey:[name lowercaseString]];
        [self.modules setObject:module
                     forKey:[name lowercaseString]];// 模块名存为小写
        completeHander(YES, nil);
    }
}

- (NSMutableDictionary *)parseString:(NSString *)urlString {
    NSMutableDictionary* result = nil;
    if ([KCURLUtility isValidString:urlString]) {
       //这里是遵循KCLIFE的URLencoding方法
        NSString* stingEncoding = [KCURLUtility URLEncodeAllCJKCharacters:urlString];
        result = [self parseURL:[NSURL URLWithString:stingEncoding]];
    }
    return result;
}

// 标准URL解析
- (NSMutableDictionary *)parseURL:(NSURL *)standardURL {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];

    if (![standardURL isKindOfClass:[NSURL class]]){
        return result;
    }
    NSString *host = [standardURL host];
    if ([KCURLUtility isValidString:host]) {
        result[KCURLHost] = host;
    }
    NSString *user = [standardURL user];
    if ([KCURLUtility isValidString:user]) {
        result[KCURLUser] = user;
    }
    NSString *password = [standardURL password];
    if ([KCURLUtility isValidString:password]) {
        result[KCURLPassword] = password;
    }
    NSString *path = [standardURL path];
    if ([KCURLUtility isValidString:path]) {
        result[KCURLPath] = path;
    }
    
    NSString *query = [standardURL query];
    if ([KCURLUtility isValidString:query]) {
        result[KCURLQueryString] = query;
    }
    NSString *fragment = [standardURL fragment];
    if ([KCURLUtility isValidString:fragment]) {
        result[KCURLFragment] = fragment;
    }
    NSString *parameterString = [standardURL parameterString];
    if ([KCURLUtility isValidString:parameterString]) {
        result[KCURLParameterString] = parameterString;
    }
    
    NSString *relativePath = [standardURL relativePath];
    if ([KCURLUtility isValidString:relativePath]) {
        result[KCURLRelativePath] = relativePath;
    }
    
    NSString *resourceSpecifier = [standardURL resourceSpecifier];
    if ([KCURLUtility isValidString:resourceSpecifier]) {
        result[KCURLResourceSpecifier] = resourceSpecifier;
    }
    return result;
}

- (NSDictionary *)findModuleInfo:(NSString *)moduleName {
    NSDictionary *moduleInfo = nil;
    if ([moduleName length] > 0) {
        moduleInfo = [self.modules objectForKey:moduleName.lowercaseString];//统一以小写取模块名
    }
    return moduleInfo;
}

@end

NSString * const KCModuleName = @"name";







