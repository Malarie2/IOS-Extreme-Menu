#import "BindsView.h"
#import "Magicolors/ColorsHandler.h"
#import "CustomSlider.h"
#import "../SDKCheats/TeleportManager.h"
#import "../Cheat/SDK.h"
#import "../Cheat/Pointers.h"
#import "Icons/TeleportsIcons.h"
#import "Icons/NFIcons.h"
#import <objc/message.h>

// Dodaj zewnętrzne deklaracje
extern int ActorCount;
extern uintptr_t ActorArray;
extern void GetActorPos(uintptr_t Actor, Vector3* OutPosition);

extern void ShowAlert(NSString *title, NSString *message);

// Na początku pliku, po innych zmiennych statycznych
extern NSMutableArray<NSValue*>* survivorPositions;

// Dodaj na początku pliku
// static BOOL isTeleporting = NO;

// Dodaj na początku pliku statyczną tablicę do przechowywania aktorów
static NSMutableArray *cachedSurvivorActors = nil;

// Dodaj na początku pliku
static NSTimer *updateTimer = nil;

// Na początku pliku, dodaj stałą dla odstępu między grupami
static const CGFloat kGroupSpacing = 50.0f;

// Dodaj na początku pliku, po innych deklaracjach extern
extern "C" void PrevAttachSurvivor(void);
extern "C" void NextAttachSurvivor(void);

@implementation BindsView

static UIView *currentMenuView;
static UIScrollView *bindsScrollView;
static UILabel *bindsLabel;
static BOOL isInitialized = NO;
extern bool isAttachedToSurvivor;
extern NSMutableArray *foundSurvivors;
static UIButton *teleportToggleButton;
static NSMutableDictionary *survivorButtons;
static NSMutableDictionary *survivorIcons;

+ (void)createBindsView:(UIView *)menuView {
    if (!isInitialized) {
        currentMenuView = menuView;
        
        CGFloat menuWidth = 620;
        CGFloat labelHeight = 25;
        CGFloat switchAreaHeight = 210;

        // Binds Label
        bindsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.666667, 67.3333, menuWidth, labelHeight)];
        bindsLabel.text = @"Binds";
        bindsLabel.textColor = [UIColor whiteColor];
        bindsLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:16];
        bindsLabel.textAlignment = NSTextAlignmentCenter;
        bindsLabel.hidden = YES;
        bindsLabel.tag = 1314;
        [menuView addSubview:bindsLabel];

        // Create main scroll view for Binds
        bindsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.666667, 67.3333 + labelHeight + 5, menuWidth, switchAreaHeight)];
        bindsScrollView.backgroundColor = [UIColor clearColor];
        bindsScrollView.userInteractionEnabled = YES;
        bindsScrollView.scrollEnabled = YES;
        bindsScrollView.showsVerticalScrollIndicator = YES;
        bindsScrollView.bounces = YES;
        bindsScrollView.hidden = YES;
        bindsScrollView.tag = 1313;
        [menuView addSubview:bindsScrollView];

        // Tworzenie przycisków bind
        [self createBindButtons];
        
        [self createTeleportButtons];
        
        // Dodaj obserwator dla ukrywania widoku
        [[NSNotificationCenter defaultCenter] addObserver:self
                                               selector:@selector(hideBindsView)
                                                   name:@"HideBindsView"
                                                 object:nil];
        
        // Inicjalizuj tablicę pozycji
        survivorPositions = [NSMutableArray array];
        
        isInitialized = YES;
    } else {
        // Gdy widok jest pokazywany ponownie
        [self createTeleportButtons];
    }
    
    bindsScrollView.hidden = NO;
    bindsLabel.hidden = NO;
}

+ (void)createBindButtons {
    CGFloat menuWidth = 620;
    NSArray *bindOptions = @[
        @{@"title": @"State Hooked", @"symbol": @"link.circle.fill", @"hasSegment": @YES, @"segmentItems": @[@"Hold", @"Toggle"]},
        @{@"title": @"Player Speed", @"symbol": @"speedometer", @"hasSegment": @YES, @"segmentItems": @[@"Hold", @"Toggle"]},
        @{@"title": @"Jump", @"symbol": @"arrow.up.circle.fill", @"hasSegment": @YES, @"segmentItems": @[@"Hold", @"BunnyHop"]},
        @{@"title": @"Teleports", @"symbol": @"location.fill", @"hasSegment": @NO},
        @{@"title": @"Noclip Upward", @"symbol": @"arrow.up.to.line", @"hasSegment": @NO}
    ];
    
    CGFloat yOffset = 10;
    
    for (int i = 0; i < bindOptions.count; i++) {
        NSDictionary *option = bindOptions[i];
        BOOL hasSegment = [option[@"hasSegment"] boolValue];
        
        // Container z gradientem
        UIView *switchContainer = [[UIView alloc] initWithFrame:CGRectMake(10, yOffset, menuWidth - 20, 30)];
        switchContainer.layer.cornerRadius = 5;
        switchContainer.clipsToBounds = YES;

        [self setupGradients:switchContainer];

        // Ikona
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 20, 20)];
        icon.image = [UIImage systemImageNamed:option[@"symbol"]];
        icon.tintColor = [UIColor whiteColor];
        [switchContainer addSubview:icon];

        // Label
        CGFloat labelWidth = hasSegment ? (menuWidth / 4 - 35) : (menuWidth / 2 - 35);
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(25, 0, labelWidth, 30)];
        label.text = option[@"title"];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:14];
        [switchContainer addSubview:label];

        CGFloat sliderX;
        if (hasSegment) {
            // Segment Control z odpowiednimi opcjami
            UISegmentedControl *segment = [[UISegmentedControl alloc] initWithItems:option[@"segmentItems"]];
            segment.frame = CGRectMake(menuWidth / 4, 0, menuWidth / 4, 30);
            segment.selectedSegmentIndex = 0;
            segment.tag = 2000 + i;
            [switchContainer addSubview:segment];
            sliderX = menuWidth / 2;
        } else {
            // Dla Teleports slider zaczyna się wcześniej
            sliderX = menuWidth / 4;
        }

        // Slider
        CGFloat sliderWidth = hasSegment ? (menuWidth / 4) : (menuWidth / 2);
        CustomSlider *slider = [[CustomSlider alloc] initWithFrame:CGRectMake(sliderX, 0, sliderWidth, 30)];
        slider.minimumValue = 0.1;
        slider.maximumValue = 1.0;
        slider.value = 0.5;
        slider.tag = 3000 + i;
        
        // Dodaj target dla slidera
        [slider addTarget:self 
                 action:@selector(sliderValueChanged:) 
       forControlEvents:UIControlEventValueChanged];
        
        UIColor *rightGradientColor = [UIColor colorWithCGColor:RightGradient];
        slider.minimumTrackTintColor = [rightGradientColor colorWithAlphaComponent:0.2];
        slider.maximumTrackTintColor = [UIColor colorWithWhite:1.0 alpha:0.1];
        
        [self setupSliderThumb:slider withColor:rightGradientColor];
        [switchContainer addSubview:slider];

        // Value Label dla slidera
        UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(sliderX + sliderWidth + 5, 5, 40, 20)];
        valueLabel.text = @"0.5"; // Wszystkie value labels zaczynają od 0.5
        valueLabel.textColor = [UIColor whiteColor];
        valueLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
        valueLabel.textAlignment = NSTextAlignmentCenter;
        valueLabel.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
        valueLabel.layer.cornerRadius = 5;
        valueLabel.layer.masksToBounds = YES;
        valueLabel.tag = 4000 + i;
        [switchContainer addSubview:valueLabel];

        // Toggle Switch
        UISwitch *toggle = [[UISwitch alloc] init];
        toggle.frame = CGRectMake(menuWidth - 70, 0, 51, 31);
        toggle.onTintColor = rightGradientColor;
        toggle.tag = 1000 + i;
        [switchContainer addSubview:toggle];

        [bindsScrollView addSubview:switchContainer];
        
        yOffset += 40;

        if (i == 3) { // Teleports
            [toggle addTarget:self action:@selector(teleportsToggleChanged:) forControlEvents:UIControlEventValueChanged];
        }
    }
    
    bindsScrollView.contentSize = CGSizeMake(menuWidth, yOffset);
}

// Pomocnicza metoda do konfiguracji thumba slidera
+ (void)setupSliderThumb:(UISlider *)slider withColor:(UIColor *)rightGradientColor {
    CGFloat thumbSize = 24.0;
    UIView *thumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, thumbSize, thumbSize)];
    thumbView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    thumbView.layer.cornerRadius = thumbSize / 2;
    thumbView.layer.shadowColor = rightGradientColor.CGColor;
    thumbView.layer.shadowOffset = CGSizeZero;
    thumbView.layer.shadowRadius = 4.0;
    thumbView.layer.shadowOpacity = 0.8;
    thumbView.layer.borderWidth = 1.0;
    thumbView.layer.borderColor = rightGradientColor.CGColor;

    CGFloat extraSpace = 8.0;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(thumbSize + extraSpace, thumbSize + extraSpace), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, extraSpace/2, extraSpace/2);
    [thumbView.layer renderInContext:context];
    UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [slider setThumbImage:thumbImage forState:UIControlStateNormal];
    [slider setThumbImage:thumbImage forState:UIControlStateHighlighted];
}

// Pomocnicza metoda do setupu gradientów
+ (void)setupGradients:(UIView *)container {
    // Gradient tła
    CAGradientLayer *backgroundGradient = [CAGradientLayer layer];
    backgroundGradient.frame = container.bounds;
    backgroundGradient.colors = @[
        (__bridge id)RightGradient,
        (__bridge id)blackColor,
        (__bridge id)blackColor,
        (__bridge id)LeftGradient
    ];
    backgroundGradient.locations = @[@0.0, @0.3, @0.7, @1.0];
    backgroundGradient.startPoint = CGPointMake(0, 0.5);
    backgroundGradient.endPoint = CGPointMake(1, 0.5);
    [container.layer insertSublayer:backgroundGradient atIndex:0];

    // Gradienty górny i dolny
    CAGradientLayer *topGradient = [CAGradientLayer layer];
    CAGradientLayer *bottomGradient = [CAGradientLayer layer];

    topGradient.frame = CGRectMake(0, 0, container.frame.size.width, 1.5);
    bottomGradient.frame = CGRectMake(0, container.frame.size.height - 1.5, container.frame.size.width, 1.5);

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

    [container.layer addSublayer:topGradient];
    [container.layer addSublayer:bottomGradient];
}

// Dodaj nową metodę do obsługi zmiany wartości slidera
+ (void)sliderValueChanged:(UISlider *)slider {
    // Znajdź odpowiedni label na podstawie tagu slidera
    NSInteger sliderTag = slider.tag;
    NSInteger labelTag = sliderTag + 1000; // 3000 -> 4000
    
    UILabel *valueLabel = [slider.superview viewWithTag:labelTag];
    if (valueLabel) {
        valueLabel.text = [NSString stringWithFormat:@"%.1f", slider.value];
    }
}

+ (void)toggleTeleportIcons:(UIButton *)sender {
    // Przełączaj tylko widoczność kontenera teleportacji
    UIView *teleportContainer = [[UIApplication sharedApplication].keyWindow viewWithTag:999];
    
    if (!teleportContainer) {
        NSLog(@"Teleport container not found!");
        return;
    }
    
    teleportContainer.hidden = !teleportContainer.hidden;
    
    [UIView animateWithDuration:0.3 animations:^{
        sender.transform = teleportContainer.hidden ? CGAffineTransformIdentity : CGAffineTransformMakeRotation(M_PI);
    }];
}

+ (void)createTeleportButtons {
    CGFloat buttonSize = 35;
    CGFloat spacing = 8;
    CGFloat centerSpacing = 30; // Dodatkowy odstęp między 2 i 3 przyciskiem
    
    // Oblicz całkowitą szerokość wszystkich przycisków i odstępów
    CGFloat totalWidth = (buttonSize * 4) + (spacing * 3) + centerSpacing;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat startX = (screenWidth - totalWidth) / 2; // Wyśrodkuj w poziomie
    
    // Kontener dla przycisków survivorów (na dole ekranu)
    UIView *survivorContainer = [[UIView alloc] initWithFrame:CGRectMake(
        startX,
        [UIScreen mainScreen].bounds.size.height - 45,
        totalWidth,
        buttonSize
    )];
    survivorContainer.tag = 997;
    survivorContainer.hidden = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:survivorContainer];
    
    // Zmień timer na sprawdzanie LocalPlayer i aktualizację przycisków
    if (updateTimer) {
        [updateTimer invalidate];
        updateTimer = nil;
    }
    
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                repeats:YES
                                                  block:^(NSTimer *timer) {
        if (!LocalPlayer) {
            return;
        }
        
        UIView *survivorContainer = [[UIApplication sharedApplication].keyWindow viewWithTag:997];
        if (!survivorContainer) {
            [timer invalidate];
            return;
        }
        
        [BindsView updateSurvivorButtons:survivorContainer withButtonSize:40 andSpacing:10];
        
        // Upewnij się, że kontener jest widoczny jeśli teleport jest włączony
        UISwitch *teleportSwitch = [bindsScrollView viewWithTag:1003];
        if (teleportSwitch && teleportSwitch.isOn) {
            survivorContainer.hidden = NO;
        }
    }];
    
    // Kontener dla przycisków teleportacji (prawa strona)
    UIView *teleportContainer = [[UIView alloc] initWithFrame:CGRectMake(
        [UIScreen mainScreen].bounds.size.width - buttonSize - 20,
        [UIScreen mainScreen].bounds.size.height - 60 - 200 - 5,
        buttonSize + spacing * 2,
        300
    )];
    teleportContainer.tag = 999;
    teleportContainer.hidden = YES;
   
    [[UIApplication sharedApplication].keyWindow addSubview:teleportContainer];
    
    // Kontener dla przycisków attach (lewa strona HomBar)
    UIView *attachContainer = [[UIView alloc] initWithFrame:CGRectMake(
        20, // Pozycja w lewo
        [UIScreen mainScreen].bounds.size.height - 100, // Trochę niżej (było -120)
        buttonSize * 4 + spacing * 5,
        buttonSize * 2 + spacing // Zwiększona wysokość dla dwóch rzędów
    )];
    attachContainer.tag = 998;
    attachContainer.hidden = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:attachContainer];
    
    // Inicjalizuj ikony survivorów
    [self initializeSurvivorIcons];
    
    // Funkcja pomocnicza do tworzenia przycisków
    void (^createButton)(NSDictionary*, NSUInteger, UIView*) = ^(NSDictionary *config, NSUInteger idx, UIView *container) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        CGFloat yPosition = idx * (buttonSize + spacing);
        NSLog(@"Creating button %ld at y position: %.1f", (long)(2000 + idx), yPosition);
        
        button.frame = CGRectMake(
            (container.bounds.size.width - buttonSize) / 2,
            yPosition,
            buttonSize, 
            buttonSize
        );
        
        // Sprawdź czy przycisk mieści się w kontenerze
        NSLog(@"Button bottom: %.1f, Container height: %.1f", 
              yPosition + buttonSize, 
              container.bounds.size.height);
        
        button.layer.cornerRadius = buttonSize / 2;
        button.clipsToBounds = YES;
        button.userInteractionEnabled = YES; // Upewnij się, że interakcja jest włączona
        
        // Dodaj tag dla debugowania
        button.tag = 2000 + idx;
        
        // Dodaj gradient
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = button.bounds;
        gradientLayer.colors = @[(__bridge id)RightGradient, (__bridge id)blackColor, (__bridge id)blackColor, (__bridge id)LeftGradient];
        gradientLayer.locations = @[@0.0, @0.3, @0.7, @1.0];
        gradientLayer.startPoint = CGPointMake(0, 0.5);
        gradientLayer.endPoint = CGPointMake(1, 0.5);
        gradientLayer.cornerRadius = buttonSize / 2;
        [button.layer insertSublayer:gradientLayer atIndex:0];
        

        NSString *base64String = ((NSString* (^)(void))config[@"base64"])();
        if (base64String) {
            NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
            UIImage *iconImage = [UIImage imageWithData:imageData];
            [button setImage:iconImage forState:UIControlStateNormal];
            button.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        }
        
        // Debug log przed dodaniem targetów
        NSLog(@"Creating button %ld with selector: %@", (long)button.tag, config[@"selector"]);
        
        // Dodaj wszystkie targety
        SEL actionSelector = NSSelectorFromString(config[@"selector"]);
        [button addTarget:self action:actionSelector forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        
        // Dodaj przycisk do kontenera
        [container addSubview:button];
        
        // Debug log po dodaniu targetów
        NSLog(@"Button %ld created. Responds to selector: %d, userInteractionEnabled: %d, frame: %@", 
              (long)button.tag, 
              [self respondsToSelector:actionSelector],
              button.userInteractionEnabled,
              NSStringFromCGRect(button.frame));
    };
    
    // Konfiguracja ikon teleportacji (prawa strona)
    NSArray *teleportConfigs = @[
        @{@"base64": ^{ return [TeleportsIcons Hooks]; }, @"selector": @"cycleAndTeleportToSurvivor:", @"hasArrow": @NO},
        @{@"base64": ^{ return [TeleportsIcons Generator]; }, @"selector": @"teleportToGenerator:", @"hasArrow": @NO},
        @{@"base64": ^{ return [TeleportsIcons Totem]; }, @"selector": @"cycleAndTeleportToTotem:", @"hasArrow": @NO},
        @{@"base64": ^{ return [TeleportsIcons Gate]; }, @"selector": @"teleportToGate:", @"hasArrow": @NO},
        @{@"base64": ^{ return [TeleportsIcons Hatch]; }, @"selector": @"hatchButtonTapped:", @"hasArrow": @NO}
    ];
    
    // Konfiguracja ikon attach (lewa strona HomBar)
    NSArray *attachConfigs = @[
        @{@"base64": ^{ return [TeleportsIcons Hooks]; }, @"selector": @"attachToSurvivor:", @"hasArrow": @YES},
        @{@"base64": ^{ return [TeleportsIcons Hooks]; }, @"selector": @"attachToKiller:", @"hasArrow": @NO}
    ];

    // Twórz przyciski teleportacji
    [teleportConfigs enumerateObjectsUsingBlock:^(NSDictionary *config, NSUInteger idx, BOOL *stop) {
        createButton(config, idx, teleportContainer);
    }];
    
    // Twórz przyciski attach poziomo
    [attachConfigs enumerateObjectsUsingBlock:^(NSDictionary *config, NSUInteger idx, BOOL *stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        // Pozycja przycisku
        CGFloat xPosition;
        CGFloat yPosition;
        if (idx == 0) { // AS button
            xPosition = buttonSize + spacing; // Miejsce na lewą strzałkę
            yPosition = buttonSize + spacing; // Dolny rząd
        } else { // AK button
            xPosition = 0; // Nad lewą strzałką
            yPosition = 0; // Górny rząd
        }
        
        button.frame = CGRectMake(xPosition, yPosition, buttonSize, buttonSize);
        button.layer.cornerRadius = buttonSize / 2;
        button.clipsToBounds = YES;
        
        // Dodaj gradient
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = button.bounds;
        gradientLayer.colors = @[(__bridge id)RightGradient, (__bridge id)blackColor, (__bridge id)blackColor, (__bridge id)LeftGradient];
        gradientLayer.locations = @[@0.0, @0.3, @0.7, @1.0];
        gradientLayer.startPoint = CGPointMake(0, 0.5);
        gradientLayer.endPoint = CGPointMake(1, 0.5);
        gradientLayer.cornerRadius = buttonSize / 2;
        [button.layer insertSublayer:gradientLayer atIndex:0];
        
        // Ustaw tekst zamiast ikony
        NSString *buttonText = idx == 0 ? @"AS" : @"AK";
        [button setTitle:buttonText forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:12]; // Zmniejszona czcionka
        
        button.tag = idx;
        [button addTarget:self action:NSSelectorFromString(config[@"selector"]) forControlEvents:UIControlEventTouchUpInside];
        [attachContainer addSubview:button];
        
        // Dodaj strzałki tylko dla przycisku AS (idx == 0)
        if (idx == 0) {
            // Lewa strzałka
            UIButton *leftArrow = [UIButton buttonWithType:UIButtonTypeCustom];
            leftArrow.frame = CGRectMake(0, buttonSize + spacing, buttonSize, buttonSize); // Dolny rząd
            [leftArrow setImage:[UIImage systemImageNamed:@"chevron.left"] forState:UIControlStateNormal];
            leftArrow.tintColor = [UIColor whiteColor];
            [leftArrow addTarget:self action:@selector(prevAttachSurvivor:) forControlEvents:UIControlEventTouchUpInside];
            [attachContainer addSubview:leftArrow];
            
            // Prawa strzałka
            UIButton *rightArrow = [UIButton buttonWithType:UIButtonTypeCustom];
            rightArrow.frame = CGRectMake(buttonSize * 2 + spacing * 2, buttonSize + spacing, buttonSize, buttonSize); // Dolny rząd
            [rightArrow setImage:[UIImage systemImageNamed:@"chevron.right"] forState:UIControlStateNormal];
            rightArrow.tintColor = [UIColor whiteColor];
            [rightArrow addTarget:self action:@selector(nextAttachSurvivor:) forControlEvents:UIControlEventTouchUpInside];
            [attachContainer addSubview:rightArrow];
        }
    }];
}



// Metody teleportacji
+ (void)teleportToGenerator:(UIButton *)sender {
    if (!LocalPlayer) {
        ShowAlert(@"Error", @"LocalPlayer not found");
        return;
    }
    
    // Zbierz informacje o generatorach
    NSMutableArray *generators = [NSMutableArray array];
    
    uintptr_t World = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
    if (!World) return;
    
    uintptr_t GameState = *(uintptr_t*)(World + Offsets::SDK::UWorldToGameState);
    if (!GameState) return;
    
    uintptr_t _generators = *(uintptr_t*)(GameState + Offsets::SDK::ADBDGameStateTo_generators);
    int32_t _generatorsCount = *(int32_t*)(GameState + Offsets::SDK::ADBDGameStateTo_generators + Offsets::Special::TArrayToCount);
    
    // Znajdź wszystkie generatory
    for (int g = 0; g < _generatorsCount && _generators != 0; g++) {
        uintptr_t Generator = *(uintptr_t*)(_generators + g * Offsets::Special::PointerSize);
        if (!Generator) continue;
        
        uintptr_t RootComponent = GetRootComponent(Generator);
        if (!RootComponent) continue;
        
        Vector3 position = *(Vector3*)(RootComponent + Offsets::SDK::USceneComponentToRelativeLocation);
        [generators addObject:@{
            @"actor": @(Generator),
            @"position": [NSValue valueWithBytes:&position objCType:@encode(Vector3)]
        }];
    }
    
    if (generators.count == 0) {
        ShowAlert(@"Error", @"No generators found");
        return;
    }
    
    // Przejdź do następnego generatora
    static int currentGeneratorIndex = 0;
    currentGeneratorIndex = (currentGeneratorIndex + 1) % generators.count;
    
    // Pobierz informacje o wybranym generatorze
    NSDictionary *selectedGenerator = generators[currentGeneratorIndex];
    uintptr_t Actor = [selectedGenerator[@"actor"] unsignedLongLongValue];
    
    // Teleportuj do wybranego generatora
    uintptr_t RootComponent = GetRootComponent(Actor);
    if (!RootComponent) return;
    
    Vector3 position = *(Vector3*)(RootComponent + Offsets::SDK::USceneComponentToRelativeLocation);
    FRotator rotation = *(FRotator*)(RootComponent + Offsets::SDK::USceneComponentToRelativeRotation);
    
    // Dodaj offset do pozycji, aby uniknąć utknięcia w generatorze
    position.X += 150.0f; // Przesuń trochę w bok
    position.Z += 100.0f; // Przesuń do góry
    
    struct {
        bool snapPosition;
        Vector3 Position;
        float stopSnapDistance;
        bool snapRotation;
        FRotator Rotation;
        float Time;
        bool useZCoord;
        bool sweepOnFinalSnap;
        bool snapRoll;
    } params;
    
    params.snapPosition = true;
    params.Position = position;
    params.stopSnapDistance = 0.0f;
    params.snapRotation = true;
    params.Rotation = rotation;
    params.Time = 0.0f;
    params.useZCoord = true;
    params.sweepOnFinalSnap = false;
    params.snapRoll = true;
    
    ProcessEvent(LocalPlayer, FindObject(@"SnapCharacter"), (uintptr_t)&params);
    
    ShowAlert(@"Success", [NSString stringWithFormat:@"Teleported to generator %d/%lu", 
        currentGeneratorIndex + 1, (unsigned long)generators.count]);
}

+ (void)teleportToTotem:(UIButton *)sender { TeleportToTotem(); }
+ (void)teleportToGate:(UIButton *)sender { TeleportToGate(); }
+ (void)teleportToSurvivor:(UIButton *)sender { TeleportToSurvivor(); }
+ (void)teleportToHatch:(UIButton *)sender { TeleportToHatch(); }
 

+ (void)cycleAndTeleportToSurvivor:(UIButton *)sender {
    if (!LocalPlayer) {
        ShowAlert(@"Error", @"LocalPlayer not found");
        return;
    }
    
    // Zbierz informacje o survivorach
    NSMutableArray *survivors = [NSMutableArray array];
    
    uintptr_t World = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
    if (!World) return;
    
    uintptr_t PersistentLevel = *(uintptr_t*)(World + Offsets::SDK::UWorldToPersistentLevel);
    if (!PersistentLevel) return;
    
    uintptr_t ActorArray = *(uintptr_t*)(PersistentLevel + Offsets::Special::ULevelToActorArray);
    if (!ActorArray) return;
    
    int32_t ActorCount = *(int32_t*)(PersistentLevel + Offsets::Special::ULevelToActorArray + Offsets::Special::TArrayToCount);
    
    // Znajdź wszystkich survivorów
    for (int i = 0; i < ActorCount; i++) {
        uintptr_t Actor = *(uintptr_t*)(ActorArray + i * Offsets::Special::PointerSize);
        if (!Actor || Actor == LocalPlayer || !IsValidPointer(Actor)) continue;
        
        NSString* ActorName = GetNameFromFName(*(int32_t*)(Actor + Offsets::Special::UObjectToFNameOffset));
        if (!ActorName) continue;
        
        // Sprawdź czy to survivor
        if ([ActorName hasPrefix:@"BP_CamperFemale"] || [ActorName hasPrefix:@"BP_CamperMale"]) {
            uintptr_t RootComponent = GetRootComponent(Actor);
            if (!RootComponent) continue;
            
            Vector3 position = *(Vector3*)(RootComponent + Offsets::SDK::USceneComponentToRelativeLocation);
            [survivors addObject:@{
                @"actor": @(Actor),
                @"position": [NSValue valueWithBytes:&position objCType:@encode(Vector3)]
            }];
        }
    }
    
    if (survivors.count == 0) {
        ShowAlert(@"Error", @"No survivors found");
        return;
    }
    
    // Przejdź do następnego survivora
    currentSurvivorIndex = (currentSurvivorIndex + 1) % survivors.count;
    
    // Pobierz informacje o wybranym survivorze
    NSDictionary *selectedSurvivor = survivors[currentSurvivorIndex];
    uintptr_t Actor = [selectedSurvivor[@"actor"] unsignedLongLongValue];
    
    // Teleportuj do wybranego survivora
    uintptr_t RootComponent = GetRootComponent(Actor);
    if (!RootComponent) return;
    
    Vector3 position = *(Vector3*)(RootComponent + Offsets::SDK::USceneComponentToRelativeLocation);
    FRotator rotation = *(FRotator*)(RootComponent + Offsets::SDK::USceneComponentToRelativeRotation);
    position.Z += 100.0f;
    
    struct {
        bool snapPosition;
        Vector3 Position;
        float stopSnapDistance;
        bool snapRotation;
        FRotator Rotation;
        float Time;
        bool useZCoord;
        bool sweepOnFinalSnap;
        bool snapRoll;
    } params;
    
    params.snapPosition = true;
    params.Position = position;
    params.stopSnapDistance = 0.0f;
    params.snapRotation = true;
    params.Rotation = rotation;
    params.Time = 0.0f;
    params.useZCoord = true;
    params.sweepOnFinalSnap = false;
    params.snapRoll = true;
    
    ProcessEvent(LocalPlayer, FindObject(@"SnapCharacter"), (uintptr_t)&params);
    
    ShowAlert(@"Success", [NSString stringWithFormat:@"Teleported to survivor %d/%lu", 
        currentSurvivorIndex + 1, (unsigned long)survivors.count]);
}

+ (void)cycleAndTeleportToTotem:(UIButton *)sender {
    UpdateTotemPositions();
    if (totemPositions.count == 0) {
        ShowAlert(@"Error", @"No totems found");
        return;
    }
    
    currentTotemIndex = (currentTotemIndex + 1) % totemPositions.count;
    Vector3 position;
    [[totemPositions objectAtIndex:currentTotemIndex] getValue:&position];
    
    // Dodaj offset do pozycji, aby uniknąć utknięcia w totemie
    position.X += 100.0f; // Przesuń w bok
    position.Z += 100.0f; // Przesuń do góry
    
    TeleportTo(position);
    
    ShowAlert(@"Success", [NSString stringWithFormat:@"Teleported to totem %d/%lu", 
        currentTotemIndex + 1, totemPositions.count]);
}


+ (void)attachToKiller:(UIButton *)sender {
    AttachToKiller();
}

+ (void)attachToSurvivor:(UIButton *)sender {
    static BOOL isAttached = NO;
    isAttached = !isAttached;
    
    if (isAttached) {
        AttachToSurvivor();
        ShowAlert(@"Success", @"Attached to survivor");
    } else {
        StopSurvivorAttach();
        ShowAlert(@"Success", @"Detached from survivor");
    }
}

+ (void)nextAttachSurvivor:(UIButton *)sender {
    if (!isAttachedToSurvivor) {
        ShowAlert(@"Error", @"First attach to survivor using Attach [S]");
        return;
    }
    
    if (!foundSurvivors || foundSurvivors.count == 0) {
        ShowAlert(@"Error", @"No survivors found");
        return;
    }
    
    NextAttachSurvivor();
}

// Dodaj nową metodę do ukrywania widoku
+ (void)hideBindsView {
    bindsScrollView.hidden = YES;
    bindsLabel.hidden = YES;
    
    // Wyczyść timer i dane przy ukrywaniu widoku
    [self cleanup];
    
    // Ukryj kontenery
    UIView *teleportContainer = [[UIApplication sharedApplication].keyWindow viewWithTag:999];
    UIView *attachContainer = [[UIApplication sharedApplication].keyWindow viewWithTag:998];
    UIView *survivorContainer = [[UIApplication sharedApplication].keyWindow viewWithTag:997];
    
    teleportContainer.hidden = YES;
    attachContainer.hidden = YES;
    survivorContainer.hidden = YES;
}

+ (void)teleportsToggleChanged:(UISwitch *)sender {
    // Znajdź kontenery
    UIView *teleportContainer = [[UIApplication sharedApplication].keyWindow viewWithTag:999];
    UIView *attachContainer = [[UIApplication sharedApplication].keyWindow viewWithTag:998];
    UIView *survivorContainer = [[UIApplication sharedApplication].keyWindow viewWithTag:997];
    
    NSLog(@"Teleport toggle changed to: %d", sender.isOn);
    NSLog(@"Teleport container frame: %@", NSStringFromCGRect(teleportContainer.frame));
    
    if (sender.isOn) {
        // Pokaż przyciski attach i survivor container od razu
        attachContainer.hidden = NO;
        survivorContainer.hidden = NO;
        teleportContainer.hidden = NO;
        
        // Debug info
        NSLog(@"Container size: %@", NSStringFromCGRect(teleportContainer.bounds));
        NSLog(@"Total buttons: %lu", (unsigned long)teleportContainer.subviews.count);
        
        for (UIView *subview in teleportContainer.subviews) {
            if ([subview isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)subview;
                NSLog(@"Button %ld frame: %@, visible in container: %d", 
                    (long)button.tag,
                    NSStringFromCGRect(button.frame),
                    CGRectContainsRect(teleportContainer.bounds, button.frame));
            }
        }
    } else {
        // Ukryj wszystkie kontenery przy wyłączeniu
        teleportContainer.hidden = YES;
        attachContainer.hidden = YES;
        survivorContainer.hidden = YES;
    }
}

+ (void)addArrowsToButton:(UIButton *)button 
              withConfig:(NSDictionary *)config 
                atIndex:(NSUInteger)idx 
            inContainer:(UIView *)container 
         withButtonSize:(CGFloat)buttonSize 
            andSpacing:(CGFloat)spacing {
    
    NSArray *arrowConfigs = @[
        @{@"direction": @"left", @"x": @(-buttonSize - spacing), @"selector": @"previousTarget:"},
        @{@"direction": @"right", @"x": @(buttonSize + spacing), @"selector": @"nextTarget:"}
    ];
    
    [arrowConfigs enumerateObjectsUsingBlock:^(NSDictionary *arrowConfig, NSUInteger j, BOOL *stop) {
        UIButton *arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        arrowButton.frame = CGRectMake([arrowConfig[@"x"] floatValue], button.frame.origin.y, buttonSize, buttonSize);
        arrowButton.layer.cornerRadius = buttonSize / 2;
        
        // Dodaj gradient dla strzałek
        CAGradientLayer *arrowGradient = [CAGradientLayer layer];
        arrowGradient.frame = arrowButton.bounds;
        arrowGradient.colors = @[(__bridge id)RightGradient, (__bridge id)blackColor, (__bridge id)blackColor, (__bridge id)LeftGradient];
        arrowGradient.locations = @[@0.0, @0.3, @0.7, @1.0];
        arrowGradient.startPoint = CGPointMake(0, 0.5);
        arrowGradient.endPoint = CGPointMake(1, 0.5);
        arrowGradient.cornerRadius = buttonSize / 2;
        [arrowButton.layer insertSublayer:arrowGradient atIndex:0];
        
        [arrowButton setImage:[UIImage systemImageNamed:[NSString stringWithFormat:@"chevron.%@", arrowConfig[@"direction"]]] forState:UIControlStateNormal];
        arrowButton.tintColor = [UIColor whiteColor];
        arrowButton.tag = idx * 2 + j;
        [arrowButton addTarget:self action:NSSelectorFromString(arrowConfig[@"selector"]) forControlEvents:UIControlEventTouchUpInside];
        [container addSubview:arrowButton];
    }];
}

+ (void)initializeSurvivorIcons {
    survivorIcons = [NSMutableDictionary dictionary];
    survivorButtons = [NSMutableDictionary dictionary];
    
    // Mapowanie nazw postaci na selektory ikon
    NSDictionary *survivorIconMapping = @{
        @"Dwight": @"S01_DwightFairfield_Portrait",
        @"Meg": @"S02_MegThomas_Portrait", 
        @"Claudette": @"S03_ClaudetteMorel_Portrait",
        @"Jake": @"S04_JakePark_Portrait",
        @"Nea": @"S05_NeaKarlsson_Portrait",
        @"Laurie": @"S06_LaurieStrode_Portrait",
        @"Ace": @"S07_AceVisconti_Portrait",
        @"Bill": @"S08_WilliamBillOverbeck_Portrait",
        @"Feng": @"S09_FengMin_Portrait",
        @"David": @"S10_DavidKing_Portrait",
        @"Kate": @"S13_KateDenson_Portrait",
        @"Quentin": @"S11_QuentinSmith_Portrait",
        @"Tapp": @"S12_DetectiveDavidTapp_Portrait",
        @"Adam": @"S14_AdamFrancis_Portrait",
        @"Jeff": @"S15_JeffJohansen_Portrait",
        @"Jane": @"S16_JaneRomero_Portrait",
        @"Ash": @"S17_AshleyJWilliams_Portrait",
        @"Yui": @"S20_YuiKimura_Portrait",
        @"Zarina": @"S21_ZarinaKassir_Portrait",
        @"Felix": @"S23_FelixRichter_Portrait",
        @"Jonah": @"S29_JonahVasquez_Portrait",
        @"Yoichi": @"S30_YoichiAsakawa_Portrait",
        @"Vittorio": @"S34_VittorioToscano_Portrait",
        @"Renato": @"S36_RenatoLyra_Portrait",
        @"Gabriel": @"S37_GabrielSoma_Portrait",
        @"Nicolas": @"S38_NicolasCage_Portrait",
        @"Elodie": @"S25_ElodiePRakoto_Portrait",
        @"Yun-Jin Lee": @"S26_YunJinLee_Portrait",
        @"Mikela": @"S27_MikaelaPReid_Portrait",
        @"Thalita": @"S31_ThalitaLyra_Portrait",
        @"Sable": @"S32_SableWard_Portrait",
        @"Haddie": @"S33_HaddiePKaur_Portrait"
    };
    
    survivorIcons = [survivorIconMapping mutableCopy];
}

// Dodaj metodę do mapowania nazwy postaci na metodę ikony
+ (SEL)getIconSelectorForSurvivor:(NSString *)actorName {
    // Mapowanie prefiksów na nazwy ikon
    NSDictionary *iconMapping = @{
        // Female survivors
        @"BP_CamperFemale01_Character_C": @"S02_MegThomas_Portrait",
        @"BP_CamperFemale02_Character_C": @"S03_ClaudetteMorel_Portrait",
        @"BP_CamperFemale03_Character_C": @"S05_NeaKarlsson_Portrait",
        @"BP_CamperFemale04_Character_C": @"S06_LaurieStrode_Portrait",
        @"BP_CamperFemale05_Character_C": @"S09_FengMin_Portrait",
        @"BP_CamperFemale06_Character_C": @"S13_KateDenson_Portrait",
        @"BP_CamperFemale07_Character_C": @"S16_JaneRomero_Portrait",
        @"BP_CamperFemale09_Character_C": @"S20_YuiKimura_Portrait",
        @"BP_CamperFemale10_Character_C": @"S21_ZarinaKassir_Portrait",
        @"BP_CamperFemale12_Character_C": @"S25_ElodiePRakoto_Portrait",
        @"BP_CamperFemale13_Character_C": @"S26_YunJinLee_Portrait",
        @"BP_CamperFemale15_Character_C": @"S27_MikaelaPReid_Portrait",
        @"BP_CamperFemale19_Character_C": @"S31_ThalitaLyra_Portrait",
        @"BP_CamperFemale21_Character_C": @"S32_SableWard_Portrait",
        @"BP_CamperFemale16_Character_C": @"S33_HaddiePKaur_Portrait",
        
        // Male survivors
        @"BP_CamperMale01_Character_C": @"S01_DwightFairfield_Portrait",
        @"BP_CamperMale02_Character_C": @"S04_JakePark_Portrait",
        @"BP_CamperMale03_Character_C": @"S07_AceVisconti_Portrait",
        @"BP_CamperMale04_Character_C": @"S08_WilliamBillOverbeck_Portrait",
        @"BP_CamperMale05_Character_C": @"S10_DavidKing_Portrait",
        @"BP_CamperMale06_Character_C": @"S11_QuentinSmith_Portrait",
        @"BP_CamperMale07_Character_C": @"S12_DetectiveDavidTapp_Portrait",
        @"BP_CamperMale08_Character_C": @"S14_AdamFrancis_Portrait",
        @"BP_CamperMale09_Character_C": @"S15_JeffJohansen_Portrait",
        @"BP_CamperMale10_Character_C": @"S17_AshleyJWilliams_Portrait",
        @"BP_CamperMale11_Character_C": @"S23_FelixRichter_Portrait",
        @"BP_CamperMale12_Character_C": @"S29_JonahVasquez_Portrait",
        @"BP_CamperMale13_Character_C": @"S36_RenatoLyra_Portrait",
        @"BP_CamperMale14_Character_C": @"S34_VittorioToscano_Portrait",
        @"BP_CamperMale15_Character_C": @"S30_YoichiAsakawa_Portrait",
        @"BP_CamperMale16_Character_C": @"S37_GabrielSoma_Portrait",
        @"BP_CamperMale17_Character_C": @"S38_NicolasCage_Portrait"
    };
    
    return NSSelectorFromString(iconMapping[actorName]);
}

+ (void)updateSurvivorButtons:(UIView *)container withButtonSize:(CGFloat)buttonSize andSpacing:(CGFloat)spacing {
    @try {
        if (!container || !LocalPlayer) {
            return;
        }
        
        // Zbierz dane o survivorach w tle
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *survivorActors = [NSMutableArray array];
            
            // Użyj tego samego kodu co w ESPView
            uintptr_t World = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
            if (!World) return;
            
            uintptr_t PersistentLevel = *(uintptr_t*)(World + Offsets::SDK::UWorldToPersistentLevel);
            if (!PersistentLevel) return;

            uintptr_t ActorArray = *(uintptr_t*)(PersistentLevel + Offsets::Special::ULevelToActorArray);
            if (!ActorArray) return;
            
            int32_t ActorCount = *(int32_t*)(PersistentLevel + Offsets::Special::ULevelToActorArray + Offsets::Special::TArrayToCount);
            
            // Zbierz informacje o survivorach
            for (int i = 0; i < ActorCount; i++) {
                uintptr_t Actor = *(uintptr_t*)(ActorArray + i * Offsets::Special::PointerSize);
                if (!Actor || Actor == LocalPlayer || !IsValidPointer(Actor)) continue;

                NSString* ActorName = GetNameFromFName(*(int32_t*)(Actor + Offsets::Special::UObjectToFNameOffset));
                if (!ActorName) continue;

                NSString *iconName = nil;
                
                // Sprawdź czy to survivor (skrócona wersja dla czytelności)
                if ([ActorName hasPrefix:@"BP_CamperFemale"] || [ActorName hasPrefix:@"BP_CamperMale"]) {
                    SEL iconSelector = [self getIconSelectorForSurvivor:ActorName];
                    if (iconSelector) {
                        iconName = NSStringFromSelector(iconSelector);
                        
                        uintptr_t RootComponent = GetRootComponent(Actor);
                        if (!RootComponent) continue;

                        [survivorActors addObject:@{
                            @"actor": @(Actor),
                            @"name": iconName,
                            @"index": @(i)
                        }];
                    }
                }
            }
            
            // Aktualizuj UI na głównym wątku
            dispatch_async(dispatch_get_main_queue(), ^{
                // Usuń stare przyciski
                for (UIButton *button in [survivorButtons allValues]) {
                    [button removeFromSuperview];
                }
                [survivorButtons removeAllObjects];
                
                // Zaktualizuj cache
                cachedSurvivorActors = [survivorActors mutableCopy];
                
                // Zaktualizuj pozycje survivorów
                [survivorPositions removeAllObjects];
                for (NSDictionary *survivorInfo in survivorActors) {
                    uintptr_t Actor = [survivorInfo[@"actor"] unsignedLongLongValue];
                    Vector3 position;
                    GetActorPos(Actor, &position);
                    [survivorPositions addObject:[NSValue valueWithBytes:&position objCType:@encode(Vector3)]];
                }
                
                // Twórz przyciski dla każdego survivora
                for (int i = 0; i < 4; i++) {
                    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                    
                    // Oblicz pozycję X dla każdego przycisku
                    CGFloat xPosition = i < 2 ? 
                        i * (buttonSize + spacing) : 
                        (i * (buttonSize + spacing)) + kGroupSpacing;
                    
                    button.frame = CGRectMake(xPosition, 0, buttonSize, buttonSize);
                    button.layer.cornerRadius = buttonSize / 2;
                    button.clipsToBounds = YES;
                    
                    // Dodaj gradient
                    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
                    gradientLayer.frame = button.bounds;
                    gradientLayer.colors = @[(__bridge id)RightGradient, (__bridge id)blackColor, (__bridge id)blackColor, (__bridge id)LeftGradient];
                    gradientLayer.locations = @[@0.0, @0.3, @0.7, @1.0];
                    gradientLayer.startPoint = CGPointMake(0, 0.5);
                    gradientLayer.endPoint = CGPointMake(1, 0.5);
                    gradientLayer.cornerRadius = buttonSize / 2;
                    [button.layer insertSublayer:gradientLayer atIndex:0];
                    
                  
                    if (i < survivorActors.count) {
                        NSDictionary *survivorInfo = survivorActors[i];
                        NSString *iconName = survivorInfo[@"name"];
                        
                        SEL iconSelector = NSSelectorFromString(iconName);
                        if ([ImageBase64 respondsToSelector:iconSelector]) {
                            NSString *base64String = ((NSString* (*)(id, SEL))objc_msgSend)(ImageBase64.class, iconSelector);
                            if (base64String) {
                                NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
                                UIImage *iconImage = [UIImage imageWithData:imageData];
                                
                                button.imageView.contentMode = UIViewContentModeScaleAspectFit;
                                button.contentMode = UIViewContentModeScaleAspectFit;
                                button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                                button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                                
                                button.imageEdgeInsets = UIEdgeInsetsMake(8.0, 5.0, 2.0, 5.0);
                                [button setImage:iconImage forState:UIControlStateNormal];
                                
                                button.imageView.layer.magnificationFilter = kCAFilterNearest;
                                button.imageView.layer.minificationFilter = kCAFilterNearest;
                                button.imageView.userInteractionEnabled = NO;
                            }
                        }
                        
                        button.userInteractionEnabled = YES;
                        button.tag = i;
                        [button addTarget:self action:@selector(teleportToSpecificSurvivor:) forControlEvents:UIControlEventTouchUpInside];
                    } else {
                        [button setTitle:@"N/A" forState:UIControlStateNormal];
                        button.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
                        button.enabled = NO;
                        button.alpha = 0.5;
                    }
                    
                    [container addSubview:button];
                    survivorButtons[@(i)] = button;
                }
                
                // Dodaj przycisk killera identycznie jak survivor buttons
                static UIButton *killerButton = nil;
                if (!killerButton) {
                    killerButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    CGFloat killerX = (buttonSize + spacing) * 4 + kGroupSpacing;
                    killerButton.frame = CGRectMake(killerX, 0, buttonSize, buttonSize);
                    killerButton.layer.cornerRadius = buttonSize / 2;
                    killerButton.clipsToBounds = YES;
                    killerButton.tag = 9212;
                    killerButton.userInteractionEnabled = YES;
                    
                    // Dodaj gradient
                    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
                    gradientLayer.frame = killerButton.bounds;
                    gradientLayer.colors = @[(__bridge id)RightGradient, (__bridge id)blackColor, (__bridge id)blackColor, (__bridge id)LeftGradient];
                    gradientLayer.locations = @[@0.0, @0.3, @0.7, @1.0];
                    gradientLayer.startPoint = CGPointMake(0, 0.5);
                    gradientLayer.endPoint = CGPointMake(1, 0.5);
                    gradientLayer.cornerRadius = buttonSize / 2;
                    [killerButton.layer insertSublayer:gradientLayer atIndex:0];
                    
                    // Dodaj akcje
                    [killerButton addTarget:self 
                                   action:@selector(teleportToKiller:) 
                         forControlEvents:UIControlEventTouchUpInside];
                    
                    // Dodaj efekty dotknięcia
                    [killerButton addTarget:self 
                                   action:@selector(buttonTouchDown:) 
                         forControlEvents:UIControlEventTouchDown];
                    
                    [killerButton addTarget:self 
                                   action:@selector(buttonTouchUp:) 
                         forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
                    
                    [container addSubview:killerButton];
                    survivorButtons[@(4)] = killerButton;
                    
                    NSLog(@"Killer button created and configured");
                }
                
                // Aktualizuj tylko ikonę killera
                uintptr_t World = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
                if (World) {
                    uintptr_t GameState = *(uintptr_t*)(World + Offsets::SDK::UWorldToGameState);
                    if (GameState) {
                        uintptr_t Slasher = *(uintptr_t*)(GameState + Offsets::SDK::ADBDGameStateToSlasher);
                        if (Slasher && Slasher != LocalPlayer) {
                            NSString* KillerName = GetNameFromFName(*(int32_t*)(Slasher + Offsets::Special::UObjectToFNameOffset));
                            if (KillerName) {
                                NSString *iconName = [self getKillerIconName:KillerName];
                                if (iconName) {
                                    SEL iconSelector = NSSelectorFromString(iconName);
                                    if ([ImageBase64 respondsToSelector:iconSelector]) {
                                        NSString *base64String = ((NSString* (*)(id, SEL))objc_msgSend)(ImageBase64.class, iconSelector);
                                        if (base64String) {
                                            NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
                                            UIImage *iconImage = [UIImage imageWithData:imageData];
                                            if (iconImage) {
                                                // Ustaw obraz dokładnie tak samo jak dla survivorów
                                                killerButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
                                                killerButton.contentMode = UIViewContentModeScaleAspectFit;
                                                killerButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
                                                killerButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                                                killerButton.imageEdgeInsets = UIEdgeInsetsMake(8.0, 5.0, 2.0, 5.0);
                                                [killerButton setImage:iconImage forState:UIControlStateNormal];
                                                killerButton.imageView.layer.magnificationFilter = kCAFilterNearest;
                                                killerButton.imageView.layer.minificationFilter = kCAFilterNearest;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Dodaj log do debugowania
                NSLog(@"Killer button configured with actions");
            });
        });
        
    } @catch (NSException *exception) {
        NSLog(@"Error updating buttons: %@", exception);
    }
}

// Dodaj metody do obsługi efektów dotknięcia
+ (void)buttonTouchDown:(UIButton *)sender {
    [UIView animateWithDuration:0.1 animations:^{
        sender.transform = CGAffineTransformMakeScale(0.9, 0.9);
        sender.alpha = 0.7;
    }];
}

+ (void)buttonTouchUp:(UIButton *)sender {
    [UIView animateWithDuration:0.1 animations:^{
        sender.transform = CGAffineTransformIdentity;
        sender.alpha = 1.0;
    }];
}

// Zmodyfikuj metodę teleportacji do survivora
+ (void)teleportToSpecificSurvivor:(UIButton *)sender {
    if (!cachedSurvivorActors || sender.tag >= cachedSurvivorActors.count || !LocalPlayer) {
        return;
    }

    NSDictionary *survivorInfo = cachedSurvivorActors[sender.tag];
    uintptr_t Actor = [survivorInfo[@"actor"] unsignedLongLongValue];
    
    if (!Actor || Actor == LocalPlayer) {
        return;
    }

    uintptr_t RootComponent = *(uintptr_t*)(Actor + Offsets::SDK::AActorToRootComponent);
    if (!RootComponent) return;
    
    Vector3 position = *(Vector3*)(RootComponent + Offsets::SDK::USceneComponentToRelativeLocation);
    FRotator rotation = *(FRotator*)(RootComponent + Offsets::SDK::USceneComponentToRelativeRotation);
    position.Z += 100.0f;

    struct {
        bool snapPosition;
        Vector3 Position;
        float stopSnapDistance;
        bool snapRotation;
        FRotator Rotation;
        float Time;
        bool useZCoord;
        bool sweepOnFinalSnap;
        bool snapRoll;
    } params;
    
    params.snapPosition = true;
    params.Position = position;
    params.stopSnapDistance = 0.0f;
    params.snapRotation = true;
    params.Rotation = rotation;
    params.Time = 0.0f;
    params.useZCoord = true;
    params.sweepOnFinalSnap = false;
    params.snapRoll = true;
    
    ProcessEvent(LocalPlayer, FindObject(@"SnapCharacter"), (uintptr_t)&params);
}

// Zmodyfikuj metodę teleportacji do killera
+ (void)teleportToKiller:(UIButton *)sender {
    NSLog(@"Teleport to killer called!");
    TeleportToKiller();
    ShowAlert(@"Success", @"Teleporting to killer");
}

// Dodaj metodę do czyszczenia timera
+ (void)cleanup {
    if (updateTimer) {
        [updateTimer invalidate];
        updateTimer = nil;
    }
    
    [survivorPositions removeAllObjects];
    [cachedSurvivorActors removeAllObjects];
    [survivorButtons removeAllObjects];
    [survivorIcons removeAllObjects];
}

// Dodaj helper do sprawdzania wskaźników
static inline BOOL IsValidPointer(uintptr_t pointer) {
    return pointer > 0x100000 && pointer < 0x7FFFFFFFFFFF;
}

// Dodaj metodę do mapowania nazwy killera na nazwę ikony
+ (NSString *)getKillerIconName:(NSString *)killerName {
    // Mapowanie nazw killerów na ikony
    NSDictionary *killerIconMapping = @{
        @"BP_Slasher_Character_01_C": @"K01_TheTrapper_Portrait",
        @"BP_Slasher_Character_02_C": @"K02_TheWraith_Portrait",
        @"BP_Slasher_Character_03_C": @"K03_TheHillbilly_Portrait",
        @"BP_Slasher_Character_04_C": @"K04_TheNurse_Portrait",
        @"BP_Slasher_Character_05_C": @"K05_TheHag_Portrait",
        @"BP_Slasher_Character_06_C": @"K06_TheShape_Portrait",
        @"BP_Slasher_Character_07_C": @"K07_TheDoctor_Portrait",
        @"BP_Slasher_Character_08_C": @"K08_TheHuntress_Portrait",
        @"BP_Slasher_Character_09_C": @"K09_TheCannibal_Portrait",
        @"BP_Slasher_Character_10_C": @"K10_TheNightmare_Portrait",
        @"BP_Slasher_Character_11_C": @"K11_ThePig_Portrait",
        @"BP_Slasher_Character_12_C": @"K12_TheClown_Portrait",
        @"BP_Slasher_Character_13_C": @"K13_TheSpirit_Portrait",
        @"BP_Slasher_Character_14_C": @"K14_TheLegion_Portrait",
        @"BP_Slasher_Character_15_C": @"K15_ThePlague_Portrait",
        @"BP_Slasher_Character_16_C": @"K16_TheGhostface_Portrait",
        @"BP_Slasher_Character_17_C": @"K17_TheDemogorgon_Portrait",
        @"BP_Slasher_Character_18_C": @"K18_TheOni_Portrait",
        @"BP_Slasher_Character_19_C": @"K19_TheDeathslinger_Portrait",
        @"BP_Slasher_Character_20_C": @"K20_TheExecutioner_Portrait",
        @"BP_Slasher_Character_21_C": @"K21_TheBlight_Portrait",
        @"BP_Slasher_Character_22_C": @"K22_TheTwins_Portrait",
        @"BP_Slasher_Character_23_C": @"K23_TheTrickster_Portrait",
        @"BP_Slasher_Character_24_C": @"K24_TheNemesis_Portrait",
        @"BP_Slasher_Character_25_C": @"K25_TheCenobite_Portrait",
        @"BP_Slasher_Character_26_C": @"K26_TheArtist_Portrait",
        @"BP_Slasher_Character_27_C": @"K27_TheOnryo_Portrait",
        @"BP_Slasher_Character_28_C": @"K28_TheDredge_Portrait",
        @"BP_Slasher_Character_29_C": @"K29_TheWesterner_Portrait",
        @"BP_Slasher_Character_30_C": @"K30_TheKnight_Portrait",
        @"BP_Slasher_Character_31_C": @"K31_TheSkullMerchant_Portrait",
        @"BP_Slasher_Character_32_C": @"K32_TheSingularity_Portrait",
        @"BP_Slasher_Character_33_C": @"K33_TheXenomorph_Portrait",
        @"BP_Slasher_Character_34_C": @"K34_TheYerkes_Portrait",
        @"BP_Slasher_Character_35_C": @"K35_TheUnknown_Portrait"
    };
    
    return killerIconMapping[killerName];
}

// Dodaj metodę testową
+ (void)killerButtonTapped:(UIButton *)sender {
    NSLog(@"Killer button tapped!");
    ShowAlert(@"Debug", @"Killer button tapped");
    TeleportToKiller();
}

+ (void)hatchButtonTapped:(UIButton *)sender {
    NSLog(@"Hatch button tapped!");
    if (!LocalPlayer) {
        ShowAlert(@"Error", @"LocalPlayer not found");
        return;
    }
    TeleportToHatch();
    ShowAlert(@"Success", @"Teleporting to hatch");
}

+ (void)prevAttachSurvivor:(UIButton *)sender {
    if (!isAttachedToSurvivor) {
        ShowAlert(@"Error", @"First attach to survivor using AS");
        return;
    }
    
    if (!foundSurvivors || foundSurvivors.count == 0) {
        ShowAlert(@"Error", @"No survivors found");
        return;
    }
    
    PrevAttachSurvivor();
    ShowAlert(@"Success", [NSString stringWithFormat:@"Switched to previous survivor"]);
}

@end

@interface BindsView (TeleportActions)
+ (void)teleportToKiller:(id)sender;
+ (void)killerButtonTapped:(id)sender;
+ (void)hatchButtonTapped:(id)sender;
@end
