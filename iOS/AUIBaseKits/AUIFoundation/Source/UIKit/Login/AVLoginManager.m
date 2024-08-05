//
//  AVLoginManager.m
//  AUIFoundation
//
//  Created by Bingo on 2024/2/21.
//

#import "AVLoginManager.h"

@implementation AVLoginManager

+ (AVLoginManager *)shared {
    static AVLoginManager *_instance = nil;
    if (!_instance) {
        _instance = [AVLoginManager new];
    }
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadLastLoginUserId];
    }
    return self;
}

- (void)loadLastLoginUserId {
    _lastLoginUId = [NSUserDefaults.standardUserDefaults objectForKey:@"aui_last_login_user_id"];
}

- (void)saveLastLoginUserId:(NSString *)uid {
    _lastLoginUId = uid;
    [NSUserDefaults.standardUserDefaults setObject:_lastLoginUId forKey:@"aui_last_login_user_id"];
}

- (BOOL)isLogin {
    return self.loginUid.length > 0;

}

- (void)updateLoginUid:(NSString *)uid {
    _loginUid = uid;
}

- (void)login:(NSString *)uid completed:(void (^)(NSError * _Nullable))completed {
    if (self.doLogin) {
        __weak typeof(self) weakSelf = self;
        self.doLogin(uid, ^(NSError * _Nullable error) {
            if (!error) {
                [weakSelf updateLoginUid:uid];
                [weakSelf saveLastLoginUserId:uid];
            }
            completed(error);
        });
    }
    else {
        completed([NSError errorWithDomain:@"aui.login" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"unimplementation dologin block"}]);
    }
}

- (void)logout:(void (^)(NSError * _Nullable))completed {
    if (!self.isLogin) {
        completed(nil);
        return;
    }
    if (self.doLogout) {
        __weak typeof(self) weakSelf = self;
        self.doLogout(self.loginUid, ^(NSError * _Nullable error) {
            if (!error) {
                [weakSelf updateLoginUid:nil];
            }
            completed(error);
        });
    }
    else {
        [self updateLoginUid:nil];
        completed(nil);
    }
}

- (BOOL)validateUid:(NSString *)uid {
    if (uid.length == 0) {
        return NO;
    }
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_"];
    return [uid rangeOfCharacterFromSet:set.invertedSet].location == NSNotFound;
}

@end
