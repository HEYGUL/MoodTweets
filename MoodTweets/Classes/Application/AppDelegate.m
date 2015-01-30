//
//  AppDelegate.m
//  I am a Buffer
//
//  Created by Guillaume Lagorce on 17/01/15.
//  Copyright (c) 2015 Gl0ub1l. All rights reserved.
//


#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Fabric with:@[CrashlyticsKit]];
    return YES;
}

@end