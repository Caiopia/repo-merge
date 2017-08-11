//
//  BugsnagKSCrashSentry.h
//  Pods
//
//  Created by Jamie Lynch on 11/08/2017.
//
//

#import <Foundation/Foundation.h>

#import "BugsnagConfiguration.h"
#import "BugsnagErrorReportApiClient.h"

@interface BugsnagCrashSentry : NSObject

- (void)install:(BugsnagConfiguration *)config
      apiClient:(BugsnagErrorReportApiClient *)apiClient
        onCrash:(KSReportWriteCallback)onCrash;

@end
