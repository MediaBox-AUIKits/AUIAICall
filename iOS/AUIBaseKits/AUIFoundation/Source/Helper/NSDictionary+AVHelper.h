//
//  NSDictionary+AVHelper.h
//  AlivcAIO_Demo
//
//  Created by Bingo on 2022/5/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (AVHelper)

- (NSString *)av_stringValueForKey:(NSString *)key;
- (NSArray *)av_arrayValueForKey:(NSString *)key;
- (NSDictionary *)av_dictionaryValueForKey:(NSString *)key;
- (NSNumber *)av_numberValueForKey:(NSString*)key;

- (NSArray<NSString *> *)av_stringArrayValueForKey:(NSString *)key;
- (NSArray<NSDictionary *> *)av_dictArrayValueForKey:(NSString *)key;

- (int)av_intValueForKey:(NSString *)key;
- (double)av_floatValueForKey:(NSString *)key;
- (double)av_doubleValueForKey:(NSString *)key;
- (BOOL)av_boolValueForKey:(NSString *)key;
- (long long)av_longLongValueForKey:(NSString*)key;
- (long)av_longValueForKey:(NSString*)key;

- (NSString *)av_jsonString;

@end

NS_ASSUME_NONNULL_END
