//
//  SIOSocket+AddSocketId.h
//  AwkwardLineShare
//
//  Created by Tomohisa Ota on 2015/04/01.
//  Copyright (c) 2015年 mitolab. All rights reserved.
//

#import "SIOSocket.h"

@interface SIOSocket (AddSocketId)

@property(nonatomic,copy,readwrite) NSString *socketId;

@end
