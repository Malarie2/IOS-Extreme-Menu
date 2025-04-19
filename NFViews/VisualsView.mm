#import "VisualsView.h"
#import "Magicolors/ColorsHandler.h"
#import "NFToggles.h"
#import "SDKCheats/Jump.h"
#import "NFramework.h"
#import <objc/runtime.h> 
#import "Cheat/Offsets.h"
#import "Magicolors/ColorPicker.h"

// Deklaracja zewnętrznej zmiennej BaseAddress
extern uintptr_t BaseAddress;

struct FLinearColor {
    float R;
    float G;
    float B;
    float A;
    
    FLinearColor() : R(0), G(0), B(0), A(1) {}
    FLinearColor(float r, float g, float b, float a) : R(r), G(g), B(b), A(a) {}
};

void SetTotemAuraColor(const FLinearColor& color) {
    uintptr_t World = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
    if (!World) return;
    
    uintptr_t GameState = *(uintptr_t*)(World + Offsets::SDK::UWorldToGameState);
    if (!GameState) return;

    uintptr_t _totems = *(uintptr_t*)(GameState + Offsets::SDK::ADBDGameStateTo_totems);
    int32_t _totemsCount = *(int32_t*)(GameState + Offsets::SDK::ADBDGameStateTo_totems + Offsets::Special::TArrayToCount);
    
    if (_totemsCount == 0) return;

    int modifiedTotems = 0;
    
    for (int g = 0; g < _totemsCount && _totems != 0; g++) {
        uintptr_t Totem = *(uintptr_t*)(_totems + g * Offsets::Special::PointerSize);
        if (!Totem) continue;
        
        @try {
            // Zmień kolor aury totemu
            FLinearColor* auraColor = (FLinearColor*)(Totem + 0x388);
            if (auraColor) {
                *auraColor = color;
            }
            
            // Zmień kolor w komponencie outline strategy
            uintptr_t outlineStrategy = *(uintptr_t*)(Totem + 0x450);
            if (outlineStrategy) {
                FLinearColor* revealedColor = (FLinearColor*)(outlineStrategy + 0x138);
                FLinearColor* boonColor = (FLinearColor*)(outlineStrategy + 0x148);
                
                if (revealedColor) *revealedColor = color;
                if (boonColor) *boonColor = color;
            }
            
            modifiedTotems++;
        } @catch (NSException *exception) {
            continue;
        }
    }
}

@implementation VisualsView

+ (void)createVisualsView:(UIView *)menuView {
    CGFloat menuWidth = 620;
    CGFloat labelHeight = 25;
    CGFloat switchAreaHeight = 210;
    CGFloat scrollViewWidth = (menuWidth - 20) / 2; // Subtract padding and divide by 2
    CGFloat scrollViewSpacing = 20; // Space between scroll views
    CGFloat leftScrollViewX = (menuWidth - (scrollViewWidth * 2 + scrollViewSpacing)) / 2;
    CGFloat rightScrollViewX = leftScrollViewX + scrollViewWidth + scrollViewSpacing;
    CGFloat switchStartY = 3;
    CGFloat switchSpacing = 18;

    // Add scroll view for  Color toggles
    UIScrollView *auraColorScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(leftScrollViewX, 67.3333 + labelHeight + 5, scrollViewWidth, switchAreaHeight)];
    auraColorScrollView.backgroundColor = [UIColor clearColor];
    auraColorScrollView.userInteractionEnabled = YES;
    auraColorScrollView.scrollEnabled = YES;
    auraColorScrollView.showsVerticalScrollIndicator = YES;
    auraColorScrollView.bounces = YES;
    auraColorScrollView.hidden = YES;
    auraColorScrollView.tag = 53;
    [menuView addSubview:auraColorScrollView];

    // Add scroll view for DBDM UI toggles
    UIScrollView *dbdmUIScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(rightScrollViewX, 67.3333 + labelHeight + 5, scrollViewWidth, switchAreaHeight)];
    dbdmUIScrollView.backgroundColor = [UIColor clearColor];
    dbdmUIScrollView.userInteractionEnabled = YES;
    dbdmUIScrollView.scrollEnabled = YES;
    dbdmUIScrollView.showsVerticalScrollIndicator = YES;
    dbdmUIScrollView.bounces = YES;
    dbdmUIScrollView.hidden = YES;
    dbdmUIScrollView.tag = 54;
    [menuView addSubview:dbdmUIScrollView];

    // Visuals Label
    UILabel *visualsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.666667, 67.3333, menuWidth, labelHeight)];
    visualsLabel.text = @"Visuals";
    visualsLabel.textColor = [UIColor whiteColor];
    visualsLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:16];
    visualsLabel.textAlignment = NSTextAlignmentCenter;
    visualsLabel.hidden = YES;
    visualsLabel.tag = 55;
    [menuView addSubview:visualsLabel];

    // Aura Color Label
    UILabel *auraColorLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftScrollViewX, 67.3333, scrollViewWidth, labelHeight)];
    auraColorLabel.text = @"Aura Color";
    auraColorLabel.textColor = [UIColor whiteColor];
    auraColorLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:16];
    auraColorLabel.textAlignment = NSTextAlignmentCenter;
    auraColorLabel.hidden = YES;
    auraColorLabel.tag = 56;
    [menuView addSubview:auraColorLabel];

    // DBDM UI Label
    UILabel *dbdmUILabel = [[UILabel alloc] initWithFrame:CGRectMake(rightScrollViewX, 67.3333, scrollViewWidth, labelHeight)];
    dbdmUILabel.text = @"DBDM UI";
    dbdmUILabel.textColor = [UIColor whiteColor];
    dbdmUILabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:16];
    dbdmUILabel.textAlignment = NSTextAlignmentCenter;
    dbdmUILabel.hidden = YES;
    dbdmUILabel.tag = 57;
    [menuView addSubview:dbdmUILabel];
    // Aura Color toggles with SF Symbols
    NSArray *auraColorToggles = @[
        @{@"title": @"Aura Totem Color", @"selector": @"openColorPicker:", @"symbol": @"paintpalette.fill", @"color": [UIColor whiteColor]},
        @{@"title": @"Aura Generators Red", @"symbol": @"circle.fill", @"color": [UIColor whiteColor]},
        @{@"title": @"Aura Generators Green", @"symbol": @"circle.fill", @"color": [UIColor whiteColor]},
        @{@"title": @"Aura Generators Blue", @"symbol": @"circle.fill", @"color": [UIColor whiteColor]},
        @{@"title": @"Aura Generators Pink", @"symbol": @"circle.fill", @"color": [UIColor whiteColor]},
        @{@"title": @"Aura Generators Purple", @"symbol": @"circle.fill", @"color": [UIColor whiteColor]},
        @{@"title": @"Aura Generators Yellow", @"symbol": @"circle.fill", @"color": [UIColor whiteColor]},
        @{@"title": @"Aura Generators Cyan", @"symbol": @"circle.fill", @"color": [UIColor whiteColor]},
        @{@"title": @"Aura White (Render)", @"symbol": @"circle.fill", @"color": [UIColor whiteColor]},
        @{@"title": @"Aura Hooks Blue", @"selector": @"HookBlue:", @"symbol": @"circle.fill", @"color": [UIColor whiteColor]},
        @{@"title": @"Aura Hooks Purple", @"selector": @"HookPurple:", @"symbol": @"circle.fill", @"color": [UIColor whiteColor]},
        @{@"title": @"Aura Hooks Yellow", @"selector": @"HookYellow:", @"symbol": @"circle.fill", @"color": [UIColor whiteColor]},
        @{@"title": @"Aura Hooks Green", @"selector": @"HookGreen:", @"symbol": @"circle.fill", @"color": [UIColor whiteColor]},
        @{@"title": @"Aura Hooks Red", @"selector": @"HookRed:", @"symbol": @"circle.fill", @"color": [UIColor whiteColor]},
        @{@"title": @"Aura Hooks Orange", @"selector": @"HookOrange:", @"symbol": @"circle.fill", @"color": [UIColor whiteColor]},
        @{@"title": @"Aura Hooks White", @"selector": @"HookWhite:", @"symbol": @"circle.fill", @"color": [UIColor whiteColor]},
    ];

    // DBDM UI toggles
    NSArray *dbdmUIToggles = @[
        @{@"title": @"DBD UI Theme Red", @"selector": @"DBDUIThemeRed:", @"symbol": @"paintbrush.fill", @"color": [UIColor whiteColor]},
        @{@"title": @"DBD UI Theme Blue", @"selector": @"DBDUIThemeBlue:", @"symbol": @"paintbrush.fill", @"color": [UIColor whiteColor]},
        @{@"title": @"DBD UI Theme Green", @"selector": @"DBDUIThemeGreen:", @"symbol": @"paintbrush.fill", @"color": [UIColor whiteColor]},
        @{@"title": @"DBD UI Theme Orange", @"selector": @"DBDUIThemeOrange:", @"symbol": @"paintbrush.fill", @"color": [UIColor whiteColor]},
        @{@"title": @"DBD UI Theme Pink", @"selector": @"DBDUIThemePink:", @"symbol": @"paintbrush.fill", @"color": [UIColor whiteColor]},
        @{@"title": @"DBD UI Theme Rainbow", @"selector": @"DBDUIThemeRainbow:", @"symbol": @"paintbrush.fill", @"color": [UIColor whiteColor]},
        @{@"title": @"DBD UI Theme Cutie", @"selector": @"DBDUIThemeCutie:", @"symbol": @"paintbrush.fill", @"color": [UIColor whiteColor]},
        @{@"title": @"DBD UI Theme Warrior Green", @"selector": @"DBDUIThemeWarriorGreen:", @"symbol": @"paintbrush.fill", @"color": [UIColor whiteColor]},
        @{@"title": @"DBD UI Theme Ultra Blue", @"selector": @"DBDUIThemeUltraBlue:", @"symbol": @"paintbrush.fill", @"color": [UIColor whiteColor]},
   ];

    // Add Aura Color toggles
    CGFloat auraColorHeight = switchStartY;
    for (NSUInteger i = 0; i < auraColorToggles.count; i++) {
        NSDictionary *toggleInfo = auraColorToggles[i];
        NSString *title = toggleInfo[@"title"];
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:", [title stringByReplacingOccurrencesOfString:@" " withString:@""]]);
        
        // Stwórz kontener dla ikony i tekstu z gradientowym tłem
        UIView *switchContainer = [[UIView alloc] initWithFrame:CGRectMake(10, auraColorHeight + i * switchSpacing, scrollViewWidth - 20, 30)];
        switchContainer.layer.cornerRadius = 5;
        switchContainer.clipsToBounds = YES;

        // Stwórz główny gradient layer dla tła
        CAGradientLayer *backgroundGradient = [CAGradientLayer layer];
        backgroundGradient.frame = switchContainer.bounds;
        backgroundGradient.colors = @[
            (__bridge id)RightGradient,
            (__bridge id)blackColor,
            (__bridge id)blackColor,
            (__bridge id)LeftGradient
        ];
        backgroundGradient.locations = @[@0.0, @0.3, @0.7, @1.0];
        backgroundGradient.startPoint = CGPointMake(0, 0.5);
        backgroundGradient.endPoint = CGPointMake(1, 0.5);
        [switchContainer.layer insertSublayer:backgroundGradient atIndex:0];

        // Dodaj gradienty dla górnej i dolnej linii
        CAGradientLayer *topGradient = [CAGradientLayer layer];
        CAGradientLayer *bottomGradient = [CAGradientLayer layer];

        topGradient.frame = CGRectMake(0, 0, switchContainer.frame.size.width, 1.5);
        bottomGradient.frame = CGRectMake(0, switchContainer.frame.size.height - 1.5, switchContainer.frame.size.width, 1.5);

        topGradient.colors = @[
            (__bridge id)RightGradient,
            (__bridge id)blackColor,
            (__bridge id)blackColor,
            (__bridge id)LeftGradient
        ];
        bottomGradient.colors = topGradient.colors;

        topGradient.locations = @[@0.0, @0.3, @0.7, @1.0];
        bottomGradient.locations = topGradient.locations;

        topGradient.startPoint = CGPointMake(0, 0.5);
        topGradient.endPoint = CGPointMake(1, 0.5);
        bottomGradient.startPoint = topGradient.startPoint;
        bottomGradient.endPoint = topGradient.endPoint;

        [switchContainer.layer addSublayer:topGradient];
        [switchContainer.layer addSublayer:bottomGradient];

        // Tworzenie UIImageView z SF Symbol
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 20, 20)];
        UIImage *symbolImage = [UIImage systemImageNamed:toggleInfo[@"symbol"]];
        imageView.tintColor = toggleInfo[@"color"];
        imageView.image = symbolImage;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [switchContainer addSubview:imageView];
        
        // Dodawanie etykiety z tekstem
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, scrollViewWidth - 85, 30)];
        label.text = title;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
        [switchContainer addSubview:label];
        
        [auraColorScrollView addSubview:switchContainer];
        
        if ([title isEqualToString:@"Aura Totem Color"]) {
            // Tworzenie przycisku zamiast przełącznika
            UIButton *colorButton = [UIButton buttonWithType:UIButtonTypeSystem];
            colorButton.frame = CGRectMake(switchContainer.frame.size.width - 55, 0, 51, 31);
            [colorButton setTitle:@"Pick" forState:UIControlStateNormal];
            [colorButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [colorButton addTarget:self action:@selector(openColorPicker:) forControlEvents:UIControlEventTouchUpInside];
            [switchContainer addSubview:colorButton];
        } else {
            // Istniejący kod dla przełączników
            UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(switchContainer.frame.size.width - 55, 0, 51, 31)];
            toggle.on = [[NSUserDefaults standardUserDefaults] boolForKey:[title stringByReplacingOccurrencesOfString:@" " withString:@""]];
            toggle.onTintColor = toggleInfo[@"color"];
            [toggle addTarget:[NFToggles class] action:selector forControlEvents:UIControlEventValueChanged];
            [switchContainer addSubview:toggle];
        }
        
        auraColorHeight += switchSpacing;
    }

    // Dodaj tę linię aby ustawić contentSize dla auraColorScrollView
    auraColorScrollView.contentSize = CGSizeMake(scrollViewWidth, MAX(auraColorHeight + 20, 940));

    // Add DBDM UI toggles
    CGFloat dbdmUIHeight = switchStartY;
    for (NSUInteger i =0; i < dbdmUIToggles.count; i++) {
        NSDictionary *toggleInfo = dbdmUIToggles[i];
        NSString *title = toggleInfo[@"title"];
        SEL selector = NSSelectorFromString(toggleInfo[@"selector"]);
        
        // Tworzenie kontenera dla ikony i tekstu z gradientowym tłem
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(10, dbdmUIHeight + i * switchSpacing, scrollViewWidth - 20, 30)];
        containerView.layer.cornerRadius = 5;
        containerView.clipsToBounds = YES;

        // Stwórz główny gradient layer dla tła
        CAGradientLayer *backgroundGradient = [CAGradientLayer layer];
        backgroundGradient.frame = containerView.bounds;
        backgroundGradient.colors = @[
            (__bridge id)RightGradient,
            (__bridge id)blackColor,
            (__bridge id)blackColor,
            (__bridge id)LeftGradient
        ];
        backgroundGradient.locations = @[@0.0, @0.3, @0.7, @1.0];
        backgroundGradient.startPoint = CGPointMake(0, 0.5);
        backgroundGradient.endPoint = CGPointMake(1, 0.5);
        [containerView.layer insertSublayer:backgroundGradient atIndex:0];

        // Dodaj gradienty dla górnej i dolnej linii
        CAGradientLayer *topGradient = [CAGradientLayer layer];
        CAGradientLayer *bottomGradient = [CAGradientLayer layer];

        topGradient.frame = CGRectMake(0, 0, containerView.frame.size.width, 1.5);
        bottomGradient.frame = CGRectMake(0, containerView.frame.size.height - 1.5, containerView.frame.size.width, 1.5);

        topGradient.colors = @[
            (__bridge id)RightGradient,
            (__bridge id)blackColor,
            (__bridge id)blackColor,
            (__bridge id)LeftGradient
        ];
        bottomGradient.colors = topGradient.colors;

        topGradient.locations = @[@0.0, @0.3, @0.7, @1.0];
        bottomGradient.locations = topGradient.locations;

        topGradient.startPoint = CGPointMake(0, 0.5);
        topGradient.endPoint = CGPointMake(1, 0.5);
        bottomGradient.startPoint = topGradient.startPoint;
        bottomGradient.endPoint = topGradient.endPoint;

        [containerView.layer addSublayer:topGradient];
        [containerView.layer addSublayer:bottomGradient];
        
        // Tworzenie UIImageView z SF Symbol
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 20, 20)];
        UIImage *symbolImage = [UIImage systemImageNamed:toggleInfo[@"symbol"]];
        imageView.tintColor = toggleInfo[@"color"];
        imageView.image = symbolImage;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [containerView addSubview:imageView];
        
        // Dodawanie etykiety z tekstem
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, scrollViewWidth - 85, 30)];
        label.text = title;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
        [containerView addSubview:label];
        
        [dbdmUIScrollView addSubview:containerView];
        
        // Dodawanie przełącznika
        UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(containerView.frame.size.width - 55, 0, 51, 31)];
        toggle.on = [[NSUserDefaults standardUserDefaults] boolForKey:[title stringByReplacingOccurrencesOfString:@" " withString:@""]];
        toggle.onTintColor = toggleInfo[@"color"];
        [toggle addTarget:[NFToggles class] action:selector forControlEvents:UIControlEventValueChanged];
        [containerView addSubview:toggle];
        
        dbdmUIHeight += switchSpacing;
    }

    // Dodaj tę linię aby ustawić contentSize dla dbdmUIScrollView
    dbdmUIScrollView.contentSize = CGSizeMake(scrollViewWidth, MAX(dbdmUIHeight + 20, 433));
}

+ (void)openColorPicker:(id)sender {
    UIViewController *topVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    
    ColorPickerViewController *colorPicker = [[ColorPickerViewController alloc] init];
    colorPicker.colorSelectedHandler = ^(UIColor *color, NSString *gradientType) {
        CGFloat r, g, b, a;
        [color getRed:&r green:&g blue:&b alpha:&a];
        
        FLinearColor linearColor(r, g, b, a);
        
        NSString *colorString = [NSString stringWithFormat:@"%f,%f,%f,%f", r, g, b, a];
        [[NSUserDefaults standardUserDefaults] setObject:colorString forKey:@"AuraTotemColor"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        SetTotemAuraColor(linearColor);
    };
    
    colorPicker.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [topVC presentViewController:colorPicker animated:YES completion:nil];
}

@end
