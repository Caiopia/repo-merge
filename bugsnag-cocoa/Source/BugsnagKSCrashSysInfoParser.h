//
//  BugsnagKSCrashSysInfoParser.h
//  Bugsnag
//
//  Created by Jamie Lynch on 28/11/2017.
//  Copyright © 2017 Bugsnag. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PLATFORM_WORD_SIZE sizeof(void*)*8

NSDictionary *_Nonnull BSGParseDeviceMetadata(NSDictionary *_Nonnull event);
