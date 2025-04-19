#import "Magicolors/RGBManager.h"
#import "NFViews/MenuView.h"

#import "Magicolors/ColorsHandler.h"

extern NSArray *gradientColors;

@interface RGBManager ()
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGFloat phase;
@property (nonatomic, assign) BOOL isEnabled;
@property (nonatomic, strong) NSArray *currentColors;
@end

@implementation RGBManager

+ (instancetype)shared {
    static RGBManager *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[RGBManager alloc] init];
    });
    return shared;
}

- (instancetype)init {
    if (self = [super init]) {
        _phase = 0.0;
        _isEnabled = NO;
    }
    return self;
}

+ (void)startRGBCycle {
    RGBManager *manager = [RGBManager shared];
    if (!manager.displayLink) {
        manager.displayLink = [CADisplayLink displayLinkWithTarget:manager 
                                                       selector:@selector(updateRGBCycle)];
        manager.displayLink.preferredFramesPerSecond = 60;
        [manager.displayLink addToRunLoop:[NSRunLoop mainRunLoop] 
                                forMode:NSRunLoopCommonModes];
    }
    manager.isEnabled = YES;
}

+ (void)stopRGBCycle {
    RGBManager *manager = [RGBManager shared];
    [manager.displayLink invalidate];
    manager.displayLink = nil;
    manager.isEnabled = NO;
    [self updateAllGradients:nil]; // Przywróć domyślne kolory
}

- (void)updateRGBCycle {
    self.phase += 0.02;
    if (self.phase > 2 * M_PI) {
        self.phase = 0;
    }
    
    UIColor *gradientColor = [RGBManager currentGradientColor];
    NSArray *colors = @[
        (__bridge id)gradientColor.CGColor,
        (__bridge id)blackColor,
        (__bridge id)blackColor,
        (__bridge id)gradientColor.CGColor
    ];
    
    [RGBManager updateAllGradients:colors];
}

+ (UIColor *)currentGradientColor {
    RGBManager *manager = [RGBManager shared];
    CGFloat red = (sin(manager.phase) + 1.0) / 2.0;
    CGFloat green = (sin(manager.phase + 2 * M_PI / 3) + 1.0) / 2.0;
    CGFloat blue = (sin(manager.phase + 4 * M_PI / 3) + 1.0) / 2.0;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

+ (void)updateAllGradients:(NSArray *)colors {
    if (!colors) {
        colors = @[
            (__bridge id)RightGradient,
            (__bridge id)blackColor,
            (__bridge id)blackColor,
            (__bridge id)LeftGradient
        ];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        
        [RGBManager shared].currentColors = colors;
        gradientColors = colors;
        
        [self updateGradientsForViews];
        
        [CATransaction commit];
    });
}

+ (void)updateGradientsForViews {
    [MenuView updateGradients];
    
    // Aktualizuj wskaźniki przewijania w obu ScrollView
    UIScrollView *leftScroll = (UIScrollView *)[menuView viewWithTag:583];
    UIScrollView *rightScroll = (UIScrollView *)[menuView viewWithTag:584];
    
    // Aktualizuj wskaźniki przewijania
    [self updateScrollIndicator:leftScroll];
    [self updateScrollIndicator:rightScroll];
    
    if (closeButton) {
        [closeButton setTintColor:[UIColor colorWithCGColor:(__bridge CGColorRef)gradientColors[0]]];
    }
    
    [self updateMenuControls:gradientColors];
    [self updateLayoutElements:gradientColors];
}

+ (void)updateMenuControls:(NSArray *)colors {
    UIColor *gradientColor = [UIColor colorWithCGColor:(__bridge CGColorRef)colors[0]];
    
    [self iterateVisibleScrollViewControls:^(UIView *control) {
        if ([control isKindOfClass:[UISlider class]]) {
            ((UISlider *)control).minimumTrackTintColor = gradientColor;
        }
        else if ([control isKindOfClass:[UISwitch class]]) {
            ((UISwitch *)control).onTintColor = gradientColor;
        }
    }];
}

+ (void)iterateVisibleScrollViewControls:(void (^)(UIView *control))handler {
    for (UIView *subview in menuView.subviews) {
        if (![subview isKindOfClass:[UIScrollView class]] || subview.hidden) continue;
        
        UIScrollView *scrollView = (UIScrollView *)subview;
        CGRect visibleRect = CGRectMake(0, scrollView.contentOffset.y, 
                                      scrollView.bounds.size.width, 
                                      scrollView.bounds.size.height);
        
        for (UIView *containerView in scrollView.subviews) {
            if (!CGRectIntersectsRect(containerView.frame, visibleRect)) continue;
            
            for (UIView *control in containerView.subviews) {
                handler(control);
            }
        }
    }
}

+ (void)updateLayoutElements:(NSArray *)colors {
    // Usuwamy tablicę nieistniejących etykiet
    [self updateGradientLayers:@[] withColors:colors];
}

+ (void)updateGradientLayers:(NSArray *)layers withColors:(NSArray *)colors {
    for (CALayer *layer in layers) {
        if ([layer isKindOfClass:[CAGradientLayer class]]) {
            ((CAGradientLayer *)layer).colors = colors;
        }
    }
}

+ (BOOL)isEnabled {
    return [RGBManager shared].isEnabled;
}

+ (void)updateScrollIndicator:(UIScrollView *)scrollView {
    if (!scrollView) return;
    
    if ([scrollView respondsToSelector:@selector(_verticalScrollIndicator)]) {
        id scrollIndicator = [scrollView performSelector:@selector(_verticalScrollIndicator)];
        if ([scrollIndicator isKindOfClass:[UIView class]]) {
            UIView *indicatorView = (UIView *)scrollIndicator;
            
            // Znajdź główną warstwę wskaźnika
            CALayer *indicatorLayer = nil;
            for (CALayer *layer in indicatorView.layer.sublayers) {
                if ([layer isKindOfClass:[CALayer class]]) {
                    indicatorLayer = layer;
                    break;
                }
            }
            
            if (indicatorLayer) {
                // Użyj aktualnego koloru RGB lub gradientu
                if ([self isEnabled]) {
                    indicatorLayer.backgroundColor = [self currentGradientColor].CGColor;
                } else {
                    indicatorLayer.backgroundColor = RightGradient;
                }
                
                indicatorLayer.cornerRadius = 1.5;
                indicatorLayer.opacity = 1.0;
                
                indicatorView.alpha = 1.0;
                indicatorView.hidden = NO;
            }
        }
    }
}

@end 