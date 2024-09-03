//
//  AVQRCodeScanner.h
//  AUIFoundation
//
//  Created by Bingo on 2024/8/7.
//

#import "AVBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AVQRCodeScanner : AVBaseViewController

@property (nonatomic, copy) void(^scanResultBlock)(AVQRCodeScanner *scanner, NSString *qrCodeContent);

@end

NS_ASSUME_NONNULL_END
