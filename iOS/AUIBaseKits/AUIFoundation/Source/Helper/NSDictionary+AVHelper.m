//
//  NSDictionary+AVHelper.m
//  AlivcAIO_Demo
//
//  Created by Bingo on 2022/5/18.
//

#import "NSDictionary+AVHelper.h"

@implementation NSDictionary (AVHelper)


- (id)av_fetchDataForKey:(NSString *)key {
    return key ? [self objectForKey:key] : nil;
}

- (id)av_fetchDataForKey:(NSString *)key dataClass:(Class)dataClass {
    id data = [self av_fetchDataForKey:key];
    assert((data == nil || [data isKindOfClass:dataClass] || [data isKindOfClass:[NSNull class]]));
    return ([data isKindOfClass:dataClass]) ? data : nil;
}

- (NSString *)av_stringValueForKey:(NSString *)key {
    return [self av_fetchDataForKey:key dataClass:[NSString class]];
}


- (NSArray *)av_arrayValueForKey:(NSString *)key {
    return [self av_fetchDataForKey:key dataClass:[NSArray class]];
}


- (NSDictionary *)av_dictionaryValueForKey:(NSString *)key {
    return [self av_fetchDataForKey:key dataClass:[NSDictionary class]];
}

- (NSNumber *)av_numberValueForKey:(NSString*)key {
    return [self av_fetchNumberForKey:key or:nil];
}

- (NSNumber *)av_fetchNumberForKey:(id)key or:(NSNumber *)fall {
    NSNumber *number = [self av_fetchObjectForKey:key expectedClass:[NSNumber class] or:nil];
    if (number==nil) {
        NSString *strNum = [self av_fetchObjectForKey:key expectedClass:[NSString class] or:nil];
        if (strNum) {
            number = [NSNumber numberWithDouble:[strNum doubleValue]];
        }
    }
    if (number==nil) {
        number = fall;
    }
    return number;
}

- (id)av_fetchObjectForKey:(id)key expectedClass:(Class)class or:(id)fall {
    id obj = [self objectForKey:key];
    if (class && [obj isKindOfClass:class]) {
        return obj;
    }
    return fall;
}

- (NSArray *)av_arrayValueForKey:(NSString *)key itemClass:(Class)itemClass {
    NSArray *array = [self av_arrayValueForKey:key];
    for (id item in array) {
        assert([item isKindOfClass:itemClass]  || [item isKindOfClass:[NSNull class]]);
        if(!([item isKindOfClass:itemClass])) {
            return nil;
        }
    }
    
    return array;
}

- (NSArray<NSString *> *)av_stringArrayValueForKey:(NSString *)key {
    return [self av_arrayValueForKey:key itemClass:[NSString class]];
}


- (NSArray<NSDictionary *> *)av_dictArrayValueForKey:(NSString *)key {
    return [self av_arrayValueForKey:key itemClass:[NSDictionary class]];
}

- (long long)av_longLongValueForKey:(NSString*)key {
    id data = [self av_fetchDataForKey:key];
    assert(data == nil || [data respondsToSelector:@selector(longLongValue)] || [data isKindOfClass:[NSNull class]]);
    if ([data respondsToSelector:@selector(longLongValue)]) {
        return [data longLongValue];
    }
    
    return 0;
}

- (long)av_longValueForKey:(NSString*)key {
    id data = [self av_fetchDataForKey:key];
    assert(data == nil || [data respondsToSelector:@selector(longValue)] || [data respondsToSelector:@selector(longLongValue)] || [data isKindOfClass:[NSNull class]]);
    if ([data respondsToSelector:@selector(longValue)]) {
        return [data longValue];
    }
    
    return 0;
}

- (int)av_intValueForKey:(NSString *)key {
    id data = [self av_fetchDataForKey:key];
    assert(data == nil || [data respondsToSelector:@selector(intValue)] || [data isKindOfClass:[NSNull class]]);
    if ([data respondsToSelector:@selector(intValue)]) {
        return [data intValue];
    }
    
    return 0;
}

- (double)av_floatValueForKey:(NSString *)key {
    id data = [self av_fetchDataForKey:key];
    assert(data == nil || [data respondsToSelector:@selector(floatValue)] || [data isKindOfClass:[NSNull class]]);
    if ([data respondsToSelector:@selector(floatValue)]) {
        return [data floatValue];
    }
    
    return 0.f;
}


- (double)av_doubleValueForKey:(NSString *)key {
    id data = [self av_fetchDataForKey:key];
    assert(data == nil || [data respondsToSelector:@selector(doubleValue)] || [data isKindOfClass:[NSNull class]]);
    if ([data respondsToSelector:@selector(doubleValue)]) {
        return [data doubleValue];
    }
    
    return 0.f;
}

- (BOOL)av_boolValueForKey:(NSString *)key {
    id data = [self av_fetchDataForKey:key];
    assert(data == nil || [data respondsToSelector:@selector(boolValue)] || [data isKindOfClass:[NSNull class]]);
    if ([data respondsToSelector:@selector(boolValue)]) {
        return [data boolValue];
    }
    
    return NO;
}

- (NSString *)av_jsonString {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
