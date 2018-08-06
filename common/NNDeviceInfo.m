//
//  NNDeviceInfo.m
//  skeleton
//
//  Created by crablife on 16/5/31.
//  Copyright © 2016年 Mac001. All rights reserved.
//

#import "NNDeviceInfo.h"
#import <arpa/inet.h>


#define ETHERNET_INTERFACE          @"en0"          // wifi接口，以太网类型
#define PDP_INTERFACE               @"pdp_ip0"      // 3G/4G网络接口
#define BRIDGE_INTERFACE            @"bridge0"      // 通过热点的网络接口

@implementation NNDeviceInfo

- (NSString *)deviceIPAdress
{
    NSString *address = nil;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    
    if (success == 0)
    {
        temp_addr = interfaces;
        char addrBuf[MAX(INET_ADDRSTRLEN,INET6_ADDRSTRLEN)];
        while (temp_addr != NULL)
        {
            if ([[NSString stringWithUTF8String: temp_addr->ifa_name] isEqualToString: ETHERNET_INTERFACE] ||
                [[NSString stringWithUTF8String: temp_addr->ifa_name] isEqualToString: PDP_INTERFACE] ||
                [[NSString stringWithUTF8String: temp_addr->ifa_name] isEqualToString: BRIDGE_INTERFACE]) {
                
                if( temp_addr->ifa_addr->sa_family == AF_INET)
                {
                    //address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    address = [NSString stringWithUTF8String:inet_ntop(AF_INET, &((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr, addrBuf, INET_ADDRSTRLEN)];
                } else if (temp_addr->ifa_addr->sa_family == AF_INET6) {
                    address = [NSString stringWithUTF8String:inet_ntop(AF_INET6, &((struct sockaddr_in6 *)temp_addr->ifa_addr)->sin6_addr, addrBuf, INET6_ADDRSTRLEN)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    return address;
}
static IMP __oldDictionaryInitWithObjectAndKeysCountSafeIMP = NULL;

static IMP __oldArrayInitWithObjectsCountSafeIMP = NULL;

static id __DictionaryInitWithObjectAndKeysCountSafeIMP(id obj, SEL sel, const __unsafe_unretained id *objects, const __unsafe_unretained id *keys, NSUInteger count)
{
    CFMutableDictionaryRef dict = CFDictionaryCreateMutable(NULL, count, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    for (NSInteger iLooper = 0; iLooper < count; ++iLooper)
    {
        id value = objects[iLooper];
        id key = keys[iLooper];
        if (value && key)
        {
            CFDictionarySetValue(dict, (__bridge const void *)(key), (__bridge const void *)(value));
        }
    }
    
    return (__bridge id)(dict);
}

static id __ArrayInitWithObjectsCountSafeIMP(id obj, SEL sel, const __unsafe_unretained id *objects, NSUInteger count)
{
    CFMutableArrayRef array = CFArrayCreateMutable(NULL, count, &kCFTypeArrayCallBacks);
    //CFMutableDictionaryRef dict = CFDictionaryCreateMutable(NULL, count, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    for (NSInteger iLooper = 0; iLooper < count; ++iLooper)
    {
        id value = objects[iLooper];
        //id key = keys[iLooper];
        if (value)
        {
            CFArrayAppendValue(array, (__bridge const void *)value);
            //CFDictionarySetValue(dict, (__bridge const void *)(key), (__bridge const void *)(value));
        }
    }
    
    return (__bridge id)(array);
}

@implementation CMBUtil

static Class kCMBUtilStringClass = Nil;
static Class kCMBUtilNumberClass = Nil;

+ (void)load
{
    Method method = class_getInstanceMethod(objc_getClass("__NSPlaceholderDictionary"), @selector(initWithObjects:forKeys:count:));
    __oldDictionaryInitWithObjectAndKeysCountSafeIMP = method_setImplementation(method, (IMP)__DictionaryInitWithObjectAndKeysCountSafeIMP);
    
    
    Method methodArray = class_getInstanceMethod(objc_getClass("__NSPlaceholderArray"), @selector(initWithObjects:count:));
    __oldArrayInitWithObjectsCountSafeIMP = method_setImplementation(methodArray, (IMP)__ArrayInitWithObjectsCountSafeIMP);

    kCMBUtilStringClass = [NSString class];
    kCMBUtilNumberClass = [NSNumber class];
}

@end
