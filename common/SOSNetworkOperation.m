//
//  SOSNetworkOperation.m
//  OnStarAFNetWork
//
//  Created by Gennie Sun on 15/8/20.
//  Modified by Joshua Xu on 15/8/31.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import "SOSNetworkOperation.h"
#import "JsonHandler.h"
#import "NSString+Common.h"

@interface SOSNetworkOperation ()
{
    SOSSuccessBlock _mSuccessBlock;
    SOSFailureBlock _mFailureBlock;
    dispatch_semaphore_t semo;
}
@end

@implementation SOSNetworkOperation

+ (SOSNetworkOperation *)requestWithURL:(NSString *)url
                                 params:(NSString *)params
                           successBlock:(SOSSuccessBlock)successBlock
                           failureBlock:(SOSFailureBlock)failureBlock
{
    SOSNetworkOperation *operation = [[SOSNetworkOperation alloc] initWithURL:url
                                                                       params:params
                                                                 successBlock:successBlock
                                                                 failureBlock:failureBlock];
    return operation;
}

- (SOSNetworkOperation *)initWithURL:(NSString *)url
                              params:(NSString *)params
                        successBlock:(SOSSuccessBlock)successBlock
                        failureBlock:(SOSFailureBlock)failureBlock
{
    if (self = [super init]) {
        // 设置URL以及Http body
        _mRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        if (params) {
            [_mRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
            if ([params hasPrefix:@"<"]) {
                [_mRequest setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
            } else {
                [_mRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            }
        }
        [self initDefaultValueForRequest];
        NSLog(@">>>>>> HTTP request URL \n[%@]", url);
        NSLog(@">>>>>> HTTP request Body\n[%@]", params);

        if (successBlock) {
            _mSuccessBlock = Block_copy(successBlock);
        }
        if (failureBlock) {
            _mFailureBlock = Block_copy(failureBlock);
        }
    }
    return self;
}

- (void)initDefaultValueForRequest
{
    [_mRequest setHTTPMethod:@"POST"];
    [_mRequest setTimeoutInterval:HTTP_TIME_OUT_NORMAL];
}

- (void)setHttpMethod:(NSString *)httpMethod
{
    [_mRequest setHTTPMethod:httpMethod];
}

- (void)setHttpHeaders:(NSDictionary *)headerDict
{
    NSArray* keyList = [headerDict allKeys];
    for(NSString* key in keyList)
    {
        NSString *value = [headerDict objectForKey:key];
        if (key && value) {
            [_mRequest setValue:[headerDict objectForKey:key] forHTTPHeaderField:key];
        }
    }
}

- (void)setHttpTimeOutInterval:(NSInteger)timeOutInterval
{
    [_mRequest setTimeoutInterval:timeOutInterval];
}

-(void)start
{
    semo = dispatch_semaphore_create(0);
    if (!_afOperation) {
        _afOperation = [[AFHTTPRequestOperation alloc] initWithRequest:_mRequest];
        // 让Success/failure block在子线程执行
        dispatch_queue_t operationQueue = dispatch_queue_create("com.shanghaionstar.httpRequest", DISPATCH_QUEUE_CONCURRENT);
        [_afOperation setCompletionQueue:operationQueue];
    }
    
    [_afOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"<<<<<< HTTP response \n[%@]", operation.responseString);
        if (_mSuccessBlock) {
            _mSuccessBlock(self, operation.responseString);
        }
        dispatch_semaphore_signal(semo);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"<<<<<< HTTP response \n[%@]", operation.responseString);
        if (_mFailureBlock) {
            _mFailureBlock(operation.response.statusCode, operation.responseString, operation.error);
        }
        dispatch_semaphore_signal(semo);
    }];
    
    [_afOperation start];
}

- (void)startSync
{
    [self start];
    //[_afOperation waitUntilFinished];
    //waitUntilFinished方法在 Operation成功或者失败后就执行，不会等到block执行完。需要用信号量来自己控制同步。
    dispatch_semaphore_wait(semo, DISPATCH_TIME_FOREVER);
    
}

- (void)pause
{
    [_afOperation pause];
}

- (void)resume
{
    [_afOperation resume];
}

- (void)cancel
{
    [_afOperation cancel];
}

- (void)dealloc
{
    [_mRequest release], _mRequest = nil;
    [_afOperation release], _afOperation = nil;
    Block_release(_mSuccessBlock);
    Block_release(_mFailureBlock);
    [super dealloc];
}

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
{
    if (self = [super init])
    {
        self.networkHttpType = networkHttpType;
        self.networkDataFormat = networkDataFormat;
        self.url = url;
        self.params = params;
        self.showHUD = showHUD;
        self.delegate = delegate;
        self.hashValue = hashValue;
        
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);

        //Xml 格式
        if (networkDataFormat == NetWorkDATAXML)
        {
            if (networkHttpType == NetWorkHTTPGET)
            {
                
            }
            else if (networkHttpType == NetWorkHTTPPOST)
            {
                // 将地址编码
                url = [url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
                // 实例化NSMutableURLRequest，并进行参数配置
                self.mRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
                [self.mRequest setHTTPMethod:@"POST"];
                [self.mRequest addValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
                [self.mRequest setTimeoutInterval:API_TIME_OUT];
                
                // 设置AFNetworking的缓存问题
                NSHTTPCookie *cookie;
                for (cookie in cookies)
                {
                    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
                }

                NSString * string = nil;
                if ([params isKindOfClass:[NSString class]])
                {
                    string = params;
                }
                
                // 设置post数据 httpbody
                if (string)
                {
                    [self.mRequest setHTTPBody:[string dataUsingEncoding:NSUTF8StringEncoding]];
                }

                self.afOperation = [[AFHTTPRequestOperation alloc] initWithRequest:self.mRequest];
                
                __block SOSNetworkOperation *weekSelf = self;
                
                [self.afOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    if (successBlock)
                    {
                        successBlock(operation.response.statusCode,operation.responseString);
                        dispatch_semaphore_signal(sema);
                    }
                    
                    [[SOSNetworkHandler sharedInstance] removeItem:weekSelf];

                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

                    if (failureBlock)
                    {
                        failureBlock(operation.response.statusCode,operation.error);
                        dispatch_semaphore_signal(sema);
                    }
                    
                    [[SOSNetworkHandler sharedInstance] removeItem:weekSelf];
                }];
                
                [[SOSNetworkHandler sharedInstance] addItem:self];

                [self.afOperation start];
                [self.afOperation waitUntilFinished];

            }
            
        }//json 格式
        else if (networkDataFormat == NetWorkDATAJSON)
        {
            self.manager = [AFHTTPRequestOperationManager manager];
            AFHTTPResponseSerializer *serializer = [AFHTTPResponseSerializer serializer];
            serializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
            self.manager.responseSerializer = serializer;
            self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
            
            NSArray* arr = [requestHeaderDic allKeys];
            for(NSString* str in arr)
            {
                NSLog(@"%@", [requestHeaderDic objectForKey:str]);
                [self.manager.requestSerializer setValue:[requestHeaderDic objectForKey:str] forHTTPHeaderField:str];
            }
            
            // 设置AFNetworking的缓存问题
            NSHTTPCookie *cookie;
            for (cookie in cookies)
            {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
            }

            if (networkHttpType == NetWorkHTTPGET)
            {
                __block SOSNetworkOperation *weekSelf = self;

                [self.manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){

                    NSString *responseString = [NSString stringWithString:operation.responseString];
#if DEBUG
                    NSLog(@"BM网络请求接口url:%@的回返数据 responseString:\n%@", url, responseString);
#endif
                    // 如果返回值有html特殊字符，请释放这一句
                    //responseString = [responseString ignoreHTMLSpecialString];
                    id returnData = [JsonHandler JSONValue:responseString];

                    if (successBlock)
                    {
                        successBlock(operation.response.statusCode,returnData);
                        dispatch_semaphore_signal(sema);
                    }
                    
                    [[SOSNetworkHandler sharedInstance] removeItem:weekSelf];

                }
                    failure:^(AFHTTPRequestOperation *operation, NSError *error){
                        
                        if (failureBlock)
                        {
                            failureBlock(operation.response.statusCode,operation.error);
                            dispatch_semaphore_signal(sema);
                        }
                        
                        [[SOSNetworkHandler sharedInstance] removeItem:weekSelf];
                    }];
                
                [[SOSNetworkHandler sharedInstance] addItem:self];

            }
            else if (networkHttpType == NetWorkHTTPPOST)
            {
                __block SOSNetworkOperation *weekSelf = self;

                [self.manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject){
                    
                    NSString *responseString = [NSString stringWithString:operation.responseString];
#if DEBUG
                    NSLog(@"BM网络请求接口url:%@的回返数据 responseString:\n%@", url, responseString);
#endif
                    // 如果返回值有html特殊字符，请释放这一句
                    // responseString = [responseString ignoreHTMLSpecialString];
                    id returnData = [JsonHandler JSONValue:responseString];

                    if (successBlock)
                    {
                        successBlock(operation.response.statusCode,returnData);
                    }
                    
                    [[SOSNetworkHandler sharedInstance] removeItem:weekSelf];
                }
                        failure:^(AFHTTPRequestOperation *operation, NSError *error){
                               if (failureBlock)
                               {
                                   failureBlock(operation.response.statusCode,operation.error);
                               }
                            [[SOSNetworkHandler sharedInstance] removeItem:weekSelf];

                           }];
                [[SOSNetworkHandler sharedInstance] addItem:self];
            }
        }
        
        //同步
        if (sync) {
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }
    }
    return self;
}
*/
@end
