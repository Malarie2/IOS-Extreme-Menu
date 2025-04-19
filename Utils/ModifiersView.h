#import <UIKit/UIKit.h>

@interface ModifiersView : NSObject

+ (void)createModifiersView:(UIView *)menuView;
+ (void)renderSliderChanged:(UISlider *)sender;
+ (void)playerSpeedToggleChanged:(UISwitch *)sender;
+ (void)sensitivityToggleChanged:(UISwitch *)sender; 
+ (void)renderToggleChanged:(UISwitch *)sender;
+ (void)fovToggleChanged:(UISwitch *)sender;
+ (void)fovSliderChanged:(UISlider *)sender;
+ (void)jumpHeightSliderChanged:(UISlider *)sender;
+ (void)jumpHeightToggleChanged:(UISwitch *)sender;
+ (void)interactionsSegmentChanged:(UISegmentedControl *)sender;
+ (void)enableInteractions:(UISwitch *)sender;

@end