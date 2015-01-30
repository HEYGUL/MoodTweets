//
// Created by Guillaume Lagorce on 28/01/15.
// Copyright (c) 2015 Gl0ub1l. All rights reserved.
//

#import "Tweet.h"

NSString *const kNeutralMoodString = @"neutral";
NSString *const kPositiveMoodString = @"positive";

@implementation Tweet

/********************************************************************************/
#pragma mark - JSONModel overrides

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

+ (JSONKeyMapper *)keyMapper
{
    return [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
}

/********************************************************************************/
#pragma mark - Public Methods

+ (TWMoodType)moodTypeFromSentimentText:(NSString *)sentimentText
{
    TWMoodType moodType = TWMoodNegative;
    if([sentimentText isEqualToString:kNeutralMoodString])
    {
        moodType = TWMoodNeutral;
    }
    else if([sentimentText isEqualToString:kPositiveMoodString])
    {
        moodType = TWMoodPositive;
    }
    return moodType;
}

@end