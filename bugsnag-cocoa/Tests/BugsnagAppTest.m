//
//  BugsnagDeviceTest.m
//  Tests
//
//  Created by Jamie Lynch on 01/04/2020.
//  Copyright © 2020 Bugsnag. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "BugsnagAppWithState.h"
#import "BugsnagConfiguration.h"
#import "BugsnagTestConstants.h"

@interface BugsnagApp ()
+ (BugsnagApp *)appWithDictionary:(NSDictionary *)event config:(BugsnagConfiguration *)config;

- (NSDictionary *)toDict;
@end

@interface BugsnagAppWithState ()
+ (BugsnagAppWithState *)appWithDictionary:(NSDictionary *)event config:(BugsnagConfiguration *)config;
+ (BugsnagAppWithState *)appWithOomData:(NSDictionary *)event;
- (NSDictionary *)toDict;
@end

@interface BugsnagAppTest : XCTestCase
@property NSDictionary *data;
@property BugsnagConfiguration *config;
@end

@implementation BugsnagAppTest

- (void)setUp {
    [super setUp];
    self.data = @{
            @"system": @{
                    @"application_stats": @{
                            @"active_time_since_launch": @2,
                            @"background_time_since_launch": @5,
                            @"application_in_foreground": @YES,
                    },
                    @"CFBundleExecutable": @"MyIosApp",
                    @"CFBundleIdentifier": @"com.example.foo.MyIosApp",
                    @"CFBundleShortVersionString": @"5.6.3",
                    @"CFBundleVersion": @"1",
                    @"app_uuid": @"dsym-uuid-123"
            },
            @"user": @{
                    @"config": @{
                            @"releaseStage": @"beta"
                    }
            }
    };

    self.config = [[BugsnagConfiguration alloc] initWithApiKey:DUMMY_APIKEY_32CHAR_1];
    self.config.appType = @"iOS";
    self.config.codeBundleId = @"bundle-123";
}

- (void)testApp {
    BugsnagApp *app = [BugsnagApp appWithDictionary:self.data config:self.config];

    // verify stateless fields
    XCTAssertEqualObjects(@"1", app.bundleVersion);
    XCTAssertEqualObjects(@"bundle-123", app.codeBundleId);
    XCTAssertEqualObjects(@"dsym-uuid-123", app.dsymUuid);
    XCTAssertEqualObjects(@"com.example.foo.MyIosApp", app.id);
    XCTAssertEqualObjects(@"beta", app.releaseStage);
    XCTAssertEqualObjects(@"iOS", app.type);
    XCTAssertEqualObjects(@"5.6.3", app.version);
}

- (void)testAppWithState {
    BugsnagAppWithState *app = [BugsnagAppWithState appWithDictionary:self.data config:self.config];

    // verify stateful fields
    XCTAssertEqual(7000, app.duration);
    XCTAssertEqual(2000, app.durationInForeground);
    XCTAssertTrue(app.inForeground);

    // verify stateless fields
    XCTAssertEqualObjects(@"1", app.bundleVersion);
    XCTAssertEqualObjects(@"bundle-123", app.codeBundleId);
    XCTAssertEqualObjects(@"dsym-uuid-123", app.dsymUuid);
    XCTAssertEqualObjects(@"com.example.foo.MyIosApp", app.id);
    XCTAssertEqualObjects(@"beta", app.releaseStage);
    XCTAssertEqualObjects(@"iOS", app.type);
    XCTAssertEqualObjects(@"5.6.3", app.version);
}

- (void)testAppToDict {
    BugsnagApp *app = [BugsnagApp appWithDictionary:self.data config:self.config];
    NSDictionary *dict = [app toDict];

    // verify stateless fields
    XCTAssertEqualObjects(@"1", dict[@"bundleVersion"]);
    XCTAssertEqualObjects(@"bundle-123", dict[@"codeBundleId"]);
    XCTAssertEqualObjects(@[@"dsym-uuid-123"], dict[@"dsymUUIDs"]);
    XCTAssertEqualObjects(@"com.example.foo.MyIosApp", dict[@"id"]);
    XCTAssertEqualObjects(@"beta", dict[@"releaseStage"]);
    XCTAssertEqualObjects(@"iOS", dict[@"type"]);
    XCTAssertEqualObjects(@"5.6.3", dict[@"version"]);
}

- (void)testAppWithStateToDict {
    BugsnagAppWithState *app = [BugsnagAppWithState appWithDictionary:self.data config:self.config];
    NSDictionary *dict = [app toDict];

    // verify stateful fields
    XCTAssertEqual(7000, [dict[@"duration"] longValue]);
    XCTAssertEqual(2000, [dict[@"durationInForeground"] longValue]);
    XCTAssertTrue([dict[@"inForeground"] boolValue]);

    // verify stateless fields
    XCTAssertEqualObjects(@"1", dict[@"bundleVersion"]);
    XCTAssertEqualObjects(@"bundle-123", dict[@"codeBundleId"]);
    XCTAssertEqualObjects(@[@"dsym-uuid-123"], dict[@"dsymUUIDs"]);
    XCTAssertEqualObjects(@"com.example.foo.MyIosApp", dict[@"id"]);
    XCTAssertEqualObjects(@"beta", dict[@"releaseStage"]);
    XCTAssertEqualObjects(@"iOS", dict[@"type"]);
    XCTAssertEqualObjects(@"5.6.3", dict[@"version"]);
}

- (void)testAppFromOOM {
    NSDictionary *oomData = @{
            @"id": @"com.example.foo.MyIosApp",
            @"releaseStage": @"beta",
            @"version": @"5.6.3",
            @"bundleVersion": @"1",
            @"codeBundleId": @"bundle-123",
            @"inForeground": @YES,
            @"type": @"iOS"
    };

    BugsnagAppWithState *app = [BugsnagAppWithState appWithOomData:oomData];

    // verify stateful fields
    XCTAssertEqual(0, app.duration);
    XCTAssertEqual(0, app.durationInForeground);
    XCTAssertTrue(app.inForeground);

    // verify stateless fields
    XCTAssertEqualObjects(@"1", app.bundleVersion);
    XCTAssertEqualObjects(@"bundle-123", app.codeBundleId);
    XCTAssertNil(app.dsymUuid);
    XCTAssertEqualObjects(@"com.example.foo.MyIosApp", app.id);
    XCTAssertEqualObjects(@"beta", app.releaseStage);
    XCTAssertEqualObjects(@"iOS", app.type);
    XCTAssertEqualObjects(@"5.6.3", app.version);
}

@end
