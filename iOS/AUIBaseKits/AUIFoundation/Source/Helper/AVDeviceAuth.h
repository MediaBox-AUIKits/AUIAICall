//
//  AVDeviceAuth.h
//  AliInteractionLiveDemo
//
//  Created by Bingo on 2022/11/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVDeviceAuth : NSObject

+ (void)checkCameraAuth:(void(^)(BOOL auth))completed;
+ (void)checkMicAuth:(void(^)(BOOL auth))completed;

@end

NS_ASSUME_NONNULL_END
