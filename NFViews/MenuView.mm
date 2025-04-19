
#import "NFViews/IGGMemView.h"
#import "NFramework.h"
#import "NFViews/MenuView.h"
#import "Magicolors/ColorsHandler.h"
#import "NFToggles.h"
#import "Magicolors/ColorPicker.h"
#import "Magicolors/RGBManager.h"
#import <objc/runtime.h>
#import <WebKit/WebKit.h>
#import <mach/mach.h>
#import <mach/vm_map.h>

// Dodaj na początku pliku, po innych deklaracjach extern
extern UIView *countdownContainer;
extern UIView *celebrationContainer;

// Na początku pliku, po importach a przed @interface
typedef enum {
    AnimationStyleNone = 0,
    AnimationStyleSlide = 1,
    AnimationStyleRotate = 2,
    AnimationStyleWave = 3,
    AnimationStyleSpin = 4,
    AnimationStyleZoom = 5,
    AnimationStyleMatrix = 6
} AnimationStyle;

static struct {
    BOOL animateAlways;
    AnimationStyle animationStyle;
    NSTimeInterval duration;
} menuAnimationSettings = {
    .animateAlways = YES,
    .animationStyle = AnimationStyleNone,
    .duration = 0.5
};

// Na początku pliku, po importach a przed @interface, dodaj deklaracje tablic:
static NSArray *leftMenuTitles;
static NSArray *leftMenuIcons;
static NSArray *rightMenuTitles;
static NSArray *rightMenuIcons;

// Na początku pliku, po innych zmiennych statycznych
static CGFloat rgbPhase = 0.0;
static CADisplayLink *rgbDisplayLink;
NSArray *gradientColors = nil;

// Definicje zmiennych extern
UIImageView *headerImageView;
UIImageView *footerImageView;

// Na początku pliku, dodaj zmienne współdzielone
CGFloat sharedRGBPhase = 0.0;
CADisplayLink *sharedRGBDisplayLink = nil;

// Dodaj na początku pliku, po innych zmiennych statycznych
static UITextField *secureField;
static UIView *secureOverlay;

// Dodaj na początku pliku, po innych zmiennych statycznych
static UIView *hideView;

@interface MenuView () <UIScrollViewDelegate>
@end

static dispatch_queue_t gradientUpdateQueue;
static NSDictionary *gradientAttributes;

// Dodaj na początku pliku
static CFTimeInterval lastRGBUpdate = 0;
static const CFTimeInterval kRGBUpdateInterval = 1.0/60.0; // 60 FPS dla RGB

@implementation MenuView

+ (void)initialize {
    if (self == [MenuView class]) {
        // Ustaw domyślną wartość dla stylu animacji jeśli nie została wcześniej ustawiona
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"MenuAnimationStyle"] == nil) {
            [[NSUserDefaults standardUserDefaults] setInteger:AnimationStyleNone forKey:@"MenuAnimationStyle"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        gradientAttributes = @{
            @"locations": @[@0.0, @0.3, @0.7, @1.0],
            @"startPoint": [NSValue valueWithCGPoint:CGPointMake(0, 0.5)],
            @"endPoint": [NSValue valueWithCGPoint:CGPointMake(1, 0.5)]
        };
    }
}

+ (void)updateGradientColors {
    if ([RGBManager isEnabled]) {
        return;
    }
    
    gradientColors = @[
        (__bridge id)RightGradient,
        (__bridge id)blackColor,
        (__bridge id)blackColor,
        (__bridge id)LeftGradient
    ];
}

+ (void)createMenuView {
    CGFloat switchAreaHeight = 210; // Ustawiona stała wysokość na 210
    CGFloat scrollViewWidth = (620 - 20) / 2; // Subtract padding and divide by 2
    CGFloat scrollViewSpacing = 20; // Space between scroll views
    CGFloat leftScrollViewX = (620 - (scrollViewWidth * 2 + scrollViewSpacing)) / 2;
    CGFloat rightScrollViewX = leftScrollViewX + scrollViewWidth + scrollViewSpacing;
    CGFloat labelHeight = 25; // Dodajemy definicję labelHeight
    CGFloat switchStartY = 3; // Dodajemy definicję switchStartY
    CGFloat switchSpacing = 18; // Dodajemy definicję switchSpacing

    // Zoptymalizuj tworzenie gradientów - przygotuj kolory raz
    NSArray *gradientColors = @[
        (__bridge id)RightGradient,
        (__bridge id)blackColor, 
        (__bridge id)blackColor,
        (__bridge id)LeftGradient
    ];
    
    // Przygotuj wspólne atrybuty gradientu
    NSDictionary *gradientAttributes = @{
        @"locations": @[@0.0, @0.3, @0.7, @1.0],
        @"startPoint": [NSValue valueWithCGPoint:CGPointMake(0, 0.5)],
        @"endPoint": [NSValue valueWithCGPoint:CGPointMake(1, 0.5)]
    };

    // Funkcja pomocnicza do tworzenia kontenera
    UIView *(^createContainerView)(CGRect, NSString *, NSString *) = ^(CGRect frame, NSString *title, NSString *iconName) {
        UIView *container = [[UIView alloc] initWithFrame:frame];
        container.layer.cornerRadius = 5;
        container.clipsToBounds = YES;
        
        // Dodaj gradient tła
        CAGradientLayer *backgroundGradient = [self createGradientLayerWithColors:gradientColors 
                                                                     attributes:gradientAttributes 
                                                                         frame:container.bounds];
        [container.layer insertSublayer:backgroundGradient atIndex:0];
        
        // Dodaj gradienty krawędzi
        [self addBorderGradientsToView:container 
                           withColors:gradientColors 
                          attributes:gradientAttributes];
        
        return container;
    };

    // Create left menu scroll view
    UIScrollView *leftMenuScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(leftScrollViewX, 67.3333 + labelHeight + 5, scrollViewWidth, switchAreaHeight)];
    leftMenuScrollView.backgroundColor = [UIColor clearColor];
    leftMenuScrollView.userInteractionEnabled = YES;
    leftMenuScrollView.scrollEnabled = YES;
    leftMenuScrollView.showsVerticalScrollIndicator = YES;
    leftMenuScrollView.bounces = YES;
    leftMenuScrollView.hidden = YES;
    leftMenuScrollView.tag = 583;
    leftMenuScrollView.delegate = (id<UIScrollViewDelegate>)self;
    leftMenuScrollView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    [self customizeScrollIndicator:leftMenuScrollView];
    [menuView addSubview:leftMenuScrollView];

    // Create right menu scroll view
    UIScrollView *rightMenuScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(rightScrollViewX, 67.3333 + labelHeight + 5, scrollViewWidth, switchAreaHeight)];
    rightMenuScrollView.backgroundColor = [UIColor clearColor];
    rightMenuScrollView.userInteractionEnabled = YES;
    rightMenuScrollView.scrollEnabled = YES;
    rightMenuScrollView.showsVerticalScrollIndicator = YES;
    rightMenuScrollView.bounces = YES;
    rightMenuScrollView.hidden = YES;
    rightMenuScrollView.tag = 584;
    rightMenuScrollView.delegate = (id<UIScrollViewDelegate>)self;
    rightMenuScrollView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    [self customizeScrollIndicator:rightMenuScrollView];
    [menuView addSubview:rightMenuScrollView];

    // Menu Label
    UILabel *menuLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.666667, 67.3333, 620, labelHeight)];
    menuLabel.text = @"Menu Settings";
    menuLabel.textColor = [UIColor whiteColor];
    menuLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:16];
    menuLabel.textAlignment = NSTextAlignmentCenter;
    menuLabel.hidden = YES;
    menuLabel.tag = 590;
    [menuView addSubview:menuLabel];

    // Podstawowe opcje menu
    NSArray *baseLeftTitles = @[
        @"Dragable Menu", @"Menu Scale", @"Menu Opacity", @"Menu Animation", @"Auto-Hide Menu", @"Streamer Mode"
    ];

    NSArray *baseLeftIcons = @[
        @"hand.draw.fill", @"arrow.up.backward.and.arrow.down.forward", @"circle.lefthalf.fill", 
        @"sparkles", @"eye.slash.fill", @"camera.viewfinder"
    ];

    NSArray *baseRightTitles = @[
        @"Background Blur", @"Custom Colors", @"Font Style", @"RGB Cycle", @"Telegram"
    ];

    NSArray *baseRightIcons = @[
        @"camera.filters", @"eyedropper.full", @"textformat", @"sparkles", @"paperplane.fill"
    ];

    // Przypisz finalne tablice do statycznych zmiennych
    leftMenuTitles = [baseLeftTitles copy];
    leftMenuIcons = [baseLeftIcons copy];
    rightMenuTitles = [baseRightTitles copy];
    rightMenuIcons = [baseRightIcons copy];

    CGFloat leftContentHeight = switchStartY;
    CGFloat rightContentHeight = switchStartY;

    // Add left menu options
    for (NSUInteger i = 0; i < leftMenuTitles.count; i++) {
        UIView *containerView = createContainerView(CGRectMake(10, leftContentHeight + i * switchSpacing, scrollViewWidth - 20, 30), leftMenuTitles[i], leftMenuIcons[i]);

        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 20, 20)];
        iconView.image = [UIImage systemImageNamed:leftMenuIcons[i]];
        iconView.tintColor = [UIColor whiteColor];
        [containerView addSubview:iconView];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, scrollViewWidth - 85, 30)];
        label.text = leftMenuTitles[i];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
        [containerView addSubview:label];

        // Dodaj odpowiedni kontroler w zależności od typu opcji
        if ([leftMenuTitles[i] isEqualToString:@"Menu Opacity"] || 
            [leftMenuTitles[i] isEqualToString:@"Menu Scale"]) {
            UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(containerView.frame.size.width - 100, 0, 90, 31)];
            slider.minimumValue = 0.0;
            slider.maximumValue = 1.0;
            slider.value = [[NSUserDefaults standardUserDefaults] floatForKey:[leftMenuTitles[i] stringByReplacingOccurrencesOfString:@" " withString:@""]];
            slider.tintColor = [UIColor colorWithCGColor:RightGradient];
            slider.continuous = YES;
            
            if ([leftMenuTitles[i] isEqualToString:@"Menu Scale"]) {
                slider.tag = 1001;
                slider.minimumValue = 0.8;
                slider.maximumValue = 1.2;
                slider.value = 1.0;
                [slider addTarget:self action:@selector(menuScaleChanged:) forControlEvents:UIControlEventValueChanged];
            } else if ([leftMenuTitles[i] isEqualToString:@"Menu Opacity"]) {
                slider.tag = 1002;
                slider.value = 0.77; // Domyślna wartość
                [slider addTarget:self action:@selector(menuOpacityChanged:) forControlEvents:UIControlEventValueChanged];
            }
            
            [containerView addSubview:slider];
        } else if ([leftMenuTitles[i] isEqualToString:@"Menu Style"] || 
                   [leftMenuTitles[i] isEqualToString:@"Menu Border Style"] || 
                   [leftMenuTitles[i] isEqualToString:@"Menu Animation"]) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.frame = CGRectMake(containerView.frame.size.width - 45, 0, 35, 31);
            
            UIImageConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:15 weight:UIImageSymbolWeightMedium];
            UIImage *chevronImage = [UIImage systemImageNamed:@"chevron.right.circle.fill" withConfiguration:config];
            [button setImage:chevronImage forState:UIControlStateNormal];
            
            button.tintColor = [UIColor whiteColor];
            if ([leftMenuTitles[i] isEqualToString:@"Menu Animation"]) {
                button.enabled = YES;
                [button addTarget:self 
                         action:@selector(showAnimationOptions:) 
               forControlEvents:UIControlEventTouchUpInside];
            } else {
                [button addTarget:self 
                         action:@selector(showStyleOptions:) 
               forControlEvents:UIControlEventTouchUpInside];
            }
            [containerView addSubview:button];
        } else if ([leftMenuTitles[i] isEqualToString:@"Dragable Menu"]) {
            UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(containerView.frame.size.width - 55, 0, 51, 31)];
            toggle.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"DragableMenu"];
            toggle.onTintColor = [UIColor colorWithCGColor:RightGradient];
            [toggle addTarget:[NFramework class] 
                       action:@selector(dragableMenuToggleChanged:) 
             forControlEvents:UIControlEventValueChanged];
            [containerView addSubview:toggle];
        } else if ([leftMenuTitles[i] isEqualToString:@"Streamer Mode"]) {
            UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(containerView.frame.size.width - 55, 0, 51, 31)];
            toggle.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"StreamerMode"];
            toggle.onTintColor = [UIColor colorWithCGColor:RightGradient];
            [toggle addTarget:self action:@selector(handleScreenshot:) forControlEvents:UIControlEventValueChanged];
            [containerView addSubview:toggle];
            
            // Jeśli toggle jest włączony, od razu dodaj obserwator
            if (toggle.on) {
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(screenCaptured:)
                                                             name:UIApplicationUserDidTakeScreenshotNotification
                                                           object:nil];
            }
        } else {
            UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(containerView.frame.size.width - 55, 0, 51, 31)];
            toggle.on = [[NSUserDefaults standardUserDefaults] boolForKey:[leftMenuTitles[i] stringByReplacingOccurrencesOfString:@" " withString:@""]];
            toggle.onTintColor = [UIColor colorWithCGColor:RightGradient];
            [containerView addSubview:toggle];
        }

        [leftMenuScrollView addSubview:containerView];
        leftContentHeight += switchSpacing;
    }

    // Add right menu options
    for (NSUInteger i = 0; i < rightMenuTitles.count; i++) {
        UIView *containerView = createContainerView(CGRectMake(10, rightContentHeight + i * switchSpacing, scrollViewWidth - 20, 30), rightMenuTitles[i], rightMenuIcons[i]);

        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 20, 20)];
        iconView.image = [UIImage systemImageNamed:rightMenuIcons[i]];
        iconView.tintColor = [UIColor whiteColor];
        [containerView addSubview:iconView];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, scrollViewWidth - 85, 30)];
        label.text = rightMenuTitles[i];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
        [containerView addSubview:label];

        // Dodaj odpowiedni kontroler w zależności od typu opcji
        if ([rightMenuTitles[i] isEqualToString:@"Background Blur"]) {
            UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(containerView.frame.size.width - 100, 0, 90, 31)];
            slider.minimumValue = 0.0;
            slider.maximumValue = 1.0;
            slider.value = 0.77;
            slider.continuous = YES;
            slider.tag = 1003;
            slider.tintColor = [UIColor colorWithCGColor:RightGradient];
            [slider addTarget:self action:@selector(backgroundBlurChanged:) forControlEvents:UIControlEventValueChanged];
            [containerView addSubview:slider];
        } else if ([rightMenuTitles[i] isEqualToString:@"Font Style"]) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.frame = CGRectMake(containerView.frame.size.width - 45, 0, 35, 31);
            
            UIImageConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:15 weight:UIImageSymbolWeightMedium];
            UIImage *chevronImage = [UIImage systemImageNamed:@"chevron.right.circle.fill" withConfiguration:config];
            [button setImage:chevronImage forState:UIControlStateNormal];
            
            button.tintColor = [UIColor whiteColor];
            [button addTarget:self 
                       action:@selector(showFontStyleOptions:) 
             forControlEvents:UIControlEventTouchUpInside];
            [containerView addSubview:button];
        } else if ([rightMenuTitles[i] isEqualToString:@"Custom Colors"] || 
                   [rightMenuTitles[i] isEqualToString:@"Gradient Style"]) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.frame = CGRectMake(containerView.frame.size.width - 45, 0, 35, 31);
            
            UIImageConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:15 weight:UIImageSymbolWeightMedium];
            UIImage *chevronImage = [UIImage systemImageNamed:@"chevron.right.circle.fill" withConfiguration:config];
            [button setImage:chevronImage forState:UIControlStateNormal];
            
            button.tintColor = [UIColor whiteColor];
            [button addTarget:self 
                       action:@selector(showColorOptions:) 
             forControlEvents:UIControlEventTouchUpInside];
            [containerView addSubview:button];
        } else if ([rightMenuTitles[i] isEqualToString:@"RGB Cycle"]) {
            UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(containerView.frame.size.width - 55, 0, 51, 31)];
            toggle.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"RGBCycleEnabled"];
            toggle.onTintColor = [UIColor colorWithCGColor:RightGradient];
            [toggle addTarget:self 
                       action:@selector(rgbCycleToggleChanged:) 
             forControlEvents:UIControlEventValueChanged];
            [containerView addSubview:toggle];
        } else if ([rightMenuTitles[i] isEqualToString:@"Telegram"]) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.frame = CGRectMake(containerView.frame.size.width - 45, 0, 35, 31);
            
            UIImageConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:15 weight:UIImageSymbolWeightMedium];
            UIImage *chevronImage = [UIImage systemImageNamed:@"chevron.right.circle.fill" withConfiguration:config];
            [button setImage:chevronImage forState:UIControlStateNormal];
            
            button.tintColor = [UIColor whiteColor];
            [button addTarget:self 
                       action:@selector(showTelegramWebView:) 
             forControlEvents:UIControlEventTouchUpInside];
            [containerView addSubview:button];
        } else {
            UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(containerView.frame.size.width - 55, 0, 51, 31)];
            toggle.on = [[NSUserDefaults standardUserDefaults] boolForKey:[rightMenuTitles[i] stringByReplacingOccurrencesOfString:@" " withString:@""]];
            toggle.onTintColor = [UIColor colorWithCGColor:RightGradient];
            [containerView addSubview:toggle];
        }

        [rightMenuScrollView addSubview:containerView];
        rightContentHeight += switchSpacing;
    }

    leftMenuScrollView.contentSize = CGSizeMake(scrollViewWidth, MAX(leftContentHeight + 20, 430 + 1));
    rightMenuScrollView.contentSize = CGSizeMake(scrollViewWidth, MAX(rightContentHeight + 20, 430 + 1));

  
}

+ (void)showColorOptions:(UIButton *)sender {
    ColorPickerViewController *colorPickerVC = [[ColorPickerViewController alloc] init];
    colorPickerVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    colorPickerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    colorPickerVC.colorSelectedHandler = ^(UIColor *selectedColor, NSString *gradientType) {
        CGFloat red, green, blue, alpha;
        [selectedColor getRed:&red green:&green blue:&blue alpha:&alpha];
        
        NSString *colorString = [NSString stringWithFormat:@"%f,%f,%f,%f", 
                               red, green, blue, alpha];
        
        if ([gradientType isEqualToString:@"both"]) {
            [[NSUserDefaults standardUserDefaults] setObject:colorString forKey:@"CustomLeftColor"];
            [[NSUserDefaults standardUserDefaults] setObject:colorString forKey:@"CustomRightColor"];
        } else {
            NSString *key = [gradientType isEqualToString:@"left"] ? 
                           @"CustomLeftColor" : @"CustomRightColor";
            [[NSUserDefaults standardUserDefaults] setObject:colorString forKey:key];
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // Inicjalizuj kolory na nowo
        [Colors initializeColors];
        
        // Zaktualizuj UI na głównym wątku
        dispatch_async(dispatch_get_main_queue(), ^{
            // Aktualizuj kolory gradientu
            gradientColors = @[
                (__bridge id)RightGradient,
                (__bridge id)blackColor,
                (__bridge id)blackColor,
                (__bridge id)LeftGradient
            ];
            
            [self updateGradients];
            [self updateMenuColors];
            [self updateSliderColors];
            [MenuView updateGradientColors];
            
            // Zaktualizuj kolor tint dla SF Symbol w przycisku zamykania
            if (closeButton) {
                [closeButton setTintColor:[UIColor colorWithCGColor:RightGradient]];
            }
            
            // Wymuś odświeżenie widoku
            UIScrollView *leftScroll = (UIScrollView *)[menuView viewWithTag:583];
            UIScrollView *rightScroll = (UIScrollView *)[menuView viewWithTag:584];
            [leftScroll setNeedsDisplay];
            [rightScroll setNeedsDisplay];
            
            // Usuń bezpośrednie odwołania do celebrationContainer
            // Zamiast tego wyślij notyfikację do NFramework
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGradientColors" object:nil];
        });
    };
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (!window) {
        window = [[[UIApplication sharedApplication] windows] firstObject];
    }
    [window.rootViewController presentViewController:colorPickerVC animated:YES completion:nil];
}

+ (void)updateSliderColors {
    UIScrollView *leftScroll = (UIScrollView *)[menuView viewWithTag:583];
    UIScrollView *rightScroll = (UIScrollView *)[menuView viewWithTag:584];
    
    // Funkcja pomocnicza do aktualizacji sliderów w danym ScrollView
    void (^updateSlidersInView)(UIScrollView *) = ^(UIScrollView *scrollView) {
        for (UIView *containerView in scrollView.subviews) {
            for (UIView *subview in containerView.subviews) {
                if ([subview isKindOfClass:[UISlider class]]) {
                    UISlider *slider = (UISlider *)subview;
                    slider.minimumTrackTintColor = [UIColor colorWithCGColor:RightGradient];
                }
            }
        }
    };
    
    // Aktualizuj slidery w obu ScrollView
    updateSlidersInView(leftScroll);
    updateSlidersInView(rightScroll);
}

+ (void)updateGradients {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gradientUpdateQueue = dispatch_queue_create("com.ninja.gradientupdate", DISPATCH_QUEUE_SERIAL);
    });
    
    [self updateGradientColors];
    
    dispatch_async(gradientUpdateQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            
            UIScrollView *leftScroll = (UIScrollView *)[menuView viewWithTag:583];
            UIScrollView *rightScroll = (UIScrollView *)[menuView viewWithTag:584];
            
            // Batch update gradients
            [self batchUpdateGradients:leftScroll.subviews];
            [self batchUpdateGradients:rightScroll.subviews];
            
            // Aktualizuj gradienty linii nad i pod headerem oraz pod segmentedControl
            for (UIView *subview in menuView.subviews) {
                // Znajdź widoki linii gradientu (te z wysokością 2.0 lub 1.5)
                if (subview.frame.size.height == 2.0 || subview.frame.size.height == 1.5) {
                    for (CALayer *layer in subview.layer.sublayers) {
                        if ([layer isKindOfClass:[CAGradientLayer class]]) {
                            ((CAGradientLayer *)layer).colors = gradientColors;
                        }
                    }
                }
                
                // Znajdź secondHeaderView (widok zawierający segmentItems)
                if ([subview isKindOfClass:[UIView class]] && 
                    subview.frame.size.height == 30 && // wysokość secondHeaderView
                    [subview.subviews.firstObject isKindOfClass:[UISegmentedControl class]]) {
                    for (CALayer *layer in subview.layer.sublayers) {
                        if ([layer isKindOfClass:[CAGradientLayer class]]) {
                            ((CAGradientLayer *)layer).colors = gradientColors;
                        }
                    }
                }
                
                // Znajdź segmentedControl i zaktualizuj gradient pod nim
                if ([subview isKindOfClass:[UISegmentedControl class]] && subview.tag == 100) {
                    // Znajdź widok gradientu pod segmentedControl
                    UIView *nextView = [menuView.subviews objectAtIndex:[menuView.subviews indexOfObject:subview] + 1];
                    if (nextView.frame.size.height == 2.0 || nextView.frame.size.height == 1.5) {
                        for (CALayer *layer in nextView.layer.sublayers) {
                            if ([layer isKindOfClass:[CAGradientLayer class]]) {
                                ((CAGradientLayer *)layer).colors = gradientColors;
                            }
                        }
                    }
                }
            }
            
            // Aktualizuj closeButton
            if (closeButton) {
               
                [closeButton setTitleColor:[UIColor colorWithCGColor:RightGradient] forState:UIControlStateNormal];
            }
            
            [CATransaction commit];
        });
    });
}

+ (void)batchUpdateGradients:(NSArray *)views {
    for (UIView *view in views) {
        if (![view.layer.sublayers firstObject]) continue;
        
        for (CALayer *layer in view.layer.sublayers) {
            if ([layer isKindOfClass:[CAGradientLayer class]]) {
                ((CAGradientLayer *)layer).colors = gradientColors;
            }
        }
    }
}

+ (void)updateMenuColors {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Znajdź wszystkie przyciski i przełączniki w menu i zaktualizuj ich kolory
        UIScrollView *leftScroll = (UIScrollView *)[menuView viewWithTag:583];
        UIScrollView *rightScroll = (UIScrollView *)[menuView viewWithTag:584];
        
        for (UIView *containerView in leftScroll.subviews) {
            [self updateColorsForContainer:containerView];
        }
        
        for (UIView *containerView in rightScroll.subviews) {
            [self updateColorsForContainer:containerView];
        }
    });
}

+ (void)updateColorsForContainer:(UIView *)containerView {
    for (UIView *subview in containerView.subviews) {
        if ([subview isKindOfClass:[UISwitch class]]) {
            ((UISwitch *)subview).onTintColor = [UIColor colorWithCGColor:RightGradient];
        } else if ([subview isKindOfClass:[UISlider class]]) {
            ((UISlider *)subview).tintColor = [UIColor colorWithCGColor:RightGradient];
        } else if ([subview isKindOfClass:[UIButton class]]) {
            ((UIButton *)subview).tintColor = [UIColor whiteColor];
        }
    }
}

+ (CAGradientLayer *)createGradientLayerWithColors:(NSArray *)colors 
                                      attributes:(NSDictionary *)attributes 
                                          frame:(CGRect)frame {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = frame;
    gradient.colors = colors;
    gradient.locations = attributes[@"locations"];
    gradient.startPoint = [attributes[@"startPoint"] CGPointValue];
    gradient.endPoint = [attributes[@"endPoint"] CGPointValue];
    return gradient;
}

+ (void)addBorderGradientsToView:(UIView *)view 
                     withColors:(NSArray *)colors 
                    attributes:(NSDictionary *)attributes {
    // Górny gradient
    CAGradientLayer *topGradient = [self createGradientLayerWithColors:colors 
                                                           attributes:attributes 
                                                               frame:CGRectMake(0, 0, view.frame.size.width, 1.5)];
    
    // Dolny gradient
    CAGradientLayer *bottomGradient = [self createGradientLayerWithColors:colors 
                                                              attributes:attributes 
                                                                  frame:CGRectMake(0, view.frame.size.height - 1.5, view.frame.size.width, 1.5)];
    
    [view.layer addSublayer:topGradient];
    [view.layer addSublayer:bottomGradient];
}

+ (void)menuScaleChanged:(UISlider *)sender {
    // Zaokrąglij wartość do 2 miejsc po przecinku dla płynniejszej animacji
    float roundedValue = roundf(sender.value * 100) / 100.0;
    menuView.transform = CGAffineTransformMakeScale(roundedValue, roundedValue);
    
    // Zapisz wartość w NSUserDefaults tylko gdy użytkownik puści slider
    if (sender.tracking == NO) {
        [[NSUserDefaults standardUserDefaults] setFloat:roundedValue forKey:@"MenuScale"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void)menuOpacityChanged:(UISlider *)sender {
    float value = sender.value;
    
    // Znajdź darkOverlay i blurView
    for (UIView *subview in menuView.subviews) {
        if ([subview isKindOfClass:[UIVisualEffectView class]]) {
            // Aktualizuj przezroczystość blur efektu
            subview.alpha = value;
        } else if ([subview isKindOfClass:[UIView class]]) {
            CGFloat alpha;
            [subview.backgroundColor getRed:NULL green:NULL blue:NULL alpha:&alpha];
            if (alpha < 1.0) {
                // Aktualizuj przezroczystość ciemnego overlaya
                subview.alpha = value;
            }
        }
    }
    
    if (sender.tracking == NO) {
        [[NSUserDefaults standardUserDefaults] setFloat:value forKey:@"MenuOpacity"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void)backgroundBlurChanged:(UISlider *)sender {
    float value = sender.value;
    
    // Znajdź UIVisualEffectView
    for (UIView *subview in menuView.subviews) {
        if ([subview isKindOfClass:[UIVisualEffectView class]]) {
            UIVisualEffectView *blurView = (UIVisualEffectView *)subview;
            // Dostosuj intensywność rozmycia
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            blurView.effect = blurEffect;
            blurView.alpha = value;
        }
    }
    
    if (sender.tracking == NO) {
        [[NSUserDefaults standardUserDefaults] setFloat:value forKey:@"BackgroundBlur"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (void)expand {
    // ... (istniejący kod)
    
    // Przywróć zapisane wartości
    float savedOpacity = [[NSUserDefaults standardUserDefaults] floatForKey:@"MenuOpacity"];
    float savedBlur = [[NSUserDefaults standardUserDefaults] floatForKey:@"BackgroundBlur"];
    float savedScale = [[NSUserDefaults standardUserDefaults] floatForKey:@"MenuScale"];
    
    // Ustaw domyślne wartości jeśli nie ma zapisanych
    if (savedOpacity == 0) savedOpacity = 0.77;
    if (savedBlur == 0) savedBlur = 0.77;
    if (savedScale == 0) savedScale = 1.0;
    
    // Wczytaj zapisaną czcionkę i zastosuj do całego mod menu
    NSString *savedFont = [[NSUserDefaults standardUserDefaults] objectForKey:@"MenuFontStyle"];
    if (savedFont) {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        if (!keyWindow) {
            for (UIWindow *window in [UIApplication sharedApplication].windows) {
                if (window.isKeyWindow) {
                    keyWindow = window;
                    break;
                }
            }
        }
        [self updateFontForView:keyWindow withFontName:savedFont];
    }
    
    // Zastosuj zapisane wartości
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Znajdź i ustaw slidery na zapisane wartości
        UIScrollView *leftMenuScrollView = [menuView viewWithTag:583];
        UIScrollView *rightMenuScrollView = [menuView viewWithTag:584];
        
        // Przeszukaj oba ScrollView w poszukiwaniu sliderów
        for (UIView *containerView in leftMenuScrollView.subviews) {
            UISlider *opacitySlider = [containerView viewWithTag:1002];
            UISlider *scaleSlider = [containerView viewWithTag:1001];
            
            if (opacitySlider) {
                opacitySlider.value = savedOpacity;
                [self menuOpacityChanged:opacitySlider];
            }
            if (scaleSlider) {
                scaleSlider.value = savedScale;
                [self menuScaleChanged:scaleSlider];
            }
        }
        
        for (UIView *containerView in rightMenuScrollView.subviews) {
            UISlider *blurSlider = [containerView viewWithTag:1003];
            if (blurSlider) {
                blurSlider.value = savedBlur;
                [self backgroundBlurChanged:blurSlider];
            }
        }
    });
    
    // ... (pozostały kod)

    // Po rozwinięciu menu, sprawdź czy RGB Cycle jest włączone
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"RGBCycleEnabled"]) {
        [RGBManager startRGBCycle];
    }
}

+ (void)showFontStyleOptions:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController 
        alertControllerWithTitle:@"Select Font Style" 
        message:@"Choose a font for the menu" 
        preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Zdefiniuj ograniczon listę popularnych czcionek zamiast ładować wszystkie
    NSArray *preferredFonts = @[
        @"ArialRoundedMTBold",
        @"Helvetica",
        @"Helvetica-Bold",
        @"HelveticaNeue",
        @"HelveticaNeue-Bold",
        @"Avenir",
        @"Avenir-Heavy",
        @"AvenirNext-Bold",
        @"Futura",
        @"Futura-Bold",
        @"Georgia",
        @"Georgia-Bold",
        @"SFPro-Regular",
        @"SFPro-Bold",
        @"TimesNewRomanPS",
        @"TimesNewRomanPS-Bold"
    ];
    
    // Dodaj akcje tylko dla preferowanych czcionek
    for (NSString *fontName in preferredFonts) {
        // Sprawdź czy czcionka jest dostępna w systemie
        if ([UIFont fontWithName:fontName size:12.0]) {
            UIAlertAction *action = [UIAlertAction 
                actionWithTitle:fontName 
                style:UIAlertActionStyleDefault 
                handler:^(UIAlertAction *action) {
                    [self changeFontStyle:fontName];
                }];
            [alertController addAction:action];
        }
    }
    
    // Dodaj akcję "Show All Fonts" na końcu listy
    UIAlertAction *showAllAction = [UIAlertAction 
        actionWithTitle:@"Show All Fonts..." 
        style:UIAlertActionStyleDefault 
        handler:^(UIAlertAction *action) {
            [self showAllFontOptions];
        }];
    [alertController addAction:showAllAction];
    
    // Dodaj akcję Anuluj
    UIAlertAction *cancelAction = [UIAlertAction 
        actionWithTitle:@"Cancel" 
        style:UIAlertActionStyleCancel 
        handler:nil];
    [alertController addAction:cancelAction];
    
    // Prezentuj alert
    UIViewController *topVC = [self topViewController];
    [topVC presentViewController:alertController animated:YES completion:nil];
}

// Nowa metoda do pokazywania wszystkich czcionek
+ (void)showAllFontOptions {
    UIAlertController *alertController = [UIAlertController 
        alertControllerWithTitle:@"All Fonts" 
        message:@"Choose a font for the menu" 
        preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Pobierz wszystkie dostępne czcionki systemowe w tle
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *familyNames = [UIFont familyNames];
        NSMutableArray *allFonts = [NSMutableArray array];
        
        for (NSString *familyName in familyNames) {
            NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
            [allFonts addObjectsFromArray:fontNames];
        }
        
        // Posortuj czcionki alfabetycznie
        NSArray *sortedFonts = [allFonts sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        // Wróć na główny wątek aby zaktualizować UI
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSString *fontName in sortedFonts) {
                UIAlertAction *action = [UIAlertAction 
                    actionWithTitle:fontName 
                    style:UIAlertActionStyleDefault 
                    handler:^(UIAlertAction *action) {
                        [self changeFontStyle:fontName];
                    }];
                [alertController addAction:action];
            }
            
            UIAlertAction *cancelAction = [UIAlertAction 
                actionWithTitle:@"Cancel" 
                style:UIAlertActionStyleCancel 
                handler:nil];
            [alertController addAction:cancelAction];
            
            // Prezentuj alert
            UIViewController *topVC = [self topViewController];
            [topVC presentViewController:alertController animated:YES completion:nil];
        });
    });
}

// Metoda pomocnicza do znalezienia aktualnego UIViewController
+ (UIViewController *)topViewController {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIViewController *topController = window.rootViewController;
    
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    
    return topController;
}

// Metoda do zmiany czcionki w całym menu
+ (void)changeFontStyle:(NSString *)fontName {
    // Najpierw sprawdź czy czcionka jest dostępna
    UIFont *testFont = [UIFont fontWithName:fontName size:12.0];
    if (!testFont) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController 
                alertControllerWithTitle:@"Error" 
                message:[NSString stringWithFormat:@"Font %@ is not available on this device", fontName]
                preferredStyle:UIAlertControllerStyleAlert];
                
            UIAlertAction *okAction = [UIAlertAction 
                actionWithTitle:@"OK" 
                style:UIAlertActionStyleDefault 
                handler:nil];
                
            [alert addAction:okAction];
            
            UIViewController *topVC = [self topViewController];
            [topVC presentViewController:alert animated:YES completion:nil];
        });
        return;
    }

    // Zapisz wybraną czcionkę
    [[NSUserDefaults standardUserDefaults] setObject:fontName forKey:@"MenuFontStyle"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        @try {
            // Aktualizuj czcionki w całym mod menu
            UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
            if (!keyWindow) {
                for (UIWindow *window in [UIApplication sharedApplication].windows) {
                    if (window.isKeyWindow) {
                        keyWindow = window;
                        break;
                    }
                }
            }
            
            // Aktualizuj czcionki we wszystkich widokach
            [self updateFontForView:menuView withFontName:fontName];
            
            // Pokaż powiadomienie o zmianie
            UIAlertController *alert = [UIAlertController 
                alertControllerWithTitle:@"Font Style" 
                message:[NSString stringWithFormat:@"Changed to %@", fontName]
                preferredStyle:UIAlertControllerStyleAlert];
                
            UIAlertAction *okAction = [UIAlertAction 
                actionWithTitle:@"OK" 
                style:UIAlertActionStyleDefault 
                handler:nil];
                
            [alert addAction:okAction];
            
            UIViewController *topVC = [self topViewController];
            [topVC presentViewController:alert animated:YES completion:^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [alert dismissViewControllerAnimated:YES completion:nil];
                });
            }];
            
            // Powiadom Layout.x o zmianie czcionki
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateLayoutFont"
                                                            object:nil
                                                          userInfo:@{@"fontName": fontName}];
        } @catch (NSException *exception) {
            NSLog(@"Error changing font: %@", exception);
            UIAlertController *alert = [UIAlertController 
                alertControllerWithTitle:@"Error" 
                message:@"Failed to change font style"
                preferredStyle:UIAlertControllerStyleAlert];
                
            UIAlertAction *okAction = [UIAlertAction 
                actionWithTitle:@"OK" 
                style:UIAlertActionStyleDefault 
                handler:nil];
                
            [alert addAction:okAction];
            
            UIViewController *topVC = [self topViewController];
            [topVC presentViewController:alert animated:YES completion:nil];
        }
    });
}

// Metoda rekurencyjna do aktualizacji czcionek
+ (void)updateFontForView:(UIView *)view withFontName:(NSString *)fontName {
    @try {
        // Aktualizuj czcionkę dla UILabel
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)view;
            CGFloat currentSize = label.font.pointSize;
            UIFont *newFont = [UIFont fontWithName:fontName size:currentSize];
            if (newFont) {
                label.font = newFont;
            }
        }
        // Aktualizuj czcionkę dla UIButton
        else if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            CGFloat currentSize = button.titleLabel.font.pointSize;
            UIFont *newFont = [UIFont fontWithName:fontName size:currentSize];
            if (newFont) {
                button.titleLabel.font = newFont;
            }
        }
        // Aktualizuj czcionkę dla UITextField
        else if ([view isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)view;
            CGFloat currentSize = textField.font.pointSize;
            UIFont *newFont = [UIFont fontWithName:fontName size:currentSize];
            if (newFont) {
                textField.font = newFont;
            }
        }
        // Aktualizuj czcionkę dla UISegmentedControl
        else if ([view isKindOfClass:[UISegmentedControl class]]) {
            UISegmentedControl *segment = (UISegmentedControl *)view;
            UIFont *newFont = [UIFont fontWithName:fontName size:10.0];
            if (newFont) {
                NSDictionary *attributes = @{
                    NSFontAttributeName: newFont
                };
                [segment setTitleTextAttributes:attributes forState:UIControlStateNormal];
            }
        }
        
        // Rekurencyjnie przejdź przez wszystkie podwidoki
        for (UIView *subview in view.subviews) {
            [self updateFontForView:subview withFontName:fontName];
        }
    } @catch (NSException *exception) {
        NSLog(@"Error updating font for view: %@", exception);
    }
}

// Zmodyfikuj metodę updateIGGMemViewFont:
+ (void)updateIGGMemViewFont:(NSString *)fontName {
    // Znajdź wszystkie widoki IGGMemView
    for (UIView *view in menuView.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            
            // Przeszukaj wszystkie podwidoki rekurencyjnie
            [self updateIGGMemViewSubviews:scrollView withFont:fontName];
        }
    }
}

// Dodaj nową metodę pomocniczą do rekurencyjnego przeszukiwania podwidoków IGGMemView
+ (void)updateIGGMemViewSubviews:(UIView *)view withFont:(NSString *)fontName {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)subview;
            CGFloat currentSize = label.font.pointSize;
            label.font = [UIFont fontWithName:fontName size:currentSize];
        } 
        else if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            CGFloat currentSize = button.titleLabel.font.pointSize;
            button.titleLabel.font = [UIFont fontWithName:fontName size:currentSize];
        } 
        else if ([subview isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)subview;
            CGFloat currentSize = textField.font.pointSize;
            textField.font = [UIFont fontWithName:fontName size:currentSize];
        } 
        else if ([subview isKindOfClass:[UISegmentedControl class]]) {
            UISegmentedControl *segment = (UISegmentedControl *)subview;
            NSDictionary *attributes = @{
                NSFontAttributeName: [UIFont fontWithName:fontName size:10.0]
            };
            [segment setTitleTextAttributes:attributes forState:UIControlStateNormal];
        }
        
        // Rekurencyjnie przeszukaj podwidoki
        if (subview.subviews.count > 0) {
            [self updateIGGMemViewSubviews:subview withFont:fontName];
        }
    }
}

// Dodaj metodę do aktualizacji segmentów w NFramework
+ (void)updateNFrameworkSegments:(NSString *)fontName {
    // Znajdź wszystkie segmenty w głównym widoku
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        for (UIView *view in window.subviews) {
            [self updateSegmentsInView:view withFont:fontName];
        }
    }
}

// Dodaj metodę pomocniczą do rekurencyjnego przeszukiwania segmentów
+ (void)updateSegmentsInView:(UIView *)view withFont:(NSString *)fontName {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UISegmentedControl class]]) {
            UISegmentedControl *segment = (UISegmentedControl *)subview;
            NSDictionary *attributes = @{
                NSFontAttributeName: [UIFont fontWithName:fontName size:10.0]
            };
            [segment setTitleTextAttributes:attributes forState:UIControlStateNormal];
        }
        
        // Rekurencyjnie przeszukaj podwidoki
        if (subview.subviews.count > 0) {
            [self updateSegmentsInView:subview withFont:fontName];
        }
    }
}

+ (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self customizeScrollIndicator:scrollView];
    
    CGPoint velocity = [scrollView.panGestureRecognizer velocityInView:scrollView];
    CGFloat scrollSpeed = fabs(velocity.y);
    
    AnimationStyle style = (AnimationStyle)[[NSUserDefaults standardUserDefaults] integerForKey:@"MenuAnimationStyle"];
    
    // Jeśli nie wybrano stylu animacji lub scrollSpeed jest zbyt mała, nie rób nic
    if (style == AnimationStyleNone || scrollSpeed < 50) {
        return;
    }
    
    // Reszta istniejącego kodu animacji...
}

+ (void)showAnimationOptions:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController 
        alertControllerWithTitle:@"Menu Animation" 
        message:@"Choose animation style" 
        preferredStyle:UIAlertControllerStyleActionSheet];
        
    NSArray *styles = @[
        @"None",
        @"Slide",
        @"Rotate",
        @"Wave",
        @"Spin",
        @"Zoom",
        @"Matrix"
    ];
    
    for (NSUInteger i = 0; i < styles.count; i++) {
        UIAlertAction *action = [UIAlertAction 
            actionWithTitle:styles[i] 
            style:UIAlertActionStyleDefault 
            handler:^(UIAlertAction *action) {
                // Zapisz nowy styl
                [[NSUserDefaults standardUserDefaults] setInteger:i forKey:@"MenuAnimationStyle"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                // Znajdź i zresetuj oba ScrollView
                UIScrollView *leftScroll = (UIScrollView *)[menuView viewWithTag:583];
                UIScrollView *rightScroll = (UIScrollView *)[menuView viewWithTag:584];
                
                // Resetuj wszystkie widoki
                [self resetViews:leftScroll];
                [self resetViews:rightScroll];
            }];
        [alert addAction:action];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction 
        actionWithTitle:@"Cancel" 
        style:UIAlertActionStyleCancel 
        handler:nil];
    [alert addAction:cancelAction];
    
    UIViewController *topVC = [self topViewController];
    [topVC presentViewController:alert animated:YES completion:nil];
}

// Najpierw dodaj metody animacji wejścia
+ (void)animateView:(UIView *)view withStyle:(AnimationStyle)style duration:(NSTimeInterval)duration {
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (style) {
            case AnimationStyleNone:
                // Nic nie rób dla AnimationStyleNone
                break;
                
            case AnimationStyleSlide: {
                CGRect original = view.frame;
                CGRect newFrame = original;
                newFrame.origin.x += original.size.width;
                view.frame = newFrame;
                [UIView animateWithDuration:duration animations:^{
                    view.frame = original;
                }];
                break;
            }
            
            case AnimationStyleRotate: {
                CGAffineTransform originalTransform = view.transform;
                view.transform = CGAffineTransformMakeRotation(M_PI);
                [UIView animateWithDuration:duration animations:^{
                    view.transform = originalTransform;
                }];
                break;
            }
            
            case AnimationStyleWave: {
                CGAffineTransform originalTransform = view.transform;
                view.transform = CGAffineTransformMakeTranslation(-20, 0);
                [UIView animateWithDuration:duration animations:^{
                    view.transform = originalTransform;
                }];
                break;
            }
            
            case AnimationStyleSpin: {
                CGAffineTransform originalTransform = view.transform;
                view.transform = CGAffineTransformMakeRotation(M_PI * 2);
                [UIView animateWithDuration:duration animations:^{
                    view.transform = originalTransform;
                }];
                break;
            }
            
            case AnimationStyleZoom: {
                CGAffineTransform originalTransform = view.transform;
                view.transform = CGAffineTransformMakeScale(0.1, 0.1);
                [UIView animateWithDuration:duration animations:^{
                    view.transform = originalTransform;
                }];
                break;
            }
            
            case AnimationStyleMatrix: {
                // Przygotuj początkową transformację dla ikony
                for (UIView *subview in view.subviews) {
                    if ([subview isKindOfClass:[UIImageView class]]) {
                        subview.transform = CGAffineTransformMakeRotation(M_PI * 2);
                    }
                    else if ([subview isKindOfClass:[UILabel class]]) {
                        UILabel *label = (UILabel *)subview;
                        label.textColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0]; // Zielony, ale przezroczysty
                    }
                    else if ([subview isKindOfClass:[UISwitch class]]) {
                        UISwitch *toggle = (UISwitch *)subview;
                        toggle.alpha = 0;
                        toggle.backgroundColor = [UIColor blackColor];
                        toggle.layer.cornerRadius = toggle.frame.size.height / 2;
                    }
                }
                
                [UIView animateWithDuration:duration animations:^{
                    for (UIView *subview in view.subviews) {
                        if ([subview isKindOfClass:[UIImageView class]]) {
                            subview.transform = CGAffineTransformIdentity;
                        }
                        else if ([subview isKindOfClass:[UILabel class]]) {
                            UILabel *label = (UILabel *)subview;
                            label.textColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1.0];
                        }
                        else if ([subview isKindOfClass:[UISwitch class]]) {
                            subview.alpha = 1.0;
                        }
                    }
                }];
                break;
            }
        }
    });
}

+ (void)rgbCycleToggleChanged:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"RGBCycleEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (sender.isOn) {
        [RGBManager startRGBCycle];
    } else {
        [RGBManager stopRGBCycle];
    }
}

+ (void)customizeScrollIndicator:(UIScrollView *)scrollView {
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
                // Sprawdź czy RGB Cycle jest włączony
                if ([RGBManager isEnabled]) {
                    // Użyj aktualnego koloru RGB
                    indicatorLayer.backgroundColor = [RGBManager currentGradientColor].CGColor;
                } else {
                    // Użyj standardowego koloru gradientu
                    indicatorLayer.backgroundColor = RightGradient;
                }
                
                indicatorLayer.cornerRadius = 1.5;
                indicatorLayer.opacity = 1.0;
                
                // Upewnij się, że wskaźnik jest widoczny
                indicatorView.alpha = 1.0;
                indicatorView.hidden = NO;
            }
        }
    }
}

+ (void)resetViews:(UIScrollView *)scrollView {
    [UIView animateWithDuration:0.3 
                      delay:0 
                    options:UIViewAnimationOptionBeginFromCurrentState 
                 animations:^{
        for (UIView *containerView in scrollView.subviews) {
            if (containerView.frame.size.height == 30 && 
                [containerView.layer.sublayers.firstObject isKindOfClass:[CAGradientLayer class]]) {
                containerView.transform = CGAffineTransformIdentity;
                containerView.alpha = 1.0;
                
                // Resetuj wszystkie podwidoki
                for (UIView *subview in containerView.subviews) {
                    subview.transform = CGAffineTransformIdentity;
                    subview.alpha = 1.0;
                    
                    // Przywróć oryginalny tekst i kolory dla animacji Matrix
                    if ([subview isKindOfClass:[UILabel class]]) {
                        UILabel *label = (UILabel *)subview;
                        label.textColor = [UIColor whiteColor];
                        
                        // Znajdź oryginalny tekst na podstawie indeksu w menu
                        NSInteger index = [containerView.superview.subviews indexOfObject:containerView];
                        if (containerView.superview.tag == 583) { // Left menu
                            label.text = leftMenuTitles[index];
                        } else if (containerView.superview.tag == 584) { // Right menu
                            label.text = rightMenuTitles[index];
                        }
                    }
                }
            }
        }
    } completion:nil];
}

+ (void)showTelegramWebView:(UIButton *)sender {
    // Znajdź scrollViews i label
    UIScrollView *leftScroll = (UIScrollView *)[menuView viewWithTag:583];
    UIScrollView *rightScroll = (UIScrollView *)[menuView viewWithTag:584];
    UILabel *menuLabel = (UILabel *)[menuView viewWithTag:590];
    
    // Stwórz WKWebView w obszarze od segmentu do footera
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 67.3333,
                                                                 menuView.bounds.size.width,
                                                                 248)];
    webView.backgroundColor = [UIColor blackColor];
    
    // Ustaw minimalną i maksymalną skalę oraz początkową skalę
    [webView.scrollView setMinimumZoomScale:0.5];
    [webView.scrollView setMaximumZoomScale:1.0];
    webView.scrollView.zoomScale = 0.7; // Możesz dostosować tę wartość (0.5 - 1.0)
    
    // Dostosuj wielkość zawartości
    NSString *jScript = @"var meta = document.createElement('meta'); \
                         meta.setAttribute('name', 'viewport'); \
                         meta.setAttribute('content', 'width=device-width, initial-scale=0.7, maximum-scale=1.0, minimum-scale=0.5'); \
                         document.getElementsByTagName('head')[0].appendChild(meta);";
    
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript
                                                    injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                 forMainFrameOnly:YES];
    [webView.configuration.userContentController addUserScript:wkUScript];
    
    // Stwórz URL i załaduj stronę
    NSURL *url = [NSURL URLWithString:@"https://web.telegram.org/k/#-1982478378"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    
    // Stwórz przycisk zamykania i umieść go w prawym górnym rogu webView
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    closeButton.frame = CGRectMake(webView.frame.size.width - 40, 10, 30, 30);
    [closeButton setTitle:@"✕" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    closeButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [closeButton addTarget:self action:@selector(closeTelegramWebView:) forControlEvents:UIControlEventTouchUpInside];
    
    // Ukryj scrollViews i label
    leftScroll.hidden = YES;
    rightScroll.hidden = YES;
    menuLabel.hidden = YES;
    
    // Dodaj WebView i przycisk zamykania bezpośrednio do menuView
    [menuView addSubview:webView];
    [menuView addSubview:closeButton];
    
    // Zapisz tag dla WebView aby móc go później zidentyfikować
    webView.tag = 999;
    closeButton.tag = 1000;
}

+ (void)closeTelegramWebView:(UIButton *)sender {
    // Znajdź i usuń WebView oraz przycisk zamykania
    UIView *webView = [menuView viewWithTag:999];
    UIView *closeButton = [menuView viewWithTag:1000];
    
    // Znajdź scrollViews i label
    UIScrollView *leftScroll = (UIScrollView *)[menuView viewWithTag:583];
    UIScrollView *rightScroll = (UIScrollView *)[menuView viewWithTag:584];
    UILabel *menuLabel = (UILabel *)[menuView viewWithTag:590];
    
    [UIView animateWithDuration:0.3 animations:^{
        webView.alpha = 0;
        closeButton.alpha = 0;
    } completion:^(BOOL finished) {
        [webView removeFromSuperview];
        [closeButton removeFromSuperview];
        
        // Pokaż z powrotem scrollViews i label
        leftScroll.hidden = NO;
        rightScroll.hidden = NO;
        menuLabel.hidden = NO;
    }];
}
// Zmodyfikuj metodę handleScreenshot:
+ (void)handleScreenshot:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"HideOnScreenshot"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (sender.isOn) {
        if (!hideView) {
            hideView = [self createSecureView];
            [menuView addSubview:hideView];
        }
        
        // Dodaj obserwator screenshotów
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(screenCaptured:)
                                                     name:UIApplicationUserDidTakeScreenshotNotification
                                                   object:nil];
                                                   
        // Powiadom Layout.x o włączeniu zabezpieczenia
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EnableScreenshotProtection" 
                                                          object:nil];
    } else {
        // Przywróć wszystkie podwidoki z powrotem do menu
        if (hideView) {
            UIView *clearView = hideView.subviews.firstObject.subviews.firstObject;
            NSArray *subviews = [clearView subviews];
            for (UIView *view in subviews) {
                [menuView addSubview:view];
            }
            
            [hideView removeFromSuperview];
            hideView = nil;
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                      name:UIApplicationUserDidTakeScreenshotNotification
                                                    object:nil];
                                                    
        // Powiadom Layout.x o wyłączeniu zabezpieczenia
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DisableScreenshotProtection" 
                                                          object:nil];
    }
}

+ (void)screenCaptured:(NSNotification *)notification {
    // Możemy zostawić tę metodę pustą, ponieważ zabezpieczenie działa automatycznie
}

// Dodaj nową metodę do tworzenia widoku zabezpieczającego
+ (UIView *)createSecureView {
    UIView *containerView = [[UIView alloc] initWithFrame:menuView.bounds];
    
    UITextField *textField = [[UITextField alloc] init];
    textField.secureTextEntry = YES;
    textField.frame = containerView.bounds;
    [containerView addSubview:textField];
    
    UIView *clearView = [[UIView alloc] init];
    clearView.frame = containerView.bounds;
    [textField.subviews.firstObject addSubview:clearView];
    
    // Przenieś wszystkie podwidoki menu do clearView
    NSArray *subviews = [menuView subviews];
    for (UIView *view in subviews) {
        [clearView addSubview:view];
    }
    
    return containerView;
}

@end 