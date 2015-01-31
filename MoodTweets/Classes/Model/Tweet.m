//
// Created by Guillaume Lagorce on 28/01/15.
// Copyright (c) 2015 Gl0ub1l. All rights reserved.
//

#import "Tweet.h"

NSString *const kNeutralMoodString = @"neutral";
NSString *const kPositiveMoodString = @"positive";
NSString *const kNegativeMoodString = @"negative";
NSString *const kUndefinedMoodString = @"undefined";

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
    TWMoodType moodType = TWMoodUndefined;
    if ([sentimentText isEqualToString:kNeutralMoodString])
    {
        moodType = TWMoodNeutral;
    }
    else if ([sentimentText isEqualToString:kPositiveMoodString])
    {
        moodType = TWMoodPositive;
    }
    else if ([sentimentText isEqualToString:kNegativeMoodString])
    {
        moodType = TWMoodNegative;
    }

    return moodType;
}

- (NSString *)moodToText
{
    NSString *sentimentText = kUndefinedMoodString;

    switch (self.mood)
    {
        case TWMoodNegative:
            sentimentText = kNegativeMoodString;
            break;

        case TWMoodPositive:
            sentimentText = kPositiveMoodString;
            break;


        case TWMoodNeutral:
            sentimentText = kNeutralMoodString;
            break;

        default:
            break;
    }

    return sentimentText;
}
@end