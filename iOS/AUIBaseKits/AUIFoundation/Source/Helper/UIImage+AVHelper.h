//
//  UIImage+AVHelper.h
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (AVHelper)

+ (UIImage *)av_imageWithColor:(UIColor *)color size:(CGSize)size;

+ (UIImage *)av_imageWithLightNamed:(NSString *)lightNamed withDarkNamed:(NSString *)darkNamed inBundle:(nullable NSBundle *)bundle;


@end

NS_ASSUME_NONNULL_END
