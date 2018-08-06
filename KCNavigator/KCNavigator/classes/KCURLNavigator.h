//  KCURLNavigator.h
//  router
//
//  Created by Joshua on 2017/12/25.
//
#ifndef __KCURLNavigator_h__
#define __KCURLNavigator_h__

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KCNavigationController.h"

typedef void(^KCNavigationCallback)(BOOL success, id result, id obj);

@protocol KCNavigatorProtocol <NSObject>
- (void)setNavigatorContext:(NSDictionary *)dict callback:(KCNavigationCallback)callback;
@end

// 页面导航传递的URL信息，包括host，path，queryString等
extern const NSString *KCNavURLInfo;

// 页面导航传递的自定义object
extern const NSString *KCNavURLObj;

@interface KCURLNavigator : NSObject <UINavigationControllerDelegate>

@property (nonatomic, strong) KCNavigationController *rootNavigationController;

/**
 @brief 单例模式
 @return 应用唯一的页面结构组织
 */
+ (instancetype)globalNavigator;

/**
 @brief 初始化页面导航器的rootviewcontroller， 一般在Appdelegate启动的时候处理。
 @param rootVC 整个应用的第一个VC
 @return 页面导航器
 */
- (UINavigationController *)buildNavigatorWithRoot:(UIViewController *)rootVC;

/**
 @brief 注册的URL页面跳转
 @param url 目标URL, URL的queryString不能出现Object这个key。
 @param object 要传递的页面对象
 @param callback 调用页面的callback
 @return 成功与否
 */
- (BOOL)navigateToURL:(NSURL *)url object:(id)object callback:(KCNavigationCallback)callback;

/**
 @brief 非注册的URL页面跳转
 @param viewController 目标的ViewController
 @param moduleInfo 目标ViewController的属性
 @param args 附带的参数
 */
- (void)show:(UIViewController *)viewController info:(NSDictionary *)moduleInfo withArguments:(NSDictionary *)args callback:(KCNavigationCallback)callback;

/**
 @brief 退出模块
 @param animated 动画
 */
- (void)vanish:(BOOL)animated;

/**
 @brief 退出流程
 @param animated 动画
 */
- (void)popGroup:(id)args animated:(BOOL)animated;

/**
 @brief 回退到栈顶
 @param animated 动画
 */
- (void)popToMainPage:(BOOL)animated;

/**
 @brief 页面回退（A->B->C->D,D可以返回到BC不能直接返回到A）
 @param pageName 模块名
 @param args 附带的参数
 @param animated 是否动画
 */
- (BOOL)popToPage:(NSString *)pageName args:(NSDictionary *)args animated:(BOOL)animated;

/**
 @brief 增加URL页面跳转后的操作
 @param actionBlock 页面跳转后要执行的block
 */
- (void)addNextAction:(dispatch_block_t)actionBlock;

@end

#endif
