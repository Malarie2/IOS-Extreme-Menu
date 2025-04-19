#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NFToggleGroup) {
    NFToggleGroupAuraActors,
    NFToggleGroupAuraObjects
};

@interface NFToggles : NSObject

// Base methods
+ (NSArray *)toggleTitlesForGroup:(NFToggleGroup)group;
+ (NSDictionary *)toggleConfigForGroup:(NFToggleGroup)group;



// UI Theme methods
+ (void)DBDUIThemeRed:(UISwitch *)sender;
+ (void)DBDUIThemeBlue:(UISwitch *)sender;
+ (void)DBDUIThemeGreen:(UISwitch *)sender;
+ (void)DBDUIThemeOrange:(UISwitch *)sender;
+ (void)DBDUIThemePink:(UISwitch *)sender;
+ (void)DBDUIThemeRainbow:(UISwitch *)sender;
+ (void)DBDUIThemeCutie:(UISwitch *)sender;
+ (void)DBDUIThemeWarriorGreen:(UISwitch *)sender;
+ (void)DBDUIThemeUltraBlue:(UISwitch *)sender;


+ (void)interactionsX125:(UISwitch *)sender;
+ (void)interactionsX2:(UISwitch *)sender;
+ (void)interactionsX3:(UISwitch *)sender;

@end
