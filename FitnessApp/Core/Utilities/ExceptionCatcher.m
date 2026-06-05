#import "ExceptionCatcher.h"

@implementation ExceptionCatcher

+ (BOOL)tryRun:(void (^)(void))block error:(NSError **)error {
    @try {
        block();
        return YES;
    } @catch (NSException *exception) {
        if (error) {
            NSDictionary *info = @{
                @"NSExceptionName": exception.name ?: @"Unknown",
                @"NSExceptionReason": exception.reason ?: @"",
                NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%@: %@",
                    exception.name ?: @"Error",
                    exception.reason ?: @"内部错误"]
            };
            *error = [NSError errorWithDomain:@"com.fitmind.exception"
                                         code:-9999
                                     userInfo:info];
        }
        return NO;
    }
}

@end
