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

#import <Core/OIDAuthState.h>
#import <Core/OIDAuthStateChangeDelegate.h>
#import <Core/OIDAuthStateErrorDelegate.h>
#import <Core/OIDAuthorizationRequest.h>
#import <Core/OIDAuthorizationResponse.h>
#import <Core/OIDAuthorizationService.h>
#import <Core/OIDError.h>
#import <Core/OIDErrorUtilities.h>
#import <Core/OIDExternalUserAgent.h>
#import <Core/OIDExternalUserAgentRequest.h>
#import <Core/OIDExternalUserAgentSession.h>
#import <Core/OIDGrantTypes.h>
#import <Core/OIDIDToken.h>
#import <Core/OIDRegistrationRequest.h>
#import <Core/OIDRegistrationResponse.h>
#import <Core/OIDResponseTypes.h>
#import <Core/OIDScopes.h>
#import <Core/OIDScopeUtilities.h>
#import <Core/OIDServiceConfiguration.h>
#import <Core/OIDServiceDiscovery.h>
#import <Core/OIDTokenRequest.h>
#import <Core/OIDTokenResponse.h>
#import <Core/OIDTokenUtilities.h>
#import <Core/OIDURLSessionProvider.h>
#import <Core/OIDEndSessionRequest.h>
#import <Core/OIDEndSessionResponse.h>

#if TARGET_OS_TV
#elif TARGET_OS_WATCH
#elif TARGET_OS_IOS || TARGET_OS_MACCATALYST
#import <Core/OIDAuthState+IOS.h>
#import <AppAuth/OIDAuthorizationService+IOS.h>
#import <AppAuth/OIDExternalUserAgentIOS.h>
#import <AppAuth/OIDExternalUserAgentIOSCustomBrowser.h>
#import "AppAuth/OIDExternalUserAgentCatalyst.h"
#elif TARGET_OS_MAC
#import <AppAuth/OIDAuthState+Mac.h>
#import <AppAuth/OIDAuthorizationService+Mac.h>
#import <AppAuth/OIDExternalUserAgentMac.h>
#import <AppAuth/OIDRedirectHTTPHandler.h>
#else
#error "Platform Undefined"
#endif

