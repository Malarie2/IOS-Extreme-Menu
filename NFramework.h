//奶茶
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NFramework : UIView

+ (instancetype)View;
- (void)show;
+ (void)closeMenu;
+ (void)expand;
+ (void)updateFont:(NSString *)fontName;
+ (void)updateGradientColors;
+ (void)startRGBCycle;
+ (void)stopRGBCycle;

@end

NS_ASSUME_NONNULL_END
