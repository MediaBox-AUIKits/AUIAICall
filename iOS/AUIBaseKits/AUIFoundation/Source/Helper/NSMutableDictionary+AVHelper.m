//
//  NSMutableDictionary+AVHelper.m
//  AlivcAIO_Demo
//
//  Created by Bingo on 2022/5/18.
//

#import "NSMutableDictionary+AVHelper.h"

@implementation NSMutableDictionary (AVHelper)


- (void)av_setObject:(id)object forKey:(id<NSCopying>)key {
    if (object) {
        [self setObject:object forKey:key];
    }
}

- (void)av_setInt:(int)value forKey:(id<NSCopying>)key {
    [self av_setObject:@(value) forKey:key];
}

- (void)av_setLong:(long)value forKey:(id<NSCopying>)key {
    [self av_setObject:@(value) forKey:key];
}

- (void)av_setFloat:(float)value forKey:(id<NSCopying>)key {
    [self av_setObject:@(value) forKey:key];
}

- (void)av_setBool:(BOOL)value forKey:(id<NSCopying>)key {
    [self av_setObject:@(value) forKey:key];
}

@end
