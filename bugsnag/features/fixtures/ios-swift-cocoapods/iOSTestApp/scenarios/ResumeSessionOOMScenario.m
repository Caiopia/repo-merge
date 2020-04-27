#import "ResumeSessionOOMScenario.h"

@implementation ResumeSessionOOMScenario

- (void)startBugsnag {
    self.config.autoTrackSessions = NO;
    self.config.enabledErrorTypes = BSGErrorTypesCPP
        | BSGErrorTypesMach
        | BSGErrorTypesNSExceptions
        | BSGErrorTypesOOMs
        | BSGErrorTypesSignals;
    [super startBugsnag];
}

- (void)run {
    [Bugsnag startSession];
    // This test has determinism issues with ordering of payloads and batching of event payloads
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [Bugsnag notify:[NSException exceptionWithName:@"foo" reason:nil userInfo:nil]];
        [Bugsnag pauseSession];
        [Bugsnag resumeSession];
        kill(getpid(), SIGKILL);
    });
}

@end
