//
// Created by Guillaume Lagorce on 31/01/15.
// Copyright (c) 2015 Gl0ub1l. All rights reserved.
//

#import "Tweet+Helpers.h"
#import <FlatUIKit/FlatUIKit.h>

@implementation Tweet (Helpers)

- (UIColor *)moodColor
{
    UIColor *color = [UIColor clearColor];

    switch (self.mood)
    {
        case TWMoodNegative:
            color = [UIColor peterRiverColor];
            break;

        case TWMoodPositive:
            color = [UIColor turquoiseColor];
            break;


        case TWMoodNeutral:
            color = [UIColor sunflowerColor];
            break;

        default:
            break;
    }

    return color;

}

@end