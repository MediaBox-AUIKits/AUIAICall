//
//  AVNavigationController.h
//  AlivcAIO_Demo
//
//  Created by Bingo on 2022/5/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AVUIViewControllerInteractivePopGesture <NSObject>

- (BOOL)disableInteractivePopGesture;

@end

@interface AVNavigationController : UINavigationController

@end

NS_ASSUME_NONNULL_END
