//
//  AVBlockButton.m
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/9/2.
//

#import "AVBlockButton.h"

@interface AVBlockButton ()

@property (nonatomic, strong) NSMutableDictionary *borderColorDict;
@property (nonatomic, strong) NSMutableDictionary *backgroundColorDict;

@end

@implementation AVBlockButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)setClickBlock:(void (^)(AVBlockButton * _Nonnull))clickBlock {
    _clickBlock = clickBlock;
    if (clickBlock) {
        [self addTarget:self action:@selector(onClickAction) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [self removeTarget:self action:@selector(onClickAction) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)onClickAction {
    if (self.clickBlock) {
        self.clickBlock(self);
    }
}

- (void)setTouchDownBlock:(void (^)(AVBlockButton * _Nonnull))touchDownBlock {
    _touchDownBlock = touchDownBlock;
    if (touchDownBlock) {
        [self addTarget:self action:@selector(onTouchDownAction) forControlEvents:UIControlEventTouchDown];
    } else {
        [self removeTarget:self action:@selector(onTouchDownAction) forControlEvents:UIControlEventTouchDown];
    }
}

- (void)onTouchDownAction {
    if (self.touchDownBlock) {
        self.touchDownBlock(self);
    }
}

- (void)setTouchDragEnterBlock:(void (^)(AVBlockButton * _Nonnull))touchDragEnterBlock {
    _touchDragEnterBlock = touchDragEnterBlock;
    if (touchDragEnterBlock) {
        [self addTarget:self action:@selector(onTouchDragEnterAction) forControlEvents:UIControlEventTouchDragEnter];
    } else {
        [self removeTarget:self action:@selector(onTouchDragEnterAction) forControlEvents:UIControlEventTouchDragEnter];
    }
}

- (void)onTouchDragEnterAction {
    if (self.touchDragEnterBlock) {
        self.touchDragEnterBlock(self);
    }
}

- (void)setTouchDragExitBlock:(void (^)(AVBlockButton * _Nonnull))touchDragExitBlock {
    _touchDragExitBlock = touchDragExitBlock;
    if (touchDragExitBlock) {
        [self addTarget:self action:@selector(onTouchDragExitAction) forControlEvents:UIControlEventTouchDragExit];
    } else {
        [self removeTarget:self action:@selector(onTouchDragExitAction) forControlEvents:UIControlEventTouchDragExit];
    }
}

- (void)onTouchDragExitAction {
    if (self.touchDragExitBlock) {
        self.touchDragExitBlock(self);
    }
}

- (void)setTouchUpInsideBlock:(void (^)(AVBlockButton * _Nonnull))touchUpInsideBlock {
    _touchUpInsideBlock = touchUpInsideBlock;
    if (touchUpInsideBlock) {
        [self addTarget:self action:@selector(onTouchUpInsideAction) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self removeTarget:self action:@selector(onTouchUpInsideAction) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)onTouchUpInsideAction {
    if (self.touchUpInsideBlock) {
        self.touchUpInsideBlock(self);
    }
}

- (void)setTouchUpOutsideBlock:(void (^)(AVBlockButton * _Nonnull))touchUpOutsideBlock {
    _touchUpOutsideBlock = touchUpOutsideBlock;
    if (touchUpOutsideBlock) {
        [self addTarget:self action:@selector(onTouchUpOutsideAction) forControlEvents:UIControlEventTouchUpOutside];
    } else {
        [self removeTarget:self action:@selector(onTouchUpOutsideAction) forControlEvents:UIControlEventTouchUpOutside];
    }
}

- (void)onTouchUpOutsideAction {
    if (self.touchUpOutsideBlock) {
        self.touchUpOutsideBlock(self);
    }
}

- (NSMutableDictionary *)borderColorDict {
    if (!_borderColorDict) {
        _borderColorDict = [NSMutableDictionary dictionary];
    }
    return _borderColorDict;
}

- (NSMutableDictionary *)backgroundColorDict {
    if (!_backgroundColorDict) {
        _backgroundColorDict = [NSMutableDictionary dictionary];
    }
    return _backgroundColorDict;
}

- (void)updateBorderColor {
    NSUInteger state = UIControlStateNormal;
    if (self.isSelected) {
        state = state | UIControlStateSelected;
    }
    if (self.isHighlighted) {
        state = state | UIControlStateHighlighted;
    }
    if (!self.isEnabled) {
        state = state | UIControlStateDisabled;
    }
    UIColor *borderColor = [self.borderColorDict objectForKey:@(state)] ?: [self.borderColorDict objectForKey:@(UIControlStateNormal)];
    self.layer.borderColor = [borderColor CGColor];
}

- (void)setBorderColor:(UIColor *)color forState:(UIControlState)state {
    [self.borderColorDict setObject:color forKey:@(state)];
    [self updateBorderColor];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [self setBackgroundColor:backgroundColor forState:UIControlStateNormal];
}

- (void)updateBackgroundColor {
    NSUInteger state = UIControlStateNormal;
    if (self.isSelected) {
        state = state | UIControlStateSelected;
    }
    if (self.isHighlighted) {
        state = state | UIControlStateHighlighted;
    }
    if (!self.isEnabled) {
        state = state | UIControlStateDisabled;
    }
    UIColor *backgroundColor = [self.backgroundColorDict objectForKey:@(state)] ?: [self.backgroundColorDict objectForKey:@(UIControlStateNormal)];
    super.backgroundColor = backgroundColor;
}

- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state {
    [self.backgroundColorDict setObject:color forKey:@(state)];
    [self updateBackgroundColor];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    [self updateBorderColor];
    [self updateBackgroundColor];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    [self updateBorderColor];
    [self updateBackgroundColor];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    
    [self updateBorderColor];
    [self updateBackgroundColor];
}



@end
