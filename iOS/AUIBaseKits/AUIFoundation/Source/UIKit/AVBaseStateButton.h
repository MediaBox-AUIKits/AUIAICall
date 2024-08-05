//
//  AVBaseStateButton.h
//  AUIFoundation
//
//  Created by coder.pi on 2022/6/1.
//

#import "AVBaseButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface AVBaseStateButtonInfo : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *disabledImage;
@property (nonatomic, strong) UIImage *selectedImage;
+ (AVBaseStateButtonInfo *) InfoWithTitle:(nullable NSString *)title
                                    image:(nullable UIImage *)image
                            disabledImage:(nullable UIImage *)disabledImage
                            selectedImage:(nullable UIImage *)selectedImage;
+ (AVBaseStateButtonInfo *) InfoWithTitle:(nullable NSString *)title
                                    image:(nullable UIImage *)image
                            disabledImage:(nullable UIImage *)disabledImage;
+ (AVBaseStateButtonInfo *) InfoWithTitle:(nullable NSString *)title image:(nullable UIImage *)image;
+ (AVBaseStateButtonInfo *) InfoWithImage:(UIImage *)image disabledImage:(UIImage *)disabledImage;
+ (AVBaseStateButtonInfo *) InfoWithImage:(UIImage *)image selectedImage:(UIImage *)selectedImage;
+ (AVBaseStateButtonInfo *) InfoWithImage:(UIImage *)image selectedImage:(UIImage *)selectedImage disabledImage:(UIImage *)disabledImage;
+ (AVBaseStateButtonInfo *) InfoWithImage:(UIImage *)image;
@end

@interface AVBaseStateButton : AVBaseButton
@property (nonatomic, assign) int defaultCustomState;
@property (nonatomic, assign) int customState;
@property (nonatomic, readonly) NSDictionary<NSNumber */*state*/, AVBaseStateButtonInfo *> *stateInfos;
- (instancetype) initWithStateInfos:(NSDictionary<NSNumber */*state*/, AVBaseStateButtonInfo *> *)stateInfos
                         buttonType:(AVBaseButtonType)btnType;
- (instancetype) initWithStateInfos:(NSDictionary<NSNumber */*state*/, AVBaseStateButtonInfo *> *)stateInfos
                  imageTextTitlePos:(AVBaseButtonTitlePos)titlePos;
- (instancetype) initWithStateInfos:(NSDictionary<NSNumber *,AVBaseStateButtonInfo *> *)stateInfos
                         buttonType:(AVBaseButtonType)btnType
                           titlePos:(AVBaseButtonTitlePos)titlePos;
@end

NS_ASSUME_NONNULL_END
