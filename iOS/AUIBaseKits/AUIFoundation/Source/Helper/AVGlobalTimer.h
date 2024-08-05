//
//  AVGlobalTimer.h
//  AUIFoundation
//
//  Created by coder.pi on 2022/6/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AVTimerDelegate <NSObject>
- (void)onAVTimerStepWithDuration:(NSTimeInterval)duration settingInterval:(NSTimeInterval)interval;
@end

@interface AVGlobalTimer : NSObject
+ (AVGlobalTimer *) Shared;
- (NSUInteger)startTimer:(NSTimeInterval)interval withTarget:(id<AVTimerDelegate>)target;
- (BOOL)stopTimerWithTarget:(id<AVTimerDelegate>)target;
- (BOOL)stopTimerWithId:(NSUInteger)timerId;
@end

NS_ASSUME_NONNULL_END
