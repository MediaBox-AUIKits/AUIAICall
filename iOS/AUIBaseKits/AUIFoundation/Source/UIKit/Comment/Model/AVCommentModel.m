//
//  AVCommentModel.m
//  AUIFoundation
//
//  Created by Bingo on 2024/2/21.
//

#import "AVCommentModel.h"
#import "UIColor+AVHelper.h"
#import "AUIFoundationMacro.h"
#import "UIView+AVHelper.h"

@interface AVCommentModel()

@end

@implementation AVCommentModel

- (instancetype) init {
    self = [super init];
    if (self) {
        _cellInsets = UIEdgeInsetsMake(2, 0, 2, 0);

        _sentContentColor = [UIColor whiteColor];
        _sentContentFontSize = 14;
        _sentContentInsets = UIEdgeInsetsMake(2, 8, 2, 8);
        _flagOriginPoint = CGPointMake(0, -4);
    }
    return self;
}

+ (UIColor *)nickColorWithUid:(NSString *)uid {
    static NSArray *_array = nil;
    if (!_array) {
        _array = @[
            [UIColor av_colorWithHexString:@"#FFAB91"],
            [UIColor av_colorWithHexString:@"#FED998"],
            [UIColor av_colorWithHexString:@"#F6A0B5"],
            [UIColor av_colorWithHexString:@"#CBED8E"],
            [UIColor av_colorWithHexString:@"#95D8F8"],
        ];
    }
    
    if (uid.length > 0) {
        unsigned short first = [uid characterAtIndex:0];
        return _array[first % _array.count];
    }
    
    return nil;
}

+ (UIColor *)anchorFlagForegroundColor {
    return [UIColor av_colorWithLightColor:[UIColor av_colorWithHexString:@"#FC8800"] darkColor:[UIColor av_colorWithHexString:@"#FC8800"]];
}

+ (UIColor *)anchorFlagBackgroundColor {
    return [UIColor av_colorWithLightColor:[UIColor av_colorWithHexString:@"#FFF8EA"] darkColor:[UIColor av_colorWithHexString:@"#FEEECC"]];
}

+ (UIColor *)meFlagForegroundColor {
    return [UIColor av_colorWithLightColor:[UIColor av_colorWithHexString:@"#FF5722"] darkColor:[UIColor av_colorWithHexString:@"#FF5722"]];
}

+ (UIColor *)meFlagBackgroundColor {
    return [UIColor av_colorWithLightColor:[UIColor av_colorWithHexString:@"#FBE9E7"] darkColor:[UIColor av_colorWithHexString:@"#FFCCBC"]];
}

+ (UIImage *)flagImage:(NSString *)title fontSize:(CGFloat)fontSize textColor:(UIColor *)textColor bgColor:(UIColor *)bgColor cornerRadius:(CGFloat)cornerRadius minWidth:(CGFloat)minWidth height:(CGFloat)height {
    UILabel *label = [UILabel new];
    label.text = title;
    label.font = AVGetRegularFont(fontSize);
    label.textColor = textColor;
    label.backgroundColor = bgColor;
    label.clipsToBounds = YES;
    label.layer.cornerRadius = cornerRadius;
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    label.av_width = MAX(label.av_width + 8, minWidth);
    label.av_height = height;
    
    UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [label.layer renderInContext:ctx];
    UIImage* tImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tImage;
}

+ (UIImage *)anchorFlagImage {
    static UIImage *_image = nil;
    if (!_image) {
        _image = [self flagImage:AUIFoundationLocalizedString(@"Host") fontSize:12 textColor:[self anchorFlagForegroundColor] bgColor:[self anchorFlagBackgroundColor] cornerRadius:2 minWidth:20 height:18];
    }
    return _image;
}

+ (UIImage *)meFlagImage {
    static UIImage *_image = nil;
    if (!_image) {
        _image = [self flagImage:AUIFoundationLocalizedString(@"Myself") fontSize:12 textColor:[self meFlagForegroundColor] bgColor:[self meFlagBackgroundColor] cornerRadius:2 minWidth:20 height:18];
    }
    return _image;
}

- (UIImage *)anchorFlagImage {
    return _anchorFlagImage ?: [self.class anchorFlagImage];
}

- (UIImage *)meFlagImage {
    return _meFlagImage ?: [self.class meFlagImage];
}

- (NSAttributedString *)renderContent {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] init];
    
    if (self.useFlag) {
        if (self.isAnchor) {
            
            NSTextAttachment *attach = [[NSTextAttachment alloc] init];
            attach.image = [self anchorFlagImage];
            attach.bounds = CGRectMake(self.flagOriginPoint.x, self.flagOriginPoint.y, attach.image.size.width, attach.image.size.height);
            if (@available(iOS 15.0, *)) {
                attach.lineLayoutPadding = 2;
            }
            [attributeString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
        }
        if (self.isMe) {
            
            NSTextAttachment *attach = [[NSTextAttachment alloc] init];
            attach.image = [self meFlagImage];
            attach.bounds = CGRectMake(self.flagOriginPoint.x, self.flagOriginPoint.y, attach.image.size.width, attach.image.size.height);
            if (@available(iOS 15.0, *)) {
                attach.lineLayoutPadding = 2;
            }
            [attributeString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
        }
    }
    
    NSString *nickName = self.senderNick ?: self.senderID;
    if (nickName.length > 0) {
        UIColor *nickColor = self.senderNickColor;
        if (!nickColor) {
            nickColor = [self.class nickColorWithUid:self.senderID ?: @"2"];
        }
        [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:[nickName stringByAppendingString:@"："] attributes:@{NSForegroundColorAttributeName:nickColor, NSFontAttributeName:AVGetRegularFont(self.sentContentFontSize)}]];
    }
    if (self.sentContent.length > 0) {
        UIColor *sentContentColor = self.sentContentColor;
        if (!sentContentColor) {
            sentContentColor = [UIColor av_colorWithHexString:@"#FCFCFD"];
        }
        [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:self.sentContent attributes:@{NSForegroundColorAttributeName:sentContentColor, NSFontAttributeName:AVGetRegularFont(self.sentContentFontSize)}]];
    }
    return attributeString;
}

@end
