//
// Created by Guillaume Lagorce on 31/01/15.
// Copyright (c) 2015 Gl0ub1l. All rights reserved.
//

#import "JSONValueTransformer+CustomTransformer.h"


NSString *const kApiDateFormat = @"eee MMM dd HH:mm:ss ZZZZ yyyy";

@implementation JSONValueTransformer (CustomTransformer)

- (NSDate *)NSDateFromNSString:(NSString*)string {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:kApiDateFormat];
    return [formatter dateFromString:string];
}

@end