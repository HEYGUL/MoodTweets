//
// Created by Guillaume Lagorce on 31/01/15.
// Copyright (c) 2015 Gl0ub1l. All rights reserved.
//

#import "NSMutableArray+Shuffle.h"


@implementation NSMutableArray (Shuffle)

- (void)shuffle
{
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; ++i)
    {
        NSInteger remainingCount = count - i;
        NSUInteger exchangeIndex = i + arc4random_uniform((u_int32_t) remainingCount);
        [self exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
    }
}

@end