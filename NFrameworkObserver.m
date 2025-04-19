#import "NFrameworkObserver.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@implementation NFrameworkObserver

@synthesize menuView;

+ (instancetype)sharedObserver {
    static NFrameworkObserver *sharedObserver = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObserver = [[NFrameworkObserver alloc] init];
    });
    return sharedObserver;
}

- (void)setMenuView:(UIView *)view {
    menuView = view;
}

- (void)observeValueForKeyPath:(NSString *)keyPath 
                     ofObject:(id)object 
                       change:(NSDictionary *)change 
                      context:(void *)context {
    if ([object isKindOfClass:[UIScrollView class]] && [keyPath isEqualToString:@"contentOffset"]) {
        UIScrollView *scrollView = (UIScrollView *)object;
        UILabel *externalToolLabel = [self.menuView viewWithTag:21];
        
        if (scrollView.contentOffset.y > 0) {
            externalToolLabel.hidden = YES;
        } else {
            externalToolLabel.hidden = NO;
        }
    } else if ([object isKindOfClass:[UISlider class]] && [keyPath isEqualToString:@"frame"]) {
        UISlider *slider = (UISlider *)object;
        CAGradientLayer *gradientLayer = (CAGradientLayer *)slider.layer.sublayers.firstObject;
        if ([gradientLayer isKindOfClass:[CAGradientLayer class]]) {
            gradientLayer.frame = slider.bounds;
        }
    }
}

@end