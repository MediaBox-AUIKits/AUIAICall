//
//  UIColor+AVHelper.m
//  AlivcAIO_Demo
//
//  Created by Bingo on 2022/5/19.
//

#import "UIColor+AVHelper.h"

@implementation UIColor (AVHelper)


+ (instancetype)av_colorWithHexString:(NSString *)hexStr {
    CGFloat r, g, b, a;
    if (av_hexStrToRGBA(hexStr, &r, &g, &b, &a)) {
        return [UIColor colorWithRed:r green:g blue:b alpha:a];
    }
    return nil;
}

+ (instancetype)av_colorWithHexString:(NSString *)hexStr alpha:(CGFloat)alpha {
    CGFloat r, g, b, a;
    if (av_hexStrToRGBA(hexStr, &r, &g, &b, &a)) {
        a = alpha;
        return [UIColor colorWithRed:r green:g blue:b alpha:a];
    }
    return nil;
}

static BOOL av_hexStrToRGBA(NSString *str,
                         CGFloat *r, CGFloat *g, CGFloat *b, CGFloat *a) {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    str = [[str stringByTrimmingCharactersInSet:set] uppercaseString];
    if ([str hasPrefix:@"#"]) {
        str = [str substringFromIndex:1];
    } else if ([str hasPrefix:@"0X"]) {
        str = [str substringFromIndex:2];
    }
    
    NSUInteger length = [str length];
    //         RGB            RGBA          RRGGBB        RRGGBBAA
    if (length != 3 && length != 4 && length != 6 && length != 8) {
        return NO;
    }
    
    //RGB,RGBA,RRGGBB,RRGGBBAA
    if (length < 5) {
        *r = av_hexStrToInt([str substringWithRange:NSMakeRange(0, 1)]) / 255.0f;
        *g = av_hexStrToInt([str substringWithRange:NSMakeRange(1, 1)]) / 255.0f;
        *b = av_hexStrToInt([str substringWithRange:NSMakeRange(2, 1)]) / 255.0f;
        if (length == 4)  *a = av_hexStrToInt([str substringWithRange:NSMakeRange(3, 1)]) / 255.0f;
        else *a = 1;
    } else {
        *r = av_hexStrToInt([str substringWithRange:NSMakeRange(0, 2)]) / 255.0f;
        *g = av_hexStrToInt([str substringWithRange:NSMakeRange(2, 2)]) / 255.0f;
        *b = av_hexStrToInt([str substringWithRange:NSMakeRange(4, 2)]) / 255.0f;
        if (length == 8) *a = av_hexStrToInt([str substringWithRange:NSMakeRange(6, 2)]) / 255.0f;
        else *a = 1;
    }
    return YES;
}

static inline NSUInteger av_hexStrToInt(NSString *str) {
    uint32_t result = 0;
    sscanf([str UTF8String], "%X", &result);
    return result;
}


+ (UIColor *)av_colorWithLightColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return darkColor;
            } else {
                return lightColor;
            }
        }];
    }
    else {
        return lightColor;
    }
}

@end
