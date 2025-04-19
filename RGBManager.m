#import "RGBManager.h"
#import "ColorsHandler.h"
#import <QuartzCore/QuartzCore.h>

@implementation RGBManager

static CADisplayLink *rgbDisplayLink = nil;
static CGFloat rgbPhase = 0.0;
static BOOL isRGBCycleEnabled = NO;

+ (void)startRGBCycle {
    if (rgbDisplayLink || isRGBCycleEnabled) return;
    
    isRGBCycleEnabled = YES;
    rgbDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateRGBCycle:)];
    [rgbDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

+ (void)stopRGBCycle {
    isRGBCycleEnabled = NO;
    [rgbDisplayLink invalidate];
    rgbDisplayLink = nil;
    [self updateLayoutElements:@[
        (__bridge id)RightGradient,
        (__bridge id)blackColor,
        (__bridge id)blackColor,
        (__bridge id)LeftGradient
    ]];
}

+ (void)updateRGBCycle:(CADisplayLink *)displayLink {
    if (!isRGBCycleEnabled) return;
    
    rgbPhase += 0.02;
    if (rgbPhase > 1.0) rgbPhase -= 1.0;
    
    UIColor *color1 = [UIColor colorWithHue:rgbPhase saturation:1.0 brightness:1.0 alpha:1.0];
    UIColor *color2 = [UIColor colorWithHue:fmod(rgbPhase + 0.5, 1.0) saturation:1.0 brightness:1.0 alpha:1.0];
    
    [self updateLayoutElements:@[
        (__bridge id)color2.CGColor,
        (__bridge id)blackColor,
        (__bridge id)blackColor,
        (__bridge id)color1.CGColor
    ]];
}



@end 