//
//  BugsnagApp.h
//  Bugsnag
//
//  Created by Jamie Lynch on 01/04/2020.
//  Copyright © 2020 Bugsnag. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Stateless information set by the notifier about your app can be found on this class. These values
 * can be accessed and amended if necessary.
 */
@interface BugsnagApp : NSObject

/**
 * The bundle version used by the application
 */
@property(nonatomic) NSString *_Nullable bundleVersion;

/**
 * The revision ID from the manifest (React Native apps only)
 */
@property(nonatomic) NSString *_Nullable codeBundleId;

/**
 * Unique identifier for the debug symbols file corresponding to the application
 */
@property(nonatomic) NSString *_Nullable dsymUuid;

/**
 * The app identifier used by the application
 */
@property(nonatomic) NSString *_Nullable id;

/**
 * For an app, this key is the executable. For a loadable bundle, it's the binary that's loaded dynamically by the
 * bundle. For a framework, it's the shared library framework and must have the same name as the framework but
 * without the .framework extension.
 */
@property(nonatomic) NSString *_Nullable name;

/**
 * The release stage set in Configuration
 */
@property(nonatomic) NSString *_Nullable releaseStage;

/**
 * The application type set in Configuration
 */
@property(nonatomic) NSString *_Nullable type;

/**
 * The version of the application set in Configuration
 */
@property(nonatomic) NSString *_Nullable version;

@end
