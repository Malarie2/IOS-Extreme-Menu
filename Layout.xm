#import "Layout.h"
#import "Magicolors/ColorsHandler.h"
#import "NFViews/MenuView.h"
#import "Magicolors/RGBManager.h"
#import "Cheat/Offsets.h"
#import <sys/stat.h>
#import <mach-o/dyld.h>
#import <mach/mach.h>
#import <mach/vm_map.h>
#import "Cheat/Utils.h"

// Deklaracja zewnętrzna zmiennej z Pointers.xm
extern uintptr_t LocalPlayer;
extern uintptr_t BaseAddress;
extern uintptr_t(*ProcessEvent)(uintptr_t Instance, uintptr_t Function, uintptr_t Parameters);

// Deklaracja funkcji GetSpectatorsCount
static int GetSpectatorsCount(void);

// Najpierw dodaj stałe dla ikon na początku pliku, po innych stałych
static NSString * const kScoreIcon = @"star.fill";
static NSString * const kPingIcon = @"wifi";
static NSString * const kKillerIcon = @"person.fill";
static NSString * const kPlayerIcon = @"person.2.fill";

// Na początku pliku, przed implementacją
struct FString {
    wchar_t* Data;
    int32_t Count;
    int32_t Max;
};

// Dodaj funkcję IsBadReadPtr jeśli jej nie ma
static inline bool IsBadReadPtr(void* p, size_t size) {
    if (!p || p == (void*)-1) return true;
    volatile uint8_t dummy;
    for (size_t i = 0; i < size; i += 0x1000) {
        dummy = ((uint8_t*)p)[i];
    }
    size_t remainder = size & 0xFFF;
    if (remainder) {
        dummy = ((uint8_t*)p)[size - 1];
    }
    return false;
}

// Funkcja do pobrania nazwy mapy
static NSString* GetCurrentMapName(void) {
    if (!BaseAddress) return @"N/A";
    
    uintptr_t World = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
    if (!World) return @"N/A";
    
    uintptr_t GameState = *(uintptr_t*)(World + Offsets::SDK::UWorldToGameState);
    if (!GameState) return @"N/A";
    
    static uintptr_t GetMapThemeName_Function = FindObject(@"GetMapThemeName");
    if (!GetMapThemeName_Function) return @"N/A";
    
    @try {
        struct {
            int32_t ReturnValue;
        } Parameters;
        memset(&Parameters, 0, sizeof(Parameters));
        
        ProcessEvent(GameState, GetMapThemeName_Function, (uintptr_t)&Parameters);
        
        NSString *mapName = GetNameFromFName(Parameters.ReturnValue);
        
        // Mapowanie nazw kodowych na przyjazne nazwy
        NSDictionary *mapNames = @{
            @"Ion": @"EYRIE OF CROWS",
            @"Ukraine": @"DEAD DAWG SALOON", 
            @"England": @"BADHAM PRESCHOOL",
            @"Kenya": @"ORMOND",
            @"Finland": @"THE GAME",
            @"Hospital": @"TREATMENT THEATRE",
            @"Swamp": @"SWAMP",
            @"Suburbs": @"HADDONFIELD",
            @"Asylum": @"ASYLUM",
            @"Haiti": @"YAMOKA",
            @"Farm": @"COLDWIND FARM",
            @"Junkyard": @"AUTO HEAVEN",
            @"Industrial": @"MAC MILLIAN"
        };
        
        // Jeśli mamy mapowanie dla tej mapy, użyj go
        NSString *friendlyName = mapNames[mapName];
        if (friendlyName) {
            return friendlyName;
        }
        
        // Jeśli nie znaleziono mapowania, zwróć oryginalną nazwę lub N/A
        return mapName.length > 0 ? mapName : @"N/A";
    } @catch (NSException *exception) {
        return @"N/A";
    }
}

// Add these forward declarations
static void updateLabelSize(UIView *labelView, NSString *newText);
static void updateLabels(void);  // Add this line
static NSString * const SHABBOS = @"30c28925bc848f267ba4f9b9b05c26261f561be17ca0d2c917b73be632d526b9";

static dispatch_source_t _timer;
static double FPSPerSecond = 0;
static dispatch_queue_t _timerQueue;
static CGFloat hue = 0.0;

UILabel *watermark = nil;

// Dodaj tę zmienną globalną na początku pliku
static BOOL isNSStringHookActive = NO;

// Dodaj te deklaracje na początku pliku, zaraz po innych deklaracjach statycznych
static dispatch_queue_t labelUpdateQueue = nil;
static CFTimeInterval lastUpdateTime = 0;
static const CFTimeInterval kMinUpdateInterval = 1.0/30.0; // Limit do 30 aktualizacji/s

extern BOOL isRGBCycleDisabled;

// Dodaj zmienne dla RGB Cycle
static CADisplayLink *rgbDisplayLink = nil;
static CGFloat rgbPhase = 0.0;
static BOOL isRGBCycleEnabled = NO;

// Dodaj na początku pliku
static CFTimeInterval lastRGBUpdate = 0;
static const CFTimeInterval kRGBUpdateInterval = 1.0/60.0; // 60 FPS dla RGB

// Deklaracja funkcji updateGradientColors na początku pliku
void updateGradientColors(void);

// Dodaj na początku pliku, po innych deklaracjach funkcji statycznych
static void updateLayoutFonts(NSString *fontName);

// Na początku Layout.x, dodaj definicje zmiennych extern
UIView *cruexLabel = nil;
UIView *timeLabel = nil;
UIView *fpsLabel = nil;
UIView *debugLabel = nil;
UIView *acwLabel = nil;
UIView *jbLabel = nil;

// Dodaj nowe zmienne na początku pliku
static UIView *layoutHideView = nil;
static NSArray *layoutLabels = nil;

// Na początku pliku, po innych deklaracjach funkcji statycznych, a przed definicjami zmiennych
static UIView* createLayoutSecureView(void);

// Dodaj na początku pliku, po innych zmiennych statycznych
static NSString *currentFontName = nil;

// Dodaj na początku pliku, po innych zmiennych statycznych
static NSDate *localPlayerDetectionTime = nil;

// Na początku pliku, gdzie są inne deklaracje UI elementów
static UIView *playerInfoLabel = nil;

// Najpierw zmodyfikujmy funkcję isInfoLabel, aby była bezpieczniejsza
static BOOL isInfoLabel(NSString *text) {
    if (!text) return NO;
    
    // Sprawdź czy to jest playerInfoLabel sprawdzając początek tekstu "Score:"
    return [text hasPrefix:@"Score:"] || 
           [text hasPrefix:@"Ping:"] || 
           [text hasPrefix:@"Killer:"] || 
           [text hasPrefix:@"Player:"];
}

#pragma mark - Label Creation and Management

static NSString * const kFontName = @"ArialRoundedMTBold";
static CGFloat const kLabelHeight = 15.0;
static CGFloat const kCornerRadius = 4.0;
static CGFloat const kSideMargin = 8.0;
static CGFloat const kTopMargin = 10.0;
static CGFloat const kLabelSpacing = 4.0;

// Dodaj funkcję createLabel
static UIView* createLabel(CGRect frame, NSString *text, BOOL alignRight) {
    // Pobierz zapisaną czcionkę lub użyj domyślnej
    if (!currentFontName) {
        currentFontName = [[NSUserDefaults standardUserDefaults] objectForKey:@"MenuFontStyle"];
        if (!currentFontName) {
            currentFontName = kFontName;
        }
    }
    
    UIFont *labelFont = [UIFont fontWithName:currentFontName size:8] ?: [UIFont fontWithName:kFontName size:8];
    
    CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName: labelFont}];
    CGFloat padding = [text isEqualToString:@"NINJA FRAMEWORK"] ? 0 : 2;
    CGFloat textWidth = textSize.width + padding * 2;
    
    UIView *containerView;
    if (isInfoLabel(text)) {
        containerView = [[UIView alloc] initWithFrame:frame];
        
        CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName: labelFont}];
        CGFloat innerWidth = textSize.width + 20; // Zmniejszono z 100 na 20 (usunięto miejsce na ikony)
        CGFloat xOffset = (frame.size.width - innerWidth) / 2;
        
        UIView *innerContainer = [[UIView alloc] initWithFrame:CGRectMake(xOffset, 0, innerWidth, frame.size.height)];
        innerContainer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        innerContainer.layer.cornerRadius = kCornerRadius;
        innerContainer.clipsToBounds = YES;
        
        // Dodaj gradienty
        CAGradientLayer *topGradient = [CAGradientLayer layer];
        topGradient.frame = CGRectMake(0, 0, innerWidth, 1.5);
        topGradient.colors = @[(__bridge id)RightGradient, (__bridge id)blackColor, (__bridge id)blackColor, (__bridge id)LeftGradient];
        topGradient.locations = @[@0.0, @0.3, @0.7, @1.0];
        topGradient.startPoint = CGPointMake(0, 0.5);
        topGradient.endPoint = CGPointMake(1, 0.5);
        
        CAGradientLayer *bottomGradient = [CAGradientLayer layer];
        bottomGradient.frame = CGRectMake(0, frame.size.height - 1.5, innerWidth, 1.5);
        bottomGradient.colors = @[(__bridge id)RightGradient, (__bridge id)blackColor, (__bridge id)blackColor, (__bridge id)LeftGradient];
        bottomGradient.locations = @[@0.0, @0.3, @0.7, @1.0];
        bottomGradient.startPoint = CGPointMake(0, 0.5);
        bottomGradient.endPoint = CGPointMake(1, 0.5);
        
        [innerContainer.layer addSublayer:topGradient];
        [innerContainer.layer addSublayer:bottomGradient];

        UILabel *label = [[UILabel alloc] initWithFrame:innerContainer.bounds];
        label.text = text;
        label.font = labelFont;
        label.textAlignment = NSTextAlignmentCenter;
        label.userInteractionEnabled = NO;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor clearColor];
        [innerContainer addSubview:label];
        
        [containerView addSubview:innerContainer];
        return containerView;
    } else {
        // Oryginalny kod dla pozostałych labeli
        containerView = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, textWidth, frame.size.height)];
    }
    containerView.backgroundColor = [UIColor clearColor];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:containerView.bounds];
    backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    backgroundView.layer.cornerRadius = kCornerRadius;
    backgroundView.clipsToBounds = YES;
    
    CAGradientLayer *topGradient = [CAGradientLayer layer];
    topGradient.frame = CGRectMake(0, 0, containerView.bounds.size.width, 1.5);
    topGradient.colors = @[(__bridge id)RightGradient, (__bridge id)blackColor, (__bridge id)blackColor, (__bridge id)LeftGradient];
    topGradient.locations = @[@0.0, @0.3, @0.7, @1.0];
    topGradient.startPoint = CGPointMake(0, 0.5);
    topGradient.endPoint = CGPointMake(1, 0.5);
    
    CAGradientLayer *bottomGradient = [CAGradientLayer layer];
    bottomGradient.frame = CGRectMake(0, containerView.bounds.size.height - 1.5, containerView.bounds.size.width, 1.5);
    bottomGradient.colors = @[(__bridge id)RightGradient, (__bridge id)blackColor, (__bridge id)blackColor, (__bridge id)LeftGradient];
    bottomGradient.locations = @[@0.0, @0.3, @0.7, @1.0];
    bottomGradient.startPoint = CGPointMake(0, 0.5);
    bottomGradient.endPoint = CGPointMake(1, 0.5);
    
    [backgroundView.layer addSublayer:topGradient];
    [backgroundView.layer addSublayer:bottomGradient];
    [containerView addSubview:backgroundView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:containerView.bounds];
    label.text = text;
    label.font = labelFont;
    if (isInfoLabel(text)) {
        label.textAlignment = NSTextAlignmentCenter;
    } else {
        label.textAlignment = alignRight ? NSTextAlignmentRight : NSTextAlignmentLeft;
    }
    label.userInteractionEnabled = NO;
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    [containerView addSubview:label];
    
    return containerView;
}

static void createLabelsIfNeeded(UIWindow *self) {
    CGFloat currentY = kTopMargin;
    CGFloat labelWidth = 100;
    
    // Prosta tablica z informacjami o etykietach
    if (!cruexLabel) {
        cruexLabel = createLabel(CGRectMake(kSideMargin, currentY, labelWidth, kLabelHeight),
                               @"NINJA FRAMEWORK", NO);
        [self addSubview:cruexLabel];
        currentY = CGRectGetMaxY(cruexLabel.frame) + kLabelSpacing;
    }
    
    if (!timeLabel) {
        timeLabel = createLabel(CGRectMake(kSideMargin, currentY, labelWidth, kLabelHeight),
                              @"TIME:", NO);
        [self addSubview:timeLabel];
        currentY = CGRectGetMaxY(timeLabel.frame) + kLabelSpacing;
    }
    
    if (!fpsLabel) {
        fpsLabel = createLabel(CGRectMake(kSideMargin, currentY, labelWidth, kLabelHeight),
                             @"FPS:", NO);
        [self addSubview:fpsLabel];
    }
    
    // Prawe etykiety
    currentY = kTopMargin;
    
    if (!debugLabel) {
        debugLabel = createLabel(CGRectMake(self.frame.size.width - labelWidth - kSideMargin,
                                          currentY, labelWidth, kLabelHeight),
                               @"PRIVATE BUILD", YES);
        [self addSubview:debugLabel];
        currentY = CGRectGetMaxY(debugLabel.frame) + kLabelSpacing;
    }
    
    if (!acwLabel) {
        acwLabel = createLabel(CGRectMake(self.frame.size.width - labelWidth - kSideMargin,
                                        currentY, labelWidth, kLabelHeight),
                             @"ACW:", YES);
        [self addSubview:acwLabel];
        currentY = CGRectGetMaxY(acwLabel.frame) + kLabelSpacing;
    }
    
    if (!jbLabel) {
        jbLabel = createLabel(CGRectMake(self.frame.size.width - labelWidth - kSideMargin,
                                       currentY, labelWidth, kLabelHeight),
                            @"JB:", YES);
        [self addSubview:jbLabel];
        currentY = CGRectGetMaxY(jbLabel.frame) + kLabelSpacing;
    }
    
    // Po utworzeniu innych labeli, dodaj nowy label na środku
    if (!playerInfoLabel) {
        CGFloat labelWidth = self.frame.size.width - 20; // Zostaw małe marginesy po bokach
        playerInfoLabel = createLabel(CGRectMake(10, kTopMargin, labelWidth, kLabelHeight),
                                    @"Score: N/A | Ping: N/A | Killer: N/A | Player: N/A", NO);
        [self addSubview:playerInfoLabel];
        [self bringSubviewToFront:playerInfoLabel];
    }
}

#pragma mark - Label Update

static void updateLabels(void) {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm"];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    });
    
    // Aktualizacja czasu wykrycia LocalPlayer
    if (LocalPlayer && !localPlayerDetectionTime) {
        localPlayerDetectionTime = [NSDate date];
    } else if (!LocalPlayer) {
        localPlayerDetectionTime = nil;
    }
    
    // Batch updates
    dispatch_async(labelUpdateQueue, ^{
        NSString *timeString = [NSString stringWithFormat:@"TIME: %@", [formatter stringFromDate:[NSDate date]]];
        
        // Oblicz czas od wykrycia LocalPlayer
        NSString *matchString;
        if (localPlayerDetectionTime) {
            NSTimeInterval timeSinceDetection = -[localPlayerDetectionTime timeIntervalSinceNow];
            int minutes = (int)(timeSinceDetection / 60);
            int seconds = (int)timeSinceDetection % 60;
            matchString = [NSString stringWithFormat:@"MATCH: %02d:%02d", minutes, seconds];
        } else {
            matchString = @"MATCH: N/A";
        }
        
        NSString *mapString = [NSString stringWithFormat:@"MAP: %@", GetCurrentMapName()];
        NSString *specString;
        int spectatorCount = GetSpectatorsCount();
        if (spectatorCount > 0) {
            specString = [NSString stringWithFormat:@"SPECTATORS: %d", spectatorCount];
        } else {
            specString = @"SPECTATORS: N/A";
        }
        
        // Zadeklaruj zmienne przed użyciem
        NSString *characterName = @"N/A";
        NSString *playerName = @"Unknown";
        int ping = 0;
        float score = 0.0f;
        
        // Dodaj aktualizację informacji o graczu
        if (LocalPlayer) {
            uintptr_t World = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
            if (World) {
                uintptr_t GameState = *(uintptr_t*)(World + Offsets::SDK::UWorldToGameState);
                if (GameState) {
                    uintptr_t Slasher = *(uintptr_t*)(GameState + Offsets::SDK::ADBDGameStateToSlasher);
                    if (Slasher) {
                        NSString* KillerName = GetNameFromFName(*(int32_t*)(Slasher + Offsets::Special::UObjectToFNameOffset));
                        
                        // Mapowanie dla killerów
                        static NSDictionary *killerNames = @{
                            @"BP_Slasher_Character_01_C": @"Traper",
                            @"BP_Slasher_Character_02_C": @"Wraith",
                            @"BP_Slasher_Character_03_C": @"Hillbilly",
                            @"BP_Slasher_Character_04_C": @"Nurse",
                            @"BP_Slasher_Character_05_C": @"Hag",
                            @"BP_Slasher_Character_06_C": @"Shape",
                            @"BP_Slasher_Character_07_C": @"Doctor",
                            @"BP_Slasher_Character_08_C": @"Huntress",
                            @"BP_Slasher_Character_09_C": @"Cannibal",
                            @"BP_Slasher_Character_10_C": @"Nightmare",
                            @"BP_Slasher_Character_11_C": @"Pig",
                            @"BP_Slasher_Character_12_C": @"Clown",
                            @"BP_Slasher_Character_13_C": @"Spirit",
                            @"BP_Slasher_Character_14_C": @"Legion",
                            @"BP_Slasher_Character_15_C": @"Plague",
                            @"BP_Slasher_Character_16_C": @"Ghostface",
                            @"BP_Slasher_Character_18_C": @"Oni",
                            @"BP_Slasher_Character_19_C": @"Deathslinger",
                            @"BP_Slasher_Character_21_C": @"Blight",
                            @"BP_Slasher_Character_22_C": @"Twins",
                            @"BP_Slasher_Character_23_C": @"Trickster",
                            @"BP_Slasher_Character_25_C": @"Cenobite",
                            @"BP_Slasher_Character_26_C": @"Artist",
                            @"BP_Slasher_Character_27_C": @"Onryo",
                            @"BP_Slasher_Character_28_C": @"Dredge",
                            @"BP_Slasher_Character_30_C": @"Knight",
                            @"BP_Slasher_Character_31_C": @"Skull",
                            @"BP_Slasher_Character_32_C": @"Singularity",
                            @"BP_Slasher_Character_34_C": @"Chucky",
                            @"BP_Slasher_Character_35_C": @"Unknown"
                        };
                        
                        characterName = killerNames[KillerName] ?: @"Unknown Killer";
                        
                        uintptr_t PlayerState = *(uintptr_t*)(Slasher + 0x250);
                        if (PlayerState) {
                            // Pobierz nazwę gracza
                            struct FString* namePtr = (struct FString*)(PlayerState + 0x310);
                            if (namePtr && !IsBadReadPtr(namePtr, sizeof(struct FString))) {
                                struct FString name = *namePtr;
                                if (name.Data && name.Count > 0 && !IsBadReadPtr(name.Data, name.Count * sizeof(wchar_t))) {
                                    playerName = [[NSString alloc] initWithBytes:name.Data
                                                                       length:name.Count * 2
                                                                     encoding:NSUTF16LittleEndianStringEncoding] ?: @"Unknown";
                                }
                            }
                            
                            @try {
                                if (!IsBadReadPtr((void*)(PlayerState + 0x230), sizeof(float))) {
                                    score = *(float*)(PlayerState + 0x230);
                                }
                                
                                if (!IsBadReadPtr((void*)(PlayerState + 0x238), sizeof(char))) {
                                    ping = *(char*)(PlayerState + 0x238);
                                }
                                
                            } @catch (NSException *exception) {
                                NSLog(@"[ERROR] Exception while updating playerInfo: %@", exception);
                            }
                        }
                    }
                }
            }
        }

        // Teraz możemy bezpiecznie użyć tych zmiennych w bloku dispatch_async
        dispatch_async(dispatch_get_main_queue(), ^{
            updateLabelSize(timeLabel, timeString);
            updateLabelSize(debugLabel, matchString);
            updateLabelSize(acwLabel, mapString);
            updateLabelSize(jbLabel, specString);
            
            // Formatuj wszystkie informacje w jeden string w żądanej kolejności
            NSString *killerDisplay;
            if (LocalPlayer && (ping <= 0)) {
                // Jeśli LocalPlayer jest wykryty i ping jest 0 lub niedostępny, dodaj oznaczenie (BOT)
                killerDisplay = [characterName isEqualToString:@"Unknown"] ? @"N/A" : 
                              [NSString stringWithFormat:@"%@ (BOT)", characterName];
            } else {
                killerDisplay = [characterName isEqualToString:@"Unknown"] ? @"N/A" : characterName;
            }
            
            NSString *playerInfoString = [NSString stringWithFormat:@"Score: %@ | Ping: %@ | Killer: %@ | Player: %@",
                                        score > 0 ? [NSString stringWithFormat:@"%.0f", score] : @"N/A",
                                        ping > 0 ? [NSString stringWithFormat:@"%d", ping] : @"N/A",
                                        killerDisplay,
                                        [playerName isEqualToString:@"Unknown"] ? @"N/A" : playerName];
            
            updateLabelSize(playerInfoLabel, playerInfoString);
        });
    });
}

// Na początku pliku, dodaj deklarację kolejki
static dispatch_queue_t gradientUpdateQueue;
// W istniejącej metodzie updateGradientColors, dodaj aktualizację dla nowych elementów
void updateGradientColors(void) {
    if (rgbDisplayLink) {
        // Jeśli RGB Cycle jest aktywny, kolory są już aktualizowane przez displayLink
        return;
    }
    
    // Standardowe kolory gdy RGB Cycle jest wyłączony
    NSArray *colors = @[
        (__bridge id)RightGradient,
        (__bridge id)blackColor,
        (__bridge id)blackColor,
        (__bridge id)LeftGradient
    ];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *allLabels = @[
            cruexLabel, timeLabel, fpsLabel, watermark, debugLabel,
            acwLabel, jbLabel, playerInfoLabel
        ];
        
        for (UIView *view in allLabels) {
            if (!view) continue;
            
            if (view == watermark) {
                for (CALayer *layer in view.layer.sublayers) {
                    if ([layer isKindOfClass:[CAGradientLayer class]]) {
                        ((CAGradientLayer *)layer).colors = colors;
                    }
                }
                continue;
            }
            
            UIView *backgroundView = [view.subviews firstObject];
            if (!backgroundView) continue;
            
            for (CALayer *layer in backgroundView.layer.sublayers) {
                if ([layer isKindOfClass:[CAGradientLayer class]]) {
                    ((CAGradientLayer *)layer).colors = colors;
                }
            }
        }
    });
}

#pragma mark - Hook Method

%hook UIWindow

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        createLabelsIfNeeded(self);
        startRefreshTimer();
        
        // Add watermark
        CGFloat watermarkWidth = self.frame.size.width / 5;
        
        watermark = (UILabel *)[[UILabel alloc] initWithFrame:CGRectMake(0, 0, watermarkWidth, 15)];
        ((UILabel *)watermark).backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.8];
        ((UILabel *)watermark).layer.cornerRadius = 5.0;
        ((UILabel *)watermark).clipsToBounds = YES;
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:@"T.ME/CRUEXGG DEVELOPED BY ALEX ZERO"];
        [attributedText addAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"ArialRoundedMTBold" size:12]} range:NSMakeRange(0, 13)];
        [attributedText addAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"ArialRoundedMTBold" size:10]} range:NSMakeRange(13, attributedText.length - 13)];
        ((UILabel *)watermark).attributedText = attributedText;
        
        [Colors initializeColors];
        
        void (^addGradientLayer)(CAGradientLayer *, CGRect) = ^(CAGradientLayer *layer, CGRect frame) {
            layer.frame = frame;
            layer.colors = @[(__bridge id)RightGradient, (__bridge id)blackColor, (__bridge id)blackColor, (__bridge id)LeftGradient];
            layer.locations = @[@0.0, @0.3, @0.7, @1.0];
            layer.startPoint = CGPointMake(0, 0.5);
            layer.endPoint = CGPointMake(1, 0.5);
            [watermark.layer addSublayer:layer];
        };
        
        addGradientLayer([CAGradientLayer layer], CGRectMake(0, 0, watermarkWidth, 2));
        addGradientLayer([CAGradientLayer layer], CGRectMake(0, watermark.frame.size.height - 2, watermarkWidth, 2));
        
        ((UILabel *)watermark).adjustsFontSizeToFitWidth = YES;
        ((UILabel *)watermark).center = CGPointMake(CGRectGetMinX(self.frame) + watermarkWidth / 2 + 10, CGRectGetMaxY(self.frame) - watermark.frame.size.height - 5);
        ((UILabel *)watermark).textAlignment = NSTextAlignmentCenter;
        ((UILabel *)watermark).textColor = UIColor.whiteColor;
        [self addSubview:watermark];
        
        // Dodaj obserwatory dla zabezpieczenia screenshotów
        [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLayoutScreenshotProtection:)
                                                 name:@"EnableScreenshotProtection"
                                               object:nil];
                                               
        [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleLayoutScreenshotDisable:)
                                                 name:@"DisableScreenshotProtection"
                                               object:nil];
                                               
        // Zachowaj referencje do wszystkich etykiet
        layoutLabels = @[cruexLabel, timeLabel, fpsLabel, watermark, debugLabel,
                        acwLabel, jbLabel, playerInfoLabel];
        
        // Dodaj obserwator zmiany czcionki
        [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleFontChange:)
                                                 name:@"UpdateLayoutFont"
                                               object:nil];
    });
    updateLabels();
    return %orig;
}

%new
- (void)handleLayoutScreenshotProtection:(NSNotification *)notification {
    if (!layoutHideView) {
        layoutHideView = createLayoutSecureView();
        UIView *clearView = layoutHideView.subviews.firstObject.subviews.firstObject;
        
        // Przenieś wszystkie etykiety do zabezpieczonego widoku
        for (UIView *label in layoutLabels) {
            if (label && label.superview) {
                [clearView addSubview:label];
            }
        }
        
        [self addSubview:layoutHideView];
    }
}

%new
- (void)handleLayoutScreenshotDisable:(NSNotification *)notification {
    if (layoutHideView) {
        UIView *clearView = layoutHideView.subviews.firstObject.subviews.firstObject;
        
        // Przywróć wszystkie etykiety do głównego okna
        for (UIView *label in layoutLabels) {
            if (label && label.superview == clearView) {
                [self addSubview:label];
            }
        }
        
        [layoutHideView removeFromSuperview];
        layoutHideView = nil;
    }
}

%new
- (void)handleFontChange:(NSNotification *)notification {
    NSString *newFont = notification.userInfo[@"fontName"];
    if (newFont) {
        updateLayoutFonts(newFont);
    }
}

%end

#pragma mark - Frame Tick Calculation

static void frameTick() {
    static double lastTime = 0;
    static double frameSum = 0;
    static int frameCount = 0;
    static const int FRAME_SAMPLE_SIZE = 30; // Zmniejszono z 60 na 30
    
    double currentTime = CACurrentMediaTime() * 1000.0;
    if (lastTime == 0) {
        lastTime = currentTime;
        return;
    }
    
    double delta = currentTime - lastTime;
    lastTime = currentTime;
    
    frameSum += delta;
    frameCount++;
    
    if (frameCount >= FRAME_SAMPLE_SIZE) {
        FPSPerSecond = (1000.0 * FRAME_SAMPLE_SIZE) / frameSum;
        frameCount = 0;
        frameSum = 0;
    }
}

#pragma mark - GL Hooks

%hook EAGLContext

- (BOOL)presentRenderbuffer:(NSUInteger)target {
    BOOL ret = %orig;
    frameTick();
    return ret;
}

%end

#pragma mark - Metal Hooks

%hook CAMetalDrawable

- (void)present {
    %orig;
    frameTick();
}

- (void)presentAfterMinimumDuration:(CFTimeInterval)duration {
    %orig;
    frameTick();
}

- (void)presentAtTime:(CFTimeInterval)presentationTime {
    %orig;
    frameTick();
}

%end

// Move the implementation of updateLabelSize to the end of the file
static void updateLabelSize(UIView *labelView, NSString *newText) {
    if (!labelView) return;
    
    // Sprawdź czy to jest info label
    BOOL isInfo = isInfoLabel(newText);
    
    if (isInfo) {
        UIView *innerContainer = [labelView.subviews firstObject];
        if (innerContainer) {
            UILabel *label = [innerContainer.subviews lastObject];
            if ([label isKindOfClass:[UILabel class]]) {
                label.text = newText;
                
                // Oblicz dokładną szerokość tekstu bez paddingu
                CGSize textSize = [newText sizeWithAttributes:@{NSFontAttributeName: label.font}];
                CGFloat newWidth = textSize.width; // Bez dodatkowego paddingu
                
                // Aktualizuj pozycję i rozmiar kontenera
                CGFloat xOffset = (labelView.superview.frame.size.width - newWidth) / 2;
                innerContainer.frame = CGRectMake(xOffset, innerContainer.frame.origin.y, 
                                                newWidth, 
                                                innerContainer.frame.size.height);
                
                // Aktualizuj gradienty
                for (CALayer *layer in innerContainer.layer.sublayers) {
                    if ([layer isKindOfClass:[CAGradientLayer class]]) {
                        CAGradientLayer *gradientLayer = (CAGradientLayer *)layer;
                        CGRect frame = gradientLayer.frame;
                        frame.size.width = newWidth;
                        gradientLayer.frame = frame;
                    }
                }
                
                // Aktualizuj ramkę labela
                label.frame = innerContainer.bounds;
            }
        }
    } else {
        // Oryginalny kod dla pozostałych labeli
        UILabel *label = [labelView.subviews lastObject];
        label.text = newText;
        
        // Calculate new width
        CGSize textSize = [newText sizeWithAttributes:@{NSFontAttributeName: label.font}];
        CGFloat padding = [newText isEqualToString:@"NINJA FRAMEWORK"] ? 0 : 2;
        CGFloat newWidth = textSize.width + padding * 2;
        
        // Update frames
        if (label.textAlignment == NSTextAlignmentRight) {
            // For right-aligned labels
            CGFloat rightMargin = 10;
            labelView.frame = CGRectMake(labelView.superview.frame.size.width - newWidth - rightMargin, 
                                       labelView.frame.origin.y, 
                                       newWidth, 
                                       labelView.frame.size.height);
        } else {
            // For left-aligned labels
            labelView.frame = CGRectMake(labelView.frame.origin.x, 
                                       labelView.frame.origin.y, 
                                       newWidth, 
                                       labelView.frame.size.height);
        }
        
        UIView *backgroundView = [labelView.subviews firstObject];
        backgroundView.frame = labelView.bounds;
        label.frame = labelView.bounds;
        
        // Update gradient layers
        for (CALayer *layer in backgroundView.layer.sublayers) {
            if ([layer isKindOfClass:[CAGradientLayer class]]) {
                CAGradientLayer *gradientLayer = (CAGradientLayer *)layer;
                gradientLayer.frame = CGRectMake(0, gradientLayer.frame.origin.y, newWidth, gradientLayer.frame.size.height);
            }
        }
    }
}

%hook FIOSNetEaseListener

- (void)OnNetEaseExtendNotification:(id)notification {
    NSMutableDictionary *userInfo = [[notification userInfo] mutableCopy];
    
    // Jeśli to sprawdzenie jailbreak
    if ([userInfo[@"methodId"] isEqualToString:@"isJailBreak"]) {
        // Wymuszamy false
        userInfo[@"jailBreak"] = @NO;
        notification = [[NSNotification alloc] initWithName:[notification name] 
                                                   object:[notification object] 
                                                 userInfo:userInfo];
    }
    
    %orig(notification);
}

%end
%hook NSString

- (const char*)UTF8String {
    isNSStringHookActive = YES;
    const char* result = %orig;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        isNSStringHookActive = NO;
    });
    
    if (self.length != 64) return result;
    
    static NSCharacterSet *hexCharacterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hexCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefABCDEF"];
    });
    
    if ([self rangeOfCharacterFromSet:[hexCharacterSet invertedSet]].location != NSNotFound) {
        return result;
    }
    
    return [SHABBOS UTF8String];
}

%end

// Przenieś implementację createLayoutSecureView przed %hook UIWindow
static UIView* createLayoutSecureView(void) {
    UIView *containerView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    UITextField *textField = [[UITextField alloc] init];
    textField.secureTextEntry = YES;
    textField.frame = containerView.bounds;
    [containerView addSubview:textField];
    
    UIView *clearView = [[UIView alloc] init];
    clearView.frame = containerView.bounds;
    [textField.subviews.firstObject addSubview:clearView];
    
    return containerView;
}

// Następnie poprawmy funkcję updateLayoutFonts
static void updateLayoutFonts(NSString *fontName) {
    if (!fontName) return;
    
    currentFontName = fontName;
    UIFont *newFont = [UIFont fontWithName:fontName size:8];
    if (!newFont) return;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *allLabels = @[cruexLabel, timeLabel, fpsLabel, debugLabel,
                              acwLabel, jbLabel, playerInfoLabel];
        
        for (UIView *labelView in allLabels) {
            if (!labelView) continue;
            
            // Bezpieczniejsze sprawdzanie czy to playerInfoLabel
            BOOL isInfo = NO;
            if ([labelView.subviews.firstObject isKindOfClass:[UIView class]]) {
                UIView *innerContainer = [labelView.subviews firstObject];
                if ([innerContainer.subviews.lastObject isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel *)innerContainer.subviews.lastObject;
                    isInfo = isInfoLabel(label.text);
                }
            }
            
            if (isInfo) {
                UIView *innerContainer = [labelView.subviews firstObject];
                if (innerContainer) {
                    UILabel *label = [innerContainer.subviews lastObject];
                    if ([label isKindOfClass:[UILabel class]]) {
                        NSString *currentText = label.text;
                        label.font = newFont;
                        updateLabelSize(labelView, currentText);
                    }
                }
            } else {
                UILabel *label = [labelView.subviews lastObject];
                if ([label isKindOfClass:[UILabel class]]) {
                    NSString *currentText = label.text;
                    label.font = newFont;
                    updateLabelSize(labelView, currentText);
                }
            }
        }
        
        // Zaktualizuj watermark jeśli istnieje
        if (watermark) {
            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] 
                initWithString:@"T.ME/CRUEXGG DEVELOPED BY ALEX ZERO"];
            [attributedText addAttributes:@{NSFontAttributeName: [UIFont fontWithName:fontName size:12]} 
                                  range:NSMakeRange(0, 13)];
            [attributedText addAttributes:@{NSFontAttributeName: [UIFont fontWithName:fontName size:10]} 
                                  range:NSMakeRange(13, attributedText.length - 13)];
            ((UILabel *)watermark).attributedText = attributedText;
        }
    });
}

// Funkcja do zliczania spectatorów
static int GetSpectatorsCount(void) {
    if (!BaseAddress) return 0;
    
    uintptr_t World = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
    if (!World) return 0;
    
    uintptr_t GameState = *(uintptr_t*)(World + Offsets::SDK::UWorldToGameState);
    if (!GameState) return 0;
    
    int spectatorCount = 0;
    
    @try {
        // Pobierz tablicę PlayerArray z GameState
        uintptr_t PlayerArray = *(uintptr_t*)(GameState + 0x248);  // Offset PlayerArray
        if (!PlayerArray) return 0;
        
        const int32_t PlayerCount = 4;  // Stała liczba survivors
        bool foundAnyValidPlayer = false;
        
        for (int i = 0; i < PlayerCount; i++) {
            uintptr_t PlayerState = *(uintptr_t*)(PlayerArray + i * sizeof(uintptr_t));
            if (!PlayerState) continue;
            
            // Sprawdź czy adres PlayerState jest poprawny
            vm_size_t outSize;
            if (vm_read_overwrite(mach_task_self(), PlayerState + 0x23a, sizeof(uint8_t), (vm_address_t)&outSize, &outSize) != KERN_SUCCESS) {
                continue;
            }
            
            foundAnyValidPlayer = true;
            
            // Sprawdź flagi spectatora
            uint8_t flags = *(uint8_t*)(PlayerState + 0x23a);
            bool isSpectator = (flags & (1 << 1)) != 0;  // bIsSpectator
            bool onlySpectator = (flags & (1 << 2)) != 0;  // bOnlySpectator
            
            if (isSpectator || onlySpectator) {
                spectatorCount++;
            }
        }
        
        // Jeśli nie znaleziono żadnego poprawnego gracza, zwróć 0
        if (!foundAnyValidPlayer) {
            return 0;
        }
        
    } @catch (NSException *exception) {
        return 0;
    }
    
    return spectatorCount;
}

@implementation Layout

+ (void)startRGBCycle {
    [RGBManager startRGBCycle];
}

+ (void)stopRGBCycle {
    [RGBManager stopRGBCycle];
}

@end

void startRefreshTimer(void) {
    if (_timer) return;
    
    if (!labelUpdateQueue) {
        labelUpdateQueue = dispatch_queue_create("com.cruex.labelupdate", DISPATCH_QUEUE_SERIAL);
    }
    
    _timerQueue = dispatch_queue_create("com.cruex.fps", DISPATCH_QUEUE_SERIAL);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _timerQueue);
    
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, (uint64_t)(0.033 * NSEC_PER_SEC), 0);
    
    dispatch_source_set_event_handler(_timer, ^{
        CFTimeInterval currentTime = CACurrentMediaTime();
        if (currentTime - lastUpdateTime < kMinUpdateInterval) return;
        
        lastUpdateTime = currentTime;
        
        dispatch_async(labelUpdateQueue, ^{
            NSString *fpsString = [NSString stringWithFormat:@"FPS: %.1lf", FPSPerSecond];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                updateLabelSize(fpsLabel, fpsString);
                updateGradientColors();
                updateLabels();
            });
        });
    });
    dispatch_resume(_timer);
}








