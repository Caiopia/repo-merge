//
// Created by Jamie Lynch on 07/06/2018.
// Copyright (c) 2018 Bugsnag. All rights reserved.
//

#import "ManualSessionScenario.h"

@implementation ManualSessionScenario

- (void)run {
    [self.config setUser:@"123" withName:@"Joe Bloggs" andEmail:@"user@example.com"];
    [Bugsnag startSession];
}

@end
