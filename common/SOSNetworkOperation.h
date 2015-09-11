//
//  SOSNetworkOperation.h
//  OnStarAFNetWork
//
//  Created by Gennie Sun on 15/8/20.
//  Modified by Joshua Xu on 15/8/31.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSNetworkDefine.h"
#import "AFNetworking.h"
#import "SOSNetWorkUrls.h"

#define HTTP_TIME_OUT_NORMAL    60

@class SOSNetworkOperation;
/**
 *  请求成功回调
 *
 *  @param statusCode , operation 回调block
 */
typedef void (^SOSSuccessBlock)(SOSNetworkOperation *operation, id responseStr);

/**
 *  请求失败回调
 *
 *  @param statusCode , error 回调block
 */
typedef void (^SOSFailureBlock)(NSInteger statusCode, NSString *responseStr, NSError *error);


/**
 *  网络请求子项
 */
@interface SOSNetworkOperation : NSObject

/**
 *  网络请求的委托
 */
@property (nonatomic, assign) id delegate;

/**
 *  网络请求的委托delegate的唯一标示，因为delegate不能直接作为Key，所以转化了一步，用hashValue代替
 */
@property (nonatomic, assign) NSUInteger hashValue;

/**
 *  NSMutableURLRequest成员变量
 */
@property (nonatomic ,strong) NSMutableURLRequest *mRequest;

/**
 *  AFHTTPRequestOperation成员变量
 */
@property (nonatomic ,strong) AFHTTPRequestOperation* afOperation;



+ (SOSNetworkOperation *)requestWithURL:(NSString *)url
                                 params:(NSString *)params
                           successBlock:(SOSSuccessBlock)successBlock
                           failureBlock:(SOSFailureBlock)failureBlock;

- (SOSNetworkOperation *)initWithURL:(NSString *)url
                              params:(NSString *)params
                        successBlock:(SOSSuccessBlock)successBlock
                        failureBlock:(SOSFailureBlock)failureBlock;

/// 设置Http Get/Post方法。默认Post
- (void)setHttpMethod:(NSString *)httpMethod;

/// 设置Http headers
- (void)setHttpHeaders:(NSDictionary *)headerDict;

/// 设置Http超时时间，默认为60秒。车辆操作为180秒
- (void)setHttpTimeOutInterval:(NSInteger)timeOutInterval;

/// 异步请求
- (void)start;

/// 同步请求
- (void)startSync;
- (void)pause;
- (void)resume;
- (void)cancel;


/**
 *  创建一个网络请求项，开始请求网络
 *
 *  @param networkHttpType      网络HTTP请求方式post/xml
 *  @param networkDataFormat    网络请求数据返回格式json/xml
 *  @param url                  网络请求URL
 *  @param params               网络请求参数
 *  @param delegate             网络请求的委托，如果没有取消网络请求的需求，可传nil
 *  @param hashValue            网络请求的委托delegate的唯一标示
 *  @param cookies              设置请求缓存
 *  @param requestHeader        设置请求header
 *  @param showHUD              是否显示HUD
 *  @param successBlock         请求成功后的block
 *  @param failureBlock         请求失败后的block
 *
 *  @return BMNetworkItem对象
 */

/*
- (SOSNetworkOperation *) initWithType:(NetWorkHTTPType) networkHttpType
                networkDataFormat:(NetWorkDATAFormat)networkDataFormat
                              url:(NSString *) url
                           params:(id) params
                         delegate:delegate
                        hashValue:hashValue
                          cookies:(NSMutableArray *)cookies
                 requestHeaderDic:(NSMutableDictionary *)requestHeaderDic
//                       getCookies:(BOOL)getCookies
                          showHUD:(BOOL) showHUD
                     successBlock:(SOSSuccessBlock) successBlock
                     failureBlock:(SOSFailureBlock) failureBlock
                          isSync:(BOOL)sync;
*/
@end
