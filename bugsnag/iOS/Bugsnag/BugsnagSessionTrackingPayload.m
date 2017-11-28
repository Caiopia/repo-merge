//
//  BugsnagSessionTrackingPayload.m
//  Bugsnag
//
//  Created by Jamie Lynch on 27/11/2017.
//  Copyright © 2017 Bugsnag. All rights reserved.
//

#import "BugsnagSessionTrackingPayload.h"
#import "BugsnagCollections.h"
#import "BugsnagNotifier.h"
#import "Bugsnag.h"
#import "BugsnagKeys.h"
#import "BSG_KSSystemInfo.h"
#import "BugsnagKSCrashSysInfoParser.h"

@interface Bugsnag ()
+ (BugsnagNotifier *)notifier;
@end

@implementation BugsnagSessionTrackingPayload

- (NSDictionary *)toJson {
    
    NSMutableDictionary *dict = [NSMutableDictionary new];
    NSMutableArray *sessionData = [NSMutableArray new];
    
    for (BugsnagSession *session in self.sessions) {
        [sessionData addObject:[session toJson]];
    }
    BSGDictInsertIfNotNil(dict, sessionData, @"sessions");
    BSGDictSetSafeObject(dict, [Bugsnag notifier].details, BSGKeyNotifier);
    
    NSDictionary *systemInfo = [BSG_KSSystemInfo systemInfo];
    BSGDictSetSafeObject(dict, BSGParseApp(systemInfo), @"app");
    BSGDictSetSafeObject(dict, BSGParseDevice(systemInfo), @"device");
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
