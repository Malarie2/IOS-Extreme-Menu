#import <UIKit/UIKit.h>
#import "KittyMemory/MemoryPatch.hpp"
#import "CustomSlider.h"

@interface ToolsView : NSObject

// Static properties
@property (class, nonatomic) float sliderValue;
@property (class, nonatomic) NSString *lastMSHookOffset;
@property (class, nonatomic) float lastMSHookSliderValue;
@property (class, nonatomic, strong) UIView *menuView;
@property (class, nonatomic, strong) UIScrollView *drawScrollView;

// Class methods
+ (void)setMenuView:(UIView *)view;
+ (void)createToolsView:(UIView *)view;
+ (UIScrollView *)createMSHookView:(UIView *)view;
+ (UIScrollView *)createEllekitHookView:(UIView *)view;
+ (void)applyPatchWithOffset:(UIButton *)sender;
+ (void)restorePatchWithOffset:(UIButton *)sender;
+ (void)createJailbreakPatcherInView:(UIView *)view;
+ (void)createJailedPatcherInView:(UIView *)view;
+ (void)jailbreakSegmentChanged:(UISegmentedControl *)sender;
+ (void)applyVMPatchWithOffset:(UIButton *)sender;
+ (void)ellekitSliderTextfieldChanged:(UISegmentedControl *)sender;
+ (void)applyEllekitHook:(UIButton *)sender;
+ (void)removeEllekitHook:(UIButton *)sender;
+ (void)updateToolsColors;
+ (void)msHookSliderTextfieldChanged:(UISegmentedControl *)sender;
+ (void)sliderValueChanged:(UISlider *)sender;
+ (CAGradientLayer *)createGradientLayer:(CGRect)frame;
+ (id<UITextFieldDelegate>)textFieldDelegate;
+ (UIScrollView *)createSemiMITMView;
+ (UIScrollView *)createDrawView;
+ (void)drawButtonPressedInTools:(UIButton *)sender;
+ (void)clearButtonPressedInTools:(UIButton *)sender;

@end
