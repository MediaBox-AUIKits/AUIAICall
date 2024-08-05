//
//  AVGlobalTimer.m
//  AUIFoundation
//
//  Created by coder.pi on 2022/6/15.
//

#import "AVGlobalTimer.h"

@interface __AVTimerInfo : NSObject
@property (nonatomic, readonly) NSUInteger timerId;
@property (nonatomic, readonly) NSTimeInterval interval;
@property (nonatomic, weak) id<AVTimerDelegate> delegate;
@property (nonatomic, readonly) NSTimeInterval curStep;
@property (nonatomic, assign) BOOL isInvalid;
+ (__AVTimerInfo *)InfoWithId:(NSUInteger)timerId interval:(NSTimeInterval)interval;
- (BOOL)step:(NSTimeInterval)step;
@end

@implementation __AVTimerInfo
+ (__AVTimerInfo *)InfoWithId:(NSUInteger)timerId interval:(NSTimeInterval)interval {
    return [[__AVTimerInfo alloc] initWithId:timerId interval:interval];
}
- (instancetype)initWithId:(NSUInteger)timerId interval:(NSTimeInterval)interval {
    self = [super init];
    if (self) {
        _timerId = timerId;
        _interval = interval;
        _curStep = 0;
    }
    return self;
}

- (BOOL)step:(NSTimeInterval)step {
    if (_isInvalid) {
        return NO;
    }
    
    _curStep += step;
    if (_curStep < _interval) {
        return NO;
    }
    
    NSTimeInterval curStep = _curStep;
    if ([_delegate respondsToSelector:@selector(onAVTimerStepWithDuration:settingInterval:)]) {
        [_delegate onAVTimerStepWithDuration:curStep settingInterval:_interval];
    }
    _curStep = 0;
    return YES;
}

@end

@interface __DisplayLinkObserver : NSObject
@property (nonatomic, weak) AVGlobalTimer *weakTimer;
- (void) onDisplayLinkCallback:(CADisplayLink *)displayLink;
@end

@interface AVGlobalTimer ()
@property (nonatomic, assign) NSUInteger currentTimerId;
@property (nonatomic, strong) NSMutableArray<__AVTimerInfo *> *timerInfos;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) NSMutableArray<__AVTimerInfo *> *needRemoveOutOfFire;
@property (nonatomic, strong) __DisplayLinkObserver *displayLinkObserver;
@end

@implementation AVGlobalTimer

+ (AVGlobalTimer *) Shared {
    static dispatch_once_t onceToken;
    static AVGlobalTimer *s_shared;
    dispatch_once(&onceToken, ^{
        s_shared = [AVGlobalTimer new];
    });
    return s_shared;
}

- (void)dealloc {
    [_displayLink invalidate];
    [_displayLink removeFromRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentTimerId = 1;
        _timerInfos = @[].mutableCopy;
        _displayLinkObserver = [__DisplayLinkObserver new];
        _displayLinkObserver.weakTimer = self;
        _displayLink = [CADisplayLink displayLinkWithTarget:_displayLinkObserver
                                                   selector:@selector(onDisplayLinkCallback:)];
        [_displayLink addToRunLoop:NSRunLoop.mainRunLoop forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (NSUInteger)startTimer:(NSTimeInterval)interval withTarget:(id<AVTimerDelegate>)target {
    __AVTimerInfo *info = [__AVTimerInfo InfoWithId:++_currentTimerId interval:interval];
    info.delegate = target;
    [_timerInfos addObject:info];
    return info.timerId;
}

- (BOOL)stopTimerWithTarget:(id<AVTimerDelegate>)target {
    NSMutableArray<__AVTimerInfo *> *needRemoves = @[].mutableCopy;
    for (__AVTimerInfo *info in _timerInfos) {
        if (info.delegate == target) {
            info.isInvalid = YES;
            [needRemoves addObject:info];
        }
    }
    
    if (_needRemoveOutOfFire) {
        [_needRemoveOutOfFire addObjectsFromArray:needRemoves];
    }
    else {
        [_timerInfos removeObjectsInArray:needRemoves];
    }
    return needRemoves.count > 0;
}

- (BOOL)stopTimerWithId:(NSUInteger)timerId {
    for (__AVTimerInfo *info in _timerInfos) {
        if (info.timerId == timerId) {
            info.isInvalid = YES;
            if (_needRemoveOutOfFire) {
                [_needRemoveOutOfFire addObject:info];
            }
            else {
                [_timerInfos removeObject:info];
            }
            return YES;
        }
    }
    return NO;
}

- (void)onStep:(CADisplayLink *)displayLink {
    NSTimeInterval duration = displayLink.duration;
    _needRemoveOutOfFire = @[].mutableCopy;
    for (__AVTimerInfo *info in _timerInfos) {
        if (info.delegate == nil) {
            [_needRemoveOutOfFire addObject:info];
            continue;
        }
        [info step:duration];
    }
    [_timerInfos removeObjectsInArray:_needRemoveOutOfFire];
    _needRemoveOutOfFire = nil;
}

@end

@implementation __DisplayLinkObserver
- (void) onDisplayLinkCallback:(CADisplayLink *)displayLink {
    [_weakTimer onStep:displayLink];
}
@end
