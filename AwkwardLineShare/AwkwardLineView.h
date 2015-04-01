//
//  AwkwardLineView.h
//
//
//  Created by YuheiMiyazato on 3/22/15.
//  Copyright (c) 2015 mitolab. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    AwkwardLineViewModeOwner,
    AwkwardLineViewModeMember,
} AwkwardLineViewMode;

@interface AwkwardLineView : UIView

@property(nonatomic,copy,readwrite) NSArray *points;
@property(nonatomic,assign,readwrite)AwkwardLineViewMode mode;
@property(nonatomic,copy,readwrite) UIColor *lineColor;

- (void) pickRandomLineColor;

- (void) appendPoint:(CGPoint)point;
- (void) removeFirstPoint;

@end
