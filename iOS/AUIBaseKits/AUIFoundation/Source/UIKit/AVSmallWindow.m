//
//  AVSmallWindow.h
//  AUIFoundation
//
//  Created by Bingo on 2024/2/15.
//

#import "AVSmallWindow.h"
#import "UIView+AVHelper.h"

@interface AVSmallWindowViewController ()

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong, nullable) id<NSObject> targetHolder;


@end

@implementation AVSmallWindowViewController

- (instancetype)initWithTarget:(id<AVSmallWindowTargetProtocol>)target {
    self = [super init];
    if (self) {
        _target = target;
    }
    return self;
}

- (void)addGestureRecognizer:(UIWindow *)smallWindow {
    if (!self.panGestureRecognizer) {
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
    }
    [smallWindow addGestureRecognizer:self.panGestureRecognizer];
    
    if (!self.tapGestureRecognizer) {
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    }
    [smallWindow addGestureRecognizer:self.tapGestureRecognizer];
}


- (void)removeGestureRecognizer:(UIWindow *)smallWindow {
    if (self.panGestureRecognizer) {
        [smallWindow removeGestureRecognizer:self.panGestureRecognizer];
    }
    if (self.tapGestureRecognizer) {
        [smallWindow removeGestureRecognizer:self.tapGestureRecognizer];
    }
}

- (void)panGesture:(UIPanGestureRecognizer *)recognizer {
    if (!recognizer.view) {
        return;
    }
    CGPoint point = [recognizer translationInView:recognizer.view];
    CGPoint center = CGPointMake(recognizer.view.center.x + point.x, recognizer.view.center.y + point.y);
    recognizer.view.center = center;
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
    
    // 拖拽停止/取消/失败
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateFailed) {
        
        [self updateViewPosition:recognizer.view];
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer {
    [self.target onTapSmallWindow];
}

- (void)startFloating:(UIWindow *)smallWindow completed:(void(^)(UIWindow *))completed {
    self.targetHolder = [self.target targetHolder];
    [self.target onStartFloat:self];
    smallWindow.frame = [self.target targetFrame];
    if (completed) {
        completed(smallWindow);
    }
}

- (void)exitFloating:(UIWindow *)smallWindow needClose:(BOOL)needClose completed:(void(^)(UIWindow *))completed {
    [self.target onExitFloat:self needClose:needClose];
    self.targetHolder = nil;
    if (completed) {
        completed(smallWindow);
    }
}

- (void)updateViewPosition:(UIView *)view {
    UIEdgeInsets safeInsets = UIEdgeInsetsMake(AVSafeTop, 16, AVSafeBottom, 16);
    CGRect rect = UIScreen.mainScreen.bounds;
    CGRect frame = view.frame;
    
    if (CGRectGetMinX(frame) < safeInsets.left) {
        frame.origin.x = safeInsets.left;
    }
    
    if (CGRectGetMinY(frame) < safeInsets.top) {
        frame.origin.y = safeInsets.top;
    }
    
    if (CGRectGetMaxX(frame) >= CGRectGetMaxX(rect) - safeInsets.right) {
        frame.origin.x = CGRectGetMaxX(rect) - safeInsets.right - CGRectGetWidth(view.bounds);
    }
    
    if (CGRectGetMaxY(frame) >= CGRectGetMaxY(rect) - safeInsets.bottom) {
        frame.origin.y = CGRectGetMaxY(rect) - safeInsets.bottom - CGRectGetHeight(view.bounds);
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        view.frame = frame;
    } completion:^(BOOL finished) {
        ;
    }];
}

@end

@interface AVSmallWindow ()

@end

@implementation AVSmallWindow

static UIWindow *g_window = nil;

+ (BOOL)isShowing {
    return g_window != nil;
}

+ (BOOL)isShowing:(id<AVSmallWindowTargetProtocol>)target {
    if (g_window) {
        AVSmallWindowViewController *vc = (AVSmallWindowViewController *)g_window.rootViewController;
        if ([vc isKindOfClass:AVSmallWindowViewController.class]) {
            return vc.target == target;
        }
    }
    return NO;
}

+ (void)start:(id<AVSmallWindowTargetProtocol>)target {
    if (g_window) {
        return;
    }
    
    AVSmallWindowViewController *vc = [[AVSmallWindowViewController alloc] initWithTarget:target];
    
    UIWindow *win = nil;
    if (@available(iOS 13.0, *)) {
        __block UIWindowScene *activeScene = nil;
        [UIApplication.sharedApplication.connectedScenes enumerateObjectsUsingBlock:^(UIScene * _Nonnull obj, BOOL * _Nonnull stop) {
            if (obj.activationState == UISceneActivationStateForegroundActive && [obj isKindOfClass:UIWindowScene.class]) {
                activeScene = (UIWindowScene *)obj;
            }
        }];
        if (activeScene) {
            win = [[UIWindow alloc] initWithWindowScene:activeScene];
        }
    } 
    if (!win) {
        win = [UIWindow new];
    }
    win.layer.masksToBounds = YES;
    win.layer.borderWidth = 1;
    win.layer.borderColor = [UIColor.whiteColor colorWithAlphaComponent:0.25].CGColor;
    win.layer.cornerRadius = 4;
    win.windowLevel = UIWindowLevelAlert + 1;
    win.rootViewController = vc;
    win.hidden = NO;
    [vc addGestureRecognizer:win];
    [vc startFloating:win completed:nil];
    g_window = win;
}

+ (void)exit:(BOOL)needClose {
    if (g_window) {
        AVSmallWindowViewController *vc = (AVSmallWindowViewController *)g_window.rootViewController;
        if ([vc isKindOfClass:AVSmallWindowViewController.class]) {
            [vc removeGestureRecognizer:g_window];
            [vc exitFloating:g_window needClose:needClose completed:^(UIWindow *win) {
                g_window.rootViewController = nil;
                g_window.hidden = YES;
                g_window = nil;
            }];
        }
    }
}

@end
