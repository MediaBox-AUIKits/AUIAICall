//
//  AVAlertController.h
//  ApsaraVideo
//
//  Created by Bingo on 2021/3/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVAlertController : NSObject

+ (void)show:(NSString *)message vc:(UIViewController *)vc;
+ (void)show:(NSString *)message;

+ (void)showInput:(nullable NSString *)title
               vc:(nullable UIViewController *)vc
      onCompleted:(void(^)(NSString *input))completed;

+ (void)showInput:(nullable NSString *)input
            title:(nullable NSString *)title
          message:(nullable NSString *)message
          okTitle:(nullable NSString *)okTitle
      cancelTitle:(nullable NSString *)cancelTitle
               vc:(nullable UIViewController *)vc
      onCompleted:(void(^)(NSString *input, BOOL isCancel))completed;

+ (void)showInput:(nullable NSString *)inputTitle1
      inputTitle2:(nullable NSString *)inputTitle2
            title:(nullable NSString *)title
          message:(nullable NSString *)message
          okTitle:(nullable NSString *)okTitle
      cancelTitle:(nullable NSString *)cancelTitle
               vc:(nullable UIViewController *)vc
      onCompleted:(void(^)(NSString *input1, NSString *input2))completed;

+ (void)showWithTitle:(nullable NSString *)title
              message:(NSString *)message
           needCancel:(BOOL)needCancel
          onCompleted:(void(^)(BOOL isCanced))completed;

+ (void)showWithTitle:(nullable NSString *)title
              message:(NSString *)message
          cancelTitle:(NSString *)cancelTitle
              okTitle:(NSString *)okTitle
          onCompleted:(void(^)(BOOL isCanced))completed;

+ (void)showSheet:(NSArray<NSString *> *)actionTitles
       alertTitle:(nullable NSString *)alertTitle
          message:(nullable NSString *)message
      cancelTitle:(nullable NSString *)cancelTitle
               vc:(nullable UIViewController *)vc
      onCompleted:(void (^)(NSInteger idx))completed;

@end

NS_ASSUME_NONNULL_END
