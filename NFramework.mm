#import <CommonCrypto/CommonCrypto.h>
#import <QuartzCore/QuartzCore.h>
#import "NFramework.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIAlertView.h>
#import <UIKit/UIControl.h>
#import "Magicolors/RGBManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "NFViews/MenuView.h"
#import "Utils/NakanoIchika.h"
#import "Utils/NakanoNino.h"
#import "Utils/NakanoMiku.h"
#import "Utils/NFPatch.h"
#import "Utils/NakanoItsuki.h"
#import "Utils/dobby.h"
#import "Icons/NFIcons.h"
#import "Magicolors/ColorsHandler.h"
#import "TrustMe/Auth.h"
#import "KittyMemory/MemoryPatch.hpp"
#import <objc/runtime.h>
#import "NFToggles.h"
#import "NFViews/IGGMemView.h"
#import "Icons/Customization.h"
#import "Cheat/Globals.h"
#import "Cheat/Pointers.h"
#import "Cheat/Utils.h"
#import "SDKCheats/TeleportManager.h"
#import "SDKCheats/CharacterManager.h"
#import <mach/mach.h>
#import <mach/vm_map.h>
#import "ESPView.h"
#import "NFViews/ModifiersView.h"
#import "Cheat/SDK.h"
#import "NFViews/VisualsView.h"
#import "NFViews/ExploitView.h"
#import "NFViews/MiscView.h"
#import "NFViews/Aimbot.h"
#import "NFViews/ToolsView.h"
#import "NFViews/AuraView.h"
#import "NFViews/KillerView.h"
#import "NFViews/SkillChecksView.h"
#import "NFViews/SurvivorView.h"
#import "NFViews/StatesView.h"
#import "NFViews/BindsView.h"







static BOOL isFloatIconEnabled = NO;
extern "C" BOOL getFloatIconEnabled(void) { return isFloatIconEnabled; }
extern "C" void setFloatIconEnabled(BOOL value) { isFloatIconEnabled = value; }

extern void SetCustomFOV(float fov);
extern void SetPlayerAnimation(EInteractionAnimation animation);

typedef enum EInteractionAnimation EInteractionAnimation;

extern void SetPrestigeLevel(int prestige);
static BOOL isMenuOpen = NO;

extern NSMutableArray<NSValue*>* generatorPositions;
extern int currentGeneratorIndex;

NSMutableArray<NSValue*>* generatorPositions = nil;
int currentGeneratorIndex = 0;

extern void TeleportToNearestGenerator(void);
extern void UpdateGeneratorPositions(void);

static UILabel *survivorLeftLabel;
static UILabel *survivorRightLabel;
static UILabel *killerLeftLabel;
static UILabel *killerRightLabel;
static BOOL isDragableMenuEnabled = NO;

@interface NFramework() <UITextFieldDelegate>


@property (nonatomic) UIButton *btnConsole;
@property (nonatomic, strong) UIImageView *imageView;
@end

UIView *menuView;
UIButton *closeButton;
static CGFloat hue = 0.0;
static CADisplayLink *displayLink;
extern BOOL isRGBCycleDisabled;

BOOL isRGBCycleDisabled = YES;

static float (*orig_player_speed)(void *) = NULL;
static float (*orig_sensitivity)(void *) = NULL;
static float (*orig_render_scale)(void *) = NULL;

static NSString *currentFont = @"ArialRoundedMTBold";
static UIImageView *menuIcon;
static BOOL isDraggingIcon = NO;
static CGPoint lastTouchPoint;
static dispatch_queue_t gradientUpdateQueue;
static BOOL isAutoHideEnabled = NO;

NSMutableDictionary *appliedPatches;
NSMutableDictionary *originalBytes;

static BOOL isInitialized = NO;

// Dodaj nowe zmienne statyczne na początku pliku
static CGFloat lastMenuRotation = 0.0;
static CGFloat lastMenuScale = 0.8;

// Dodaj nową zmienną statyczną dla timera
static NSTimer *countdownTimer;
static UILabel *countdownLabel;

// Dodaj na początku pliku z innymi zmiennymi statycznymi
UIView *countdownContainer;

// Dodaj nowe zmienne statyczne na początku pliku
static UILabel *deviceStatsLabel;
static UIView *deviceStatsContainer;

// Dodaj nowe zmienne statyczne na początku pliku
static processor_info_array_t previousCPUInfo = NULL;
static mach_msg_type_number_t previousCPUInfoCnt = 0;
static unsigned numPrevCPUSamples = 0;

@implementation NFramework

#pragma mark -------------------------------------View-------------------------------------------

+ (void)load
{
    static NSString *const kExpectedVersion = @"1.292949.292949";


   
    // Reszta kodu metody load...
    if (!generatorPositions) {
        generatorPositions = [NSMutableArray new];
    }

    // Start UpdatePointersLoop in a background thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UpdatePointersLoop();
    });

    // Sprawdź czy plik wideo istnieje
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject 
                      stringByAppendingPathComponent:@"NFramework/video.MOV"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSURL *videoURL = [NSURL fileURLWithPath:path];
        AVPlayer *player = [AVPlayer playerWithURL:videoURL];
        AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
        
        // Dodaj obserwator zakończenia odtwarzania
        [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
                                                        object:player.currentItem
                                                         queue:[NSOperationQueue mainQueue]
                                                    usingBlock:^(NSNotification *note) {
            [playerLayer removeFromSuperlayer];
        }];

        dispatch_async(dispatch_get_main_queue(), ^{
            UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
            playerLayer.frame = mainWindow.bounds;
            [mainWindow.layer addSublayer:playerLayer];
            [player play];
        });
    }
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Check app version and notify
        NSString *appVersion = NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"];
        if ([appVersion isEqualToString:kExpectedVersion]) {
            // Dodaj sprawdzanie licencji tutaj
            if ([TrustMe inPlist]) {
                @try {
                    // Dodaj nowy kod dla DisableACSDK
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        UISwitch *acSwitch = [[UISwitch alloc] init];
                        [acSwitch setOn:YES animated:NO];
                        [self DisableACSDK:acSwitch];
                    });
                    
                    char hostname[256];
                    gethostname(hostname, sizeof(hostname));
                    NSString *deviceName = [NSString stringWithUTF8String:hostname];
                    [self showNotification:@" Ninja Framework" message:[NSString stringWithFormat:@"Welcome %@", deviceName] duration:3.0];
                    
                    NFramework *view = [NFramework View];
                    [view show];
                    [[[[UIApplication sharedApplication] windows]lastObject] addSubview:view];
                    
                    //New Application Windows
                    UIWindow *Window = [UIApplication sharedApplication].keyWindow;
                    
                    // Dodaj ikonę menu z obsługą błędów
                    @try {
                        [self addMenuIcon];
                    } @catch (NSException *exception) {
                        NSLog(@"Error adding menu icon: %@", exception);
                    }
                } @catch (NSException *exception) {
                    NSLog(@"Error initializing menu: %@", exception);
                }
            } else {
                [TrustMe showAlert];
            }
        } else {
            [self showNotification:@" Ninja Framework" message:@"Game Updated! The menu has been unloaded!" duration:6.0];
            exit(0);
        }
    });


    appliedPatches = [NSMutableDictionary new];
    originalBytes = [NSMutableDictionary new];

    // Start color update loop if RGB cycle is not disabled
    if (!isRGBCycleDisabled) {
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateColors)];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }





    // // Zainstaluj hooki tylko raz przy starcie aplikacji
    // if (!hooksInstalled) {
    //     @try {
    //         void *player_speed_addr = (void *)getRealOffset(0x1037D5F1C);
    //         MSHookFunction(player_speed_addr, 
    //                      (void *)hook_player_speed, 
    //                      (void **)&orig_player_speed);
            
    //         void *sensitivity_addr = (void *)getRealOffset(0x1037E8A58);
    //         MSHookFunction(sensitivity_addr,
    //                      (void *)hook_sensitivity,
    //                      (void **)&orig_sensitivity);
            
    //         void *render_scale_addr = (void *)getRealOffset(0x108762608);
    //         MSHookFunction(render_scale_addr,
    //                      (void *)hook_render_scale,
    //                      (void **)&orig_render_scale);
            
    //         hooksInstalled = YES;
    //     } @catch (NSException *exception) {
    //     }
    // }

    // Wczytaj zapisany stan
    isDragableMenuEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"DragableMenu"];

    dispatch_async(dispatch_get_main_queue(), ^{
        // Wstępnie załaduj komponenty menu
        [self preloadMenuComponents];
    });

    // Dodaj obserwator dla aktualizacji gradientów
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleGradientUpdate:)
                                                 name:@"UpdateGradientColors"
                                               object:nil];
}

+ (void)preloadMenuComponents {
    if (!menuView) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        CGFloat menuWidth = 620;
        CGFloat menuHeight = 347;
        
        menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, menuWidth, menuHeight)];
        menuView.center = window.center;
        menuView.hidden = YES;
        [window addSubview:menuView];
        
        // Wstępnie załaduj podstawowe komponenty
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurView.frame = menuView.bounds;
        blurView.alpha = 0.77;
        [menuView addSubview:blurView];
        
        UIView *darkOverlay = [[UIView alloc] initWithFrame:menuView.bounds];
        darkOverlay.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.77];
        [menuView addSubview:darkOverlay];
        
        menuView.layer.cornerRadius = 10;
        menuView.layer.masksToBounds = YES;
        menuView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    }
}

+ (void)toggleDisableRGBCycle:(UISwitch *)sender {
    isRGBCycleDisabled = sender.isOn;
    if (isRGBCycleDisabled) {
        [displayLink invalidate];
        displayLink = nil;
    } else {
        displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateColors)];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}


+ (void)showNotification:(NSString *)title message:(NSString *)message duration:(NSTimeInterval)duration {
    static NSMutableArray *activeNotifications;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        activeNotifications = [NSMutableArray new];
    });

    dispatch_async(dispatch_get_main_queue(), ^{
        // Play notification sound
        NSString *soundPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject 
                              stringByAppendingPathComponent:@"NFramework/NFNotif.mp3"];
        NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
        SystemSoundID soundID;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &soundID);
        AudioServicesPlaySystemSound(soundID);

        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        CGFloat notificationHeight = 16; // Zmniejszona wysokość
        CGFloat topPadding = 10; // Padding od górnej krawędzi
        CGFloat spacing = 3; // Zmniejszony odstęp między powiadomieniami
        
        NSString *fullText = [NSString stringWithFormat:@"%@ %@", title, message];
        UIFont *font = [UIFont fontWithName:@"ArialRoundedMTBold" size:8]; // Zmniejszona czcionka
        CGSize textSize = [fullText sizeWithAttributes:@{NSFontAttributeName: font}];
        CGFloat padding = 12; // Zmniejszony padding
        CGFloat notificationWidth = textSize.width + padding;
        
        UILabel *notificationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        notificationLabel.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.8];
        notificationLabel.layer.cornerRadius = 4.0; // Zmniejszony promień
        notificationLabel.clipsToBounds = YES;
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:fullText];
        [attributedText addAttributes:@{NSFontAttributeName: font} range:NSMakeRange(0, attributedText.length)];
        notificationLabel.attributedText = attributedText;
        
        notificationLabel.textAlignment = NSTextAlignmentCenter;
        notificationLabel.textColor = UIColor.whiteColor;
        
        CAGradientLayer *topGradient = [CAGradientLayer layer];
        CAGradientLayer *bottomGradient = [CAGradientLayer layer];
        void (^addGradientLayer)(CAGradientLayer *, CGRect) = ^(CAGradientLayer *layer, CGRect frame) {
            layer.frame = frame;
            layer.colors = @[(__bridge id)RightGradient, (__bridge id)blackColor, (__bridge id)blackColor, (__bridge id)LeftGradient];
            layer.locations = @[@0.0, @0.3, @0.7, @1.0];
            layer.startPoint = CGPointMake(0, 0.5);
            layer.endPoint = CGPointMake(1, 0.5);
            [notificationLabel.layer addSublayer:layer];
        };
        
        addGradientLayer(topGradient, CGRectMake(0, 0, 0, 2)); // Zmniejszona wysokość gradientu
        addGradientLayer(bottomGradient, CGRectMake(0, 0, 0, 2)); // Zmniejszona wysokość gradientu
        
        CGFloat yOffset = topPadding;
        for (UIView *activeNotification in activeNotifications) {
            yOffset += (activeNotification.frame.size.height + spacing);
        }
        
        notificationLabel.frame = CGRectMake(window.center.x, yOffset, 0, notificationHeight);
        [window addSubview:notificationLabel];
        [activeNotifications addObject:notificationLabel];
        
        CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateNotificationGradient:)];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        
        [UIView animateWithDuration:0.3 animations:^{ // Skrócony czas animacji
            notificationLabel.frame = CGRectMake(window.center.x - notificationWidth/2, yOffset, notificationWidth, notificationHeight);
            topGradient.frame = CGRectMake(0, 0, notificationWidth, 1);
            bottomGradient.frame = CGRectMake(0, notificationHeight - 1, notificationWidth, 1);
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.3 animations:^{ // Skrócony czas animacji
                    notificationLabel.frame = CGRectMake(window.center.x, yOffset, 0, notificationHeight);
                    topGradient.frame = CGRectMake(0, 0, 0, 1);
                    bottomGradient.frame = CGRectMake(0, notificationHeight - 1, 0, 1);
                    notificationLabel.alpha = 0;
                } completion:^(BOOL finished) {
                    [displayLink invalidate];
                    [notificationLabel removeFromSuperview];
                    [activeNotifications removeObject:notificationLabel];
                    
                    CGFloat newYOffset = topPadding;
                    for (UIView *remainingNotification in activeNotifications) {
                        [UIView animateWithDuration:0.2 animations:^{ // Skrócony czas animacji
                            CGRect frame = remainingNotification.frame;
                            frame.origin.y = newYOffset;
                            remainingNotification.frame = frame;
                        }];
                        newYOffset += (remainingNotification.frame.size.height + spacing);
                    }
                }];
            });
        }];
    });
}

+ (void)updateNotificationGradient:(CADisplayLink *)displayLink {
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        for (UIView *view in window.subviews) {
            if ([view isKindOfClass:[UILabel class]] && view.layer.cornerRadius == 5.0) {
                for (CALayer *layer in view.layer.sublayers) {
                    if ([layer isKindOfClass:[CAGradientLayer class]]) {
                        CAGradientLayer *gradientLayer = (CAGradientLayer *)layer;
                        gradientLayer.colors = @[(__bridge id)RightGradient, (__bridge id)[UIColor blackColor].CGColor, (__bridge id)[UIColor blackColor].CGColor, (__bridge id)LeftGradient];
                    }
                }
            }
        }
    }
}

+ (instancetype)View
{
    return [[NFramework alloc] initWithFrame:[UIScreen mainScreen].bounds];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
  
    }
    return self;
}

- (void)show
{
    self.hidden = NO;
}

#pragma mark -------------------------------------Event-------------------------------------------//Start creating menu
+ (void)expand {
    @try {
        if (isMenuOpen) return;
        
        UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
        if (!mainWindow) {
            NSLog(@"Error: Could not find main window");
            return;
        }
        
        isMenuOpen = YES;

        if (isInitialized && menuView) {
            menuView.hidden = NO;
            menuView.alpha = 0.0;
            menuView.transform = CGAffineTransformMakeScale(0.7, 0.7);
            CGPoint originalCenter = menuView.center;
            menuView.center = CGPointMake(originalCenter.x, originalCenter.y + 10);
            
            [UIView animateWithDuration:0.2 
                                delay:0.0 
                              options:UIViewAnimationOptionCurveEaseOut 
                           animations:^{
                menuView.alpha = 1.0;
                menuView.transform = CGAffineTransformMakeScale(0.8, 0.8);
                menuView.center = originalCenter;
            } completion:nil];
            return;
        }
        
        // Oznacz jako zainicjalizowane
        isInitialized = YES;

        // Ustawienia menu
        CGFloat menuWidth = 620;
        CGFloat menuHeight = 347;
        CGFloat headerHeight = 30;
        CGFloat footerHeight = 30;
        CGFloat gradientLineHeight = 2; // Wysokość linii gradientu
        CGFloat cornerRadius = 10; // Promień zaokrąglenia rogów
            
        // Tworzenie głównego widoku menu
        menuView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, menuWidth, menuHeight)];
                
        // Dodaj efekt rozmycia z ciemniejszymi ustawieniami
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurView.frame = menuView.bounds;
        blurView.alpha = 0.77; // Zwiększona nieprzezroczystość
                
        // Dodaj ciemniejszą warstwę przyciemniającą
        UIView *darkOverlay = [[UIView alloc] initWithFrame:menuView.bounds];
        darkOverlay.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.77]; // Czerwony overlay
        [menuView addSubview:blurView];
        [menuView addSubview:darkOverlay];

        menuView.layer.cornerRadius = cornerRadius;
        menuView.layer.masksToBounds = YES;
        menuView.hidden = NO;
        menuView.center = mainWindow.center;
        [mainWindow addSubview:menuView];

        // Przeskaluj widok o 80%
        CGFloat scaleFactorMenu = 0.8;
        menuView.transform = CGAffineTransformMakeScale(scaleFactorMenu, scaleFactorMenu);

        // Upewnij się, że wszystkie pozostałe elementy są dodawane po blurView i darkOverlay
        // aby były widoczne na wierzchu rozmytego tła

        // Funkcja do tworzenia linii gradientu
        void (^addGradientLine)(CGRect) = ^(CGRect frame) {
            UIView *gradientLineView = [[UIView alloc] initWithFrame:frame];
            [Colors initializeColors];
            CAGradientLayer *gradientLine = [CAGradientLayer layer];
            gradientLine.frame = gradientLineView.bounds;
            gradientLine.colors = @[
                (__bridge id)RightGradient,
                (__bridge id)blackColor,
                (__bridge id)blackColor,
                (__bridge id)LeftGradient
            ];
            gradientLine.locations = @[@0.0, @0.3, @0.7, @1.0];
            gradientLine.startPoint = CGPointMake(0, 0.5);
            gradientLine.endPoint = CGPointMake(1, 0.5);
            [gradientLineView.layer insertSublayer:gradientLine atIndex:0];
            [menuView addSubview:gradientLineView];
        };

        // Linia gradientu nad pierwszym headerem
        addGradientLine(CGRectMake(0, 0, menuWidth, gradientLineHeight));

        // Pierwszy header - tylko obraz
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, gradientLineHeight, menuWidth, headerHeight)];
        headerView.backgroundColor = [UIColor clearColor];
        headerView.userInteractionEnabled = YES; // Dodaj tę linię
        // Dodaj gest przeciągania
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];

        [headerView addGestureRecognizer:panGesture];

        NSString *base64String = [ImageBase64 headerImageBase64];
        NSData *imageData = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *headerImage = [UIImage imageWithData:imageData];

        CGFloat scaleFactor = 1.4;
        CGSize newSize = CGSizeMake(headerView.bounds.size.width * scaleFactor, headerView.bounds.size.height * scaleFactor);

        headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(
            (headerView.bounds.size.width - newSize.width) / 2,
            (headerView.bounds.size.height - newSize.height) / 2,
            newSize.width,
            newSize.height
        )];
        headerImageView.image = headerImage;
        headerImageView.contentMode = UIViewContentModeScaleAspectFit;
        [headerView addSubview:headerImageView];

        [menuView addSubview:headerView];

        // Footer - tylko obraz
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, menuHeight - footerHeight, menuWidth, footerHeight)];
        footerView.backgroundColor = [UIColor clearColor];

        CGFloat scaleFactor2 = 1.2;
        CGSize originalSize = footerView.bounds.size;
        CGSize newSize2 = CGSizeMake(originalSize.width * scaleFactor2, originalSize.height * scaleFactor2);

        NSString *footerBase64String = [ImageBase64 footerImageBase64];
        NSData *footerImageData = [[NSData alloc] initWithBase64EncodedString:footerBase64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *footerImage = [UIImage imageWithData:footerImageData];

        footerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(
            (originalSize.width - newSize2.width) / 2,
            (originalSize.height - newSize2.height) / 2,
            newSize2.width,
            newSize2.height
        )];
        footerImageView.image = footerImage;
        footerImageView.contentMode = UIViewContentModeScaleAspectFit;
        [footerView addSubview:footerImageView];

        [menuView addSubview:footerView];

        // Linia gradientu pod pierwszym headerem
        addGradientLine(CGRectMake(0, gradientLineHeight + headerHeight, menuWidth, gradientLineHeight));

        // Drugi header z segmentowanym kontrolerem
        UIView *secondHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, gradientLineHeight + headerHeight + gradientLineHeight, menuWidth, headerHeight)];
        [menuView addSubview:secondHeaderView];
                
        CAGradientLayer *secondHeaderGradient = [CAGradientLayer layer];
        secondHeaderGradient.frame = secondHeaderView.bounds;
        secondHeaderGradient.colors = @[
            (__bridge id)RightGradient,
            (__bridge id)blackColor,
            (__bridge id)blackColor,
            (__bridge id)LeftGradient
        ];
        secondHeaderGradient.locations = @[@0.0, @0.3, @0.7, @1.0];
        secondHeaderGradient.startPoint = CGPointMake(0, 0.5);
        secondHeaderGradient.endPoint = CGPointMake(1, 0.5);
        [secondHeaderView.layer insertSublayer:secondHeaderGradient atIndex:0];




        NSArray *segmentItems = @[@"Aura", @"Survivor", @"Killer", @"SChecks", @"States", @"Modifrs", @"Menu", @"Visuals", @"Misc", @"Exploit", @"Aimbot", @"ESP", @"Binds", @"Tools"];
                
        NSArray *segmentImages = @[
            [UIImage systemImageNamed:@"eye.circle.fill"],           // Aura
            [UIImage systemImageNamed:@"person.fill"],               // Survivor
            [UIImage systemImageNamed:@"bolt.circle.fill"],          // Killer
            [UIImage systemImageNamed:@"checkmark.circle.fill"],     // SChecks
            [UIImage systemImageNamed:@"switch.2"],                  // States
            [UIImage systemImageNamed:@"slider.horizontal.3"],       // Modifrs
            [UIImage systemImageNamed:@"gearshape.fill"],           // Menu
            [UIImage systemImageNamed:@"paintbrush.fill"],          // Visuals
            [UIImage systemImageNamed:@"ellipsis.circle.fill"],      // Misc
            [UIImage systemImageNamed:@"exclamationmark.triangle.fill"], // Exploit
            [UIImage systemImageNamed:@"target"],                     // Aimbot
            [UIImage systemImageNamed:@"scope"],                     // ESP
            [UIImage systemImageNamed:@"keyboard"],                  // Binds
            [UIImage systemImageNamed:@"wrench.fill"]               // Tools
        ];

        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentItems];
        segmentedControl.frame = CGRectMake(0, 0, menuWidth, headerHeight);
        segmentedControl.selectedSegmentIndex = 0;
        segmentedControl.tintColor = [UIColor whiteColor];

        // Dodaj ikony i tekst do segmentów
        for (NSUInteger i = 0; i < segmentItems.count; i++) {
            // Stwórz kontener dla ikony i tekstu
            UIView *segmentContent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 55, headerHeight)];
            
            // Oblicz szerokość tekstu
            UIFont *font = [UIFont fontWithName:currentFont size:8.5];
            CGSize textSize = [segmentItems[i] sizeWithAttributes:@{NSFontAttributeName: font}];
            
            // Oblicz całkowitą szerokość (ikona + odstęp + tekst)
            CGFloat totalWidth = 16 + 4 + textSize.width; // 16 (ikona) + 4 (odstęp) + szerokość tekstu
            CGFloat startX = (55 - totalWidth) / 2; // Wyśrodkuj całość w kontenerze
            
            // Dodaj ikonę
            UIImageView *imageView = [[UIImageView alloc] initWithImage:segmentImages[i]];
            imageView.frame = CGRectMake(startX, (headerHeight - 16) / 2, 16, 16);
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.tintColor = [UIColor whiteColor];
            [segmentContent addSubview:imageView];
            
            // Dodaj tekst
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(startX + 20, 0, textSize.width, headerHeight)];
            label.text = segmentItems[i];
            label.font = [UIFont fontWithName:currentFont size:8.5]; 
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentLeft;
            [segmentContent addSubview:label];
            
            // Konwertuj widok na obraz
            UIGraphicsBeginImageContextWithOptions(segmentContent.bounds.size, NO, 0.0);
            [segmentContent.layer renderInContext:UIGraphicsGetCurrentContext()];
            UIImage *combinedImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            // Ustaw połączony obraz jako zawartość segmentu
            [segmentedControl setImage:combinedImage forSegmentAtIndex:i];
        }

        [secondHeaderView addSubview:segmentedControl];
                
        // Ustawienie czcionki na ArialRoundedMTBold Bold dla wszystkich segmentów
        NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:currentFont size:8.5] forKey:NSFontAttributeName];
        [segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
        closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = CGRectMake(menuWidth - 30, (headerView.frame.size.height - 25) / 2, 25, 25);
        closeButton.layer.cornerRadius = 12.5;
        closeButton.layer.masksToBounds = YES;
      
        // Użyj symbolu SF "xmark.circle.fill" zamiast tekstu "✕"
        UIImageConfiguration *configuration = [UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIImageSymbolWeightBold];
        UIImage *closeImage = [UIImage systemImageNamed:@"xmark.circle.fill" withConfiguration:configuration];
        [closeButton setImage:closeImage forState:UIControlStateNormal];
        
        // Ustaw kolor obrazu
        [closeButton setTintColor:[UIColor colorWithCGColor:RightGradient]];
        
        [closeButton addTarget:self action:@selector(closeMenu) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:closeButton];

        // Linia gradientu nad footerem
        addGradientLine(CGRectMake(0, menuHeight - footerHeight - gradientLineHeight, menuWidth, gradientLineHeight));
                
        // Linia gradientu pod footerem
        addGradientLine(CGRectMake(0, menuHeight - gradientLineHeight, menuWidth, gradientLineHeight));

        // Oblicz wysokość obszaru dla przełączników
        CGFloat switchAreaHeight = 210; // Ustawiona stała wysokość na 210
        CGFloat scrollViewWidth = (menuWidth - 20) / 2; // Subtract padding and divide by 2
        CGFloat scrollViewSpacing = 20; // Space between scroll views
        CGFloat leftScrollViewX = (menuWidth - (scrollViewWidth * 2 + scrollViewSpacing)) / 2;
        CGFloat rightScrollViewX = leftScrollViewX + scrollViewWidth + scrollViewSpacing;
        CGFloat labelHeight = 25; // Dodajemy definicję labelHeight
        CGFloat switchStartY = 3; // Dodajemy definicję switchStartY
        CGFloat switchSpacing = 18; // Dodajemy definicję switchSpacing

            
        // Add tag to segmented control for easy access
        segmentedControl.tag = 100;
        // Utwórz UIScrollView dla States
          
        // Add target for segmented control
        [segmentedControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];




       [ToolsView createToolsView:menuView];
        // Zmień w drugim miejscu:
        [VisualsView createVisualsView:menuView]; // Dodaj tę linię
        [ExploitView createExploitView:menuView];
        [ModifiersView createModifiersView:menuView];
      [AimbotView createAimbotView:menuView];
        [ESPView createESPView];
        [MenuView createMenuView];
        [ToolsView createMSHookView:menuView];
        [ToolsView createEllekitHookView:menuView];
        [MiscView createMiscView:menuView]; // Dodaj tę linię
        [AuraView createAuraView:menuView];
        [StatesView createStatesView:menuView];
        [SkillChecksView createSkillChecksView:menuView];
        [SurvivorView createSurvivorView:menuView];
        [KillerView createKillerView:menuView];
        [BindsView createBindsView:menuView];
        menuView.alpha = 0.0;
        menuView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        
        [UIView animateWithDuration:0.3 
                              delay:0.0 
         usingSpringWithDamping:0.8 
          initialSpringVelocity:0.5 
                        options:UIViewAnimationOptionCurveEaseInOut 
                     animations:^{
            menuView.alpha = 1.0;
            menuView.transform = CGAffineTransformMakeScale(0.8, 0.8);
        } completion:nil];

        menuView.alpha = 0.0;
        CGPoint finalCenter = menuView.center;
        menuView.center = CGPointMake(finalCenter.x, finalCenter.y + 20);
        
        [UIView animateWithDuration:0.3 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseOut 
                         animations:^{
            menuView.alpha = 1.0;
            menuView.center = finalCenter;
        } completion:nil];

        [segmentedControl setSelectedSegmentIndex:0]; // Ustaw Aura jako domyślny segment
        [self segmentChanged:segmentedControl]; // Wywołaj zmianę segmentu ręcznie

        // Najpierw stwórz label i oblicz aktualną szerokość tekstu
        countdownLabel = [[UILabel alloc] init];
        countdownLabel.font = [UIFont fontWithName:currentFont size:9];
        
        // Aktualizuj tekst i oblicz jego szerokość
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *targetDate = [formatter dateFromString:@"2025-03-20"];
        NSTimeInterval timeInterval = [targetDate timeIntervalSinceNow];
        
        int days = timeInterval / 86400;
        int hours = (int)timeInterval % 86400 / 3600;
        int minutes = (int)timeInterval % 3600 / 60;
        int seconds = (int)timeInterval % 60;
        
        countdownLabel.text = [NSString stringWithFormat:@"Servers Shutdown: %dd %02dh %02dm %02ds",
                             days, hours, minutes, seconds];
        
        CGSize textSize = [countdownLabel.text sizeWithAttributes:@{NSFontAttributeName: countdownLabel.font}];
        
        // Dodaj marginesy do szerokości
        CGFloat containerWidth = textSize.width + 20; // 10px padding z każdej strony
        
        // Teraz stwórz kontener z odpowiednią szerokością
        countdownContainer = [[UIView alloc] initWithFrame:CGRectMake(
            menuWidth - containerWidth - 10,  // Wyrównaj do prawej z marginesem 10px
            menuHeight - footerHeight + (footerHeight - 20)/2, // Wyśrodkuj w footerze
            containerWidth,  // Użyj obliczonej szerokości
            20  // Wysokość labela
        )];
        countdownContainer.layer.cornerRadius = 5;
        countdownContainer.clipsToBounds = YES;

        // Stwórz główny gradient layer dla tła
        CAGradientLayer *backgroundGradient = [CAGradientLayer layer];
        backgroundGradient.frame = countdownContainer.bounds;
        backgroundGradient.colors = @[
            (__bridge id)RightGradient,
            (__bridge id)blackColor,
            (__bridge id)blackColor,
            (__bridge id)LeftGradient
        ];
        backgroundGradient.locations = @[@0.0, @0.3, @0.7, @1.0];
        backgroundGradient.startPoint = CGPointMake(0, 0.5);
        backgroundGradient.endPoint = CGPointMake(1, 0.5);
        [countdownContainer.layer insertSublayer:backgroundGradient atIndex:0];

        // Zaktualizuj frame labela do nowego kontenera
        countdownLabel.frame = CGRectMake(
            10,  // Lewy padding
            0,
            containerWidth - 20,  // Szerokość minus paddingi
            20
        );
        countdownLabel.textAlignment = NSTextAlignmentRight;
        countdownLabel.textColor = [UIColor whiteColor];
        countdownLabel.backgroundColor = [UIColor clearColor];
        [countdownContainer addSubview:countdownLabel];
        [menuView addSubview:countdownContainer];

        // Rozpocznij odliczanie
        [self startCountdown];

        // Dodaj nowy kontener ze statystykami
        deviceStatsLabel = [[UILabel alloc] init];
        deviceStatsLabel.font = [UIFont fontWithName:currentFont size:9];

        NSDictionary *stats = [self getDeviceStats];
        // Stwórz konfigurację dla SF Symbols
        UIImageSymbolConfiguration *symbolConfig = [UIImageSymbolConfiguration configurationWithPointSize:12 weight:UIImageSymbolWeightRegular];

        // Utwórz obrazy z SF Symbols
        UIImage *batteryImage = [[UIImage systemImageNamed:@"battery.100.bolt" withConfiguration:symbolConfig] imageWithTintColor:[UIColor whiteColor]];
        UIImage *cpuImage = [[UIImage systemImageNamed:@"cpu" withConfiguration:symbolConfig] imageWithTintColor:[UIColor whiteColor]];
        UIImage *ramImage = [[UIImage systemImageNamed:@"memorychip" withConfiguration:symbolConfig] imageWithTintColor:[UIColor whiteColor]];
        UIImage *tempImage = [[UIImage systemImageNamed:@"thermometer" withConfiguration:symbolConfig] imageWithTintColor:[UIColor whiteColor]];

        // Stwórz atrybutowany string z obrazami i tekstem
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];

        // Funkcja pomocnicza do dodawania obrazu
        void (^addImageAndText)(UIImage *, float) = ^(UIImage *image, float value) {
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            attachment.image = image;
            attachment.bounds = CGRectMake(0, -3, 12, 12);
            
            [attributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %.1f%% | ", value]]];
        };

        // Dodaj wszystkie obrazy i wartości
        addImageAndText(batteryImage, [stats[@"battery"] floatValue]);
        addImageAndText(cpuImage, [stats[@"cpu"] floatValue]);
        addImageAndText(ramImage, [stats[@"ram"] floatValue]);
        addImageAndText(tempImage, [stats[@"temp"] floatValue]);

        // Usuń ostatni separator
        NSRange lastSeparatorRange = [attributedString.string rangeOfString:@" | " options:NSBackwardsSearch];
        if (lastSeparatorRange.location != NSNotFound) {
            [attributedString deleteCharactersInRange:lastSeparatorRange];
        }

        // Ustaw atrybuty dla całego tekstu
        [attributedString addAttributes:@{
            NSFontAttributeName: [UIFont fontWithName:currentFont size:9],
            NSForegroundColorAttributeName: [UIColor whiteColor]
        } range:NSMakeRange(0, attributedString.length)];

        deviceStatsLabel.attributedText = attributedString;

        CGSize statsTextSize = CGSizeMake(300, 20); // Stała szerokość początkowa
        CGFloat statsContainerWidth = statsTextSize.width; // Dodaj tę linię

        deviceStatsContainer = [[UIView alloc] initWithFrame:CGRectMake(
            10, // Lewy margines
            menuHeight - footerHeight + (footerHeight - 20)/2, // Wyśrodkuj w footerze
            statsContainerWidth,
            20
        )];
        deviceStatsContainer.layer.cornerRadius = 5;
        deviceStatsContainer.clipsToBounds = YES;

        // Stwórz gradient dla tła
        CAGradientLayer *statsBackgroundGradient = [CAGradientLayer layer];
        statsBackgroundGradient.frame = deviceStatsContainer.bounds;
        statsBackgroundGradient.colors = @[
            (__bridge id)RightGradient,
            (__bridge id)blackColor,
            (__bridge id)blackColor,
            (__bridge id)LeftGradient
        ];
        statsBackgroundGradient.locations = @[@0.0, @0.3, @0.7, @1.0];
        statsBackgroundGradient.startPoint = CGPointMake(0, 0.5);
        statsBackgroundGradient.endPoint = CGPointMake(1, 0.5);
        [deviceStatsContainer.layer insertSublayer:statsBackgroundGradient atIndex:0];

        deviceStatsLabel.frame = CGRectMake(
            10,
            0,
            statsContainerWidth - 20,
            20
        );
        deviceStatsLabel.textAlignment = NSTextAlignmentLeft;
        deviceStatsLabel.textColor = [UIColor whiteColor];
        deviceStatsLabel.backgroundColor = [UIColor clearColor];
        [deviceStatsContainer addSubview:deviceStatsLabel];
        [menuView addSubview:deviceStatsContainer];
    } @catch (NSException *exception) {
        NSLog(@"Error expanding menu: %@", exception);
        isMenuOpen = NO; // Reset stanu w przypadku błędu
    }
}
+ (void)startRGBCycle {
    [RGBManager startRGBCycle];  // Zmienione z [MenuView startRGBCycle]
}

+ (void)stopRGBCycle {
    [RGBManager stopRGBCycle];   // Zmienione z [MenuView stopRGBCycle]
}

// Dodaj nową metodę pomocniczą do aktualizacji czcionki w segmentach
+ (void)updateSegmentFont:(UISegmentedControl *)segment withFont:(NSString *)fontName {
    NSDictionary *attributes = @{
        NSFontAttributeName: [UIFont fontWithName:fontName size:10.0]
    };
    [segment setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    // Dodaj również dla stanu wybranego
    NSDictionary *selectedAttributes = @{
        NSFontAttributeName: [UIFont fontWithName:fontName size:10.0],
        NSForegroundColorAttributeName: [UIColor whiteColor]
    };
    [segment setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];
}


+ (void)handlePan:(UIPanGestureRecognizer *)gesture {
    // Sprawdź czy funkcja jest włączona
    if (!isDragableMenuEnabled) {
        return;
    }
    
    static CGPoint originalPosition;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        originalPosition = menuView.center;
    }
    
    CGPoint translation = [gesture translationInView:window];
    CGPoint newCenter = CGPointMake(originalPosition.x + translation.x, originalPosition.y + translation.y);
    
    // Oblicz granice, uwzględniając rozmiar menu
    CGFloat halfWidth = menuView.frame.size.width / 2;
    CGFloat halfHeight = menuView.frame.size.height / 2;
    CGFloat minX = halfWidth;
    CGFloat maxX = window.frame.size.width - halfWidth;
    CGFloat minY = halfHeight;
    CGFloat maxY = window.frame.size.height - halfHeight;
    
    // Ogranicz pozycję menu do granic ekranu
    newCenter.x = fmax(minX, fmin(maxX, newCenter.x));
    newCenter.y = fmax(minY, fmin(maxY, newCenter.y));
    
    menuView.center = newCenter;
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        originalPosition = menuView.center;
    }
}

// Dodaj metodę do obsługi przełącznika
+ (void)dragableMenuToggleChanged:(UISwitch *)sender {
    isDragableMenuEnabled = sender.isOn;
    
    // Zapisz stan w NSUserDefaults
    [[NSUserDefaults standardUserDefaults] setBool:isDragableMenuEnabled forKey:@"DragableMenu"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// Metoda do tworzenia gradientu (zmodyfikowana)
+ (CAGradientLayer *)createGradientLayer:(CGRect)frame {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = frame;
    gradientLayer.colors = @[
        (__bridge id)RightGradient,
        (__bridge id)blackColor,
        (__bridge id)blackColor,
        (__bridge id)LeftGradient
    ];
    gradientLayer.locations = @[@0.0, @0.3, @0.7, @1.0];
    gradientLayer.startPoint = CGPointMake(0, 0.5);
    gradientLayer.endPoint = CGPointMake(1, 0.5);
    return gradientLayer;
}




// Metoda pomocnicza do tworzenia przełączników (zmodyfikowana)
+ (void)addSwitchWithTitle:(NSString *)title frame:(CGRect)frame selector:(SEL)selector toView:(UIView *)view switchColumnWidth:(CGFloat)width {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, width * 0.7, frame.size.height)];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
    [view addSubview:label];
    
    // Przesuwamy przełącznik na prawą stronę UIScrollView
    UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(view.frame.size.width - 61, frame.origin.y, 51, frame.size.height)];
    toggle.on = [[NSUserDefaults standardUserDefaults] boolForKey:[title stringByReplacingOccurrencesOfString:@" " withString:@""]];
    [toggle addTarget:[NFToggles class] action:selector forControlEvents:UIControlEventValueChanged];
    
    // Set the onTintColor to the RightGradient color
    toggle.onTintColor = [UIColor colorWithCGColor:RightGradient];
    
    [view addSubview:toggle];
}

// Zmodyfikuj metodę closeMenu
+ (void)closeMenu {
    CGPoint originalCenter = menuView.center;
    
    [UIView animateWithDuration:0.2  // Skrócony czas animacji
                          delay:0.0 
                        options:UIViewAnimationOptionCurveEaseIn 
                     animations:^{
        menuView.alpha = 0.0;
        menuView.center = CGPointMake(originalCenter.x, originalCenter.y + 10); // Zmniejszone przesunięcie
    } completion:^(BOOL finished) {
        [self finalizeMenuClose];
        menuView.center = originalCenter;
    }];
}

// Dodaj nową metodę pomocniczą do finalizacji zamykania menu
+ (void)finalizeMenuClose {
    menuView.hidden = YES;
    menuView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    menuView.layer.transform = CATransform3DIdentity;
    isMenuOpen = NO;
    menuIcon.hidden = NO;
}

// Add this method to update colors
+ (void)updateColors {
   
    
    // Update gradient lines
    for (UIView *subview in menuView.subviews) {
        if ([subview.layer.sublayers.firstObject isKindOfClass:[CAGradientLayer class]]) {
            CAGradientLayer *gradientLayer = (CAGradientLayer *)subview.layer.sublayers.firstObject;
            gradientLayer.colors = @[(__bridge id)RightGradient, (__bridge id)blackColor, (__bridge id)blackColor, (__bridge id)LeftGradient];
        }
    }
    
    // Update segmented control
    UISegmentedControl *segmentedControl = [menuView viewWithTag:100];
    [segmentedControl setTintColor:[UIColor colorWithCGColor:RightGradient]];
    
    // Update tools colors
    [self updateToolsColors];
    
    // Update countdown containers gradients
    if (countdownContainer) {
        CAGradientLayer *countdownGradient = (CAGradientLayer *)[countdownContainer.layer.sublayers firstObject];
        if ([countdownGradient isKindOfClass:[CAGradientLayer class]]) {
            countdownGradient.colors = @[
                (__bridge id)RightGradient,
                (__bridge id)blackColor,
                (__bridge id)blackColor,
                (__bridge id)LeftGradient
            ];
        }
    }
}

// Add this method before updateGradientColors
+ (void)updateLayoutGradients {
    // Update gradients for all layout elements
    for (UIView *view in menuView.subviews) {
        if ([view.layer.sublayers.firstObject isKindOfClass:[CAGradientLayer class]]) {
            CAGradientLayer *gradientLayer = (CAGradientLayer *)view.layer.sublayers.firstObject;
            gradientLayer.colors = @[
                (__bridge id)RightGradient,
                (__bridge id)blackColor,
                (__bridge id)blackColor,
                (__bridge id)LeftGradient
            ];
        }
        
        // Update gradients in subviews
        for (UIView *subview in view.subviews) {
            if ([subview.layer.sublayers.firstObject isKindOfClass:[CAGradientLayer class]]) {
                CAGradientLayer *gradientLayer = (CAGradientLayer *)subview.layer.sublayers.firstObject;
                gradientLayer.colors = @[
                    (__bridge id)RightGradient,
                    (__bridge id)blackColor,
                    (__bridge id)blackColor,
                    (__bridge id)LeftGradient
                ];
            }
        }
    }
}

+ (void)updateGradientColors {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gradientUpdateQueue = dispatch_queue_create("com.ninja.gradientupdate", DISPATCH_QUEUE_SERIAL);
    });
    
    dispatch_async(gradientUpdateQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update menu gradients
            [self updateLayoutGradients];
            
            // Update countdown container gradient
            if (countdownContainer) {
                CAGradientLayer *countdownGradient = (CAGradientLayer *)[countdownContainer.layer.sublayers firstObject];
                if ([countdownGradient isKindOfClass:[CAGradientLayer class]]) {
                    countdownGradient.colors = @[
                        (__bridge id)RightGradient,
                        (__bridge id)blackColor,
                        (__bridge id)blackColor,
                        (__bridge id)LeftGradient
                    ];
                }
            }
        });
    });
}




+ (void)updateFont:(NSString *)fontName {
    currentFont = fontName;
    
    // Aktualizuj wszystkie segmenty w menu
    [self updateSegmentedControlFont];
    [self updateMiscSegmentFont]; // Dodaj tę linię
    
    // Istniejący kod aktualizacji innych elementów...
    for (UIView *view in menuView.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            // Znajdź ninjaSegment w toolsScrollView
            if (view.tag == 9) { // toolsScrollView
                for (UIView *subview in view.subviews) {
                    if ([subview isKindOfClass:[UISegmentedControl class]]) {
                        UISegmentedControl *segment = (UISegmentedControl *)subview;
                        // Aktualizuj czcionkę dla każdego segmentu
                        NSDictionary *attributes = @{
                            NSFontAttributeName: [UIFont fontWithName:fontName size:10.0]
                        };
                        [segment setTitleTextAttributes:attributes forState:UIControlStateNormal];
                        
                        // Aktualizuj również dla stanu wybranego
                        NSDictionary *selectedAttributes = @{
                            NSFontAttributeName: [UIFont fontWithName:fontName size:10.0],
                            NSForegroundColorAttributeName: [UIColor whiteColor]
                        };
                        [segment setTitleTextAttributes:selectedAttributes forState:UIControlStateSelected];
                    }
                }
            }
        }
        
        // Istniejący kod dla innych elementów...
        if ([view isKindOfClass:[UISegmentedControl class]]) {
            UISegmentedControl *segment = (UISegmentedControl *)view;
            [self updateSegmentFont:segment withFont:fontName];
        }
        
        if ([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel *)view;
            CGFloat currentSize = label.font.pointSize;
            label.font = [UIFont fontWithName:fontName size:currentSize];
        }
    }
}

+ (void)updateMiscSegmentFont {
    UIScrollView *miscScrollView = [menuView viewWithTag:64];
    UISegmentedControl *miscSegment = [miscScrollView viewWithTag:66];
    if (!miscSegment) return;
    
    NSArray *segmentItems = @[@"EndGame", @"Animations", @"Spoofing", @"Teleport", @"Changer", @"Name Change"];
    NSArray *segmentImages = @[
        [UIImage systemImageNamed:@"flag.fill"],
        [UIImage systemImageNamed:@"figure.wave"],
        [UIImage systemImageNamed:@"person.crop.circle.badge.questionmark"],
        [UIImage systemImageNamed:@"arrow.up.and.down.and.arrow.left.and.right"],
        [UIImage systemImageNamed:@"person.2.circle.fill"]
    ];
    
    while (miscSegment.numberOfSegments > 0) {
        [miscSegment removeSegmentAtIndex:0 animated:NO];
    }
    
    for (NSUInteger i = 0; i < segmentItems.count; i++) {
        UIView *segmentContent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, miscSegment.frame.size.height)];
        
        UIFont *font = [UIFont fontWithName:currentFont size:10];
        CGSize textSize = [segmentItems[i] sizeWithAttributes:@{NSFontAttributeName: font}];
        
        CGFloat iconSize = 14;
        CGFloat iconTextSpacing = 5;
        CGFloat leftPadding = 10;
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:segmentImages[i]];
        imageView.frame = CGRectMake(leftPadding, (miscSegment.frame.size.height - iconSize) / 2, iconSize, iconSize);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tintColor = [UIColor whiteColor];
        [segmentContent addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding + iconSize + iconTextSpacing, 
                                                                  0, 
                                                                  textSize.width, 
                                                                  miscSegment.frame.size.height)];
        label.text = segmentItems[i];
        label.font = font;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentLeft;
        [segmentContent addSubview:label];
        
        UIGraphicsBeginImageContextWithOptions(segmentContent.bounds.size, NO, 0.0);
        [segmentContent.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *combinedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [miscSegment insertSegmentWithImage:combinedImage atIndex:i animated:NO];
    }
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:currentFont size:10]};
    [miscSegment setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    miscSegment.selectedSegmentIndex = 0;
}

+ (void)updateSegmentedControlFont {
    UISegmentedControl *segmentedControl = [menuView viewWithTag:100];
    if (!segmentedControl) return;
    
    NSArray *segmentItems = @[@"Aura", @"Survivor", @"Killer", @"SChecks", @"States", @"Modifrs", @"Menu", @"Visuals", @"Misc", @"Exploit", @"Aimbot", @"ESP", @"Binds", @"Tools"];
    NSArray *segmentImages = @[
        [UIImage systemImageNamed:@"eye.circle.fill"],
        [UIImage systemImageNamed:@"person.fill"], 
        [UIImage systemImageNamed:@"bolt.circle.fill"],
        [UIImage systemImageNamed:@"checkmark.circle.fill"],
        [UIImage systemImageNamed:@"switch.2"],
        [UIImage systemImageNamed:@"slider.horizontal.3"],
        [UIImage systemImageNamed:@"gearshape.fill"],
        [UIImage systemImageNamed:@"paintbrush.fill"],
        [UIImage systemImageNamed:@"ellipsis.circle.fill"],
        [UIImage systemImageNamed:@"exclamationmark.triangle.fill"],
        [UIImage systemImageNamed:@"target"],
        [UIImage systemImageNamed:@"scope"],
        [UIImage systemImageNamed:@"keyboard"],
        [UIImage systemImageNamed:@"wrench.fill"]
    ];
    
    for (NSUInteger i = 0; i < segmentItems.count; i++) {
        UIView *segmentContent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 55, segmentedControl.frame.size.height)];
        
        UIFont *font = [UIFont fontWithName:currentFont size:8.5];
        CGSize textSize = [segmentItems[i] sizeWithAttributes:@{NSFontAttributeName: font}];
        
        CGFloat totalWidth = 16 + 4 + textSize.width;
        CGFloat startX = (55 - totalWidth) / 2;
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:segmentImages[i]];
        imageView.frame = CGRectMake(startX, (segmentedControl.frame.size.height - 16) / 2, 16, 16);
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tintColor = [UIColor whiteColor];
        [segmentContent addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(startX + 20, 0, textSize.width, segmentedControl.frame.size.height)];
        label.text = segmentItems[i];
        label.font = font;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentLeft;
        [segmentContent addSubview:label];
        
        UIGraphicsBeginImageContextWithOptions(segmentContent.bounds.size, NO, 0.0);
        [segmentContent.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *combinedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [segmentedControl setImage:combinedImage forSegmentAtIndex:i];
    }
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:currentFont size:8.5]};
    [segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
}

+ (void)updateToolsColors {
    UIScrollView *toolsScrollView = [menuView viewWithTag:9];
    UIScrollView *msHookScrollView = [menuView viewWithTag:29];
    UIScrollView *ellekitScrollView = [menuView viewWithTag:38];
    
    NSArray *viewsToUpdate = @[toolsScrollView, msHookScrollView, ellekitScrollView];
    
    for (UIScrollView *scrollView in viewsToUpdate) {
        for (UIView *subview in scrollView.subviews) {
            if ([subview isKindOfClass:[UIView class]] && (subview.tag == 14 || subview.tag == 15 || subview.tag == 38)) {
                for (UIView *childView in subview.subviews) {
                    [self updateGradientForView:childView withColor:[UIColor colorWithCGColor:RightGradient]];
                }
            } else {
                [self updateGradientForView:subview withColor:[UIColor colorWithCGColor:RightGradient]];
            }
        }
    }
    
    // Dodaj aktualizację gradientów dla countdown i celebration containers
    if (countdownContainer) {
        CAGradientLayer *countdownGradient = (CAGradientLayer *)[countdownContainer.layer.sublayers firstObject];
        if ([countdownGradient isKindOfClass:[CAGradientLayer class]]) {
            countdownGradient.colors = @[
                (__bridge id)RightGradient,
                (__bridge id)blackColor,
                (__bridge id)blackColor,
                (__bridge id)LeftGradient
            ];
        }
    }
}


+ (void)updateGradientForView:(UIView *)view withColor:(UIColor *)color {
    if ([view isKindOfClass:[UIButton class]] || [view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UISlider class]]) {
        CAGradientLayer *gradientLayer = (CAGradientLayer *)view.layer.sublayers.firstObject;
        if ([gradientLayer isKindOfClass:[CAGradientLayer class]]) {
            gradientLayer.colors = @[
                (__bridge id)color.CGColor,
                (__bridge id)blackColor,
                (__bridge id)blackColor,
                (__bridge id)color.CGColor
            ];
        }
    }
}

+ (void)addMenuIcon {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    NSString *NFmenuImageBase64 = [ImageBase64 NFmenuImageBase64];
     NSData *imageData = [[NSData alloc] initWithBase64EncodedString:NFmenuImageBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *iconImage = [UIImage imageWithData:imageData];
    
    menuIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 100, 50, 50)];
    menuIcon.image = iconImage;
    menuIcon.userInteractionEnabled = YES;
    menuIcon.layer.cornerRadius = 25;
    menuIcon.clipsToBounds = YES;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleIconPan:)];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleIconTap:)];
    
    [menuIcon addGestureRecognizer:panGesture];
    [menuIcon addGestureRecognizer:tapGesture];
    
    [window addSubview:menuIcon];
}
+ (void)handleIconPan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:gesture.view.superview];
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            isDraggingIcon = YES;
            lastTouchPoint = gesture.view.center;
            break;
            
        case UIGestureRecognizerStateChanged: {
            CGPoint newCenter = CGPointMake(lastTouchPoint.x + translation.x, 
                                          lastTouchPoint.y + translation.y);
            
            CGRect bounds = gesture.view.superview.bounds;
            CGFloat halfWidth = gesture.view.frame.size.width / 2;
            CGFloat halfHeight = gesture.view.frame.size.height / 2;
            
            newCenter.x = MAX(halfWidth, MIN(bounds.size.width - halfWidth, newCenter.x));
            newCenter.y = MAX(halfHeight, MIN(bounds.size.height - halfHeight, newCenter.y));
            
            gesture.view.center = newCenter;
            break;
        }
            
        case UIGestureRecognizerStateEnded:
            isDraggingIcon = NO;
            break;
            
        default:
            break;
    }
}
+ (void)handleIconTap:(UITapGestureRecognizer *)gesture {
    if (!isDraggingIcon) {
        [self expand];
        menuIcon.hidden = YES;
    }
}
+ (id<UITextFieldDelegate>)textFieldDelegate {
    return (id<UITextFieldDelegate>)self;
}

+ (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

+ (void)addSwitchesForOptions:(NSDictionary *)options toView:(UIScrollView *)scrollView withType:(NSInteger)type {
    CGFloat switchSpacing = 18;
    CGFloat switchStartY = 5;
    CGFloat switchWidth = scrollView.frame.size.width - 20;
    
    __block CGFloat currentY = switchStartY;
    [options enumerateKeysAndObjectsUsingBlock:^(NSString *title, NSString *symbol, BOOL *stop) {
        // Tworzenie kontenera dla ikony i tekstu z gradientowym tłem
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(10, currentY, switchWidth, 30)];
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
        
        // Add icon
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 20, 20)];
        iconView.image = [UIImage systemImageNamed:symbol];
        iconView.tintColor = [UIColor whiteColor];
        [containerView addSubview:iconView];
        
        // Add label
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, switchWidth - 85, 30)];
        label.text = title;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
        [containerView addSubview:label];
        
        if (type == 0) { // Type
            UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(switchWidth - 55, 0, 51, 31)];
            toggle.onTintColor = [UIColor systemBlueColor];
            [containerView addSubview:toggle];
        } else if (type == 1) { // Colors
            UIButton *colorButton = [UIButton buttonWithType:UIButtonTypeSystem];
            colorButton.frame = CGRectMake(switchWidth - 35, 0, 30, 30);
            [colorButton setImage:[UIImage systemImageNamed:@"paintbrush.fill"] forState:UIControlStateNormal];
            colorButton.tintColor = [UIColor whiteColor];
            [containerView addSubview:colorButton];
        } else { // Size
            UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(switchWidth - 100, 5, 90, 20)];
            slider.minimumValue = 0.0;
            slider.maximumValue = 100.0;
            slider.value = 50.0;
            slider.tintColor = [UIColor colorWithRed:255.0/255.0 green:23.0/255.0 blue:65.0/255.0 alpha:1.0];
            [containerView addSubview:slider];
        }
        
        [scrollView addSubview:containerView];
        
        currentY += switchSpacing;
    }];
    
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, currentY);
}

+ (void)segmentChanged:(UISegmentedControl *)sender {
    NSInteger selectedIndex = sender.selectedSegmentIndex;
    
    // Najpierw ukryj wszystkie widoki
    [self hideAllViews];
    
    // Pokaż odpowiednie widoki i etykiety w zależności od wybranego segmentu
    switch (selectedIndex) {
        case 0: { // Aura
            UIScrollView *actorsScrollView = [menuView viewWithTag:2000];
            UIScrollView *objectsScrollView = [menuView viewWithTag:2003];
            UILabel *actorsLabel = [menuView viewWithTag:2001];
            UILabel *objectsLabel = [menuView viewWithTag:2004];
            
            actorsScrollView.hidden = NO;
            objectsScrollView.hidden = NO;
            actorsLabel.hidden = NO;
            objectsLabel.hidden = NO;
            break;
        }
        case 1: { // Survivor
            UIScrollView *leftScrollView = [menuView viewWithTag:7000];
            UIScrollView *rightScrollView = [menuView viewWithTag:7001];
            UILabel *survivorLabel = [menuView viewWithTag:7002];
            
            leftScrollView.hidden = NO;
            rightScrollView.hidden = NO;
            survivorLabel.hidden = NO;
            break;
        }
        case 2: { // Killer
            UIScrollView *leftScrollView = [menuView viewWithTag:3000];
            UIScrollView *rightScrollView = [menuView viewWithTag:3001];
            UILabel *killerLabel = [menuView viewWithTag:3002];
            
            leftScrollView.hidden = NO;
            rightScrollView.hidden = NO;
            killerLabel.hidden = NO;
            break;
        }
        case 3: { // SChecks
            UIScrollView *friendlyScrollView = [menuView viewWithTag:4000];
            UIScrollView *unfriendlyScrollView = [menuView viewWithTag:4001];
            UILabel *schecksLabel = [menuView viewWithTag:4002];
            UILabel *friendlyLabel = [menuView viewWithTag:4003];
            UILabel *unfriendlyLabel = [menuView viewWithTag:4004];
            
            friendlyScrollView.hidden = NO;
            unfriendlyScrollView.hidden = NO;
            schecksLabel.hidden = NO;
            friendlyLabel.hidden = NO;
            unfriendlyLabel.hidden = NO;
            break;
        }
        case 4: { // States
            UIScrollView *clientScrollView = [menuView viewWithTag:5000];
            UIScrollView *serverScrollView = [menuView viewWithTag:5001];
            UILabel *statesLabel = [menuView viewWithTag:5002];
            UILabel *clientLabel = [menuView viewWithTag:5003];
            UILabel *serverLabel = [menuView viewWithTag:5004];
            
            clientScrollView.hidden = NO;
            serverScrollView.hidden = NO;
            statesLabel.hidden = NO;
            clientLabel.hidden = NO;
            serverLabel.hidden = NO;
            break;
        }
        case 5: { // Modifiers
            UIScrollView *modifiersScrollView = [menuView viewWithTag:58];
            UILabel *modifiersLabel = [menuView viewWithTag:59];
            
            modifiersScrollView.hidden = NO;
            modifiersLabel.hidden = NO;
            break;
        }
        case 6: { // Menu
            UIScrollView *leftMenuScrollView = [menuView viewWithTag:583];
            UIScrollView *rightMenuScrollView = [menuView viewWithTag:584];
            UILabel *menuLabel = [menuView viewWithTag:590];
            
            leftMenuScrollView.hidden = NO;
            rightMenuScrollView.hidden = NO;
            menuLabel.hidden = NO;
            break;
        }
        case 7: { // Visuals
            UIScrollView *auraColorScrollView = [menuView viewWithTag:53];
            UIScrollView *dbdmUIScrollView = [menuView viewWithTag:54];
            UILabel *visualsLabel = [menuView viewWithTag:55];
            UILabel *auraLabel = [menuView viewWithTag:56];
            UILabel *uiLabel = [menuView viewWithTag:57];
            
            auraColorScrollView.hidden = NO;
            dbdmUIScrollView.hidden = NO;
            visualsLabel.hidden = NO;
            auraLabel.hidden = NO;
            uiLabel.hidden = NO;
            break;
        }
        case 8: { // Misc
            UIScrollView *miscScrollView = [menuView viewWithTag:64];
            UILabel *miscLabel = [menuView viewWithTag:65];
            
            miscScrollView.hidden = NO;
            miscLabel.hidden = NO;
            break;
        }
        case 9: { // Exploit
            UIScrollView *exploitScrollView = [menuView viewWithTag:18];
            UILabel *exploitLabel = [menuView viewWithTag:19];
            UILabel *exploitDescLabel = [menuView viewWithTag:21];
            
            exploitScrollView.hidden = NO;
            exploitLabel.hidden = NO;
            exploitDescLabel.hidden = NO;
            break;
        }
        case 10: { // Aimbot
            UIScrollView *aimbotScrollView = [menuView viewWithTag:908];
            UILabel *aimbotLabel = [menuView viewWithTag:909];
            
            aimbotScrollView.hidden = NO;
            aimbotLabel.hidden = NO;
            break;
        }
        case 11: { // ESP
            UIScrollView *espScrollView = [menuView viewWithTag:22];
            UILabel *espLabel = [menuView viewWithTag:23];
            
            espScrollView.hidden = NO;
            espLabel.hidden = NO;
            break;
        }
        case 12: { // Binds
            UIScrollView *bindsScrollView = [menuView viewWithTag:1315];
            UILabel *bindsLabel = [menuView viewWithTag:1314];
            
            [BindsView createBindsView:menuView];
            bindsScrollView.hidden = NO;
            bindsLabel.hidden = NO;
            bindsScrollView.hidden = NO;
            break;
        }
        case 13: { // Tools
            UIScrollView *toolsScrollView = [menuView viewWithTag:9];
            UILabel *toolsLabel = [menuView viewWithTag:10];
            UILabel *toolsDescLabel = [menuView viewWithTag:13];
            
            toolsScrollView.hidden = NO;
            toolsLabel.hidden = NO;
            toolsDescLabel.hidden = NO;
            break;
        }
    }
}

// Dodaj nową metodę pomocniczą do ukrywania wszystkich widoków
+ (void)hideAllViews {
    NSArray *viewTags = @[@2000, @2003, @5000, @5001, @7000, @7001, @3000, @3001, 
                         @4000, @4001, @9, @18, @22, @583, @584, @53, @54, @58, @64, @908, @910, @1315];
    
    NSArray *labelTags = @[@55, @56, @57, @2001, @2004, @5002, @5003, @5004, @7002, 
                          @3002, @4002, @4003, @4004, @10, @13, @19, @21, @23, @590, @65, @59, @909, @911, @1313, @1314];
    
    for (NSNumber *tag in viewTags) {
        UIView *view = [menuView viewWithTag:tag.integerValue];
        view.hidden = YES;
    }
    
    for (NSNumber *tag in labelTags) {
        UIView *label = [menuView viewWithTag:tag.integerValue];
        label.hidden = YES;
    }
}

+ (void)startCountdown {
    [countdownTimer invalidate];
    
    countdownTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 // Zmniejszony interwał z 1.0 na 0.5
                                                     target:self
                                                   selector:@selector(updateCountdown)
                                                   userInfo:nil
                                                    repeats:YES];
    
    [self updateCountdown];
}

+ (void)updateCountdown {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Aktualizacja licznika serwerów
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *targetDate = [formatter dateFromString:@"2025-03-20"];
        
        NSTimeInterval timeInterval = [targetDate timeIntervalSinceNow];
        
        if (timeInterval > 0) {
            int days = timeInterval / 86400;
            int hours = (int)timeInterval % 86400 / 3600;
            int minutes = (int)timeInterval % 3600 / 60;
            int seconds = (int)timeInterval % 60;
            
            countdownLabel.text = [NSString stringWithFormat:@"Servers Shutdown: %dd %02dh %02dm %02ds",
                                 days, hours, minutes, seconds];
        } else {
            countdownLabel.text = @"Servers are closed";
        }
        
        // Aktualizacja statystyk urządzenia
        NSDictionary *stats = [self getDeviceStats];
        
        UIImageSymbolConfiguration *symbolConfig = [UIImageSymbolConfiguration configurationWithPointSize:12 weight:UIImageSymbolWeightRegular];
        
        UIImage *batteryImage = [[UIImage systemImageNamed:@"battery.100.bolt" withConfiguration:symbolConfig] imageWithTintColor:[UIColor whiteColor]];
        UIImage *cpuImage = [[UIImage systemImageNamed:@"cpu" withConfiguration:symbolConfig] imageWithTintColor:[UIColor whiteColor]];
        UIImage *ramImage = [[UIImage systemImageNamed:@"memorychip" withConfiguration:symbolConfig] imageWithTintColor:[UIColor whiteColor]];
        UIImage *tempImage = [[UIImage systemImageNamed:@"thermometer" withConfiguration:symbolConfig] imageWithTintColor:[UIColor whiteColor]];
        
        if (!batteryImage || !cpuImage || !ramImage || !tempImage) {
            // Fallback na emoji jeśli SF Symbols nie są dostępne
            deviceStatsLabel.text = [NSString stringWithFormat:@"🔋 %.1f%% | 📊 %.1f%% | 💾 %.1f%% | 🌡️ %.1f°C",
                                   [stats[@"battery"] floatValue],
                                   [stats[@"cpu"] floatValue],
                                   [stats[@"ram"] floatValue],
                                   [stats[@"temp"] floatValue]];
            return;
        }
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
        
        void (^addImageAndText)(UIImage *, float) = ^(UIImage *image, float value) {
            if (image) {
                NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
                attachment.image = image;
                attachment.bounds = CGRectMake(0, -3, 12, 12);
                
                [attributedString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attachment]];
                [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %.1f%% | ", value]]];
            }
        };
        
        addImageAndText(batteryImage, [stats[@"battery"] floatValue]);
        addImageAndText(cpuImage, [stats[@"cpu"] floatValue]);
        addImageAndText(ramImage, [stats[@"ram"] floatValue]);
        addImageAndText(tempImage, [stats[@"temp"] floatValue]);
        
        NSRange lastSeparatorRange = [attributedString.string rangeOfString:@" | " options:NSBackwardsSearch];
        if (lastSeparatorRange.location != NSNotFound) {
            [attributedString deleteCharactersInRange:lastSeparatorRange];
        }
        
        [attributedString addAttributes:@{
            NSFontAttributeName: [UIFont fontWithName:currentFont size:9],
            NSForegroundColorAttributeName: [UIColor whiteColor]
        } range:NSMakeRange(0, attributedString.length)];
        
        deviceStatsLabel.attributedText = attributedString;
        
        // Dostosuj szerokość kontenera do nowej zawartości
        CGSize statsTextSize = [attributedString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 20)
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                           context:nil].size;
        
        CGFloat statsContainerWidth = statsTextSize.width + 20;
        
        CGRect frame = deviceStatsContainer.frame;
        frame.size.width = statsContainerWidth;
        deviceStatsContainer.frame = frame;
        
        // Aktualizuj frame gradientu
        CAGradientLayer *statsGradient = (CAGradientLayer *)[deviceStatsContainer.layer.sublayers firstObject];
        statsGradient.frame = deviceStatsContainer.bounds;
        
        // Aktualizuj frame labela
        CGRect labelFrame = deviceStatsLabel.frame;
        labelFrame.size.width = statsContainerWidth - 20;
        deviceStatsLabel.frame = labelFrame;
    });
}

+ (void)DisableACSDK:(UISwitch *)SW {
    vm(ENCRYPTOFFSET("0x109CA2C5A"), strtoul(ENCRYPTHEX("0x00000000"), nullptr, 0));
    
    // Pokaż powiadomienie o wyłączeniu ACSDK
    [self showNotification:@" Ninja Framework" message:@"ACSDK has been disabled!" duration:2.0];
}

// Dodaj nową metodę do obsługi notyfikacji
+ (void)handleGradientUpdate:(NSNotification *)notification {
    // Aktualizuj gradient dla countdownContainer
    if (countdownContainer) {
        CAGradientLayer *countdownGradient = (CAGradientLayer *)[countdownContainer.layer.sublayers firstObject];
        if ([countdownGradient isKindOfClass:[CAGradientLayer class]]) {
            countdownGradient.colors = @[
                (__bridge id)RightGradient,
                (__bridge id)blackColor,
                (__bridge id)blackColor,
                (__bridge id)LeftGradient
            ];
        }
    }
}

// Dodaj nową metodę do pobierania informacji o urządzeniu
+ (NSDictionary *)getDeviceStats {
    NSMutableDictionary *stats = [NSMutableDictionary new];
    
    // Poziom baterii
    UIDevice *device = [UIDevice currentDevice];
    device.batteryMonitoringEnabled = YES;
    float batteryLevel = device.batteryLevel * 100;
    [stats setObject:@(batteryLevel) forKey:@"battery"];
    
    // Użycie CPU - zmodyfikowana implementacja
    processor_info_array_t cpuInfo;
    mach_msg_type_number_t numCpuInfo;
    natural_t numCPUs = 0;
    kern_return_t err = host_processor_info(mach_host_self(), 
                                          PROCESSOR_CPU_LOAD_INFO, 
                                          &numCPUs, 
                                          &cpuInfo, 
                                          &numCpuInfo);
    
    float cpuUsage = 0;
    if (err == KERN_SUCCESS) {
        if (previousCPUInfo) {
            if (numPrevCPUSamples != numCPUs) {
                vm_deallocate(mach_task_self(), (vm_address_t)previousCPUInfo, sizeof(integer_t) * previousCPUInfoCnt);
                previousCPUInfo = NULL;
                numPrevCPUSamples = 0;
            }
        }

        float inUse = 0;
        float total = 0;

        for (unsigned i = 0; i < numCPUs; i++) {
            float userTicks = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER];
            float systemTicks = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM];
            float niceTicks = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
            float idleTicks = cpuInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];

            if (previousCPUInfo) {
                float prevUserTicks = previousCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_USER];
                float prevSystemTicks = previousCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_SYSTEM];
                float prevNiceTicks = previousCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_NICE];
                float prevIdleTicks = previousCPUInfo[(CPU_STATE_MAX * i) + CPU_STATE_IDLE];

                float deltaUser = userTicks - prevUserTicks;
                float deltaSystem = systemTicks - prevSystemTicks;
                float deltaNice = niceTicks - prevNiceTicks;
                float deltaIdle = idleTicks - prevIdleTicks;

                float deltaTotal = deltaUser + deltaSystem + deltaNice + deltaIdle;
                float deltaWork = deltaUser + deltaSystem + deltaNice;

                if (deltaTotal > 0) {
                    inUse += deltaWork;
                    total += deltaTotal;
                }
            }
        }

        if (previousCPUInfo) {
            if (total > 0) {
                cpuUsage = (inUse / total) * 100.0;
            }
            vm_deallocate(mach_task_self(), (vm_address_t)previousCPUInfo, sizeof(integer_t) * previousCPUInfoCnt);
        }

        previousCPUInfo = cpuInfo;
        previousCPUInfoCnt = numCpuInfo;
        numPrevCPUSamples = numCPUs;
    }
    [stats setObject:@(cpuUsage) forKey:@"cpu"];
    
    // Użycie RAM
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    
    host_page_size(host_port, &page_size);
    host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    
    natural_t mem_used = (vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count) * page_size;
    natural_t mem_total = (natural_t)[[NSProcessInfo processInfo] physicalMemory];
    float memoryUsage = ((float)mem_used / mem_total) * 100;
    [stats setObject:@(memoryUsage) forKey:@"ram"];
    
    // Temperatura - bardziej dokładne obliczenie
    float tempBase = 30.0;
    float tempCPUFactor = cpuUsage * 0.5;
    float tempRAMFactor = memoryUsage * 0.2;
    float estimatedTemp = tempBase + tempCPUFactor + tempRAMFactor;
    // Ograniczenie temperatury do realistycznego zakresu
    estimatedTemp = fmin(fmax(estimatedTemp, 30.0), 95.0);
    [stats setObject:@(estimatedTemp) forKey:@"temp"];
    
    return stats;
}

@end

