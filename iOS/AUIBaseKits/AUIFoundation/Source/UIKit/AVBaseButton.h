//
//  AVBaseButton.h
//  AUIFoundation
//
//  Created by coder.pi on 2022/6/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AVBaseButtonTitlePos) {
    AVBaseButtonTitlePosTop,
    AVBaseButtonTitlePosBottom,
    AVBaseButtonTitlePosLeft,
    AVBaseButtonTitlePosRight,
};

typedef NS_ENUM(NSUInteger, AVBaseButtonType) {
    AVBaseButtonTypeOnlyText,
    AVBaseButtonTypeOnlyImage,
    AVBaseButtonTypeImageText
};

typedef NS_ENUM(NSUInteger, AVBaseButtonState) {
    AVBaseButtonStateNormal,
    AVBaseButtonStateSelected,
    AVBaseButtonStateDisabled
};

@class AVBaseButton;
typedef void(^AVBaseButtonAction)(AVBaseButton *btn);

@interface AVBaseButton : UIView
@property (nonatomic, readonly) AVBaseButtonType type;
@property (nonatomic, readonly) AVBaseButtonTitlePos titlePos;
@property (nonatomic, assign) CGFloat spacing;

@property (nonatomic, assign) AVBaseButtonState state;
@property (nonatomic, assign) BOOL disabled;
@property (nonatomic, assign) BOOL selected;

@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSString *disabledTitle;
@property (nonatomic, copy, nullable) NSString *selectedTitle;
@property (nonatomic, strong, nullable) UIFont *font;

@property (nonatomic, copy, nullable) UIColor *color;
@property (nonatomic, copy, nullable) UIColor *disabledColor;
@property (nonatomic, copy, nullable) UIColor *selectedColor;

@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, strong, nullable) UIImage *disabledImage;
@property (nonatomic, strong, nullable) UIImage *selectedImage;

@property (nonatomic, assign) UIEdgeInsets insets;

@property (nonatomic, copy) AVBaseButtonAction action;
- (instancetype) initWithType:(AVBaseButtonType)type titlePos:(AVBaseButtonTitlePos)titlePos;
+ (AVBaseButton *) ImageTextWithTitlePos:(AVBaseButtonTitlePos)titlePos;
+ (AVBaseButton *) ImageButton;
+ (AVBaseButton *) TextButton;
@end

NS_ASSUME_NONNULL_END
