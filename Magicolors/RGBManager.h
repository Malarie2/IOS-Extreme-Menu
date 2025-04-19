#import <UIKit/UIKit.h>

@interface RGBManager : NSObject

+ (instancetype)shared;
+ (void)startRGBCycle;
+ (void)stopRGBCycle;
+ (UIColor *)currentGradientColor;
+ (BOOL)isEnabled;

@end 