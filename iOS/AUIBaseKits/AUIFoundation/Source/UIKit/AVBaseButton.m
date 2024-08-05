//
//  AVBaseButton.m
//  AUIFoundation
//
//  Created by coder.pi on 2022/6/1.
//

#import "AVBaseButton.h"
#import "UIView+AVHelper.h"
#import "AUIFoundationMacro.h"
#import "Masonry.h"

@interface AVBaseButton ()
@property (nonatomic, strong) UIStackView *stackView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSString *> *titles;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIColor *> *colors;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIImage *> *images;
@end

@implementation AVBaseButton

- (instancetype) initWithType:(AVBaseButtonType)type titlePos:(AVBaseButtonTitlePos)titlePos {
    self = [super init];
    if (self) {
        [self setupWithType:type titlePos:titlePos];
    }
    return self;
}

- (void) setupWithType:(AVBaseButtonType)type titlePos:(AVBaseButtonTitlePos)titlePos {
    _insets = UIEdgeInsetsZero;
    _type = type;
    _titlePos = titlePos;
    _titleLabel = [UILabel new];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _imageView = [UIImageView new];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _titles = @{}.mutableCopy;
    _colors = @{}.mutableCopy;
    _images = @{}.mutableCopy;
    _spacing = 2.0;
    self.titleLabel.font = AVGetRegularFont(10);
    self.color = AUIFoundationColor(@"text_strong");
    self.disabledColor = AUIFoundationColor(@"text_ultraweak");
    [self setupUI];
}

- (void) updateImage {
    UIImage *image = _images[@(_state)];
    if (!image) {
        image = [self.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    _imageView.image = image;
}
- (void) setImage:(UIImage *)image {
    _images[@(AVBaseButtonStateNormal)] = image;
    [self updateImage];
}
- (void) setDisabledImage:(UIImage *)disabledImage {
    _images[@(AVBaseButtonStateDisabled)] = disabledImage;
    [self updateImage];
}
- (void) setSelectedImage:(UIImage *)selectedImage {
    _images[@(AVBaseButtonStateSelected)] = selectedImage;
    [self updateImage];
}

- (void) setFont:(UIFont *)font {
    self.titleLabel.font = font;
}
- (UIFont *)font {
    return self.titleLabel.font;
}

- (void) updateTitle {
    NSString *title = _titles[@(_state)];
    if (!title) {
        title = self.title;
    }
    _titleLabel.text = title;
}
- (void) setTitle:(NSString *)title {
    _titles[@(AVBaseButtonStateNormal)] = title;
    [self updateTitle];
}
- (void) setDisabledTitle:(NSString *)disabledTitle {
    _titles[@(AVBaseButtonStateDisabled)] = disabledTitle;
    [self updateTitle];
}
- (void) setSelectedTitle:(NSString *)selectedTitle {
    _titles[@(AVBaseButtonStateSelected)] = selectedTitle;
    [self updateTitle];
}

- (void) updateColor {
    UIColor *color = _colors[@(_state)];
    if (!color) {
        color = self.color;
    }
    _titleLabel.textColor = color;
    _imageView.tintColor = color;
}
- (void) setColor:(UIColor *)color {
    _colors[@(AVBaseButtonStateNormal)] = color;
    [self updateColor];
}
- (void) setDisabledColor:(UIColor *)disabledColor {
    _colors[@(AVBaseButtonStateDisabled)] = disabledColor;
    [self updateColor];
}
- (void) setSelectedColor:(UIColor *)selectedColor {
    _colors[@(AVBaseButtonStateSelected)] = selectedColor;
    [self updateColor];
}

- (void) setState:(AVBaseButtonState)state {
    _state = state;
    [self updateTitle];
    [self updateColor];
    [self updateImage];
}

// MARK: - layout
- (void) setupUI {
    switch (_type) {
        case AVBaseButtonTypeOnlyText: {
            [_titleLabel removeFromSuperview];
            [self addSubview:_titleLabel];
            break;
        }
        case AVBaseButtonTypeOnlyImage: {
            [_imageView removeFromSuperview];
            [self addSubview:_imageView];
            break;
        }
        case AVBaseButtonTypeImageText: {
            [self setupStackView];
            break;
        }
    }
    [self updateLayout];
}

- (void)setInsets:(UIEdgeInsets)insets {
    if (UIEdgeInsetsEqualToEdgeInsets(_insets, insets)) {
        return;
    }
    _insets = insets;
    [self updateLayout];
}

- (void)updateLayout {
    UIView *targetView = nil;
    switch (_type) {
        case AVBaseButtonTypeOnlyText: {
            targetView = _titleLabel;
            break;
        }
        case AVBaseButtonTypeOnlyImage: {
            targetView = _imageView;
            break;
        }
        case AVBaseButtonTypeImageText: {
            targetView = _stackView;
            break;
        }
    }
    if (!targetView) {
        return;
    }
    
    [targetView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(_insets);
    }];
}

- (void)setSpacing:(CGFloat)spacing {
    if (_spacing == spacing) {
        return;
    }
    _spacing = spacing;
    _stackView.spacing = spacing;
}

- (void) setupStackView {
    if (_stackView) {
        [_stackView removeFromSuperview];
    }
    _stackView = [UIStackView new];
    _stackView.alignment = UIStackViewAlignmentCenter;
    _stackView.distribution = UIStackViewDistributionEqualSpacing;
    _stackView.spacing = _spacing;
    [self addSubview:_stackView];
    switch (_titlePos) {
        case AVBaseButtonTitlePosTop:
        case AVBaseButtonTitlePosBottom:
            _titleLabel.textAlignment = NSTextAlignmentCenter;
            break;
        case AVBaseButtonTitlePosLeft:
            _titleLabel.textAlignment = NSTextAlignmentRight;
            break;
        case AVBaseButtonTitlePosRight:
            _titleLabel.textAlignment = NSTextAlignmentLeft;
            break;
    }
    
    switch (_titlePos) {
        case AVBaseButtonTitlePosTop:
        case AVBaseButtonTitlePosBottom:
            _stackView.axis = UILayoutConstraintAxisVertical;
            break;
        case AVBaseButtonTitlePosLeft:
        case AVBaseButtonTitlePosRight:
            _stackView.axis = UILayoutConstraintAxisHorizontal;
            break;
    }
    
    switch (_titlePos) {
        case AVBaseButtonTitlePosTop:
        case AVBaseButtonTitlePosLeft:
            [_stackView addArrangedSubview:_titleLabel];
            [_stackView addArrangedSubview:_imageView];
            break;
        case AVBaseButtonTitlePosBottom:
        case AVBaseButtonTitlePosRight:
            [_stackView addArrangedSubview:_imageView];
            [_stackView addArrangedSubview:_titleLabel];
    }
    
    [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh + 1 forAxis:UILayoutConstraintAxisHorizontal];
    [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh + 1 forAxis:UILayoutConstraintAxisVertical];
}

// MARK: - Action
- (void) onAction {
    if (_action) {
        _action(self);
    }
}

// MARK: - boring
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {}
- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [touches.anyObject locationInView:self];
    if (CGRectContainsPoint(self.bounds, point)) {
        [self onAction];
    }
}

- (void) setDisabled:(BOOL)disabled {
    self.state = disabled ? AVBaseButtonStateDisabled : AVBaseButtonStateNormal;
}
- (BOOL) disabled {
    return (self.state == AVBaseButtonStateDisabled);
}

- (void) setSelected:(BOOL)selected {
    self.state = selected ? AVBaseButtonStateSelected : AVBaseButtonStateNormal;
}
- (BOOL) selected {
    return (self.state == AVBaseButtonStateSelected);
}

- (NSString *) title {
    return _titles[@(AVBaseButtonStateNormal)];
}

- (NSString *) disabledTitle {
    return _titles[@(AVBaseButtonStateDisabled)];
}

- (NSString *)selectedTitle {
    return _titles[@(AVBaseButtonStateSelected)];
}

- (UIColor *) color {
    return _colors[@(AVBaseButtonStateNormal)];
}
- (UIColor *) disabledColor {
    return _colors[@(AVBaseButtonStateDisabled)];
}
- (UIColor *) selectedColor {
    return _colors[@(AVBaseButtonStateSelected)];
}

- (UIImage *) image {
    return _images[@(AVBaseButtonStateNormal)];
}
- (UIImage *) disabledImage {
    return _images[@(AVBaseButtonStateDisabled)];
}
- (UIImage *) selectedImage {
    return _images[@(AVBaseButtonStateSelected)];
}

+ (AVBaseButton *) ImageTextWithTitlePos:(AVBaseButtonTitlePos)titlePos {
    return [[self alloc] initWithType:AVBaseButtonTypeImageText titlePos:titlePos];
}
+ (AVBaseButton *) ImageButton {
    return [[self alloc] initWithType:AVBaseButtonTypeOnlyImage titlePos:AVBaseButtonTitlePosBottom];
}
+ (AVBaseButton *) TextButton {
    return [[self alloc] initWithType:AVBaseButtonTypeOnlyText titlePos:AVBaseButtonTitlePosBottom];
}
@end
