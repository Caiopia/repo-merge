/*! @file AppAuth.h
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

#import <Foundation/Foundation.h>

//! Project version number for AppAuthFramework-iOS.
FOUNDATION_EXPORT double AppAuthVersionNumber;

//! Project version string for AppAuthFramework-iOS.
FOUNDATION_EXPORT const unsigned char AppAuthVersionString[];

#import <AppAuthCore/OIDAuthState.h>
#import <AppAuthCore/OIDAuthStateChangeDelegate.h>
#import <AppAuthCore/OIDAuthStateErrorDelegate.h>
#import <AppAuthCore/OIDAuthorizationRequest.h>
#import <AppAuthCore/OIDAuthorizationResponse.h>
#import <AppAuthCore/OIDAuthorizationService.h>
#import <AppAuthCore/OIDError.h>
#import <AppAuthCore/OIDErrorUtilities.h>
#import <AppAuthCore/OIDExternalUserAgent.h>
#import <AppAuthCore/OIDExternalUserAgentRequest.h>
#import <AppAuthCore/OIDExternalUserAgentSession.h>
#import <AppAuthCore/OIDGrantTypes.h>
#import <AppAuthCore/OIDIDToken.h>
#import <AppAuthCore/OIDRegistrationRequest.h>
#import <AppAuthCore/OIDRegistrationResponse.h>
#import <AppAuthCore/OIDResponseTypes.h>
#import <AppAuthCore/OIDScopes.h>
#import <AppAuthCore/OIDScopeUtilities.h>
#import <AppAuthCore/OIDServiceConfiguration.h>
#import <AppAuthCore/OIDServiceDiscovery.h>
#import <AppAuthCore/OIDTokenRequest.h>
#import <AppAuthCore/OIDTokenResponse.h>
#import <AppAuthCore/OIDTokenUtilities.h>
#import <AppAuthCore/OIDURLSessionProvider.h>
#import <AppAuthCore/OIDEndSessionRequest.h>
#import <AppAuthCore/OIDEndSessionResponse.h>

#if TARGET_OS_TV
#elif TARGET_OS_WATCH
#elif TARGET_OS_IOS || TARGET_OS_MACCATALYST
#import <AppAuthCore/OIDAuthState+IOS.h>
#import <AppAuthCore/OIDAuthorizationService+IOS.h>
#import <AppAuthCore/OIDExternalUserAgentIOS.h>
#import <AppAuthCore/OIDExternalUserAgentIOSCustomBrowser.h>
#import "AppAuthCore/OIDExternalUserAgentCatalyst.h"
#elif TARGET_OS_MAC
#import <AppAuthCore/OIDAuthState+Mac.h>
#import <AppAuthCore/OIDAuthorizationService+Mac.h>
#import <AppAuthCore/OIDExternalUserAgentMac.h>
#import <AppAuthCore/OIDRedirectHTTPHandler.h>
#else
#error "Platform Undefined"
#endif

