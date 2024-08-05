//
//  AVLoginViewController.h
//  AUIFoundation
//
//  Created by Bingo on 2024/2/21.
//

#import <UIKit/UIKit.h>
#import "AVBaseViewController.h"
#import "AVInputView.h"

NS_ASSUME_NONNULL_BEGIN

@interface AVLoginViewController : AVBaseViewController

@property (nonatomic, strong, readonly) AVInputView *inputIdView;

@property (nonatomic, copy) void(^loginSuccessBlock)(AVLoginViewController *sender);

@end

NS_ASSUME_NONNULL_END
