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
@property(nonatomic)NSMutableArray *points;
@property(nonatomic)AwkwardLineViewMode mode;
- (void)initializeWithMode:(AwkwardLineViewMode)aMode points:(NSArray*)pts;
- (void)updatePoints:(NSArray*)pts;
@end
