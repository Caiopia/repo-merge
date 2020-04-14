#import "SessionOOMScenario.h"
#import <signal.h>

@implementation SessionOOMScenario

- (void)startBugsnag {
    self.config.autoTrackSessions = NO;
    self.config.reportOOMs = YES;
    [super startBugsnag];
}

- (void)run {
    [Bugsnag startSession];
    [Bugsnag notify:[NSException exceptionWithName:@"foo" reason:nil userInfo:nil]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        kill(getpid(), SIGKILL);
    });
}

@end
