//
//  BugsnagSessionTrackerTest.m
//  Tests
//
//  Created by Jamie Lynch on 27/11/2017.
//  Copyright © 2017 Bugsnag. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "BugsnagUser.h"
#import "BugsnagConfiguration.h"
#import "BugsnagSessionTracker.h"
#import "BugsnagSession.h"

@interface BugsnagSessionTrackerTest : XCTestCase
@property BugsnagConfiguration *configuration;
@property BugsnagSessionTracker *sessionTracker;
@property BugsnagUser *user;
@end

@implementation BugsnagSessionTrackerTest

- (void)setUp {
    [super setUp];
    self.configuration = [BugsnagConfiguration new];
    self.configuration.apiKey = @"test";
    self.configuration.shouldAutoCaptureSessions = YES;
    self.user = [BugsnagUser new];
    self.sessionTracker = [BugsnagSessionTracker new];
}

- (void)testStartNewSession {
    XCTAssertNil(self.sessionTracker.currentSession);
    NSDate *now = [NSDate date];
    [self.sessionTracker startNewSession:now
                                withUser:self.user
                            autoCaptured:NO];
    BugsnagSession *session = self.sessionTracker.currentSession;
    XCTAssertNotNil(session);
    XCTAssertNotNil(session.sessionId);
    XCTAssertEqualObjects(now, session.startedAt);
    XCTAssertNotNil(session.user);
}

- (void)testStartSessionDisabled {
    XCTAssertNil(self.sessionTracker.currentSession);
    self.configuration.shouldAutoCaptureSessions = NO;
    
    NSDate *now = [NSDate date];
    [self.sessionTracker startNewSession:now
                                withUser:self.user
                            autoCaptured:YES];
    XCTAssertNil(self.sessionTracker.currentSession);
    
    [self.sessionTracker startNewSession:now
                                withUser:self.user
                            autoCaptured:NO];
    XCTAssertNotNil(self.sessionTracker.currentSession);
}

- (void)testUniqueSessionIds {
    [self.sessionTracker startNewSession:[NSDate date]
                                withUser:self.user
                            autoCaptured:NO];
    BugsnagSession *firstSession = self.sessionTracker.currentSession;
    
    [self.sessionTracker startNewSession:[NSDate date]
                                withUser:self.user
                            autoCaptured:NO];
    
    BugsnagSession *secondSession = self.sessionTracker.currentSession;
    XCTAssertNotEqualObjects(firstSession.sessionId, secondSession.sessionId);
}

- (void)testIncrementCounts {
    
    [self.sessionTracker startNewSession:[NSDate date]
                                withUser:self.user
                            autoCaptured:NO];
     [self.sessionTracker incrementHandledError];
     [self.sessionTracker incrementHandledError];
     [self.sessionTracker incrementUnhandledError];
     [self.sessionTracker incrementUnhandledError];
     [self.sessionTracker incrementUnhandledError];

    BugsnagSession *session = self.sessionTracker.currentSession;
    XCTAssertNotNil(session);
    XCTAssertEqual(2, session.handledCount);
    XCTAssertEqual(3, session.unhandledCount);
    
    [self.sessionTracker startNewSession:[NSDate date]
                                withUser:self.user
                            autoCaptured:NO];

    session = self.sessionTracker.currentSession;
    XCTAssertEqual(0, session.handledCount);
    XCTAssertEqual(0, session.unhandledCount);
}

// TODO test session timeout

@end

