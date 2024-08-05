//
//  AVIgnoreSelfHitView.m
//  AUIFoundation
//
//  Created by coder.pi on 2022/6/6.
//

#import "AVIgnoreSelfHitView.h"

@implementation AVIgnoreSelfHitView

- (instancetype)init {
    self = [super init];
    if (self) {
        _ignoreSelfHitTest = YES;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _ignoreSelfHitTest = YES;
    }
    return self;
}

- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self && _ignoreSelfHitTest) {
        return nil;
    }
    return view;
}

@end
