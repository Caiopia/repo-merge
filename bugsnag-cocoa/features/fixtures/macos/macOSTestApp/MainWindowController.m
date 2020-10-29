//
//  MainWindowController.m
//  macOSTestApp
//
//  Created by Nick Dowell on 29/10/2020.
//  Copyright © 2020 Bugsnag Inc. All rights reserved.
//

#import "MainWindowController.h"

#import "Scenario.h"

#import <Bugsnag/Bugsnag.h>


@interface MainWindowController ()

// These properties are used with Cocoa Bindings
@property (copy) NSString *apiKey;
@property (copy) NSString *notifyEndpoint;
@property (copy) NSString *scenarioMetadata;
@property (copy) NSString *scenarioName;
@property (copy) NSString *sessionEndpoint;

@property Scenario *scenario;

@end

#pragma mark -

@implementation MainWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.apiKey = @"12312312312312312312312312312312";
    self.notifyEndpoint = @"http://bs-local.com:9339";
    self.sessionEndpoint = @"http://bs-local.com:9339";
}

- (BugsnagConfiguration *)configuration {
    BugsnagConfiguration *configuration = [BugsnagConfiguration loadConfig];
    if (self.apiKey) {
        configuration.apiKey = self.apiKey;
    }
    if (self.notifyEndpoint) {
        configuration.endpoints.notify = self.notifyEndpoint;
    }
    if (self.sessionEndpoint) {
        configuration.endpoints.sessions = self.sessionEndpoint;
    }
    configuration.enabledErrorTypes.ooms = NO;
    return configuration;
}

- (IBAction)runScenario:(id)sender {
    self.scenario = [Scenario createScenarioNamed:self.scenarioName withConfig:[self configuration]];
    
    NSLog(@"Starting Bugsnag for scenario: %@", self.scenario);
    [self.scenario startBugsnag];
    
    NSLog(@"Running scenario: %@", self.scenario);
    [self.scenario run];
}

- (IBAction)startBugsnag:(id)sender {
    self.scenario = [Scenario createScenarioNamed:self.scenarioName withConfig:[self configuration]];
    
    NSLog(@"Starting Bugsnag for scenario: %@", self.scenario);
    [self.scenario startBugsnag];
}

- (IBAction)clearPersistentData:(id)sender {
    NSLog(@"Clear persistent data");
    [NSUserDefaults.standardUserDefaults removePersistentDomainForName:NSBundle.mainBundle.bundleIdentifier];
    NSString *cachesDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSArray<NSString *> *entries = @[
        @"bsg_kvstore",
        @"bsgkv",
        @"bugsnag",
        @"bugsnag_breadcrumbs.json",
        @"bugsnag_handled_crash.txt",
        @"KSCrash",
        @"KSCrashReports"];
    for (NSString *entry in entries) {
        NSString *path = [cachesDir stringByAppendingPathComponent:entry];
        NSError *error = nil;
        if (![NSFileManager.defaultManager removeItemAtPath:path error:&error]) {
            NSLog(@"%@", error);
        }
    }
}

- (IBAction)useDashboardEndpoints:(id)sender {
    self.notifyEndpoint = @"https://notify.bugsnag.com";
    self.sessionEndpoint = @"https://sessions.bugsnag.com";
}

@end
