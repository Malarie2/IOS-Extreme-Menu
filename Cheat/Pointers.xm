#import "Pointers.h"
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Magicolors/ColorsHandler.h"
#import "Cheat/SDK.h"
#import <cmath>
#import <float.h>
#import <vector>
#import "SDKCheats/TeleportManager.h"
#import "ESPView.h"
#import "ESPOverlayView.h"
#import "SDKCheats/Jump.h"
#import "SDKCheats/Sacrifice.h"


// Przenieś tę deklarację na początek pliku, zaraz po innych deklaracjach forward
void ChangePlayerName(NSString *newName);

// Usuń tę deklarację z końca pliku (ponieważ teraz jest na początku)
// void ChangePlayerName(NSString *newName);

// Deklaracja na początku pliku
void MoveUpward(float deltaTime);

@class JoystickView;

// Add these forward declarations at the top
void UpdateGeneratorPositions();
void TeleportToNearestGenerator();
void TeleportTo(const Vector3& location);
float CalculateDistance(const Vector3& a, const Vector3& b);

// Use NSMutableArray instead of std::vector for better Objective-C compatibility

// Add this typedef to make the enum accessible in Objective-C
typedef enum EInteractionAnimation EInteractionAnimation;

// Dodaj strukturę przed jej użyciem
struct TargetInfo {
    uintptr_t Actor;
    float Distance;
    Vector3 Position;
    NSString *Name;
};

// Dodaj te deklaracje na początku pliku, zaraz po istniejących deklaracjach
void SetPlayerRotation(float pitch, float yaw);
void FindAndAimAtClosestSurvivor();
bool IsInFOV(const Vector3& targetPos);
void TeleportTo(const Vector3& location);
void TeleportToNearestGenerator();
float CalculateDistance(const Vector3& a, const Vector3& b);
Vector3 GetActorPosition(uintptr_t RootComponent);

// Dodaj na początku pliku deklarację funkcji
void ChangeCharacter(int characterId);

// Dodaj te zmienne globalne na początku pliku
static int currentCharacterId = 0;
static UIButton *leftArrowButton;
static UIButton *rightArrowButton;
static UIButton *changeCharacterButton;
static UILabel *characterIdLabel;

// Dodaj na początku pliku, przed innymi deklaracjami

// Na samym początku pliku, przed @interface NotificationManager


static UIButton *aimbotButton;

static UIView *espOverlayView;

// Dodaj zmienne globalne na początku pliku
static float joystickX = 0.0f;
static float joystickY = 0.0f;
static bool isJoystickActive = false;
static const float MOVEMENT_SPEED = 300.0f; // Prędkość ruchu (jednostki/sekundę)

// Dodaj zmienne dla kontroli wysokości
static UIButton *upButton;
static const float VERTICAL_SPEED = 100.0f; // Zmniejszona prędkość dla płynniejszego ruchu
static bool isMovingUp = false;

// Dodaj na początku pliku z innymi zmiennymi statycznymi
static UIButton *changeNameButton;
static UITextField *nameTextField;

// Dodaj na początku pliku z innymi deklaracjami
static uintptr_t (*GetFOVAngle)(void *instance);
static void (*SetFOVAngle)(void *instance, float newFOV);

// Dodaj na początku pliku, po innych zmiennych statycznych
static NSTimer *nameChangeTimer = nil;
static bool isAutoNameChangeEnabled = false;

// Dodaj nowe funkcje przed UpdatePointersLoop
void StartAutoNameChange() {
    if (nameChangeTimer) {
        [nameChangeTimer invalidate];
        nameChangeTimer = nil;
    }
    
    isAutoNameChangeEnabled = true;
    nameChangeTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 
                                                     repeats:YES 
                                                       block:^(NSTimer *timer) {
        if (isAutoNameChangeEnabled) {
            ChangePlayerName(@"NINJA FRAMEWORK | T.ME/CRUEXGG | Happy New Year 2025 <3");
        }
    }];
}

void StopAutoNameChange() {
    isAutoNameChangeEnabled = false;
    if (nameChangeTimer) {
        [nameChangeTimer invalidate];
        nameChangeTimer = nil;
    }
}

// Funkcje do obsługi joysticka
void UpdateJoystickPosition(float x, float y) {
    // Odwróć oś Y, aby góra była do przodu
    joystickX = fmax(-1.0f, fmin(1.0f, x));
    joystickY = fmax(-1.0f, fmin(1.0f, -y)); // Dodaj minus przed y
}

void SetJoystickActive(bool active) {
    isJoystickActive = active;
}

// Dodaj nową funkcję MoveUpward
void MoveUpward(float deltaTime) {
    if (!LocalPlayer || !isMovingUp) return;
    
    uintptr_t RootComponent = GetRootComponent(LocalPlayer);
    if (!RootComponent) return;
    
    Vector3 currentPosition = *(Vector3*)(RootComponent + Offsets::SDK::USceneComponentToRelativeLocation);
    Vector3 newPosition = currentPosition;

    // Płynny ruch w górę
    static float currentSpeed = 0.0f;
    float acceleration = 200.0f;
    float maxSpeed = VERTICAL_SPEED;
    
    currentSpeed = fmin(currentSpeed + acceleration * deltaTime, maxSpeed);
    newPosition.Z += currentSpeed * deltaTime;
    
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
    } Parameters;

    Parameters.snapPosition = true;
    Parameters.Position = newPosition;
    Parameters.stopSnapDistance = 0.0f;
    Parameters.snapRotation = false;
    Parameters.Rotation = FRotator{0, 0, 0};
    Parameters.Time = 0.01f;
    Parameters.useZCoord = true;
    Parameters.sweepOnFinalSnap = false;
    Parameters.snapRoll = false;

    static uintptr_t SnapCharacter_Function = FindObject(@"SnapCharacter");
    if (!SnapCharacter_Function) return;

    ProcessEvent(LocalPlayer, SnapCharacter_Function, (uintptr_t)&Parameters);
}
// Add FString structure definition
struct FString {
    wchar_t* Data;
    int32_t Count;
    int32_t Max;
};
@interface NotificationManager : NSObject
+ (void)updateNotificationGradient:(CADisplayLink *)displayLink;
+ (void)showNotification:(NSString *)title message:(NSString *)message duration:(NSTimeInterval)duration;
+ (void)applyServerState;
+ (void)updateLocalPlayerAndServerFunction;
+ (void)buttonTouchDown:(UIButton *)sender;
+ (void)buttonTouchUp:(UIButton *)sender;
+ (UIButton *)createStateButton;

+ (void)setupCharacterChangeButtons;
+ (void)leftArrowPressed;
+ (void)rightArrowPressed;
+ (void)changeCharacterPressed;
+ (void)updateCharacterIdLabel;

+ (void)setupButton;

+ (void)setupVerticalControls;

@end

@interface NotificationManager ()
@property (nonatomic, strong) NSMutableArray<CAGradientLayer *> *activeGradients;
@end

uintptr_t BaseAddress;
uintptr_t(*ProcessEvent)(uintptr_t Instance, uintptr_t Function, uintptr_t Parameters);

uintptr_t Server_SetImmobilized;

uintptr_t PersistentLevel;
uintptr_t OwningGameInstance;

uintptr_t LocalPlayer;
bool IsKiller = false;

static int selectedState = 0;
static NSArray *stateLabels;
static UIView *menuView;

static bool isProcessingState = false;

static BOOL isButtonPressed = NO;

// Dodaj zmienną statyczną do śledzenia czy przyciski zostały już utworzone
static bool buttonsCreated = false;

// Dodaj na początku pliku
static bool isSacrificeToggled = false;

void SetCustomFOV(float fov) {
    if (!OwningGameInstance) return;
    
    uintptr_t LocalPlayers = *(uintptr_t*)(OwningGameInstance + Offsets::SDK::UGameInstanceToLocalPlayers);
    if (!LocalPlayers) return;
    
    uintptr_t ULocalPlayer = *(uintptr_t*)(LocalPlayers);
    if (!ULocalPlayer) return;
    
    uintptr_t PlayerController = *(uintptr_t*)(ULocalPlayer + Offsets::SDK::UPlayerToPlayerController);
    if (!PlayerController) return;

    // Znajdź funkcję FOV
    static uintptr_t FOV_Function = FindObject(@"FOV");
    if (!FOV_Function) {
        NSLog(@"[FOV] Failed to find FOV function");
        return;
    }

    // Przygotuj parametry dla funkcji FOV
    struct {
        float NewFOV;
    } Parameters;
    Parameters.NewFOV = fov;

    // Wywołaj funkcję FOV
    @try {
        ProcessEvent(PlayerController, FOV_Function, (uintptr_t)&Parameters);
        NSLog(@"[FOV] Successfully set FOV to: %.1f", fov);
    } @catch (NSException *exception) {
        NSLog(@"[FOV] Exception while setting FOV: %@", exception);
    }
}

uintptr_t GetLocalPlayerCameraManager() {
    if (!OwningGameInstance) return 0x0;
	uintptr_t LocalPlayers = *(uintptr_t*)(OwningGameInstance + Offsets::SDK::UGameInstanceToLocalPlayers);
	if (!LocalPlayers) return 0x0;
	uintptr_t ULocalPlayer = *(uintptr_t*)(LocalPlayers);
	if (!ULocalPlayer) return 0x0;
	uintptr_t PlayerController = *(uintptr_t*)(ULocalPlayer + Offsets::SDK::UPlayerToPlayerController);
	if (!PlayerController) return 0x0;
    uintptr_t LocalPlayerCameraManager = *(uintptr_t*)(PlayerController + Offsets::SDK::APlayerControllerToPlayerCameraManager);
	if (!LocalPlayerCameraManager) return 0x0;

    return LocalPlayerCameraManager;
}

uintptr_t GetLocalPlayer() {
    if (!OwningGameInstance) return 0x0;
	uintptr_t LocalPlayers = *(uintptr_t*)(OwningGameInstance + Offsets::SDK::UGameInstanceToLocalPlayers);
	if (!LocalPlayers) return 0x0;
	uintptr_t ULocalPlayer = *(uintptr_t*)(LocalPlayers);
	if (!ULocalPlayer) return 0x0;
	uintptr_t PlayerController = *(uintptr_t*)(ULocalPlayer + Offsets::SDK::UPlayerToPlayerController);
	if (!PlayerController) return 0x0;
	uintptr_t LocalPlayer = *(uintptr_t*)(PlayerController + Offsets::SDK::APlayerControllerToAcknowledgedPawn);
	if (!LocalPlayer) return 0x0;

    return LocalPlayer;
}

uintptr_t GetRootComponent(uintptr_t Actor) {
    return *(uintptr_t*)(Actor + Offsets::SDK::AActorToRootComponent);
}



void SetPlayerAnimation(EInteractionAnimation animation) {
    if (!LocalPlayer) return;
    
    struct {
        EInteractionAnimation Animation;
    } Parameters;
    Parameters.Animation = animation;

    static uintptr_t SetCurrentInteractionAnimation = FindObject(@"SetCurrentInteractionAnimation");
    if (!SetCurrentInteractionAnimation) return;

    ProcessEvent(LocalPlayer, SetCurrentInteractionAnimation, (uintptr_t)&Parameters);
}



@implementation NotificationManager

static NotificationManager *sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NotificationManager alloc] init];
        sharedInstance.activeGradients = [NSMutableArray array];
    });
    return sharedInstance;
}

+ (void)initialize {
    if (self == [NotificationManager class]) {
        stateLabels = @[@"NONE", @"HOOKED"];
    }
}

+ (void)updateNotificationGradient:(CADisplayLink *)displayLink {
    NotificationManager *manager = [NotificationManager sharedInstance];
    
    for (CAGradientLayer *gradient in manager.activeGradients) {
        @try {
            gradient.colors = @[
                (__bridge id)RightGradient,
                (__bridge id)blackColor,
                (__bridge id)blackColor,
                (__bridge id)LeftGradient
            ];
        } @catch (NSException *exception) {
        }
    }
}

+ (void)showNotification:(NSString *)title message:(NSString *)message duration:(NSTimeInterval)duration {
    static NSMutableArray *activeNotifications;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        activeNotifications = [NSMutableArray new];
    });

    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        CGFloat notificationHeight = 16;
        CGFloat topPadding = 10;
        CGFloat spacing = 3;
        
        NSString *fullText = [NSString stringWithFormat:@"%@ %@", title, message];
        UIFont *font = [UIFont fontWithName:@"ArialRoundedMTBold" size:8];
        CGSize textSize = [fullText sizeWithAttributes:@{NSFontAttributeName: font}];
        CGFloat padding = 16;
        CGFloat notificationWidth = textSize.width + padding;
        
        UILabel *notificationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        notificationLabel.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.8];
        notificationLabel.layer.cornerRadius = 4.0;
        notificationLabel.clipsToBounds = YES;
        
        NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:fullText];
        [attributedText addAttributes:@{NSFontAttributeName: font} range:NSMakeRange(0, attributedText.length)];
        notificationLabel.attributedText = attributedText;
        
        notificationLabel.textAlignment = NSTextAlignmentCenter;
        notificationLabel.textColor = UIColor.whiteColor;
        
        CAGradientLayer *topGradient = [CAGradientLayer layer];
        CAGradientLayer *bottomGradient = [CAGradientLayer layer];
        
        [Colors initializeColors];
        
        topGradient.frame = CGRectMake(0, 0, 0, 1.5);
        bottomGradient.frame = CGRectMake(0, notificationHeight - 1.5, 0, 1.5);
        
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
        
        [notificationLabel.layer addSublayer:topGradient];
        [notificationLabel.layer addSublayer:bottomGradient];
        
        // Oblicz pozycję Y dla nowego powiadomienia
        CGFloat yOffset = topPadding;
        for (UIView *activeNotification in activeNotifications) {
            yOffset += (activeNotification.frame.size.height + spacing);
        }
        
        notificationLabel.frame = CGRectMake(window.center.x, yOffset, 0, notificationHeight);
        [window addSubview:notificationLabel];
        [activeNotifications addObject:notificationLabel];
        
        [[NotificationManager sharedInstance].activeGradients addObject:topGradient];
        [[NotificationManager sharedInstance].activeGradients addObject:bottomGradient];
        
        [UIView animateWithDuration:0.3 animations:^{
            notificationLabel.frame = CGRectMake(window.center.x - notificationWidth/2, yOffset, notificationWidth, notificationHeight);
            topGradient.frame = CGRectMake(0, 0, notificationWidth, 1.5);
            bottomGradient.frame = CGRectMake(0, notificationHeight - 1.5, notificationWidth, 1.5);
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.3 animations:^{
                    notificationLabel.frame = CGRectMake(window.center.x, yOffset, 0, notificationHeight);
                    topGradient.frame = CGRectMake(0, 0, 0, 1.5);
                    bottomGradient.frame = CGRectMake(0, notificationHeight - 1.5, 0, 1.5);
                    notificationLabel.alpha = 0;
                } completion:^(BOOL finished) {
                    [notificationLabel removeFromSuperview];
                    [activeNotifications removeObject:notificationLabel];
                    [[NotificationManager sharedInstance].activeGradients removeObject:topGradient];
                    [[NotificationManager sharedInstance].activeGradients removeObject:bottomGradient];
                    
                    // Przesuń pozostałe powiadomienia w górę
                    CGFloat newYOffset = topPadding;
                    for (UIView *remainingNotification in activeNotifications) {
                        [UIView animateWithDuration:0.2 animations:^{
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

+ (void)applyServerState {
    static NSTimeInterval lastProcessEventTime = 0;
    static const NSTimeInterval MIN_INTERVAL = 0.05; // 50ms w sekundach
    
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    
    if (currentTime - lastProcessEventTime < MIN_INTERVAL) {
        return;
    }
    
    if (!LocalPlayer || !Server_SetImmobilized) {
        [self updateLocalPlayerAndServerFunction];
        if (!LocalPlayer || !Server_SetImmobilized) {
            return;
        }
    }

    struct {
        int8_t State;
        char padding[15];
    } Parameters = {0};
    Parameters.State = selectedState;

    ProcessEvent(LocalPlayer, Server_SetImmobilized, (uintptr_t)&Parameters);
    lastProcessEventTime = currentTime;
}

+ (void)updateLocalPlayerAndServerFunction {
    if (!LocalPlayer) {
        LocalPlayer = GetLocalPlayer();
    }
    
    if (!Server_SetImmobilized) {
        Server_SetImmobilized = FindObject(@"Server_SetImmobilized");
    }
}

+ (void)buttonTouchDown:(UIButton *)sender {
    if (isProcessingState) return;
    isProcessingState = YES;
    
    sender.alpha = 0.7;
    selectedState = 1;
    [self applyServerState];
    isProcessingState = NO;
}

+ (void)buttonTouchUp:(UIButton *)sender {
    if (isProcessingState) return;
    isProcessingState = YES;
    
    sender.alpha = 1.0;
    selectedState = 0;
    [self applyServerState];
    isProcessingState = NO;
}
+ (UIButton *)createStateButton {
    UIButton *stateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [stateButton setTitle:@"HOOKED" forState:UIControlStateNormal];
    
    stateButton.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.8];
    [stateButton.titleLabel setFont:[UIFont fontWithName:@"ArialRoundedMTBold" size:10]];
    [stateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // Make button circular
    stateButton.layer.cornerRadius = 25.0 / 2; // Half of height for circle
    stateButton.clipsToBounds = YES;
    
    CAGradientLayer *topGradient = [CAGradientLayer layer];
    CAGradientLayer *bottomGradient = [CAGradientLayer layer];
    
    [Colors initializeColors];
    
    topGradient.frame = CGRectMake(0, 0, 100, 1.5);
    bottomGradient.frame = CGRectMake(0, 23.5, 100, 1.5); // Adjusted for new height
    
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
    
    [stateButton.layer addSublayer:topGradient];
    [stateButton.layer addSublayer:bottomGradient];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat buttonWidth = 100;
    CGFloat buttonHeight = 25; // New height
    CGFloat bottomPadding = 35; // New padding
    
    stateButton.frame = CGRectMake(
        (screenBounds.size.width - buttonWidth) / 2,
        screenBounds.size.height - buttonHeight - bottomPadding,
        buttonWidth,
        buttonHeight
    );
    
    stateButton.hidden = !getFloatIconEnabled();
    
    [stateButton addTarget:self 
                   action:@selector(buttonTouchDown:) 
         forControlEvents:UIControlEventTouchDown];
    
    [stateButton addTarget:self 
                   action:@selector(buttonTouchUp:) 
         forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel];
    
    [[NotificationManager sharedInstance].activeGradients addObject:topGradient];
    [[NotificationManager sharedInstance].activeGradients addObject:bottomGradient];
    
    return stateButton;
}



+ (void)setupCharacterChangeButtons {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    if (!keyWindow) return;
    
    CGFloat buttonSize = 30;
    CGFloat spacing = 10;
    CGFloat bottomPadding = 80; // Wyżej niż przycisk HOOKED
    
    // Label pokazujący aktualny ID
    characterIdLabel = [[UILabel alloc] init];
    characterIdLabel.textAlignment = NSTextAlignmentCenter;
    characterIdLabel.textColor = [UIColor whiteColor];
    characterIdLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
    characterIdLabel.frame = CGRectMake(0, 0, 50, 20);
    characterIdLabel.center = CGPointMake(keyWindow.center.x, keyWindow.frame.size.height - bottomPadding);
    characterIdLabel.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.8];
    characterIdLabel.layer.cornerRadius = 10;
    characterIdLabel.clipsToBounds = YES;
    [keyWindow addSubview:characterIdLabel];
    
    // Lewa strzałka
    leftArrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftArrowButton.frame = CGRectMake(characterIdLabel.frame.origin.x - buttonSize - spacing,
                                      characterIdLabel.frame.origin.y - 5,
                                      buttonSize,
                                      buttonSize);
    [leftArrowButton setTitle:@"←" forState:UIControlStateNormal];
    leftArrowButton.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.8];
    leftArrowButton.layer.cornerRadius = buttonSize/2;
    [leftArrowButton addTarget:self action:@selector(leftArrowPressed) forControlEvents:UIControlEventTouchUpInside];
    [keyWindow addSubview:leftArrowButton];
    
    // Prawa strzałka
    rightArrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightArrowButton.frame = CGRectMake(characterIdLabel.frame.origin.x + characterIdLabel.frame.size.width + spacing,
                                       characterIdLabel.frame.origin.y - 5,
                                       buttonSize,
                                       buttonSize);
    [rightArrowButton setTitle:@"→" forState:UIControlStateNormal];
    rightArrowButton.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.8];
    rightArrowButton.layer.cornerRadius = buttonSize/2;
    [rightArrowButton addTarget:self action:@selector(rightArrowPressed) forControlEvents:UIControlEventTouchUpInside];
    [keyWindow addSubview:rightArrowButton];
    
    // Przycisk zmiany postaci
    changeCharacterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    changeCharacterButton.frame = CGRectMake(0, 0, 100, 25);
    changeCharacterButton.center = CGPointMake(keyWindow.center.x, 
                                             characterIdLabel.frame.origin.y - buttonSize - spacing);
    [changeCharacterButton setTitle:@"CHANGE" forState:UIControlStateNormal];
    changeCharacterButton.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.8];
    changeCharacterButton.layer.cornerRadius = 12.5;
    [changeCharacterButton.titleLabel setFont:[UIFont fontWithName:@"ArialRoundedMTBold" size:12]];
    [changeCharacterButton addTarget:self action:@selector(changeCharacterPressed) forControlEvents:UIControlEventTouchUpInside];
    [keyWindow addSubview:changeCharacterButton];
    
    [self updateCharacterIdLabel];
}

+ (void)leftArrowPressed {
    if (currentCharacterId > 0) {
        currentCharacterId--;
        [self updateCharacterIdLabel];
    }
}

+ (void)rightArrowPressed {
    if (currentCharacterId < 40) {
        currentCharacterId++;
        [self updateCharacterIdLabel];
    }
}

+ (void)changeCharacterPressed {
    ChangeCharacter(currentCharacterId);
}

+ (void)updateCharacterIdLabel {
    characterIdLabel.text = [NSString stringWithFormat:@"%d", currentCharacterId];
}

+ (void)setupButton {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        if (!keyWindow) return;
        
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        CGFloat buttonWidth = 100;
        CGFloat buttonHeight = 25;
        
        // Create and add the state button
        UIButton *stateButton = [self createStateButton];
        [keyWindow addSubview:stateButton];
        
        // Start display link for gradient animation if needed
        CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self 
                                                               selector:@selector(updateNotificationGradient:)];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] 
                         forMode:NSRunLoopCommonModes];
    });
}

+ (void)setupVerticalControls {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        if (!keyWindow) return;
        
        CGFloat buttonSize = 30;
        CGFloat padding = 20;
        CGFloat rightPadding = 100;
        
        upButton = [UIButton buttonWithType:UIButtonTypeCustom];
        upButton.frame = CGRectMake(
            keyWindow.frame.size.width - buttonSize - rightPadding,
            keyWindow.frame.size.height - buttonSize - padding,
            buttonSize,
            buttonSize
        );
        [upButton setTitle:@"Noclip\nUpward" forState:UIControlStateNormal];
        upButton.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:7];
        upButton.titleLabel.numberOfLines = 2;
        upButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        upButton.backgroundColor = [UIColor clearColor]; // Zmieniono na przezroczyste tło
        upButton.layer.cornerRadius = buttonSize / 2;
        upButton.clipsToBounds = YES;
        
        // Dodaj gradient tła
        CAGradientLayer *backgroundGradient = [CAGradientLayer layer];
        backgroundGradient.frame = upButton.bounds;
        backgroundGradient.colors = @[
            (__bridge id)RightGradient,
            (__bridge id)blackColor,
            (__bridge id)blackColor,
            (__bridge id)LeftGradient
        ];
        backgroundGradient.locations = @[@0.0, @0.3, @0.7, @1.0];
        backgroundGradient.startPoint = CGPointMake(0, 0.5);
        backgroundGradient.endPoint = CGPointMake(1, 0.5);
        [upButton.layer insertSublayer:backgroundGradient atIndex:0];

        // Dodaj gradienty górny i dolny
        CAGradientLayer *topGradient = [CAGradientLayer layer];
        CAGradientLayer *bottomGradient = [CAGradientLayer layer];
        
        topGradient.frame = CGRectMake(0, 0, buttonSize, 1.5);
        bottomGradient.frame = CGRectMake(0, buttonSize - 1.5, buttonSize, 1.5);
        
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
        
        [upButton.layer addSublayer:topGradient];
        [upButton.layer addSublayer:bottomGradient];
        
        // Dodaj efekty dotknięcia
        [upButton addTarget:self action:@selector(upButtonTouchDown:) 
            forControlEvents:UIControlEventTouchDown];
        [upButton addTarget:self action:@selector(upButtonTouchUp:) 
            forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        
        [keyWindow addSubview:upButton];
        
        // Dodaj gradienty do activeGradients
        [[NotificationManager sharedInstance].activeGradients addObject:backgroundGradient];
        [[NotificationManager sharedInstance].activeGradients addObject:topGradient];
        [[NotificationManager sharedInstance].activeGradients addObject:bottomGradient];
    });
}

+ (void)upButtonTouchDown:(UIButton *)sender {
    isMovingUp = true;
}

+ (void)upButtonTouchUp:(UIButton *)sender {
    isMovingUp = false;
}

@end

void ShowAlert(NSString *title, NSString *message) {
    [NotificationManager showNotification:title message:message duration:2.0];
}

void ForceEndGame(EEndGameReason reason) {
    if (!OwningGameInstance) {
        ShowAlert(@"[NFramework] --> ", @"Game instance not found");
        return;
    }
    
    uintptr_t LocalPlayers = *(uintptr_t*)(OwningGameInstance + Offsets::SDK::UGameInstanceToLocalPlayers);
    if (!LocalPlayers) {
        ShowAlert(@"[NFramework] --> ", @"Local players not found");
        return;
    }
    
    uintptr_t ULocalPlayer = *(uintptr_t*)(LocalPlayers);
    if (!ULocalPlayer) {
        ShowAlert(@"[NFramework] --> ", @"Local player not found");
        return;
    }
    
    uintptr_t PlayerController = *(uintptr_t*)(ULocalPlayer + Offsets::SDK::UPlayerToPlayerController);
    if (!PlayerController) {
        ShowAlert(@"[NFramework] --> ", @"Player controller not found");
        return;
    }

    // Przygotuj parametry dla Server_EndGame
    struct {
        EEndGameReason Reason;
    } Parameters;
    Parameters.Reason = reason;

    // Znajdź i wywołaj funkcj Server_EndGame
    static uintptr_t Server_EndGame = FindObject(@"Server_EndGame");
    if (Server_EndGame) {
        ProcessEvent(PlayerController, Server_EndGame, (uintptr_t)&Parameters);
        ShowAlert(@"Success", @"Game end requested");
    } else {
        ShowAlert(@"[NFramework] --> ", @"EndGame function not found");
    }
}

// Usuń drugą deklarację funkcji SetReadyToBeSacrificed z UpdatePointersLoop
void UpdatePointersLoop() {
    espOverlayView.hidden = YES;
    
    const int TargetCycleDurationMS = 16;
    static bool isSacrificed = false;

    BaseAddress = GetBaseAddressOfLibrary("DeadByDaylight");
    if (!BaseAddress) {
        return;
    }

    ProcessEvent = (uintptr_t(*)(uintptr_t, uintptr_t, uintptr_t))(BaseAddress + Offsets::Globals::ProcessEventOffset);
    
    Server_SetImmobilized = FindObject(@"Server_SetImmobilized");

    static bool espInitialized = false;
    static ESPView *espView = nil;

    for (;;) {
        @autoreleasepool {
            std::chrono::time_point<std::chrono::high_resolution_clock> CycleStartTime = std::chrono::high_resolution_clock::now();

            if (!buttonsCreated) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NotificationManager setupButton];
                    [NotificationManager setupVerticalControls];
                    buttonsCreated = true;
                });
            }

            // Sprawdź stan sacrificed
            if (LocalPlayer) {
                uintptr_t endGameComponent = *(uintptr_t*)(LocalPlayer + Offsets::SDK::ACamperToEndGameComponent);
                if (endGameComponent) {
                    bool currentSacrificed = *(bool*)(endGameComponent + 0x110);
                    if (currentSacrificed != isSacrificed) {
                        isSacrificed = currentSacrificed;
                        if (isSacrificed) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                ShowAlert(@"Status", @"Player is now sacrificed");
                            });
                        }
                    }
                }
            }

            // Inicjalizacja ESP View tylko raz
            if (!espInitialized) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    espView = [ESPView sharedInstance];
                    [espView setupESPOverlayView];
                    espInitialized = true;
                });
            }

            uintptr_t GWorld = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
            if (!GWorld) {
                goto LoopEnd;
            }

            OwningGameInstance = *(uintptr_t*)(GWorld + Offsets::SDK::UWorldToOwningGameInstance);
            if (!OwningGameInstance) {
                goto LoopEnd;
            }

            PersistentLevel = *(uintptr_t*)(GWorld + Offsets::SDK::UWorldToPersistentLevel);
            if (!PersistentLevel) {
                goto LoopEnd;
            }

            LocalPlayer = GetLocalPlayer();
            if (LocalPlayer) {
                static int espUpdateCounter = 0;
                if (++espUpdateCounter >= 1) {
                    if (espView) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [espView clearESP];
                            
                            @autoreleasepool {
                                [espView drawKillerESP];
                                [espView drawGeneratorESP];
                                [espView drawTotemESP];
                                [espView drawChestESP];
                                [espView drawGateESP];
                                [espView drawHatchESP];
                                [espView drawSurvivorESP];
                                [espView drawAllBPObjectsESP];
                            }
                        });
                    }
                    espUpdateCounter = 0;
                }
            }

            // Dodaj obsługę joysticka
            if (LocalPlayer) {
                static auto lastTime = std::chrono::high_resolution_clock::now();
                auto currentTime = std::chrono::high_resolution_clock::now();
                float deltaTime = std::chrono::duration<float>(currentTime - lastTime).count();
                lastTime = currentTime;
         
                MoveUpward(deltaTime); // Używamy nowej funkcji
            }

        
            LoopEnd:
            std::chrono::time_point<std::chrono::high_resolution_clock> CycleEndTime = std::chrono::high_resolution_clock::now();
            std::chrono::duration<double, std::milli> CycleDuration = CycleEndTime - CycleStartTime;
            int CycleDurationMS = static_cast<int>(CycleDuration.count());
            if (CycleDurationMS < TargetCycleDurationMS) 
                std::this_thread::sleep_for(std::chrono::milliseconds(TargetCycleDurationMS - CycleDurationMS));
        }
    }
}


// Modified TeleportTo function with better parameter handling
void TeleportTo(const Vector3& location) {
    if (!LocalPlayer) return;
    
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
    } Parameters;

    // Konfiguracja parametrów
    Parameters.snapPosition = true;
    Parameters.Position = location;
    Parameters.stopSnapDistance = 0.0f; // Zatrzymaj dokładnie na pozycji docelowej
    Parameters.snapRotation = false; // Nie zmieniaj rotacji
    Parameters.Rotation = FRotator{0, 0, 0};
    Parameters.Time = 0.5f; // Czas teleportacji (w sekundach)
    Parameters.useZCoord = true;
    Parameters.sweepOnFinalSnap = false;
    Parameters.snapRoll = false;

    static uintptr_t SnapCharacter_Function = FindObject(@"SnapCharacter");
    if (!SnapCharacter_Function) {
        ShowAlert(@"[NFramework] --> ", @"SnapCharacter function not found");
        return;
    }

    ProcessEvent(LocalPlayer, SnapCharacter_Function, (uintptr_t)&Parameters);
}

// Modified TeleportToNearestGenerator function with better generator detection
void TeleportToNearestGenerator() {
    UpdateGeneratorPositions();
    
    if (generatorPositions.count == 0) {
        ShowAlert(@"[NFramework] --> ", @"No valid generators found");
        return;
    }
    
    if (currentGeneratorIndex >= generatorPositions.count) {
        currentGeneratorIndex = 0;
    }
    
    Vector3 position;
    [[generatorPositions objectAtIndex:currentGeneratorIndex] getValue:&position];
    TeleportTo(position);
    
    ShowAlert(@"Success", [NSString stringWithFormat:@"Teleported to generator %d/%lu", 
        currentGeneratorIndex + 1, generatorPositions.count]);
}

// Helper function to get actor name
NSString* GetActorName(uintptr_t Actor) {
    if (!Actor) return nil;
    
    uintptr_t NamePtr = *(uintptr_t*)(Actor + Offsets::SDK::AActorToRootComponent);
    if (!NamePtr) return nil;
    
    return [NSString stringWithUTF8String:(char*)NamePtr];
}

Vector3 GetActorPosition(uintptr_t RootComponent) {
    if (!RootComponent) return Vector3{0, 0, 0};
    return *(Vector3*)(RootComponent + Offsets::SDK::USceneComponentToRelativeLocation);
}

// Add this function to update generator positions
void UpdateGeneratorPositions() {
    [generatorPositions removeAllObjects];
    
    uintptr_t World = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
    if (!World) return;
    
    uintptr_t GameState = *(uintptr_t*)(World + Offsets::SDK::UWorldToGameState);
    if (!GameState) return;
    
    uintptr_t _generators = *(uintptr_t*)(GameState + Offsets::SDK::ADBDGameStateTo_generators);
    int32_t _generatorsCount = *(int32_t*)(GameState + Offsets::SDK::ADBDGameStateTo_generators + Offsets::Special::TArrayToCount);
    
    for (int g = 0; g < _generatorsCount && _generators != 0; g++) {
        uintptr_t Generator = *(uintptr_t*)(_generators + g * Offsets::Special::PointerSize);
        if (!Generator) continue;
        
        if (*(bool*)(Generator + Offsets::SDK::AGeneratorToactivated)) continue;
        
        uintptr_t RootComponent = GetRootComponent(Generator);
        if (!RootComponent) continue;
        
        Vector3 position = *(Vector3*)(RootComponent + Offsets::SDK::USceneComponentToRelativeLocation);
        position.Z += 100.0f; // Add height offset
        
        // Wrap Vector3 in NSValue
        NSValue *positionValue = [NSValue valueWithBytes:&position objCType:@encode(Vector3)];
        [generatorPositions addObject:positionValue];
    }
}

// Dodaj implementację funkcji gdzieś w pliku
void ChangeCharacter(int characterId) {
    @try {
        if (!OwningGameInstance) {
            ShowAlert(@"[NFramework] --> ", @"Game instance not found");
            return;
        }
        
        // Pobierz PlayerState_Menu
        struct {
            uintptr_t ReturnValue;
        } GetMenuStateParams;
        GetMenuStateParams.ReturnValue = 0;
        
        static uintptr_t GetLocalPlayerStateMenu_Function = FindObject(@"GetLocalPlayerStateMenu");
        if (!GetLocalPlayerStateMenu_Function) {
            ShowAlert(@"[NFramework] --> ", @"GetLocalPlayerStateMenu function not found");
            return;
        }
        
        @try {
            ProcessEvent(OwningGameInstance, GetLocalPlayerStateMenu_Function, (uintptr_t)&GetMenuStateParams);
        } @catch (NSException *e) {
            ShowAlert(@"[NFramework] --> ", @"Failed to get menu state");
            return;
        }
        
        if (!GetMenuStateParams.ReturnValue) {
            ShowAlert(@"[NFramework] --> ", @"PlayerState_Menu not found");
            return;
        }
        
        // Przygotuj parametry z jawną inicjalizacją
        struct {
            EPlayerRole forRole;
            int32_t ID;
            bool updateDisplayData;
            char padding[3];
        } Parameters;
        
        Parameters.forRole = EPlayerRole::VE_Camper;
        Parameters.ID = characterId;
        Parameters.updateDisplayData = true;
        Parameters.padding[0] = 0;
        Parameters.padding[1] = 0;
        Parameters.padding[2] = 0;
        
        static uintptr_t Server_SetSelectedCharacterId_Function = FindObject(@"Server_SetSelectedCharacterId");
        if (!Server_SetSelectedCharacterId_Function) {
            ShowAlert(@"[NFramework] --> ", @"SetSelectedCharacterId function not found");
            return;
        }
        
        // Wykonaj zmianę postaci w bloku @try
        @try {
            ProcessEvent(GetMenuStateParams.ReturnValue, Server_SetSelectedCharacterId_Function, (uintptr_t)&Parameters);
            
            // Pokaż powiadomienie o sukcesie
            NSString *message = [NSString stringWithFormat:@"Attempting to change to ID: %d", characterId];
            NSLog(@"[DBD Character Change] %@", message);
            ShowAlert(@"Character Change", message);
            
        } @catch (NSException *e) {
            NSString *errorMsg = [NSString stringWithFormat:@"Failed to change character: %@", e.reason];
            NSLog(@"[DBD Character Change [NFramework] --> ] %@", errorMsg);
            ShowAlert(@"[NFramework] --> ", errorMsg);
        }
        
    } @catch (NSException *e) {
        NSString *errorMsg = [NSString stringWithFormat:@"Critical error: %@", e.reason];
        NSLog(@"[DBD Critical [NFramework] --> ] %@", errorMsg);
        ShowAlert(@"Critical [NFramework] --> ", errorMsg);
    }
}

// Dodaj deklarację funkcji DrawKillerESP
// extern void DrawKillerESP(void);
// extern void DrawGeneratorESP(void);
// extern void DrawTotemESP(void);
// extern void DrawChestESP(void);
// extern void DrawGateESP(void);
// extern void DrawHatchESP(void);
// extern void DrawSurvivorESP(void);

// Dodatkowe pomocnicze funkcje
void SetPlayerState(int state) {
    if (!LocalPlayer) return;
    
    static uintptr_t Server_SetPlayerGameState_Function = FindObject(@"Server_SetPlayerGameState");
    if (Server_SetPlayerGameState_Function) {
        struct {
            int32_t gameState;
        } Parameters;
        Parameters.gameState = state;
        ProcessEvent(LocalPlayer, Server_SetPlayerGameState_Function, (uintptr_t)&Parameters);
    }
}

void KillPlayer() {
    if (!LocalPlayer) return;
    
    static uintptr_t Server_Kill_Function = FindObject(@"Server_Kill");
    if (Server_Kill_Function) {
        ProcessEvent(LocalPlayer, Server_Kill_Function, 0);
    }
}

// Dodaj te definicje na początku pliku, zaraz po importach
int ActorCount = 0;
uintptr_t ActorArray = 0;

// Dodaj tę funkcję gdzieś w pliku, przed UpdatePointersLoop
void GetActorPos(uintptr_t Actor, Vector3* OutPosition) {
    if (!Actor || !OutPosition) return;
    
    uintptr_t RootComponent = GetRootComponent(Actor);
    if (RootComponent) {
        *OutPosition = GetActorPosition(RootComponent);
    }
}

