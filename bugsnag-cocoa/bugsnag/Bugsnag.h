//
//  Bugsnag.h
//  Bugsnag
//
//  Created by Simon Maynard on 8/28/13.
//  Copyright (c) 2013 Simon Maynard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BugsnagConfiguration.h"

@interface Bugsnag : NSObject

+ (void)startWithApiKey:(NSString*)apiKey;
+ (BugsnagConfiguration*)configuration;
+ (void) notify:(NSException *)exception;
+ (void) notify:(NSException *)exception withData:(NSDictionary*)metaData;

+ (void) setUserAttribute:(NSString*)attributeName withValue:(id)value;
+ (void) clearUser;
+ (void) addAttribute:(NSString*)attributeName withValue:(id)value toTabWithName:(NSString*)tabName;
+ (void) clearTabWithName:(NSString*)tabName;

@end
