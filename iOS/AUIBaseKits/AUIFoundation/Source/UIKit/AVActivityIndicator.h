//
//  AVActivityIndicator.h
//  ApsaraVideo
//
//  Created by Bingo on 2021/3/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVActivityIndicator : UIView

+ (AVActivityIndicator *)start:(UIView *)view displaySize:(CGSize)displaySize displayColor:(UIColor *)displayColor indicatorColor:(UIColor *)indicatorColor;
+ (AVActivityIndicator *)start:(UIView *)view;

+ (void)stop:(AVActivityIndicator *)activityIndicator;

@end

NS_ASSUME_NONNULL_END
