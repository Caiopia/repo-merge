//
//  BugsnagSessionTest.m
//  Tests
//
//  Created by Jamie Lynch on 27/11/2017.
//  Copyright © 2017 Bugsnag. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "BugsnagSession.h"
#import "BSG_RFC3339DateTool.h"

@interface BugsnagSessionTest : XCTestCase
@end

@implementation BugsnagSessionTest

- (void)testPayloadSerialisation {
    NSDate *now = [NSDate date];
    BugsnagSession *payload = [[BugsnagSession alloc] initWithId:@"test"
                                                       startDate:now
                                                            user:[BugsnagUser new]
                                                    autoCaptured:NO];
    payload.unhandledCount = 1;
    payload.handledCount = 2;

    NSDictionary *rootNode = [payload toJson];
    XCTAssertNotNil(rootNode);
    XCTAssertEqual(5, [rootNode count]);
    
    XCTAssertEqualObjects(@"test", rootNode[@"id"]);
    XCTAssertEqualObjects([BSG_RFC3339DateTool stringFromDate:now], rootNode[@"startedAt"]);
    XCTAssertEqualObjects(@1, rootNode[@"unhandledCount"]);
    XCTAssertEqualObjects(@2, rootNode[@"handledCount"]);
    XCTAssertNotNil(rootNode[@"user"]);
}

@end
