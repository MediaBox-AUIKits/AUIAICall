//
//  NSMutableArray+AVHelper.m
//  AlivcAIO_Demo
//
//  Created by Bingo on 2022/5/18.
//

#import "NSMutableArray+AVHelper.h"

@implementation NSMutableArray (AVHelper)

- (void)av_addObject:(id)object {
    if (object) {
        [self addObject:object];
    }
}

@end
