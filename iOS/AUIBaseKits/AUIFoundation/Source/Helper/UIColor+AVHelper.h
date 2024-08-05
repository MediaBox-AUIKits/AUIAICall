//
//  UIColor+AVHelper.h
//  AlivcAIO_Demo
//
//  Created by Bingo on 2022/5/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (AVHelper)

+ (instancetype)av_colorWithHexString:(NSString *)hexStr;
+ (instancetype)av_colorWithHexString:(NSString *)hexStr alpha:(CGFloat)alpha;

+ (UIColor *)av_colorWithLightColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor;

@end

NS_ASSUME_NONNULL_END
