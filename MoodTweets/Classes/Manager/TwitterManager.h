//
// Created by Guillaume Lagorce on 28/01/15.
// Copyright (c) 2015 Gl0ub1l. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STTwitterAPI;
@class ACAccount;
@class BFTask;


@interface TwitterManager : NSObject

+ (instancetype)sharedManager;
- (BFTask *)accessTwitterAccounts;
- (BFTask *)loginWithiOSAccount:(ACAccount *)account;
- (BFTask *)loadTimelineWithUser:(NSString *)user;
- (BFTask *)loadProfileImageForUser:(NSString*)user;

@end