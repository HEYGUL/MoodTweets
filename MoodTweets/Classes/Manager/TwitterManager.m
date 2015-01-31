//
// Created by Guillaume Lagorce on 28/01/15.
// Copyright (c) 2015 Gl0ub1l. All rights reserved.
//

#import <Accounts/Accounts.h>
#import "TwitterManager.h"
#import "STTwitterAPI.h"
#import "Tweet.h"
#import "BFTask.h"
#import "BFTaskCompletionSource.h"


@interface TwitterManager ()
@property(nonatomic, strong) STTwitterAPI *twitterAPI;
@end

@implementation TwitterManager

/********************************************************************************/
#pragma mark - Birth & Death

+ (instancetype)sharedManager
{
    static TwitterManager *twitterManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        twitterManager = [[self alloc] init];
    });
    return twitterManager;
}

/********************************************************************************/
#pragma mark - Login

- (BFTask *)accessTwitterAccounts
{
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    ACAccountStore *accountStore = [ACAccountStore new];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccountStoreRequestAccessCompletionHandler accountStoreRequestCompletionHandler = ^(BOOL granted, NSError *error)
    {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^
        {
            if (granted)
            {
                NSArray *iOSAccounts = [accountStore accountsWithAccountType:accountType];
                [source setResult:iOSAccounts];
            }
            else
            {
                [source setError:error];
            }
        }];
    };
    [accountStore requestAccessToAccountsWithType:accountType
                                          options:NULL
                                       completion:accountStoreRequestCompletionHandler];
    return source.task;
}

- (BFTask *)loginWithiOSAccount:(ACAccount *)account
{
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    self.twitterAPI = [STTwitterAPI twitterAPIOSWithAccount:account];
    [self.twitterAPI verifyCredentialsWithSuccessBlock:^(NSString *username)
            {

                [source setResult:username];
            }
                                            errorBlock:^(NSError *error)
                                            {
                                                [source setError:error];
                                            }];

    return source.task;
}

/********************************************************************************/
#pragma mark - Timeline

- (BFTask *)loadTimelineWithUser:(NSString *)user
{
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    NSString *screenName = [user hasPrefix:@"@"] ? user : [NSString stringWithFormat:@"@%@", user];
    [self.twitterAPI getUserTimelineWithScreenName:screenName
                                             count:200
                                      successBlock:^(NSArray *statuses)
                                      {
                                          NSArray *tweets = [Tweet arrayOfModelsFromDictionaries:statuses];
                                          [source setResult:tweets];
                                      }
                                        errorBlock:^(NSError *error)
                                        {
                                            [source setError:error];
                                        }];
    return source.task;
}

@end