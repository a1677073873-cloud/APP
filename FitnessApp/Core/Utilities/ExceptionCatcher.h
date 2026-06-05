#import <Foundation/Foundation.h>

@interface ExceptionCatcher: NSObject

/// 执行 block，捕获所有 ObjC 异常。返回 YES 表示无异常，NO 表示有异常（error 会被设置）
+ (BOOL)tryRun:(void (^_Nonnull)(void))block error:(NSError *_Nullable *_Nullable)error;

@end
