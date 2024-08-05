//
//  AVStringFormat.m
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/5.
//

#import "AVStringFormat.h"

@implementation AVStringFormat

+ (NSString *)formatWithDuration:(float)duration {
    if (duration <= 0) {
        return @"00:00";
    }
    
    NSInteger seconds = (NSInteger)duration;
    NSString *str_second = [NSString stringWithFormat:@"%02ld", seconds%60];
    NSString *str_minute = [NSString stringWithFormat:@"%02ld", (seconds%3600)/60];
    NSInteger hour = seconds/3600;
    if (hour > 0) {
        return [NSString stringWithFormat:@"%02ld:%@:%@", hour, str_minute, str_second];
    }
    return [NSString stringWithFormat:@"%@:%@", str_minute, str_second];
}

+ (NSString *)format2WithDuration:(float)duration {
    if (duration <= 0) {
        return @"00:00:00";
    }
    
    NSInteger seconds = (NSInteger)duration;
    NSString *str_second = [NSString stringWithFormat:@"%02ld", seconds%60];
    NSString *str_minute = [NSString stringWithFormat:@"%02ld", (seconds%3600)/60];
    NSInteger hour = seconds/3600;
    if (hour > 0) {
        return [NSString stringWithFormat:@"%02ld:%@:%@", hour, str_minute, str_second];
    }
    return [NSString stringWithFormat:@"00:%@:%@", str_minute, str_second];
}

+ (NSString *)formatWithCount:(int)count {
    if (count >= 10000) {
        return [NSString stringWithFormat:@"%0.1f万", count / 10000.0];
    }
    return [NSString stringWithFormat:@"%d", count];
}

@end
