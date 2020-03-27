//
//  Bugsnag.h
//
//  Created by Conrad Irwin on 2014-10-01.
//
//  Copyright (c) 2014 Bugsnag, Inc. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall remain in place
// in this source code.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
#import <Foundation/Foundation.h>

#import "BugsnagConfiguration.h"
#import "BugsnagMetadata.h"
#import "BugsnagPlugin.h"

static NSString *_Nonnull const BugsnagSeverityError = @"error";
static NSString *_Nonnull const BugsnagSeverityWarning = @"warning";
static NSString *_Nonnull const BugsnagSeverityInfo = @"info";

@interface Bugsnag : NSObject

/** Start listening for crashes.
 *
 * This method initializes Bugsnag with the default configuration. Any uncaught
 * NSExceptions, C++ exceptions, mach exceptions or signals will be logged to
 * disk before your app crashes. The next time your app boots, we send any such
 * reports to Bugsnag.
 *
 * @param apiKey  The API key from your Bugsnag dashboard.
 */
+ (void)startBugsnagWithApiKey:(NSString *_Nonnull)apiKey;

/** Start listening for crashes.
 *
 * This method initializes Bugsnag. Any uncaught NSExceptions, uncaught
 * C++ exceptions, mach exceptions or signals will be logged to disk before
 * your app crashes. The next time your app boots, we send any such
 * reports to Bugsnag.
 *
 * @param configuration  The configuration to use.
 */
+ (void)startBugsnagWithConfiguration:
    (BugsnagConfiguration *_Nonnull)configuration;

/**
 * @return YES if Bugsnag has been started and the previous launch crashed
 */
+ (BOOL)appDidCrashLastLaunch;

// =============================================================================
// MARK: - Notify
// =============================================================================

/** Send a custom or caught exception to Bugsnag.
 *
 * The exception will be sent to Bugsnag in the background allowing your
 * app to continue running.
 *
 * @param exception  The exception.
 */
+ (void)notify:(NSException *_Nonnull)exception;

/**
 *  Send a custom or caught exception to Bugsnag
 *
 *  @param exception The exception
 *  @param block     A block for optionally configuring the error report
 */
+ (void)notify:(NSException *_Nonnull)exception
         block:(BugsnagOnErrorBlock _Nullable)block;

/**
 *  Send an error to Bugsnag
 *
 *  @param error The error
 */
+ (void)notifyError:(NSError *_Nonnull)error;

/**
 *  Send an error to Bugsnag
 *
 *  @param error The error
 *  @param block A block for optionally configuring the error report
 */
+ (void)notifyError:(NSError *_Nonnull)error
              block:(BugsnagOnErrorBlock _Nullable)block;

/**
 * Intended for use by other clients (React Native/Unity). Calling this method
 * directly from iOS is not supported.
 */
+ (void)internalClientNotify:(NSException *_Nonnull)exception
                    withData:(NSDictionary *_Nullable)metadata
                       block:(BugsnagOnErrorBlock _Nullable)block;

/** Add custom data to send to Bugsnag with every exception. If value is nil,
 *  delete the current value for attributeName
 *
 * See also [Bugsnag configuration].metaData;
 *
 * @param key      The name of the data.
 *
 * @param value    Its value.
 *
 * @param section  The tab to show it on on the Bugsnag dashboard.
 */
+ (void)addMetadataToSection:(NSString *_Nonnull)section
                         key:(NSString *_Nonnull)key
                       value:(id _Nullable)value
    NS_SWIFT_NAME(addMetadata(_:key:value:));

// =============================================================================
// MARK: - Breadcrumbs
// =============================================================================

/**
 * Leave a "breadcrumb" log message, representing an action that occurred
 * in your app, to aid with debugging.
 *
 * @param message  the log message to leave
 */
+ (void)leaveBreadcrumbWithMessage:(NSString *_Nonnull)message;

/**
 *  Leave a "breadcrumb" log message each time a notification with a provided
 *  name is received by the application
 *
 *  @param notificationName name of the notification to capture
 */
+ (void)leaveBreadcrumbForNotificationName:(NSString *_Nonnull)notificationName;

/**
 * Leave a "breadcrumb" log message, representing an action that occurred
 * in your app, to aid with debugging, along with additional metadata and
 * a type.
 *
 * @param message The log message to leave.
 * @param metadata Additional metadata included with the breadcrumb.
 * @param type A BSGBreadcrumbTypeValue denoting the type of breadcrumb.
 */
+ (void)leaveBreadcrumbWithMessage:(NSString *_Nonnull)message
                          metadata:(NSDictionary *_Nullable)metadata
                           andType:(BSGBreadcrumbType)type
    NS_SWIFT_NAME(leaveBreadcrumb(_:metadata:type:));

/**
 * Clear any breadcrumbs that have been left so far.
 */
+ (void)clearBreadcrumbs;

/**
 * Set the maximum number of breadcrumbs to keep and sent to Bugsnag.
 * By default, we'll keep and send the 20 most recent breadcrumb log
 * messages.
 *
 * @param capacity max number of breadcrumb log messages to send
 */
+ (void)setBreadcrumbCapacity:(NSUInteger)capacity
        __deprecated_msg("Use [BugsnagConfiguration setMaxBreadcrumbs:] instead");

// =============================================================================
// MARK: - Session
// =============================================================================

/**
 * Starts tracking a new session.
 *
 * By default, sessions are automatically started when the application enters the foreground.
 * If you wish to manually call startSession at
 * the appropriate time in your application instead, the default behaviour can be disabled via
 * autoTrackSessions.
 *
 * Any errors which occur in an active session count towards your application's
 * stability score. You can prevent errors from counting towards your stability
 * score by calling pauseSession and resumeSession at the appropriate
 * time in your application.
 *
 * @see pauseSession:
 * @see resumeSession:
 */
+ (void)startSession;

/**
 * Stops tracking a session.
 *
 * When a session is stopped, errors will not count towards your application's
 * stability score. This can be advantageous if you do not wish these calculations to
 * include a certain type of error, for example, a crash in a background service.
 * You should disable automatic session tracking via autoTrackSessions if you call this method.
 *
 * A stopped session can be resumed by calling resumeSession,
 * which will make any subsequent errors count towards your application's
 * stability score. Alternatively, an entirely new session can be created by calling startSession.
 *
 * @see startSession:
 * @see resumeSession:
 */
+ (void)pauseSession;

/**
 * Resumes a session which has previously been stopped, or starts a new session if none exists.
 *
 * If a session has already been resumed or started and has not been stopped, calling this
 * method will have no effect. You should disable automatic session tracking via
 * autoTrackSessions if you call this method.
 *
 * It's important to note that sessions are stored in memory for the lifetime of the
 * application process and are not persisted on disk. Therefore calling this method on app
 * startup would start a new session, rather than continuing any previous session.
 *
 * You should call this at the appropriate time in your application when you wish to
 * resume a previously started session. Any subsequent errors which occur in your application
 * will be reported to Bugsnag and will count towards your application's stability score.
 *
 * @see startSession:
 * @see pauseSession:
 *
 * @return true if a previous session was resumed, false if a new session was started.
 */
+ (BOOL)resumeSession;

/**
* Return the metadata for a specific named section
*
* @param section The name of the section
* @returns The mutable dictionary representing the metaadata section, if it
*          exists, or nil if not.
*/
+ (NSMutableDictionary *_Nullable)getMetadata:(NSString *_Nonnull)section
    NS_SWIFT_NAME(getMetadata(_:));

/**
* Return the metadata for a key in a specific named section
*
* @param section The name of the section
* @param key The key
* @returns The value of the keyed value if it exists or nil.
*/
+ (id _Nullable )getMetadata:(NSString *_Nonnull)section key:(NSString *_Nonnull)key
    NS_SWIFT_NAME(getMetadata(_:key:));

/**
* Add a callback that would be invoked before a session is sent to Bugsnag.
*
* @param block The block to be added.
*/
+ (void)addOnSessionBlock:(BugsnagOnSessionBlock _Nonnull)block;

/**
 * Remove a callback that would be invoked before a session is sent to Bugsnag.
 *
 * @param block The block to be removed.
 */
+ (void)removeOnSessionBlock:(BugsnagOnSessionBlock _Nonnull )block;

// =============================================================================
// MARK: - Other methods
// =============================================================================
/**
 * Remove a key/value from a named matadata section.  If either the section or the
 * key do not exist no action will occur.
 *
 * @param sectionName The name of the section containing the value
 * @param key The key to remove
 */
+ (void)clearMetadataInSection:(NSString *_Nonnull)sectionName
                       withKey:(NSString *_Nonnull)key
    NS_SWIFT_NAME(clearMetadata(section:key:));

+ (NSDateFormatter *_Nonnull)payloadDateFormatter;

/**
 * Replicates BugsnagConfiguration.context
 *
 * @param context A general summary of what was happening in the application
 */
+ (void)setContext:(NSString *_Nullable)context;

/** Remove custom data from Bugsnag reports.
 *
 * @param sectionName        The section to clear.
 */
+ (void)clearMetadataInSection:(NSString *_Nonnull)sectionName
    NS_SWIFT_NAME(clearMetadata(section:));

// =============================================================================
// MARK: - User
// =============================================================================

/**
 * The current user
 */
+ (BugsnagUser *_Nonnull)user;

/**
 *  Set user metadata
 *
 *  @param userId ID of the user
 *  @param name   Name of the user
 *  @param email  Email address of the user
 */
+ (void)setUser:(NSString *_Nullable)userId
       withEmail:(NSString *_Nullable)email
       andName:(NSString *_Nullable)name;

// =============================================================================
// MARK: - onSend
// =============================================================================

/**
 *  Add a callback to be invoked before a report is sent to Bugsnag, to
 *  change the report contents as needed
 *
 *  @param block A block which returns YES if the report should be sent
 */
+ (void)addOnSendBlock:(BugsnagOnSendBlock _Nonnull)block;

/**
 * Remove an onSend callback, if it exists
 *
 * @param block The block to remove
 */
+ (void)removeOnSendBlock:(BugsnagOnSendBlock _Nonnull)block;

@end
