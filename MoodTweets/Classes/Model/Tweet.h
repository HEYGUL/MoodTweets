//
// Created by Guillaume Lagorce on 28/01/15.
// Copyright (c) 2015 Gl0ub1l. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

typedef NS_ENUM(NSInteger, TWMoodType)
{
    TWMoodUndefined = 0,
    TWMoodNeutral,
    TWMoodPositive,
    TWMoodNegative
};

@interface Tweet : JSONModel

@property(nonatomic, strong) NSString *text;
@property(nonatomic, strong) NSDate *createdAt;
@property(nonatomic, assign) float moodScore;
@property(nonatomic, assign) TWMoodType mood;

+ (TWMoodType)moodTypeFromSentimentText:(NSString *)sentimentText;

- (NSString *)moodToText;
@end