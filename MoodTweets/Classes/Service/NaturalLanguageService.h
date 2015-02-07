//
// Created by Guillaume Lagorce on 30/01/15.
// Copyright (c) 2015 Gl0ub1l. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Tweet;

@interface NaturalLanguageService : NSObject

+ (BFTask *)moodForTweet:(Tweet *)tweet;

@end