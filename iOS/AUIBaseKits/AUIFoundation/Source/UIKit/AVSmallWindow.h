//
//  AVSmallWindow.h
//  AUIFoundation
//
//  Created by Bingo on 2024/2/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AVSmallWindowViewController;

@protocol AVSmallWindowTargetProtocol <NSObject>

- (nullable id<NSObject>)targetHolder;
- (CGRect)targetFrame;
- (void)onTapSmallWindow;
- (void)onStartFloat:(AVSmallWindowViewController *)vc;
- (void)onExitFloat:(AVSmallWindowViewController *)vc needClose:(BOOL)needClose;

@end

@interface AVSmallWindowViewController : UIViewController

- (instancetype)initWithTarget:(id<AVSmallWindowTargetProtocol>)target;

@property (nonatomic, strong, readonly) id<AVSmallWindowTargetProtocol> target;

@end

@interface AVSmallWindow : UIView

+ (BOOL)isShowing;
+ (BOOL)isShowing:(id<AVSmallWindowTargetProtocol>)target;
+ (void)start:(id<AVSmallWindowTargetProtocol>)target;
+ (void)exit:(BOOL)needClose;

@end

NS_ASSUME_NONNULL_END
