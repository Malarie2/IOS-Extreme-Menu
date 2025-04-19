#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface NFrameworkObserver : NSObject

@property (nonatomic, weak) UIView *menuView;
+ (instancetype)sharedObserver;
- (void)setMenuView:(UIView *)view;

@end