//
//  NSMutableDictionary+AVHelper.h
//  AlivcAIO_Demo
//
//  Created by Bingo on 2022/5/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionary (AVHelper)

- (void)av_setObject:(id)object forKey:(id<NSCopying>)key;
- (void)av_setInt:(int)value forKey:(id<NSCopying>)key;
- (void)av_setLong:(long)value forKey:(id<NSCopying>)key;
- (void)av_setFloat:(float)value forKey:(id<NSCopying>)key;
- (void)av_setBool:(BOOL)value forKey:(id<NSCopying>)key;


@end

NS_ASSUME_NONNULL_END
