//
//  BugsnagUser.h
//  Bugsnag
//
//  Created by Jamie Lynch on 24/11/2017.
//  Copyright © 2017 Bugsnag. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Information about the current user of your application.
 */
@interface BugsnagUser : NSObject

@property(readonly) NSString *id;
@property(readonly) NSString *name;
@property(readonly) NSString *email;

@end
