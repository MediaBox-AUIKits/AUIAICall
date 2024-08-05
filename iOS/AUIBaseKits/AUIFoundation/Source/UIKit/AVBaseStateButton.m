//
//  AVBaseStateButton.m
//  AUIFoundation
//
//  Created by coder.pi on 2022/6/1.
//

#import "AVBaseStateButton.h"
#import "AUIFoundationMacro.h"

@implementation AVBaseStateButtonInfo

+ (AVBaseStateButtonInfo *) InfoWithTitle:(nullable NSString *)title
                                    image:(nullable UIImage *)image
                            disabledImage:(nullable UIImage *)disabledImage
                            selectedImage:(nullable UIImage *)selectedImage {
    AVBaseStateButtonInfo *info = [AVBaseStateButtonInfo new];
    info.title = title;
    info.image = image;
    info.disabledImage = disabledImage;
    info.selectedImage = selectedImage;
    return info;
}

+ (AVBaseStateButtonInfo *) InfoWithTitle:(nullable NSString *)title
                                    image:(nullable UIImage *)image
                            disabledImage:(nullable UIImage *)disabledImage {
    return [self InfoWithTitle:title image:image disabledImage:disabledImage selectedImage:nil];
}

+ (AVBaseStateButtonInfo *) InfoWithTitle:(nullable NSString *)title
                                    image:(nullable UIImage *)image {
    return [self InfoWithTitle:title image:image disabledImage:nil];
}

+ (AVBaseStateButtonInfo *) InfoWithImage:(UIImage *)image disabledImage:(UIImage *)disabledImage {
    return [self InfoWithTitle:nil image:image disabledImage:disabledImage];
}

+ (AVBaseStateButtonInfo *) InfoWithImage:(UIImage *)image selectedImage:(UIImage *)selectedImage {
    return [self InfoWithTitle:nil image:image disabledImage:nil selectedImage:selectedImage];
}

+ (AVBaseStateButtonInfo *) InfoWithImage:(UIImage *)image
                            selectedImage:(UIImage *)selectedImage
                            disabledImage:(UIImage *)disabledImage {
    return [self InfoWithTitle:nil image:image disabledImage:disabledImage selectedImage:selectedImage];
}

+ (AVBaseStateButtonInfo *) InfoWithImage:(UIImage *)image {
    return [self InfoWithTitle:nil image:image disabledImage:nil];
}

@end

@implementation AVBaseStateButton

- (instancetype) initWithStateInfos:(NSDictionary<NSNumber *,AVBaseStateButtonInfo *> *)stateInfos
                         buttonType:(AVBaseButtonType)btnType
                           titlePos:(AVBaseButtonTitlePos)titlePos {
    self = [super initWithType:btnType titlePos:titlePos];
    if (self) {
        self.stateInfos = stateInfos.copy;
    }
    return self;
}

- (instancetype) initWithStateInfos:(NSDictionary<NSNumber */*state*/, AVBaseStateButtonInfo *> *)stateInfos
                  imageTextTitlePos:(AVBaseButtonTitlePos)titlePos {
    return [self initWithStateInfos:stateInfos buttonType:AVBaseButtonTypeImageText titlePos:titlePos];
}

- (instancetype) initWithStateInfos:(NSDictionary<NSNumber */*state*/, AVBaseStateButtonInfo *> *)stateInfos
                         buttonType:(AVBaseButtonType)btnType {
    return [self initWithStateInfos:stateInfos buttonType:btnType titlePos:AVBaseButtonTitlePosBottom];
}

- (void) setCustomState:(int)customState {
    _customState = customState;
    [self updateState];
}

- (void) setStateInfos:(NSDictionary<NSNumber *,AVBaseStateButtonInfo *> *)stateInfos {
    _stateInfos = stateInfos;
    [self updateState];
}

- (AVBaseStateButtonInfo *) defaultStateInfo {
    if (!_stateInfos) {
        return nil;
    }
    return _stateInfos[@(_defaultCustomState)];
}

- (void) updateState {
    if (!_stateInfos) {
        return;
    }
    
    AVBaseStateButtonInfo *info = _stateInfos[@(_customState)];
    if (!info) {
        return;
    }
    AVBaseStateButtonInfo *defaultInfo = self.defaultStateInfo;
    
    if (info.title) {
        self.title = info.title;
    } else if (defaultInfo.title) {
        self.title = defaultInfo.title;
    }
    
    if (info.image) {
        self.image = info.image;
    } else if (defaultInfo.image) {
        self.image = defaultInfo.image;
    }
    
    if (info.selectedImage) {
        self.selectedImage = info.selectedImage;
    } else if (defaultInfo.selectedImage) {
        self.selectedImage = defaultInfo.selectedImage;
    }
    
    if (info.disabledImage) {
        self.disabledImage = info.disabledImage;
    } else if (defaultInfo.disabledImage) {
        self.disabledImage = defaultInfo.disabledImage;
    }
}

@end
