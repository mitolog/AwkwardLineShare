//
//  SIOSocket+AddSocketId.m
//  AwkwardLineShare
//
//  Created by Tomohisa Ota on 2015/04/01.
//  Copyright (c) 2015年 mitolab. All rights reserved.
//

#import "SIOSocket+AddSocketId.h"
#import <objc/runtime.h>

@implementation SIOSocket (AddSocketId)

static char socketIdKey ;

- (NSString *)socketId
{
    return objc_getAssociatedObject(self, &socketIdKey) ;
}

- (void)setSocketId:(NSString *)socketId
{
    objc_setAssociatedObject(self, &socketIdKey, socketId, OBJC_ASSOCIATION_RETAIN_NONATOMIC) ;
}

@end
