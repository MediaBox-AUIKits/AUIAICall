//
//  AVLoginManager.h
//  AUIFoundation
//
//  Created by Bingo on 2024/2/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVLoginManager : NSObject

@property (nonatomic, strong, class, readonly) AVLoginManager *shared;

@property (nonatomic, assign, readonly) BOOL isLogin;
@property (nonatomic, strong, readonly) NSString *loginUid;
@property (nonatomic, strong, readonly) NSString *lastLoginUId;

@property (nonatomic, copy) void(^doLogin)(NSString *uid, void(^completed)(NSError * _Nullable error));
@property (nonatomic, copy) void(^doLogout)(NSString *uid, void(^completed)(NSError * _Nullable error));

- (void)login:(NSString *)uid completed:(void(^)(NSError * _Nullable error))completed;
- (void)logout:(void(^)(NSError * _Nullable error))completed;

- (BOOL)validateUid:(NSString *)uid;

@end


NS_ASSUME_NONNULL_END
