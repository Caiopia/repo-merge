//
//  BugsnagHandledState.m
//  Bugsnag
//
//  Created by Jamie Lynch on 21/09/2017.
//  Copyright © 2017 Bugsnag. All rights reserved.
//

#import "BugsnagHandledState.h"

static NSString *const kUnhandled = @"unhandled";
static NSString *const kSeverityReasonType = @"severityReasonType";
static NSString *const kOriginalSeverity = @"originalSeverity";
static NSString *const kCurrentSeverity = @"currentSeverity";
static NSString *const kAttrValue = @"attrValue";
static NSString *const kAttrKey = @"attrKey";

@implementation BugsnagHandledState

+ (instancetype)handledStateWithSeverityReason:(SeverityReasonType)severityReason {
    return [self handledStateWithSeverityReason:severityReason
                                       severity:BSGSeverityWarning
                                      attrValue:nil];
}

+ (instancetype)handledStateWithSeverityReason:(SeverityReasonType)severityReason
                                      severity:(BSGSeverity)severity
                                     attrValue:(NSString *)attrValue {
    BOOL unhandled = NO;
    
    switch (severityReason) {
        case UnhandledException:
            severity = BSGSeverityError;
            unhandled = YES;
            break;
        case Signal:
            severity = BSGSeverityError;
            unhandled = YES;
            break;
        case HandledError:
            severity = BSGSeverityWarning;
            break;
        case HandledException:
            severity = BSGSeverityWarning;
            break;
        case UserSpecifiedSeverity:
            break;
        default:
            [NSException raise:@"UnknownSeverityReason"
                        format:@"Severity reason not supported"];
    }
    
    return [[BugsnagHandledState alloc] initWithSeverityReason:severityReason
                                                      severity:severity
                                                     unhandled:unhandled
                                                     attrValue:attrValue];
}

- (instancetype)initWithSeverityReason:(SeverityReasonType)severityReason
                              severity:(BSGSeverity)severity
                             unhandled:(BOOL)unhandled
                             attrValue:(NSString *)attrValue {
    if (self = [super init]) {
        _severityReasonType = severityReason;
        _currentSeverity = severity;
        _originalSeverity = severity;
        _unhandled = unhandled;
        
        switch (severityReason) {
            case Signal:
                _attrValue = attrValue;
                _attrKey = @"signalType";
                break;
            case HandledError:
                _attrValue = attrValue;
                _attrKey = @"errorType";
                break;
            default:
                break;
        }
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        _unhandled = dict[kUnhandled];
        _severityReasonType = [BugsnagHandledState severityReasonFromString:dict[kSeverityReasonType]];
        _originalSeverity = BSGParseSeverity(dict[kOriginalSeverity]);
        _currentSeverity = BSGParseSeverity(dict[kCurrentSeverity]);
        _attrKey = dict[kAttrKey];
        _attrValue = dict[kAttrValue];
    }
    return self;
}

- (SeverityReasonType)calculateSeverityReasonType {
    return _originalSeverity == _currentSeverity ?
    _severityReasonType : UserCallbackSetSeverity;
}

static NSString *const kUnhandledException = @"unhandledException";
static NSString *const kSignal = @"signal";
static NSString *const kHandledError = @"handledError";
static NSString *const kHandledException = @"handledException";
static NSString *const kUserSpecifiedSeverity = @"userSpecifiedSeverity";
static NSString *const kUserCallbackSetSeverity = @"userCallbackSetSeverity";

+ (NSString *)stringFromSeverityReason:(SeverityReasonType)severityReason {
    switch (severityReason) {
        case UnhandledException:
            return kUnhandledException;
        case Signal:
            return kSignal;
        case HandledError:
            return kHandledError;
        case HandledException:
            return kHandledException;
        case UserSpecifiedSeverity:
            return kUserSpecifiedSeverity;
        case UserCallbackSetSeverity:
            return kUserCallbackSetSeverity;
        default:
            [NSException raise:@"UnknownSeverityReason"
                        format:@"Severity reason not supported"];
    }
}

+ (SeverityReasonType)severityReasonFromString:(NSString *)string {
    if ([kUnhandledException isEqualToString:string]) {
        return UnhandledException;
    } else if ([kSignal isEqualToString:string]) {
        return Signal;
    } else if ([kHandledError isEqualToString:string]) {
        return HandledError;
    } else if ([kHandledException isEqualToString:string]) {
        return HandledException;
    } else if ([kUserSpecifiedSeverity isEqualToString:string]) {
        return UserSpecifiedSeverity;
    } else if ([kUserCallbackSetSeverity isEqualToString:string]) {
        return UserCallbackSetSeverity;
    } else {
        [NSException raise:@"UnknownSeverityReason"
                    format:@"Severity reason not supported"];
        return UnhandledException;
    }
}

- (NSDictionary *)toJson {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    dict[kUnhandled] = @(self.unhandled);
    dict[kSeverityReasonType] = [BugsnagHandledState stringFromSeverityReason:self.severityReasonType];
    dict[kOriginalSeverity] = BSGFormatSeverity(self.originalSeverity);
    dict[kCurrentSeverity] = BSGFormatSeverity(self.currentSeverity);
    dict[kAttrKey] = self.attrKey;
    dict[kAttrValue] = self.attrValue;
    return dict;
}

@end

