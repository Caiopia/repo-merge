//
//  BSGJSONSerialization.m
//  Bugsnag
//
//  Created by Karl Stenerud on 03.09.20.
//  Copyright © 2020 Bugsnag Inc. All rights reserved.
//

#import "BSGJSONSerialization.h"
#import "BugsnagLogger.h"

@implementation BSGJSONSerialization

static NSError* wrapException(NSException* exception) {
    NSDictionary *userInfo = @{
        NSLocalizedDescriptionKey: exception.description,
        NSUnderlyingErrorKey: exception,
    };

    return [NSError errorWithDomain:@"BSGJSONSerializationErrorDomain" code:1 userInfo:userInfo];
}

+ (BOOL)isValidJSONObject:(id)obj {
    @try {
        return [NSJSONSerialization isValidJSONObject:obj];
    } @catch (NSException *exception) {
        return NO;
    }
}

+ (nullable NSData *)dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error {
    @try {
        return [NSJSONSerialization dataWithJSONObject:obj options:opt error:error];
    } @catch (NSException *exception) {
        if (error) {
            *error = wrapException(exception);
        }
        return nil;
    }
}

+ (nullable id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error {
    @try {
        return [NSJSONSerialization JSONObjectWithData:data options:opt error:error];
    } @catch (NSException *exception) {
        if (error) {
            *error = wrapException(exception);
        }
        return nil;
    }
}

+ (NSInteger)writeJSONObject:(id)obj toStream:(NSOutputStream *)stream options:(NSJSONWritingOptions)opt error:(NSError **)error {
    @try {
        return [NSJSONSerialization writeJSONObject:obj toStream:stream options:opt error:error];
    } @catch (NSException *exception) {
        if (error) {
            *error = wrapException(exception);
        }
        return 0;
    }
}

+ (nullable id)JSONObjectWithStream:(NSInputStream *)stream options:(NSJSONReadingOptions)opt error:(NSError **)error {
    @try {
        return [NSJSONSerialization JSONObjectWithStream:stream options:opt error:error];
    } @catch (NSException *exception) {
        if (error) {
            *error = wrapException(exception);
        }
        return nil;
    }
}

+ (BOOL)writeJSONObject:(id)JSONObject toFile:(NSString *)file options:(NSJSONWritingOptions)options error:(NSError **)errorPtr {
    if (![BSGJSONSerialization isValidJSONObject:JSONObject]) {
        if (errorPtr) {
            *errorPtr = [NSError errorWithDomain:@"BSGJSONSerializationErrorDomain" code:0 userInfo:@{
                NSLocalizedDescriptionKey: @"Not a valid JSON object"}];
        }
        return NO;
    }
    NSData *data = [BSGJSONSerialization dataWithJSONObject:JSONObject options:options error:errorPtr];
    return [data writeToFile:file options:NSDataWritingAtomic error:errorPtr];
}

@end
