//
//  AVLocalization.h
//  ApsaraVideo
//
//  Created by Bingo on 2021/6/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define AVGetString(key, module)  [AVLocalization stringWithKey:(key) withModule:(module)]


@interface AVLocalization : NSObject

+ (NSString *)stringWithKey:(NSString *)key withModule:(NSString *)module;

+ (NSString *)currentLanguage;
+ (BOOL)isInternational;

@end

NS_ASSUME_NONNULL_END
