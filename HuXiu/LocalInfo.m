//
//  LocalInfo.m
//  HuXiu
//
//  Created by 邱康博 on 14-9-16.
//  Copyright (c) 2014年 Lei Yan. All rights reserved.
//

#import "LocalInfo.h"

@implementation LocalInfo

+ (LocalInfo *)sharedSingleton
{
    static LocalInfo *sharedSingleton;
    @synchronized(self) {
        if (!sharedSingleton) {
            sharedSingleton = [[LocalInfo alloc] init];
        }
        return sharedSingleton;
    }
}

- (instancetype)init
{
    self = [super init];
    
    self.notificationInfo = NO;
    
    return self;
}

@end
