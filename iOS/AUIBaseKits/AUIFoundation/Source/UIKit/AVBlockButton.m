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
