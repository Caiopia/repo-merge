//
//  AppDelegate.m
//  Bugsnag Test App
//
//  Created by Simon Maynard on 1/18/13.
//  Copyright (c) 2013 Simon Maynard. All rights reserved.
//

#import "AppDelegate.h"
#import <Bugsnag/Bugsnag.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self startBugsnagWithAPIKey];
    //[self startBugsnagWithConfiguration];
    return YES;
}

- (void)startBugsnagWithConfiguration {
    BugsnagConfiguration *config = [BugsnagConfiguration new];
    config.apiKey = @"f35a2472bd230ac0ab0f52715bbdc65d";
    config.releaseStage = @"production";
    config.notifyReleaseStages = @[@"production"];
    [Bugsnag startBugsnagWithConfiguration:config];
}

- (void)startBugsnagWithAPIKey {
    [Bugsnag startBugsnagWithApiKey:@"f35a2472bd230ac0ab0f52715bbdc65d"];
    [Bugsnag configuration].releaseStage = @"production";
    [Bugsnag configuration].notifyReleaseStages = @[@"production"];
}
@end
