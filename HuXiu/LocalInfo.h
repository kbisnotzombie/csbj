//
//  LocalInfo.h
//  HuXiu
//
//  Created by 邱康博 on 14-9-16.
//  Copyright (c) 2014年 Lei Yan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalInfo : NSObject

@property (nonatomic) BOOL notificationInfo;

+ (LocalInfo *)sharedSingleton;

@end
