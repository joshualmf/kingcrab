//  KCURLUtility.h
//  RouterComponent
//
//  Created by MAC008 on 2017/12/12.
//  Copyright © 2017年 Mac001. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KCURLUtility : NSObject

+ (BOOL)isValidString:(NSString *)inputStr;
+ (BOOL)isValidArray:(NSArray *)inputArray;
+ (BOOL)isValidDict:(NSDictionary *)inputDict;
+ (NSDictionary *)queryStringToDict:(NSString *)queryString;
+ (NSString *)URLEncodeAllCJKCharacters:(NSString *)str;

@end
