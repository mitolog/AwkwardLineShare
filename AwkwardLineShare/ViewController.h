//
//  ViewController.h
//  AwkwardLineShare
//
//  Created by YuheiMiyazato on 3/27/15.
//  Copyright (c) 2015 mitolab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AwkwardLineView.h"

static NSString * const kWebSocketHostName = @"ws://ec2-user@ec2-54-65-59-13.ap-northeast-1.compute.amazonaws.com:3000";
static NSString * const kObserverContext = @"pointsUpdate";
static NSString * const kObserverKeyPath = @"points";

@interface ViewController : UIViewController

@property(nonatomic,strong,readonly) AwkwardLineView *ownerView;

- (void) removeFirstPoint;

@end

