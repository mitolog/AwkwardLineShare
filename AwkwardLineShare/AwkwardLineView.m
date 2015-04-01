//
//  AwkwardLineView.m
//
//
//  Created by YuheiMiyazato on 3/22/15.
//  Copyright (c) 2015 mitolab. All rights reserved.
//

/**
 * Create perlin noised line
 * referenced to: http://www.technotype.net/hugo.elias/models/m_perlin.html
 */

#import "AwkwardLineView.h"
#import "ViewController.h"
#import "UIColor+HexString.h"

static const CGFloat devideNum = 10;
static const NSUInteger octave = 3;
static const CGFloat persistence = 0.25;

@implementation AwkwardLineView

#pragma mark - overrides

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    if(self.points.count <= 0)return;

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context,
                                     self.lineColor.CGColor);
    
    // Move to first point
    CGPoint pt, cpt;
    
    // Connecting the dots
    int i = 0;
    for(NSDictionary * ptDic in self.points){
        if(i==0){
            CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)self.points[0],
                                                    &pt);
            CGContextMoveToPoint(context, pt.x, pt.y);
        }
        else if(i+1 < self.points.count){
            // make curve to end point
            CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)ptDic,
                                                    &cpt);
            CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)self.points[i+1],
                                                    &pt);
            CGContextAddQuadCurveToPoint(context, cpt.x, cpt.y, pt.x, pt.y);
        }else{
            // make line to end point...
            CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)ptDic,
                                                    &pt);
            CGContextAddLineToPoint(context, pt.x, pt.y);
        }
        
        i++;
    }
    CGContextStrokePath(context);

}

#pragma mark - perlin noise related

/*
 * create noise from -1.0 to 1.0
 */
- (float)noise:(u_int32_t)x
{
    x = (x<<13) ^ x;
    return ( 1.0 - ( (x * (x * x * 15731 + 789221) + 1376312589) & 0x7fffffff) / 1073741824.0);
}

- (CGFloat)smoothedNoise:(float)x
{
    return [self noise:x]*0.5 + [self noise:x-1]*0.25 + [self noise:x+1]*0.25;
}

- (float)cosInterpolateWithV1:(float)v1
                           V2:(float)v2
                     fraction:(float)x
{
    float ft = x * M_PI;
    float f = (1 - cos(ft)) * 0.5;
    
    return  v1*(1-f) + v2*f;
}

- (float)interpolatedNoise:(float)x
{
    int intX = (int)x;
    float fractionalX = x - intX;
    
    float v1 = [self smoothedNoise:(float)intX];
    float v2 = [self smoothedNoise:(float)intX + 1];
    
    return [self cosInterpolateWithV1:v1 V2:v2 fraction:fractionalX];
}

- (CGFloat)perlinNoise:(float)x
                octave:(NSUInteger)octave
           persistence:(NSInteger)persistence
{
    float total = 0;
    
    for(NSUInteger i=0; i<octave;i++){
        CGFloat freq = pow(2,i);
        CGFloat amp = pow(persistence, i);
        total = total + [self interpolatedNoise:x * freq] * amp;
    }
    return total;
}

#pragma mark - touch events related

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    CGPoint location = [[touches anyObject] locationInView:self];
    //NSLog(@"%@", NSStringFromCGPoint(location));
    [self appendPoint:location];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    CGPoint location = [[touches anyObject] locationInView:self];
    //NSLog(@"%@", NSStringFromCGPoint(location));
    [self appendPoint:location];
}

#pragma mark - onw methods

- (void) pickRandomLineColor
{
    // http://app.coolors.co/3f86aa-95afba-bdc4a7-d5e1a3-e2f89c
    // http://app.coolors.co/c7e8f3-bf9aca-8e4162-41393e-eda2c0
    NSArray *colorPalette = @[@"3F86AA",@"95AFBA",@"BDC4A7",@"D5E1A3",@"E2F89C",@"C7E8F3",@"BF9ACA",@"8E4162",@"41393E",@"EDA2C0"];
    
    u_int32_t upperCnt = (u_int32_t) colorPalette.count;
    self.lineColor = [UIColor colorFromHexString:colorPalette[arc4random_uniform(upperCnt)]];
}

- (void)removeFirstPoint
{
    if(self.points.count == 0){
        return;
    }
    NSMutableArray *mPoints = self.points.mutableCopy;
    [mPoints removeObjectAtIndex:0];
    self.points = mPoints;
}

- (void)setLineColor:(UIColor *)lineColor
{
    _lineColor = lineColor;
    [self setNeedsDisplay];
}

- (void)setPoints:(NSArray *)points
{
    _points = points == nil ? @[] : points.copy;
    [self setNeedsDisplay];
}

- (void)setMode:(AwkwardLineViewMode)mode
{
    _mode = mode;
    if(self.mode == AwkwardLineViewModeOwner){
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    else{
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void) appendPoint:(CGPoint)pt
{
    // Prepare the dots
    CGFloat x = pt.x;
    CGFloat y = pt.y;
    CGFloat ptNum = 360 / devideNum;
    CGFloat noiseVal = arc4random_uniform(10);
    CGFloat noiseVariance = 0;
    
    noiseVariance = 10 * [self perlinNoise:noiseVal
                                    octave:octave
                               persistence:persistence];
    
    x += noiseVariance;
    y += noiseVariance;

    NSDictionary *ptDic =
    (__bridge NSDictionary*)CGPointCreateDictionaryRepresentation(CGPointMake(x, y));
    
    NSMutableArray *mPoints = self.points.mutableCopy;
    if(self.points.count >= ptNum){
        [mPoints removeObjectAtIndex:0];
    }
    [mPoints addObject:ptDic];
    self.points = mPoints;
}

@end
