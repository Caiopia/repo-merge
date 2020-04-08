//
//  BugsnagDevice.m
//  Bugsnag
//
//  Created by Jamie Lynch on 01/04/2020.
//  Copyright © 2020 Bugsnag. All rights reserved.
//

#import "BugsnagDevice.h"
#import "BugsnagConfiguration.h"
#import "BugsnagCollections.h"

@implementation BugsnagDevice

+ (BugsnagDevice *)deviceWithDictionary:(NSDictionary *)event {
    BugsnagDevice *device = [BugsnagDevice new];
    [self populateFields:device dictionary:event];
    return device;
}

+ (void)populateFields:(BugsnagDevice *)device
            dictionary:(NSDictionary *)event {
    NSDictionary *system = event[@"system"];
    device.jailbroken = [system[@"jailbroken"] boolValue];
    device.id = system[@"device_app_hash"];
    device.locale = [[NSLocale currentLocale] localeIdentifier];
    device.manufacturer = @"Apple";
    device.model = system[@"machine"];
    device.modelNumber = system[@"model"];
    device.osName = system[@"system_name"];
    device.osVersion = system[@"system_version"];
    device.totalMemory = system[@"memory"][@"usable"];

    NSMutableDictionary *runtimeVersions = [NSMutableDictionary new];
    runtimeVersions[@"osBuild"] = system[@"os_version"];
    runtimeVersions[@"clangVersion"] = system[@"clang_version"];
    device.runtimeVersions = runtimeVersions;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    BSGDictInsertIfNotNil(dict, @(self.jailbroken), @"jailbroken");
    BSGDictInsertIfNotNil(dict, self.id, @"id");
    BSGDictInsertIfNotNil(dict, self.locale, @"locale");
    BSGDictInsertIfNotNil(dict, self.manufacturer, @"manufacturer");
    BSGDictInsertIfNotNil(dict, self.model, @"model");
    BSGDictInsertIfNotNil(dict, self.modelNumber, @"modelNumber");
    BSGDictInsertIfNotNil(dict, self.osName, @"osName");
    BSGDictInsertIfNotNil(dict, self.osVersion, @"osVersion");
    BSGDictInsertIfNotNil(dict, self.runtimeVersions, @"runtimeVersions");
    BSGDictInsertIfNotNil(dict, self.totalMemory, @"totalMemory");
    return dict;
}
@end
