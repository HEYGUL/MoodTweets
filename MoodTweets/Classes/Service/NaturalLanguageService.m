//
// Created by Guillaume Lagorce on 30/01/15.
// Copyright (c) 2015 Gl0ub1l. All rights reserved.
//

#import <Bolts/BFTask.h>
#import <Bolts/BFTaskCompletionSource.h>
#import "NaturalLanguageService.h"
#import "Tweet.h"
#import "UNIRest.h"


/********************************************************************************/
#pragma mark - Constants

NSString *const kMashapeHeaderKey = @"X-Mashape-Key";
NSString *const kMashapeHeaderValue = @"m2QSKbrbBAmshYbtpJY7KL4IaXtMp1UG80HjsnktpsOdLe06kh";
NSString *const kAcceptKey = @"Accept";
NSString *const kAcceptValue = @"application/json";
NSString *const kUrlFormatString = @"https://loudelement-free-natural-language-processing-service.p.mashape.com/nlp-text/?text=%@";
NSString *const kSentimentTextKey = @"sentiment-text";
NSString *const kSentimentScoreKey = @"sentiment-score";

@implementation NaturalLanguageService

/********************************************************************************/
#pragma mark - Public Methods

+ (BFTask *)moodForTweet:(Tweet *)tweet
{
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];

    NSDictionary *headers = [self requestHeaders];

    [[UNIRest get:^(UNISimpleRequest *request)
    {
        [request setUrl:[self urlForTweetText:tweet.text]];
        [request setHeaders:headers];
    }] asJsonAsync:^(UNIHTTPJsonResponse *response, NSError *error)
    {
        if(!error)
        {
            UNIJsonNode *body = response.body;
            tweet.moodScore = [body.JSONObject[kSentimentScoreKey] floatValue];
            tweet.mood = [Tweet moodTypeFromSentimentText:body.JSONObject[kSentimentTextKey]];
            [source setResult:body];
        }
        else
        {
            [source setError:error];
        }
    }];
    return source.task;
}



/********************************************************************************/
#pragma mark - Private Methods

+ (NSString *)urlForTweetText:(NSString *)text
{
    NSString *escapedText = [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:kUrlFormatString, escapedText];
}

+ (NSDictionary *)requestHeaders
{
    NSDictionary *headers = @{kMashapeHeaderKey : kMashapeHeaderValue, kAcceptKey : kAcceptValue};
    return headers;
}

@end