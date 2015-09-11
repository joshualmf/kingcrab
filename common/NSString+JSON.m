//
//  NSString+JSON.m
//  Onstar
//
//  Created by Joshua on 15/9/9.
//  Copyright (c) 2015年 Shanghai Onstar. All rights reserved.
//

#import "NSString+Json.h"

@implementation NSString (JSON)

- (id)toBasicObject
{
    NSError *error;
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
}
@end
