/*! @file OIDURLSessionProviderTests.m
 @brief AppAuth iOS SDK
 @copyright
 Copyright 2015 Google Inc. All Rights Reserved.
 @copydetails
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <XCTest/XCTest.h>
#import "OIDURLSessionProvider.h"

@interface OIDURLSessionProviderTests : XCTestCase

@end

/*! @brief Unit tests for @c OIDURLSessionProvider
 */
@implementation OIDURLSessionProviderTests

- (void)tearDown {
    // Setting the session back to default sharedSession for future test cases
    [OIDURLSessionProvider setSession:[NSURLSession sharedSession]];
}

- (void)testCustomSession {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *customSession = [NSURLSession sessionWithConfiguration:config];
    [OIDURLSessionProvider setSession:customSession];
    NSURLSession *session = [OIDURLSessionProvider session];
    XCTAssertEqual(session, customSession);
}

@end
