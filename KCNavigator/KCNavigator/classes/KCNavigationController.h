//  KCNavigationController.h
//  router
//
//  Created by Joshua on 2017/2/17.
//
#ifndef __KCNavigationController_h__
#define __KCNavigationController_h__

#import <UIKit/UIKit.h>

typedef void(^KCNavigationCloseBlock)(id result);

@interface KCNavigationController : UINavigationController

@property (nonatomic, strong)   NSString *moduleName;
@property (nonatomic, assign)   BOOL isInContinuousProcess;
@property (nonatomic, strong)   NSString *groupName;
@property (nonatomic, assign)   BOOL canDirectlyBack;
@property (nonatomic, strong)   NSString *redirection;
@property (nonatomic, strong)   KCNavigationCloseBlock closeBlock;
@property (nonatomic, assign)   BOOL needAnimation;

/**
 @brief 模块即将关闭
 @param args 会话的相关参数
 */
- (void)moduleWillClose:(id)args;

/**
 @brief 模块即将出现
 @param args 会话的相关参数
 */
- (void)moduleWillReAppear:(id)args;
@end

#endif
