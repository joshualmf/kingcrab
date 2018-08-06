//  KCURLUtility.m
//  RouterComponent
//
//  Created by MAC008 on 2017/12/12.
//  Copyright © 2017年 Mac001. All rights reserved.
//

#import "KCURLUtility.h"

@implementation KCURLUtility

+ (BOOL)isValidString:(NSString *)inputStr {
    BOOL ret;
    do {
        if (!inputStr || ![inputStr isKindOfClass:[NSString class]] || [inputStr length] == 0) {
            ret = NO;
        }
        else
        {
            ret = YES;
        }
    } while (false);
    return ret;
}

+ (BOOL)isValidArray:(NSArray *)inputArray {
    BOOL ret;
    do {
        if (!inputArray || ![(NSArray*)inputArray isKindOfClass:[NSArray class]] || [inputArray count] == 0) {
            ret = NO;
        }
        else
        {
            ret = YES;
        }
    } while (false);
    return ret;
}

+ (BOOL)isValidDict:(NSDictionary *)inputDict {
    BOOL ret;
    do {
        if (!inputDict || ![inputDict isKindOfClass:[NSDictionary class]] || [inputDict.allKeys count] == 0) {
            ret = NO;
        }
        else {
            ret = YES;
        }
    } while (false);
    return ret;
}



+ (NSDictionary *)queryStringToDict:(NSString *)queryString {
    NSMutableDictionary *queryParams = [NSMutableDictionary dictionary];

    if (![queryParams isKindOfClass:[NSString class]]) {
        return queryParams;
    }
    [[queryString componentsSeparatedByString:@"&"] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *keyValuePair = [obj componentsSeparatedByString:@"="];
        NSString *key = keyValuePair[0];
        NSString *value = keyValuePair.count > 1 ? keyValuePair[1] : @"";
        value = [value stringByReplacingOccurrencesOfString:@"+" withString:@" "];
        value = [value stringByRemovingPercentEncoding];
        queryParams[key] = value;
    }];
    
    return queryParams;
}

+ (NSString *)URLEncodeAllCJKCharacters:(NSString *)str {
    NSString *encodedString = @"";
    
    for (int i = 0; i < str.length; i++) {
        NSString *c = [str substringWithRange:NSMakeRange(i, 1)];
        if ([KCURLUtility isCJKCharacter:c]) {
            c = [KCURLUtility URLEncodingWithUTF8:c];
        }
        
        encodedString = [encodedString stringByAppendingString:c];
    }
    
    return encodedString;
}

+ (BOOL)isCJKCharacter:(NSString *)str {
    BOOL isCJKChar = NO;
    for (int i = 0; i < str.length; i ++) {
        unichar c = [str characterAtIndex:i];
        
        //搜索字符的Unicode范围，判断是否为中日韩文字区中的字符
        if (0x2000 < c && c < 0xfffd) {
            return YES;
        }
    }
    
    return isCJKChar;
}

+ (NSString *)URLEncodingWithUTF8:(NSString *)str {
    NSCharacterSet *allowedCharacters = [NSCharacterSet characterSetWithCharactersInString:@"-._~0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
    return [str stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
}


@end
