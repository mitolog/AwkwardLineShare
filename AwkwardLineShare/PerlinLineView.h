//
//  PerlinLineView.h
//
//
//  Created by YuheiMiyazato on 3/22/15.
//  Copyright (c) 2015 mitolab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PerlinLineView : UIView
@property(nonatomic)NSMutableArray *points;
- (void)initialize;
- (void)assignOtherPtDicWithAry:(NSArray*)ary ownSocketId:(NSString*)ownSid;
@end
