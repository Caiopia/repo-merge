//
//  BugsnagCrashReport.m
//  Bugsnag
//
//  Created by Simon Maynard on 11/26/14.
//
//

#if TARGET_OS_MAC || TARGET_OS_TV
#elif TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#include <sys/utsname.h>
#endif

#import "BSGSerialization.h"
#import "Bugsnag.h"
#import "BugsnagCollections.h"
#import "BugsnagHandledState.h"
#import "BugsnagLogger.h"
#import "BugsnagKeys.h"
#import "BugsnagKSCrashSysInfoParser.h"
#import "BugsnagSession.h"
#import "BSG_RFC3339DateTool.h"

NSMutableDictionary *BSGFormatFrame(NSDictionary *frame,
                                    NSArray *binaryImages) {
    NSMutableDictionary *formatted = [NSMutableDictionary dictionary];

    unsigned long instructionAddress =
        [frame[@"instruction_addr"] unsignedLongValue];
    unsigned long symbolAddress = [frame[@"symbol_addr"] unsignedLongValue];
    unsigned long imageAddress = [frame[@"object_addr"] unsignedLongValue];

    BSGDictSetSafeObject(
        formatted, [NSString stringWithFormat:BSGKeyFrameAddrFormat, instructionAddress],
        @"frameAddress");
    BSGDictSetSafeObject(formatted,
                         [NSString stringWithFormat:BSGKeyFrameAddrFormat, symbolAddress],
                         BSGKeySymbolAddr);
    BSGDictSetSafeObject(formatted,
                         [NSString stringWithFormat:BSGKeyFrameAddrFormat, imageAddress],
                         BSGKeyMachoLoadAddr);
    BSGDictInsertIfNotNil(formatted, frame[BSGKeyIsPC], BSGKeyIsPC);
    BSGDictInsertIfNotNil(formatted, frame[BSGKeyIsLR], BSGKeyIsLR);

    NSString *file = frame[@"object_name"];
    NSString *method = frame[@"symbol_name"];

    BSGDictInsertIfNotNil(formatted, file, BSGKeyMachoFile);
    BSGDictInsertIfNotNil(formatted, method, @"method");

    for (NSDictionary *image in binaryImages) {
        if ([(NSNumber *)image[@"image_addr"] unsignedLongValue] ==
            imageAddress) {
            unsigned long imageSlide =
                [image[@"image_vmaddr"] unsignedLongValue];

            BSGDictInsertIfNotNil(formatted, image[@"uuid"], BSGKeyMachoUUID);
            BSGDictInsertIfNotNil(formatted, image[BSGKeyName], BSGKeyMachoFile);
            BSGDictSetSafeObject(
                formatted, [NSString stringWithFormat:BSGKeyFrameAddrFormat, imageSlide],
                BSGKeyMachoVMAddress);

            return formatted;
        }
    }

    return nil;
}

NSString *_Nonnull BSGParseErrorClass(NSDictionary *error,
                                      NSString *errorType,
                                      NSString *fallbackValue) {
    NSString *errorClass;

    if ([errorType isEqualToString:BSGKeyCppException]) {
        errorClass = error[BSGKeyCppException][BSGKeyName];
    } else if ([errorType isEqualToString:BSGKeyMach]) {
        errorClass = error[BSGKeyMach][BSGKeyExceptionName];
    } else if ([errorType isEqualToString:BSGKeySignal]) {
        errorClass = error[BSGKeySignal][BSGKeyName];
    } else if ([errorType isEqualToString:@"nsexception"]) {
        errorClass = error[@"nsexception"][BSGKeyName];
    } else if ([errorType isEqualToString:BSGKeyUser]) {
        errorClass = error[@"user_reported"][BSGKeyName];
    }

    if (!errorClass) { // use a default value
        errorClass = fallbackValue.length > 0 ? fallbackValue : @"Exception";
    }
    return errorClass;
}

NSString *BSGParseErrorMessage(NSDictionary *report, NSDictionary *error,
                               NSString *errorType) {
    if ([errorType isEqualToString:BSGKeyMach] || error[BSGKeyReason] == nil) {
        NSString *diagnosis = [report valueForKeyPath:@"crash.diagnosis"];
        if (diagnosis && ![diagnosis hasPrefix:@"No diagnosis"]) {
            return [[diagnosis componentsSeparatedByString:@"\n"] firstObject];
        }
    }
    return error[BSGKeyReason] ?: @"";
}

id BSGLoadConfigValue(NSDictionary *report, NSString *valueName) {
    NSString *keypath = [NSString stringWithFormat:@"user.config.%@", valueName];
    NSString *fallbackKeypath = [NSString stringWithFormat:@"user.config.config.%@", valueName];

    return [report valueForKeyPath:keypath]
    ?: [report valueForKeyPath:fallbackKeypath]; // some custom values are nested
}

NSString *BSGParseContext(NSDictionary *report, NSDictionary *metaData) {
    id context = [report valueForKeyPath:@"user.overrides.context"];
    if ([context isKindOfClass:[NSString class]])
        return context;
    context = metaData[BSGKeyContext];
    if ([context isKindOfClass:[NSString class]])
        return context;
    context = BSGLoadConfigValue(report, @"context");
    if ([context isKindOfClass:[NSString class]])
        return context;
    return nil;
}

NSString *BSGParseGroupingHash(NSDictionary *report, NSDictionary *metaData) {
    id groupingHash = [report valueForKeyPath:@"user.overrides.groupingHash"];
    if (groupingHash)
        return groupingHash;
    groupingHash = metaData[BSGKeyGroupingHash];
    if ([groupingHash isKindOfClass:[NSString class]])
        return groupingHash;
    return nil;
}

NSArray *BSGParseBreadcrumbs(NSDictionary *report) {
    return [report valueForKeyPath:@"user.overrides.breadcrumbs"]
               ?: [report valueForKeyPath:@"user.state.crash.breadcrumbs"];
}

NSString *BSGParseReleaseStage(NSDictionary *report) {
    return [report valueForKeyPath:@"user.overrides.releaseStage"]
               ?: BSGLoadConfigValue(report, @"releaseStage");
}

BSGSeverity BSGParseSeverity(NSString *severity) {
    if ([severity isEqualToString:BSGKeyInfo])
        return BSGSeverityInfo;
    else if ([severity isEqualToString:BSGKeyWarning])
        return BSGSeverityWarning;
    return BSGSeverityError;
}

NSString *BSGFormatSeverity(BSGSeverity severity) {
    switch (severity) {
    case BSGSeverityInfo:
        return BSGKeyInfo;
    case BSGSeverityError:
        return BSGKeyError;
    case BSGSeverityWarning:
        return BSGKeyWarning;
    }
}

NSDictionary *BSGParseCustomException(NSDictionary *report,
                                      NSString *errorClass, NSString *message) {
    id frames =
        [report valueForKeyPath:@"user.overrides.customStacktraceFrames"];
    id type = [report valueForKeyPath:@"user.overrides.customStacktraceType"];
    if (type && frames) {
        return @{
            BSGKeyStacktrace : frames,
            BSGKeyType : type,
            BSGKeyErrorClass : errorClass,
            BSGKeyMessage : message
        };
    }

    return nil;
}

static NSString *const DEFAULT_EXCEPTION_TYPE = @"cocoa";

@interface NSDictionary (BSGKSMerge)
- (NSDictionary *)BSG_mergedInto:(NSDictionary *)dest;
@end

@interface RegisterErrorData : NSObject
@property (nonatomic, strong) NSString *errorClass;
@property (nonatomic, strong) NSString *errorMessage;
+ (instancetype)errorDataFromThreads:(NSArray *)threads;
- (instancetype)initWithClass:(NSString *_Nonnull)errorClass message:(NSString *_Nonnull)errorMessage NS_DESIGNATED_INITIALIZER;
@end

@interface FallbackReportData : NSObject
@property (nonatomic, strong) NSString *errorClass;
@property (nonatomic, getter=isUnhandled) BOOL unhandled;
@property (nonatomic) BSGSeverity severity;
- (instancetype)initWithMetadata:(NSString *)metadata;
@end

@interface BugsnagCrashReport ()

/**
 *  The type of the error, such as `mach` or `user`
 */
@property(nonatomic, readwrite, copy, nullable) NSString *errorType;
/**
 *  The UUID of the dSYM file
 */
@property(nonatomic, readonly, copy, nullable) NSString *dsymUUID;
/**
 *  A unique hash identifying this device for the application or vendor
 */
@property(nonatomic, readonly, copy, nullable) NSString *deviceAppHash;
/**
 *  Binary images used to identify application symbols
 */
@property(nonatomic, readonly, copy, nullable) NSArray *binaryImages;
/**
 *  Thread information captured at the time of the error
 */
@property(nonatomic, readonly, copy, nullable) NSArray *threads;
/**
 *  User-provided exception metadata
 */
@property(nonatomic, readwrite, copy, nullable) NSDictionary *customException;
@property(nonatomic, strong) BugsnagSession *session;

@property (nonatomic, readwrite, getter=isIncomplete) BOOL incomplete;
@end

@implementation BugsnagCrashReport

- (instancetype)initWithKSReport:(NSDictionary *)report {
    return [self initWithKSReport:report fileMetadata:@""];
}

- (instancetype)initWithKSReport:(NSDictionary *)report
                    fileMetadata:(NSString *)metadata {
    if (self = [super init]) {
        _error = [report valueForKeyPath:@"crash.error"];
        _errorType = _error[BSGKeyType];
        if ([[report valueForKeyPath:@"user.state.didOOM"] boolValue]) {
            _errorClass = BSGParseErrorClass(_error, _errorType, nil);
            _errorMessage = BSGParseErrorMessage(report, _error, _errorType);
            _breadcrumbs = [report valueForKeyPath:@"user.state.oom.breadcrumbs"];
            _app = [report valueForKeyPath:@"user.state.oom.app"];
            _device = [report valueForKeyPath:@"user.state.oom.device"];
            _releaseStage = [report valueForKeyPath:@"user.state.oom.app.releaseStage"];
            _handledState = [BugsnagHandledState handledStateWithSeverityReason:LikelyOutOfMemory];
            _deviceAppHash = [report valueForKeyPath:@"user.state.oom.device.id"];
            _metaData = [NSMutableDictionary new];
            NSDictionary *sessionData = [report valueForKeyPath:@"user.state.oom.session"];
            if (sessionData) {
                _session = [[BugsnagSession alloc] initWithDictionary:sessionData];
                _session.unhandledCount += 1; // include own event
                if (_session.user) {
                    _metaData = @{@"user": [_session.user toJson]};
                }
            }
        } else {
            FallbackReportData *fallback = [[FallbackReportData alloc] initWithMetadata:metadata];
            _notifyReleaseStages = BSGLoadConfigValue(report, @"notifyReleaseStages");
            _releaseStage = BSGParseReleaseStage(report);
            _incomplete = report.count == 0;
            _threads = [report valueForKeyPath:@"crash.threads"];
            RegisterErrorData *data = [RegisterErrorData errorDataFromThreads:_threads];
            if (data) {
                _errorClass = data.errorClass ?: fallback.errorClass;
                _errorMessage = data.errorMessage;
            } else {
                _errorClass = BSGParseErrorClass(_error, _errorType, fallback.errorClass);
                _errorMessage = BSGParseErrorMessage(report, _error, _errorType);
            }
            _binaryImages = report[@"binary_images"];
            _breadcrumbs = BSGParseBreadcrumbs(report);
            _dsymUUID = [report valueForKeyPath:@"system.app_uuid"];
            _deviceAppHash = [report valueForKeyPath:@"system.device_app_hash"];
            _metaData =
                [report valueForKeyPath:@"user.metaData"] ?: [NSDictionary new];
            _context = BSGParseContext(report, _metaData);
            _deviceState = BSGParseDeviceState(report);
            _device = BSGParseDevice(report);
            _app = BSGParseApp(report);
            _appState = BSGParseAppState(report[BSGKeySystem],
                                         BSGLoadConfigValue(report, @"appVersion"),
                                         _releaseStage, // Already loaded from config
                                         BSGLoadConfigValue(report, @"codeBundleId"));
            _groupingHash = BSGParseGroupingHash(report, _metaData);
            _overrides = [report valueForKeyPath:@"user.overrides"];
            _customException = BSGParseCustomException(report, [_errorClass copy],
                                                       [_errorMessage copy]);

            NSDictionary *recordedState =
                [report valueForKeyPath:@"user.handledState"];

            if (recordedState) {
                _handledState =
                    [[BugsnagHandledState alloc] initWithDictionary:recordedState];

                // only makes sense to use serialised value for handled exceptions
                _depth = [[report valueForKeyPath:@"user.depth"]
                        unsignedIntegerValue];
            } else if (_errorType != nil) { // the event was unhandled.
                BOOL isSignal = [BSGKeySignal isEqualToString:_errorType];
                SeverityReasonType severityReason =
                    isSignal ? Signal : UnhandledException;
                _handledState = [BugsnagHandledState
                    handledStateWithSeverityReason:severityReason
                                          severity:BSGSeverityError
                                         attrValue:_errorClass];
                _depth = 0;
            } else { // Incomplete report
                SeverityReasonType severityReason = [fallback isUnhandled] ? UnhandledException : HandledError;
                _handledState = [BugsnagHandledState handledStateWithSeverityReason:severityReason
                                                                           severity:fallback.severity
                                                                          attrValue:nil];
            }
            _severity = _handledState.currentSeverity;

            if (report[@"user"][@"id"]) {
                _session = [[BugsnagSession alloc] initWithDictionary:report[@"user"]];
            }
        }
    }
    return self;
}

- (instancetype _Nonnull)
initWithErrorName:(NSString *_Nonnull)name
     errorMessage:(NSString *_Nonnull)message
    configuration:(BugsnagConfiguration *_Nonnull)config
         metaData:(NSDictionary *_Nonnull)metaData
     handledState:(BugsnagHandledState *_Nonnull)handledState
          session:(BugsnagSession *_Nullable)session {
    if (self = [super init]) {
        _errorClass = name;
        _errorMessage = message;
        _metaData = metaData ?: [NSDictionary new];
        _releaseStage = config.releaseStage;
        _notifyReleaseStages = config.notifyReleaseStages;
        _context = BSGParseContext(nil, metaData);
        _breadcrumbs = [config.breadcrumbs arrayValue];
        _overrides = [NSDictionary new];

        _handledState = handledState;
        _severity = handledState.currentSeverity;
        _session = session;
    }
    return self;
}

@synthesize metaData = _metaData;

- (NSDictionary *)metaData {
    @synchronized (self) {
        return _metaData;
    }
}

- (void)setMetaData:(NSDictionary *)metaData {
    @synchronized (self) {
        _metaData = BSGSanitizeDict(metaData);
    }
}

- (void)addMetadata:(NSDictionary *_Nonnull)tabData
      toTabWithName:(NSString *_Nonnull)tabName {
    NSDictionary *cleanedData = BSGSanitizeDict(tabData);
    if ([cleanedData count] == 0) {
        bsg_log_err(@"Failed to add metadata: Values not convertible to JSON");
        return;
    }
    NSMutableDictionary *allMetadata = [self.metaData mutableCopy];
    NSMutableDictionary *allTabData =
        allMetadata[tabName] ?: [NSMutableDictionary new];
    allMetadata[tabName] = [cleanedData BSG_mergedInto:allTabData];
    self.metaData = allMetadata;
}

- (void)addAttribute:(NSString *)attributeName
           withValue:(id)value
       toTabWithName:(NSString *)tabName {
    NSMutableDictionary *allMetadata = [self.metaData mutableCopy];
    NSMutableDictionary *allTabData =
        [allMetadata[tabName] mutableCopy] ?: [NSMutableDictionary new];
    if (value) {
        id cleanedValue = BSGSanitizeObject(value);
        if (!cleanedValue) {
            bsg_log_err(@"Failed to add metadata: Value of type %@ is not "
                        @"convertible to JSON",
                        [value class]);
            return;
        }
        allTabData[attributeName] = cleanedValue;
    } else {
        [allTabData removeObjectForKey:attributeName];
    }
    allMetadata[tabName] = allTabData;
    self.metaData = allMetadata;
}

- (BOOL)shouldBeSent {
    return [self.notifyReleaseStages containsObject:self.releaseStage] ||
           (self.notifyReleaseStages.count == 0 &&
            [[Bugsnag configuration] shouldSendReports]);
}

@synthesize context = _context;

- (NSString *)context {
    @synchronized (self) {
        return _context;
    }
}

- (void)setContext:(NSString *)context {
    [self setOverrideProperty:BSGKeyContext value:context];
    @synchronized (self) {
        _context = context;
    }
}

@synthesize groupingHash = _groupingHash;

- (NSString *)groupingHash {
    @synchronized (self) {
        return _groupingHash;
    }
}

- (void)setGroupingHash:(NSString *)groupingHash {
    [self setOverrideProperty:BSGKeyGroupingHash value:groupingHash];
    @synchronized (self) {
        _groupingHash = groupingHash;
    }
}

@synthesize breadcrumbs = _breadcrumbs;

- (NSArray *)breadcrumbs {
    @synchronized (self) {
        return _breadcrumbs;
    }
}

- (void)setBreadcrumbs:(NSArray *)breadcrumbs {
    [self setOverrideProperty:BSGKeyBreadcrumbs value:breadcrumbs];
    @synchronized (self) {
        _breadcrumbs = breadcrumbs;
    }
}

@synthesize releaseStage = _releaseStage;

- (NSString *)releaseStage {
    @synchronized (self) {
        return _releaseStage;
    }
}

- (void)setReleaseStage:(NSString *)releaseStage {
    [self setOverrideProperty:BSGKeyReleaseStage value:releaseStage];
    @synchronized (self) {
        _releaseStage = releaseStage;
    }
}

- (void)attachCustomStacktrace:(NSArray *)frames withType:(NSString *)type {
    [self setOverrideProperty:@"customStacktraceFrames" value:frames];
    [self setOverrideProperty:@"customStacktraceType" value:type];
}

@synthesize severity = _severity;

- (BSGSeverity)severity {
    @synchronized (self) {
        return _severity;
    }
}

- (void)setSeverity:(BSGSeverity)severity {
    @synchronized (self) {
        _severity = severity;
        _handledState.currentSeverity = severity;
    }
}

- (void)setOverrideProperty:(NSString *)key value:(id)value {
    @synchronized (self) {
        NSMutableDictionary *metadata = [self.overrides mutableCopy];
        if (value) {
            metadata[key] = value;
        } else {
            [metadata removeObjectForKey:key];
        }
        _overrides = metadata;
    }
    
}

- (NSDictionary *)serializableValueWithTopLevelData:
    (NSMutableDictionary *)data {
    return [self toJson];
}

- (NSDictionary *)toJson {
    NSMutableDictionary *event = [NSMutableDictionary dictionary];
    NSMutableDictionary *metaData = [[self metaData] mutableCopy];

    if (self.customException) {
        BSGDictSetSafeObject(event, @[ self.customException ], BSGKeyExceptions);
        BSGDictSetSafeObject(event, [self serializeThreadsWithException:nil],
                             BSGKeyThreads);
    } else {
        NSMutableDictionary *exception = [NSMutableDictionary dictionary];
        BSGDictSetSafeObject(exception, [self errorClass], BSGKeyErrorClass);
        BSGDictInsertIfNotNil(exception, [self errorMessage], BSGKeyMessage);
        BSGDictInsertIfNotNil(exception, DEFAULT_EXCEPTION_TYPE, BSGKeyType);
        BSGDictSetSafeObject(event, @[ exception ], BSGKeyExceptions);

        BSGDictSetSafeObject(
            event, [self serializeThreadsWithException:exception], BSGKeyThreads);
    }
    // Build Event
    BSGDictSetSafeObject(event, BSGFormatSeverity(self.severity), BSGKeySeverity);
    BSGDictSetSafeObject(event, [self breadcrumbs], BSGKeyBreadcrumbs);
    BSGDictSetSafeObject(event, metaData, BSGKeyMetaData);

    if ([self isIncomplete]) {
        BSGDictSetSafeObject(event, @YES, BSGKeyIncomplete);
    }

    NSDictionary *device = BSGDictMerge(self.device, self.deviceState);
    BSGDictSetSafeObject(event, device, BSGKeyDevice);
    
    NSMutableDictionary *appObj = [NSMutableDictionary new];
    [appObj addEntriesFromDictionary:self.app];
    
    for (NSString *key in self.appState) {
        BSGDictInsertIfNotNil(appObj, self.appState[key], key);
    }
    
    if (self.dsymUUID) {
        BSGDictInsertIfNotNil(appObj, @[self.dsymUUID], @"dsymUUIDs");
    }
    
    BSGDictSetSafeObject(event, appObj, BSGKeyApp);
    
    BSGDictSetSafeObject(event, [self context], BSGKeyContext);
    BSGDictInsertIfNotNil(event, self.groupingHash, BSGKeyGroupingHash);
    

    BSGDictSetSafeObject(event, @(self.handledState.unhandled), BSGKeyUnhandled);

    // serialize handled/unhandled into payload
    NSMutableDictionary *severityReason = [NSMutableDictionary new];
    NSString *reasonType = [BugsnagHandledState
        stringFromSeverityReason:self.handledState.calculateSeverityReasonType];
    severityReason[BSGKeyType] = reasonType;

    if (self.handledState.attrKey && self.handledState.attrValue) {
        severityReason[BSGKeyAttributes] =
            @{self.handledState.attrKey : self.handledState.attrValue};
    }

    BSGDictSetSafeObject(event, severityReason, BSGKeySeverityReason);

    //  Inserted into `context` property
    [metaData removeObjectForKey:BSGKeyContext];
    // Build metadata
    BSGDictSetSafeObject(metaData, [self error], BSGKeyError);

    // Make user mutable and set the id if the user hasn't already
    NSMutableDictionary *user = [metaData[BSGKeyUser] mutableCopy];
    if (user == nil) {
        user = [NSMutableDictionary dictionary];
    }
    BSGDictInsertIfNotNil(event, user, BSGKeyUser);

    if (!user[BSGKeyId] && self.device[BSGKeyId]) { // if device id is null, don't set user id to default
        BSGDictSetSafeObject(user, [self deviceAppHash], BSGKeyId);
    }

    if (self.session) {
        BSGDictSetSafeObject(event, [self generateSessionDict], BSGKeySession);
    }
    return event;
}

- (NSDictionary *)generateSessionDict {
    NSDictionary *events = @{
            @"handled": @(self.session.handledCount),
            @"unhandled": @(self.session.unhandledCount)
    };

    NSDictionary *sessionJson = @{
            BSGKeyId: self.session.sessionId,
            @"startedAt": [BSG_RFC3339DateTool stringFromDate:self.session.startedAt],
            @"events": events
    };
    return sessionJson;
}

// Build all stacktraces for threads and the error
- (NSArray *)serializeThreadsWithException:(NSMutableDictionary *)exception {
    NSMutableArray *bugsnagThreads = [NSMutableArray array];

    for (NSDictionary *thread in self.threads) {
        NSArray *backtrace = thread[@"backtrace"][@"contents"];
        BOOL stackOverflow = [thread[@"stack"][@"overflow"] boolValue];
        BOOL isReportingThread = [thread[@"crashed"] boolValue];
        
        if (isReportingThread) {
            NSUInteger seen = 0;
            NSMutableArray *stacktrace = [NSMutableArray array];

            for (NSDictionary *frame in backtrace) {
                NSMutableDictionary *mutableFrame = [frame mutableCopy];
                if (seen++ >= [self depth]) {
                    // Mark the frame so we know where it came from
                    if (seen == 1 && !stackOverflow) {
                        BSGDictSetSafeObject(mutableFrame, @YES, BSGKeyIsPC);
                    }
                    if (seen == 2 && !stackOverflow &&
                        [@[ BSGKeySignal, BSGKeyMach ]
                            containsObject:[self errorType]]) {
                        BSGDictSetSafeObject(mutableFrame, @YES, BSGKeyIsLR);
                    }
                    BSGArrayInsertIfNotNil(
                        stacktrace,
                        BSGFormatFrame(mutableFrame, [self binaryImages]));
                }
            }
            BSGDictSetSafeObject(exception, stacktrace, BSGKeyStacktrace);
        }
        [self serialiseThread:bugsnagThreads thread:thread backtrace:backtrace reportingThread:isReportingThread];
    }
    return bugsnagThreads;
}

- (void)serialiseThread:(NSMutableArray *)bugsnagThreads
                 thread:(NSDictionary *)thread
              backtrace:(NSArray *)backtrace
          reportingThread:(BOOL)isReportingThread {
    NSMutableArray *threadStack = [NSMutableArray array];

    for (NSDictionary *frame in backtrace) {
                BSGArrayInsertIfNotNil(
                    threadStack, BSGFormatFrame(frame, [self binaryImages]));
            }

    NSMutableDictionary *threadDict = [NSMutableDictionary dictionary];
    BSGDictSetSafeObject(threadDict, thread[@"index"], BSGKeyId);
    BSGDictSetSafeObject(threadDict, threadStack, BSGKeyStacktrace);
    BSGDictSetSafeObject(threadDict, DEFAULT_EXCEPTION_TYPE, BSGKeyType);

    if (isReportingThread) {
        BSGDictSetSafeObject(threadDict, @YES, @"errorReportingThread");
    }

    BSGArrayAddSafeObject(bugsnagThreads, threadDict);
}

- (NSString *_Nullable)enhancedErrorMessageForThread:(NSDictionary *_Nullable)thread {
    return [self errorMessage];
}

@end

@implementation FallbackReportData

- (instancetype)initWithMetadata:(NSString *)metadata {
    if (self = [super init]) {
        NSString *separator = @"-";
        NSString *location = metadata;
        NSRange range = [location rangeOfString:separator options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            _errorClass = [location substringFromIndex:range.location + 1];
            location = [location substringToIndex:range.location];
        }
        range = [location rangeOfString:separator options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            NSString *value = [location substringFromIndex:range.location + 1];
            _unhandled = ![value isEqualToString:@"h"];
            location = [location substringToIndex:range.location + 1];
        } else {
            _unhandled = YES;
        }
        range = [location rangeOfString:separator options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            NSString *value = [location substringFromIndex:range.location];
            if ([value isEqualToString:@"w"]) {
                _severity = BSGSeverityWarning;
            } else if ([value isEqualToString:@"i"]) {
                _severity = BSGSeverityInfo;
            } else {
                _severity = BSGSeverityError;
            }
        }
    }
    return self;
}

@end

@implementation RegisterErrorData
+ (instancetype)errorDataFromThreads:(NSArray *)threads {
    for (NSDictionary *thread in threads) {
        if (![thread[@"crashed"] boolValue]) {
            continue;
        }
        NSDictionary *notableAddresses = thread[@"notable_addresses"];
        NSMutableArray *interestingValues = [NSMutableArray new];
        NSString *reservedWord = nil;

        for (NSString *key in notableAddresses) {
            NSDictionary *data = notableAddresses[key];
            if (![@"string" isEqualToString:data[BSGKeyType]]) {
                continue;
            }
            NSString *contentValue = data[@"value"];

#pragma clang diagnostic push
#pragma ide diagnostic ignored "OCDFAInspection"
            if (contentValue == nil || ![contentValue isKindOfClass:[NSString class]]) {
                continue;
            }
#pragma clang diagnostic pop

            if ([self isReservedWord:contentValue]) {
                reservedWord = contentValue;
            } else if ([[contentValue componentsSeparatedByString:@"/"] count] <= 2) {
                // must be a string that isn't a reserved word and isn't a filepath
                [interestingValues addObject:contentValue];
            }
        }

        [interestingValues sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

        NSString *message = [interestingValues componentsJoinedByString:@" | "];
        return [[RegisterErrorData alloc] initWithClass:reservedWord
                                                message:message];
    }
    return nil;
}

/**
 * Determines whether a string is a "reserved word" that identifies it as a known value.
 *
 * For fatalError, preconditionFailure, and assertionFailure, "fatal error" will be in one of the registers.
 *
 * For assert, "assertion failed" will be in one of the registers.
 */
+ (BOOL)isReservedWord:(NSString *)contentValue {
    return [@"assertion failed" caseInsensitiveCompare:contentValue] == NSOrderedSame
    || [@"fatal error" caseInsensitiveCompare:contentValue] == NSOrderedSame
    || [@"precondition failed" caseInsensitiveCompare:contentValue] == NSOrderedSame;
}

- (instancetype)init {
    return [self initWithClass:@"Unknown" message:@"<unset>"];
}

- (instancetype)initWithClass:(NSString *)errorClass message:(NSString *)errorMessage {
    if (errorClass.length == 0) {
        return nil;
    }
    if (self = [super init]) {
        _errorClass = errorClass;
        _errorMessage = errorMessage;
    }
    return self;
}
@end
