//
// Created by Jamie Lynch on 30/11/2017.
// Copyright (c) 2017 Bugsnag. All rights reserved.
//

#import "BugsnagSessionTrackingApiClient.h"
#import "BugsnagConfiguration.h"
#import "BugsnagSessionTrackingPayload.h"
#import "BugsnagSessionFileStore.h"
#import "BugsnagLogger.h"
#import "BugsnagSession.h"
#import "BugsnagSessionInternal.h"
#import "BSG_RFC3339DateTool.h"
#import "Private.h"

@interface BugsnagConfiguration ()
@property(nonatomic, readwrite, strong) NSMutableArray *onSessionBlocks;
@property(readonly, retain, nullable) NSURL *sessionURL;
@end

@interface BugsnagSessionTrackingApiClient ()
@property NSMutableSet *activeIds;
@property(nonatomic) NSString *codeBundleId;
@end


@implementation BugsnagSessionTrackingApiClient

- (instancetype)initWithConfig:(BugsnagConfiguration *)configuration
                     queueName:(NSString *)queueName {
    if (self = [super initWithConfig:configuration queueName:queueName]) {
        _activeIds = [NSMutableSet new];
    }
    return self;
}

- (NSOperation *)deliveryOperation {
    return [NSOperation new];
}

- (void)deliverSessionsInStore:(BugsnagSessionFileStore *)store {
    NSString *apiKey = [self.config.apiKey copy];
    NSURL *sessionURL = [self.config.sessionURL copy];

    if (!apiKey) {
        bsg_log_err(@"No API key set. Refusing to send sessions.");
        return;
    }

    NSDictionary<NSString *, NSDictionary *> *filesWithIds = [store allFilesByName];

    for (NSString *fileId in [filesWithIds allKeys]) {
        // skip dupe requests
        if ([self isActiveRequest:fileId]) {
            continue;
        }
        // add request
        [self.activeIds addObject:fileId];

        BugsnagSession *session = [[BugsnagSession alloc] initWithDictionary:filesWithIds[fileId]];

        [self.sendQueue addOperationWithBlock:^{
            BugsnagSessionTrackingPayload *payload = [[BugsnagSessionTrackingPayload alloc]
                initWithSessions:@[session]
                          config:[Bugsnag configuration]
                    codeBundleId:self.codeBundleId];
            NSUInteger sessionCount = payload.sessions.count;
            NSMutableDictionary *data = [payload toJson];
            NSDictionary *HTTPHeaders = @{
                    @"Bugsnag-Payload-Version": @"1.0",
                    @"Bugsnag-API-Key": apiKey,
                    @"Bugsnag-Sent-At": [BSG_RFC3339DateTool stringFromDate:[NSDate new]]
            };
            [self sendItems:1
                withPayload:data
                      toURL:sessionURL
                    headers:HTTPHeaders
               onCompletion:^(NSUInteger sentCount, BOOL success, NSError *error) {
                   if (success && error == nil) {
                       bsg_log_info(@"Sent %lu sessions to Bugsnag", (unsigned long) sessionCount);
                       [store deleteFileWithId:fileId];
                   } else {
                       bsg_log_warn(@"Failed to send sessions to Bugsnag: %@", error);
                   }

                   // remove request
                   [self.activeIds removeObject:fileId];
               }];
        }];
    }
}

- (BOOL)isActiveRequest:(NSString *)fileId {
    for (NSString *val in self.activeIds) {
        if ([val isEqualToString:fileId]) {
            return true;
        }
    }
    return false;
}

@end
