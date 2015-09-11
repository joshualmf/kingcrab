//
//  NSObject+JSON.m
//  Onstar
//
//  Created by Joshua on 15/9/9.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import "NSObject+Json.h"

@implementation NSObject (JSON)

- (NSString *)toJson
{
    NSError *error = nil;
    NSString *jsonString = nil;
    if ([self isKindOfClass:[NSDictionary class]] ||
        [self isKindOfClass:[NSArray class]]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:self
                                                    options:kNilOptions error:&error];
        jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

@end
