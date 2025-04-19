#import "ESPView.h"
#import "Magicolors/ColorsHandler.h"
#import "NFToggles.h"
#import <mach/mach.h>
#import "Cheat/Pointers.h"
#import "Cheat/SDK.h"
#import "Icons/NFIcons.h"
#import <vector>
#import <algorithm>
#import "Magicolors/ColorPicker.h"

extern UIView *menuView;
extern CGColorRef RightGradient;
extern CGColorRef blackColor;
extern CGColorRef LeftGradient;
extern NSString *currentFont;
extern uintptr_t BaseAddress;
extern uintptr_t LocalPlayer;
extern uintptr_t OwningGameInstance;
extern bool IsKiller;

typedef enum {
    Cleansed = 0,
    Dull = 1,
    Hex = 2,
    Boon = 3,
    ETotemState_MAX = 4
} ETotemState;

typedef struct {
    float angle;
    float length;
} ArcInfo;

// Dodaj na początku pliku, przed @implementation
struct FString {
    wchar_t* Data;
    int32_t Count;
    int32_t Max;
};

// Dodaj na początku pliku, przed strukturą FString
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

@interface ESPView ()
@property (nonatomic, strong, readwrite) UIView *espOverlayView;
@property (nonatomic, strong) NSMutableDictionary *cachedColors;
@property (nonatomic, strong) NSMutableDictionary *cachedFonts;
@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, assign) CGPoint lastScreenCenter;
@property (nonatomic, assign) ViewMatrix lastViewMatrix;
@end

@implementation ESPView

+ (void)createESPView {
    CGFloat menuWidth = 620;
    CGFloat labelHeight = 25;
    CGFloat switchAreaHeight = 210;
    CGFloat scrollViewWidth = (menuWidth - 40) / 3; // Width for each scroll view
    CGFloat scrollViewSpacing = 10; // Spacing between scroll views

    // Main ESP scroll view
    UIScrollView *espScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.666667, 67.3333 + labelHeight + 5, menuWidth, switchAreaHeight)];
    espScrollView.backgroundColor = [UIColor clearColor];
    espScrollView.userInteractionEnabled = YES;
    espScrollView.scrollEnabled = YES;
    espScrollView.showsVerticalScrollIndicator = YES;
    espScrollView.bounces = YES;
    espScrollView.hidden = YES;
    espScrollView.tag = 22;
    [menuView addSubview:espScrollView];

    // ESP Label
    UILabel *espLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.666667, 67.3333, menuWidth, labelHeight)];
    espLabel.text = @"Extra Sensory Perception";
    espLabel.textColor = [UIColor whiteColor];
    espLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:16];
    espLabel.textAlignment = NSTextAlignmentCenter;
    espLabel.hidden = YES;
    espLabel.tag = 23;
    [menuView addSubview:espLabel];

    // Calculate x positions for scroll views
    CGFloat killerX = 10;
    CGFloat survivorX = killerX + scrollViewWidth + scrollViewSpacing;
    CGFloat objectsX = survivorX + scrollViewWidth + scrollViewSpacing;

    // Section Labels
    UILabel *killerLabel = [[UILabel alloc] initWithFrame:CGRectMake(killerX, 0, scrollViewWidth, 30)];
    killerLabel.text = @"Killer ESP";
    killerLabel.textColor = [UIColor whiteColor];
    killerLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:14];
    killerLabel.textAlignment = NSTextAlignmentCenter;
    [espScrollView addSubview:killerLabel];

    // Killer Segmented Control
    UISegmentedControl *killerSegment = [[UISegmentedControl alloc] initWithItems:@[@"Type", @"Colors", @"Size"]];
    killerSegment.frame = CGRectMake(killerX, 35, scrollViewWidth, 30);
    killerSegment.selectedSegmentIndex = 0;
    [killerSegment addTarget:self action:@selector(killerSegmentChanged:) forControlEvents:UIControlEventValueChanged];
    [espScrollView addSubview:killerSegment];

    UILabel *survivorLabel = [[UILabel alloc] initWithFrame:CGRectMake(survivorX, 0, scrollViewWidth, 30)];
    survivorLabel.text = @"Survivor ESP";
    survivorLabel.textColor = [UIColor whiteColor];
    survivorLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:14];
    survivorLabel.textAlignment = NSTextAlignmentCenter;
    [espScrollView addSubview:survivorLabel];

    // Survivor Segmented Control
    UISegmentedControl *survivorSegment = [[UISegmentedControl alloc] initWithItems:@[@"Type", @"Colors", @"Size"]];
    survivorSegment.frame = CGRectMake(survivorX, 35, scrollViewWidth, 30);
    survivorSegment.selectedSegmentIndex = 0;
    [survivorSegment addTarget:self action:@selector(survivorSegmentChanged:) forControlEvents:UIControlEventValueChanged];
    [espScrollView addSubview:survivorSegment];

    UILabel *objectsLabel = [[UILabel alloc] initWithFrame:CGRectMake(objectsX, 0, scrollViewWidth, 30)];
    objectsLabel.text = @"Objects ESP";
    objectsLabel.textColor = [UIColor whiteColor];
    objectsLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:14];
    objectsLabel.textAlignment = NSTextAlignmentCenter;
    [espScrollView addSubview:objectsLabel];

    // Objects Segmented Control
    UISegmentedControl *objectsSegment = [[UISegmentedControl alloc] initWithItems:@[@"Type", @"Colors", @"Size"]];
    objectsSegment.frame = CGRectMake(objectsX, 35, scrollViewWidth, 30);
    objectsSegment.selectedSegmentIndex = 0;
    [objectsSegment addTarget:self action:@selector(objectsSegmentChanged:) forControlEvents:UIControlEventValueChanged];
    [espScrollView addSubview:objectsSegment];

    // Create Killer ESP scroll view
    UIScrollView *killerScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(killerX, 75, scrollViewWidth, switchAreaHeight - 85)];
    killerScrollView.tag = 24;
    [espScrollView addSubview:killerScrollView];
    
    // Create Survivor ESP scroll view  
    UIScrollView *survivorScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(survivorX, 75, scrollViewWidth, switchAreaHeight - 85)];
    survivorScrollView.tag = 25;
    [espScrollView addSubview:survivorScrollView];

    // Create Objects ESP scroll view
    UIScrollView *objectsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(objectsX, 75, scrollViewWidth, switchAreaHeight - 85)];
    objectsScrollView.tag = 26;
    [espScrollView addSubview:objectsScrollView];

    // Initialize with Type options
    [self updateKillerOptions:killerScrollView forSegment:0];
    [self updateSurvivorOptions:survivorScrollView forSegment:0];
    [self updateObjectsOptions:objectsScrollView forSegment:0];

    // Inicjalizacja domyślnych wartości ESP
    ESPView *sharedInstance = [ESPView sharedInstance];
    sharedInstance.killerESPType = 0;
    sharedInstance.survivorESPType = 0;
    sharedInstance.objectESPType = 0;
    
    sharedInstance.killerESPColor = [UIColor redColor];
    sharedInstance.survivorESPColor = [UIColor greenColor];
    sharedInstance.generatorESPColor = [UIColor colorWithRed:64.0/255.0 green:112.0/255.0 blue:255.0/255.0 alpha:1.0];
    sharedInstance.totemESPColor = [UIColor colorWithRed:142.0/255.0 green:191.0/255.0 blue:44.0/255.0 alpha:1.0];
    sharedInstance.chestESPColor = [UIColor brownColor];
    sharedInstance.gateESPColor = [UIColor colorWithRed:252.0/255.0 green:82.0/255.0 blue:255.0/255.0 alpha:1.0];
    sharedInstance.hatchESPColor = [UIColor colorWithRed:252.0/255.0 green:177.0/255.0 blue:3.0/255.0 alpha:1.0];
    sharedInstance.killerESPSize = 50.0;
    sharedInstance.survivorESPSize = 40.0;
    sharedInstance.objectESPSize = 30.0;
    
    sharedInstance.showKiller = YES;
    sharedInstance.showSurvivors = YES;
    sharedInstance.showGenerators = YES;
    sharedInstance.showTotems = YES;
    sharedInstance.showChests = YES;
    sharedInstance.showGates = YES;
    sharedInstance.showHatch = YES;
    
    sharedInstance.killerLineWidth = 2.0;
    sharedInstance.survivorLineWidth = 2.0;
    sharedInstance.objectLineWidth = 2.0;
    
    // Tylko text ESP
    sharedInstance.showText = YES;
    sharedInstance.textColor = [UIColor whiteColor];
    sharedInstance.textSize = 6.0;
}

+ (void)killerSegmentChanged:(UISegmentedControl *)sender {
    UIScrollView *killerScrollView = [menuView viewWithTag:24];
    [self updateKillerOptions:killerScrollView forSegment:sender.selectedSegmentIndex];
}


+ (void)survivorSegmentChanged:(UISegmentedControl *)sender {
    UIScrollView *survivorScrollView = [menuView viewWithTag:25];
    [self updateSurvivorOptions:survivorScrollView forSegment:sender.selectedSegmentIndex];
}



+ (void)objectsSegmentChanged:(UISegmentedControl *)sender {
    UIScrollView *objectsScrollView = [menuView viewWithTag:26];
    [self updateObjectsOptions:objectsScrollView forSegment:sender.selectedSegmentIndex];
}






+ (void)updateKillerOptions:(UIScrollView *)scrollView forSegment:(NSInteger)segment {
    // Remove existing options
    for (UIView *view in scrollView.subviews) {
        [view removeFromSuperview];
    }
    
    NSDictionary *options;
    ESPView *sharedInstance = [ESPView sharedInstance];
    
    switch(segment) {
        case 0: // Type
            options = @{
                @"Text": @"text.bubble"
            };
            break;
        case 1: // Colors
            options = @{
                @"Text Color": @"text.bubble.fill"
            };
            break;
        case 2: // Size
            options = @{
                @"Text Size": @"textformat"
            };
            break;
    }
    [self addSwitchesForOptions:options toView:scrollView withType:segment];
}

+ (void)updateSurvivorOptions:(UIScrollView *)scrollView forSegment:(NSInteger)segment {
    // Taka sama konfiguracja jak dla Killer
    [self updateKillerOptions:scrollView forSegment:segment];
}

+ (void)updateObjectsOptions:(UIScrollView *)scrollView forSegment:(NSInteger)segment {
    // Taka sama konfiguracja jak dla Killer
    [self updateKillerOptions:scrollView forSegment:segment];
}




+ (void)espSegmentChanged:(UISegmentedControl *)sender {
    UIScrollView *espScrollView = [menuView viewWithTag:22];
    UIView *contentView = [espScrollView viewWithTag:28];
    
    UIView *survivorView = [contentView viewWithTag:24];
    UIView *killerView = [contentView viewWithTag:25];
    UIView *objectsView = [contentView viewWithTag:26];
    
    survivorView.hidden = YES;
    killerView.hidden = YES;
    objectsView.hidden = YES;
    
    switch (sender.selectedSegmentIndex) {
        case 0:
            survivorView.hidden = NO;
            break;
        case 1:
            killerView.hidden = NO;
            break;
        case 2:
            objectsView.hidden = NO;
            break;
    }
}



+ (void)hideAllESPViews:(UIScrollView *)scrollView {
    [[scrollView viewWithTag:24] setHidden:YES];
    [[scrollView viewWithTag:25] setHidden:YES]; 
    [[scrollView viewWithTag:26] setHidden:YES];
}



+ (void)showSurvivorESP:(UIScrollView *)scrollView {
    [[scrollView viewWithTag:24] setHidden:NO];
}



+ (void)showKillerESP:(UIScrollView *)scrollView {
    [[scrollView viewWithTag:25] setHidden:NO];
}

+ (void)showObjectsESP:(UIScrollView *)scrollView {
    [[scrollView viewWithTag:26] setHidden:NO];
}

+ (void)addSwitchesForOptions:(NSDictionary *)options toView:(UIScrollView *)scrollView withType:(NSInteger)type {
    CGFloat switchSpacing = 40;
    CGFloat switchStartY = 5;
    CGFloat switchWidth = scrollView.frame.size.width - 20;
    
    __block CGFloat currentY = switchStartY;
    [options enumerateKeysAndObjectsUsingBlock:^(NSString *title, NSString *symbol, BOOL *stop) {
        // Create container for icon and text with gradient background
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(10, currentY, switchWidth, 30)];
        containerView.layer.cornerRadius = 5;
        containerView.clipsToBounds = YES;

        // Create main gradient layer for background
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

        // Add gradients for top and bottom lines
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
        
        ESPView *sharedInstance = [ESPView sharedInstance];
        
        if (type == 0) { // Type
            UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(switchWidth - 55, 0, 51, 31)];
            toggle.onTintColor = [UIColor systemBlueColor];
            
            if ([title isEqualToString:@"Text"]) {
                toggle.on = sharedInstance.showText;
                [toggle addTarget:self action:@selector(textToggleChanged:) forControlEvents:UIControlEventValueChanged];
            }
            
            [containerView addSubview:toggle];
        } else if (type == 1) { // Colors
            UIButton *colorButton = [UIButton buttonWithType:UIButtonTypeSystem];
            colorButton.frame = CGRectMake(switchWidth - 35, 0, 30, 30);
            [colorButton setImage:[UIImage systemImageNamed:@"paintbrush.fill"] forState:UIControlStateNormal];
            colorButton.tintColor = [UIColor whiteColor];
            
            if ([title isEqualToString:@"Text Color"]) {
                [colorButton addTarget:self action:@selector(showTextColorPicker:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            [containerView addSubview:colorButton];
        } else if (type == 2) { // Size
            UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(switchWidth - 100, 5, 90, 20)];
            slider.minimumValue = 8.0;
            slider.maximumValue = 20.0;
            
            if ([title isEqualToString:@"Text Size"]) {
                slider.value = sharedInstance.textSize;
                [slider addTarget:self action:@selector(textSizeChanged:) forControlEvents:UIControlEventValueChanged];
            }
            
            slider.tintColor = [UIColor colorWithRed:255.0/255.0 green:23.0/255.0 blue:65.0/255.0 alpha:1.0];
            [containerView addSubview:slider];
        }
        
        [scrollView addSubview:containerView];
        currentY += switchSpacing;
    }];
    
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, currentY);
}

+ (instancetype)sharedInstance {
    static ESPView *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        _cachedColors = [NSMutableDictionary new];
        _cachedFonts = [NSMutableDictionary new];
        [self setupESPOverlayView];
        [self checkGameState];
    }
    return self;
}

- (void)setupESPOverlayView {
    if (!self.espOverlayView) {
        self.espOverlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.espOverlayView.userInteractionEnabled = NO;
        self.espOverlayView.backgroundColor = [UIColor clearColor];
        
        // Dodaj do głównego okna
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:self.espOverlayView];
    }
}

- (void)toggleESP {
    self.espOverlayView.hidden = !self.espOverlayView.hidden;
}

- (void)clearESP {
    // Usuń wszystkie podwidoki i warstwy za jednym razem
    [self.espOverlayView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.espOverlayView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
}

- (void)setupCircleLayer {
    if (!self.circleLayer) {
        self.circleLayer = [CAShapeLayer layer];
        self.circleLayer.strokeColor = [UIColor clearColor].CGColor;
        self.circleLayer.fillColor = nil;
        self.circleLayer.lineWidth = 1.0;
        [self.espOverlayView.layer addSublayer:self.circleLayer];
    }
    
    CGPoint screenCenter = CGPointMake(self.espOverlayView.bounds.size.width / 2, 
                                     self.espOverlayView.bounds.size.height / 2);
    
    // Aktualizuj ścieżkę tylko jeśli środek ekranu się zmienił
    if (!CGPointEqualToPoint(screenCenter, self.lastScreenCenter)) {
        CGFloat circleRadius = 70.0;
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:screenCenter
                                                                 radius:circleRadius
                                                             startAngle:0
                                                               endAngle:M_PI * 2
                                                              clockwise:YES];
        self.circleLayer.path = circlePath.CGPath;
        self.lastScreenCenter = screenCenter;
    }
}

- (UIColor *)getCachedColorWithKey:(NSString *)key defaultColor:(UIColor *)defaultColor {
    UIColor *color = self.cachedColors[key];
    if (!color) {
        color = defaultColor;
        self.cachedColors[key] = color;
    }
    return color;
}

- (UIFont *)getCachedFontWithSize:(CGFloat)size {
    NSString *key = [NSString stringWithFormat:@"%.1f", size];
    UIFont *font = self.cachedFonts[key];
    if (!font) {
        font = [UIFont systemFontOfSize:size];
        self.cachedFonts[key] = font;
    }
    return font;
}

- (UILabel *)createLabelWithText:(NSString *)text 
                           font:(UIFont *)font 
                          color:(UIColor *)color 
                      position:(CGPoint)position 
                       padding:(CGFloat)padding {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = font;
    label.textColor = color;
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    [label sizeToFit];
    
    label.frame = CGRectMake(
        position.x - label.frame.size.width/2,
        position.y,
        label.frame.size.width + padding,
        label.frame.size.height
    );
    
    label.clipsToBounds = YES;
    return label;
}

- (CAShapeLayer *)createArcLayerWithCenter:(CGPoint)center 
                                  radius:(CGFloat)radius 
                              startAngle:(CGFloat)startAngle 
                                endAngle:(CGFloat)endAngle 
                                  color:(UIColor *)color 
                              lineWidth:(CGFloat)lineWidth {
    UIBezierPath *arcPath = [UIBezierPath bezierPathWithArcCenter:center
                                                          radius:radius
                                                      startAngle:startAngle
                                                        endAngle:endAngle
                                                       clockwise:YES];
    
    CAShapeLayer *arcLayer = [CAShapeLayer layer];
    arcLayer.path = arcPath.CGPath;
    arcLayer.strokeColor = color.CGColor;
    arcLayer.fillColor = nil;
    arcLayer.lineWidth = lineWidth;
    arcLayer.lineCap = kCALineCapRound;
    
    return arcLayer;
}

- (void)updateESP {
    // Sprawd� czy LocalPlayer istnieje
    if (!LocalPlayer) {
        [self clearESP];
        return;
    }

    [self setupCircleLayer];
    
    // Buforuj często używane wartości
    uintptr_t World = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
    if (!World) return;
    
    uintptr_t GameState = *(uintptr_t*)(World + Offsets::SDK::UWorldToGameState);
    if (!GameState) return;
    
    uintptr_t LocalPlayerCameraManager = GetLocalPlayerCameraManager();
    if (!LocalPlayerCameraManager) return;
    
    // Buforuj parametry kamery
    uintptr_t LocalPlayerCameraPOV = LocalPlayerCameraManager + Offsets::SDK::APlayerCameraManagerToCameraCachePrivate + Offsets::SDK::FCameraCacheEntryToPOV;
    float LocalPlayerCameraFOV = *(float*)(LocalPlayerCameraPOV + Offsets::SDK::FMinimalViewInfoToFOV);
    Vector3 LocalPlayerCameraLocation = *(Vector3*)(LocalPlayerCameraPOV + Offsets::SDK::FMinimalViewInfoToLocation);
    Vector3 LocalPlayerCameraRotation = *(Vector3*)(LocalPlayerCameraPOV + Offsets::SDK::FMinimalViewInfoToRotation);
    
    // Oblicz macierz widoku tylko raz
    ViewMatrix viewMatrix = CreateViewMatrix(LocalPlayerCameraRotation);
    
    // Użyj dispatch_apply dla równoległego przetwarzania
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, queue, ^{
        [self drawGeneratorESP];
    });
    
    dispatch_group_async(group, queue, ^{
        [self drawTotemESP];
    });
    
    dispatch_group_async(group, queue, ^{
        [self drawChestESP];
    });
    
    dispatch_group_async(group, queue, ^{
        [self drawGateESP];
    });
    
    dispatch_group_async(group, queue, ^{
        [self drawHatchESP];
    });
    
    dispatch_group_async(group, queue, ^{
        [self drawSurvivorESP];
    });
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    // Killer ESP zawsze na końcu
    [self drawKillerESP];
}

- (void)drawKillerESP {
    if (!self.showKiller || !self.showText || IsKiller) return;
    
    uintptr_t World = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
    if (!World) return;
    
    uintptr_t GameState = *(uintptr_t*)(World + Offsets::SDK::UWorldToGameState);
    if (!GameState) return;

    uintptr_t LocalPlayerCameraManager = GetLocalPlayerCameraManager();
    if (!LocalPlayerCameraManager) return;

    uintptr_t LocalPlayerCameraPOV = LocalPlayerCameraManager + Offsets::SDK::APlayerCameraManagerToCameraCachePrivate + Offsets::SDK::FCameraCacheEntryToPOV;
    float LocalPlayerCameraFOV = *(float*)(LocalPlayerCameraPOV + Offsets::SDK::FMinimalViewInfoToFOV);
    Vector3 LocalPlayerCameraLocation = *(Vector3*)(LocalPlayerCameraPOV + Offsets::SDK::FMinimalViewInfoToLocation);
    Vector3 LocalPlayerCameraRotation = *(Vector3*)(LocalPlayerCameraPOV + Offsets::SDK::FMinimalViewInfoToRotation);
    ViewMatrix viewMatrix = CreateViewMatrix(LocalPlayerCameraRotation);

    // Dodaj okrąg na środku ekranu dla killera
    CGPoint screenCenter = CGPointMake(self.espOverlayView.bounds.size.width / 2, 
                                     self.espOverlayView.bounds.size.height / 2);
    CGFloat circleRadius = 70.0; // Taki sam jak dla survivors
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:screenCenter
                                                             radius:circleRadius
                                                         startAngle:0
                                                           endAngle:M_PI * 2
                                                          clockwise:YES];
    
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.path = circlePath.CGPath;
    circleLayer.strokeColor = [UIColor clearColor].CGColor;
    circleLayer.fillColor = nil;
    circleLayer.lineWidth = 1.0;
    [self.espOverlayView.layer addSublayer:circleLayer];

    uintptr_t Slasher = *(uintptr_t*)(GameState + Offsets::SDK::ADBDGameStateToSlasher);
    if (Slasher) {
        if (Slasher == LocalPlayer) {
            IsKiller = true;
            return;
        }

        NSString* KillerName = GetNameFromFName(*(int32_t*)(Slasher + Offsets::Special::UObjectToFNameOffset));
        if (!KillerName) return;

        NSString *characterName = nil;
        
        // Use a dictionary for killer name mapping
        static NSDictionary *killerNames = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            killerNames = @{
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
        });

        characterName = killerNames[KillerName] ?: @"Unknown Killer";

        uintptr_t RootComponent = GetRootComponent(Slasher);
        if (!RootComponent) return;

        Vector3 KillerPosition = GetActorPosition(RootComponent);
        CGPoint KillerScreenPosition;
        
        if (W2S(KillerScreenPosition, KillerPosition, LocalPlayerCameraLocation, LocalPlayerCameraFOV, viewMatrix)) {
            float dx = KillerPosition.X - LocalPlayerCameraLocation.X;
            float dy = KillerPosition.Y - LocalPlayerCameraLocation.Y;
            float dz = KillerPosition.Z - LocalPlayerCameraLocation.Z;
            float distance = sqrt(dx*dx + dy*dy + dz*dz) * 0.01f;

            // Oblicz kierunek dla łuku killera
            float screenDX = -(screenCenter.x - KillerScreenPosition.x);
            float screenDY = -(screenCenter.y - KillerScreenPosition.y);
            float length = sqrt(screenDX * screenDX + screenDY * screenDY);
            
            if (length > 0) {
                screenDX /= length;
                screenDY /= length;
            }

            float baseAngle = atan2(screenDY, screenDX);
            if (baseAngle < 0) {
                baseAngle += 2 * M_PI;
            }

            CGFloat arcLength = (M_PI / 8) * 0.9; // O 10% krótszy niż survivor
            CGFloat barWidth = 3.0; // Taki sam jak dla survivors

            // Rysuj główny łuk killera
            float startAngle = baseAngle - arcLength/2;
            float endAngle = baseAngle + arcLength/2;

            UIBezierPath *arcPath = [UIBezierPath bezierPathWithArcCenter:screenCenter
                                                                  radius:circleRadius
                                                              startAngle:startAngle
                                                                endAngle:endAngle
                                                               clockwise:YES];

            CAShapeLayer *arcLayer = [CAShapeLayer layer];
            arcLayer.path = arcPath.CGPath;
            arcLayer.strokeColor = [UIColor redColor].CGColor;
            arcLayer.fillColor = nil;
            arcLayer.lineWidth = barWidth;
            arcLayer.lineCap = kCALineCapRound;
            arcLayer.shadowColor = [UIColor redColor].CGColor;
            arcLayer.shadowRadius = 4.0;
            arcLayer.shadowOpacity = 0.8;
            arcLayer.shadowOffset = CGSizeZero;
            arcLayer.zPosition = 999; // Wysoka wartość, aby być nad wszystkimi innymi warstwami
            [self.espOverlayView.layer addSublayer:arcLayer];

            // Parametry drugiego, cieńszego łuku dla killera
            CGFloat thinBarWidth = 1.0;   // Taki sam jak dla survivors
            CGFloat thinBarOffset = 2.0;  // Taki sam jak dla survivors
            CGFloat thinArcRadius = circleRadius - barWidth/2 - thinBarOffset - thinBarWidth/2;

            UIBezierPath *thinArcPath = [UIBezierPath bezierPathWithArcCenter:screenCenter
                                                                      radius:thinArcRadius
                                                                  startAngle:startAngle
                                                                    endAngle:endAngle
                                                                   clockwise:YES];

            CAShapeLayer *thinArcLayer = [CAShapeLayer layer];
            thinArcLayer.path = thinArcPath.CGPath;
            thinArcLayer.strokeColor = [UIColor redColor].CGColor;
            thinArcLayer.fillColor = nil;
            thinArcLayer.lineWidth = thinBarWidth;
            thinArcLayer.lineCap = kCALineCapRound;
            thinArcLayer.shadowColor = [UIColor redColor].CGColor;
            thinArcLayer.shadowRadius = 3.0;
            thinArcLayer.shadowOpacity = 0.6;
            thinArcLayer.shadowOffset = CGSizeZero;
            thinArcLayer.zPosition = 999; // Ta sama wysoka wartość
            [self.espOverlayView.layer addSublayer:thinArcLayer];

            // Pobierz PlayerState i nazwę gracza
            uintptr_t PlayerState = *(uintptr_t*)(Slasher + 0x250); // Offset 0x250 z APawn::PlayerState
            NSString *playerName = @"Unknown";

            if (PlayerState) {
                FString* namePtr = (FString*)(PlayerState + 0x310);
                if (namePtr && IsBadReadPtr(namePtr, sizeof(FString)) == 0) {
                    FString name = *namePtr;
                    if (name.Data && name.Count > 0 && IsBadReadPtr(name.Data, name.Count * sizeof(wchar_t)) == 0) {
                        playerName = [[NSString alloc] initWithBytes:name.Data
                                                            length:name.Count * 2
                                                          encoding:NSUTF8StringEncoding];
                        if (!playerName) {
                            playerName = @"Unknown";
                        }
                    }
                }
            }

            // Label z nazwą postaci
            UILabel *nameLabel = [[UILabel alloc] init];
            nameLabel.text = characterName;
            nameLabel.font = [UIFont systemFontOfSize:self.textSize];
            nameLabel.textColor = [UIColor redColor];
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.textAlignment = NSTextAlignmentCenter;
            [nameLabel sizeToFit];

            CGFloat padding = 4;
            nameLabel.frame = CGRectMake(
                KillerScreenPosition.x - nameLabel.frame.size.width/2,
                KillerScreenPosition.y - nameLabel.frame.size.height/2,
                nameLabel.frame.size.width + padding,
                nameLabel.frame.size.height
            );

            // Label z nazwą gracza
            UILabel *playerNameLabel = [[UILabel alloc] init];
            playerNameLabel.text = playerName;
            playerNameLabel.font = [UIFont systemFontOfSize:self.textSize - 2];
            playerNameLabel.textColor = [UIColor redColor];
            playerNameLabel.backgroundColor = [UIColor clearColor];
            playerNameLabel.textAlignment = NSTextAlignmentCenter;
            [playerNameLabel sizeToFit];

            playerNameLabel.frame = CGRectMake(
                KillerScreenPosition.x - playerNameLabel.frame.size.width/2,
                KillerScreenPosition.y + nameLabel.frame.size.height/2,
                playerNameLabel.frame.size.width + padding,
                playerNameLabel.frame.size.height
            );

            nameLabel.clipsToBounds = YES;
            playerNameLabel.clipsToBounds = YES;
            [self.espOverlayView addSubview:nameLabel];
            [self.espOverlayView addSubview:playerNameLabel];

            // Label z dystansem (przesuń w dół o wysokość obu labeli)
            UILabel *distanceLabel = [[UILabel alloc] init];
            distanceLabel.text = [NSString stringWithFormat:@"%.1fm", distance];
            distanceLabel.font = [UIFont systemFontOfSize:self.textSize - 2];
            distanceLabel.textColor = [UIColor redColor];
            distanceLabel.backgroundColor = [UIColor clearColor];
            distanceLabel.textAlignment = NSTextAlignmentCenter;
            [distanceLabel sizeToFit];
            
            distanceLabel.frame = CGRectMake(
                KillerScreenPosition.x - distanceLabel.frame.size.width/2,
                KillerScreenPosition.y + nameLabel.frame.size.height + playerNameLabel.frame.size.height,
                distanceLabel.frame.size.width + padding,
                distanceLabel.frame.size.height
            );
            
            distanceLabel.clipsToBounds = YES;
            [self.espOverlayView addSubview:distanceLabel];
        }
    }
}

- (void)drawGeneratorESP {
    if (!self.showGenerators || !self.showText) return;
    
    uintptr_t World = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
    if (!World) return;
    
    uintptr_t GameState = *(uintptr_t*)(World + Offsets::SDK::UWorldToGameState);
    if (!GameState) return;

    uintptr_t LocalPlayerCameraManager = GetLocalPlayerCameraManager();
    if (!LocalPlayerCameraManager) return;

    uintptr_t LocalPlayerCameraPOV = LocalPlayerCameraManager + Offsets::SDK::APlayerCameraManagerToCameraCachePrivate + Offsets::SDK::FCameraCacheEntryToPOV;
    float LocalPlayerCameraFOV = *(float*)(LocalPlayerCameraPOV + Offsets::SDK::FMinimalViewInfoToFOV);
    Vector3 LocalPlayerCameraLocation = *(Vector3*)(LocalPlayerCameraPOV + Offsets::SDK::FMinimalViewInfoToLocation);
    Vector3 LocalPlayerCameraRotation = *(Vector3*)(LocalPlayerCameraPOV + Offsets::SDK::FMinimalViewInfoToRotation);
    ViewMatrix viewMatrix = CreateViewMatrix(LocalPlayerCameraRotation);

    uintptr_t _generators = *(uintptr_t*)(GameState + Offsets::SDK::ADBDGameStateTo_generators);
    int32_t _generatorsCount = *(int32_t*)(GameState + Offsets::SDK::ADBDGameStateTo_generators + Offsets::Special::TArrayToCount);
    
    for (int g = 0; g < _generatorsCount && _generators != 0; g++) {
        uintptr_t Generator = *(uintptr_t*)(_generators + g * Offsets::Special::PointerSize);
        if (!Generator) continue;
        
        uintptr_t RootComponent = GetRootComponent(Generator);
        if (!RootComponent) continue;

        Vector3 GeneratorPosition = GetActorPosition(RootComponent);
        CGPoint GeneratorScreenPosition;
        
        float percentComplete = *(float*)(Generator + 0x378); // Offset NativePercentComplete
        bool isRepaired = *(bool*)(Generator + 0x369); // IsRepaired offset
        
        if (W2S(GeneratorScreenPosition, GeneratorPosition, LocalPlayerCameraLocation, LocalPlayerCameraFOV, viewMatrix)) {
            // Oblicz odległość
            float dx = GeneratorPosition.X - LocalPlayerCameraLocation.X;
            float dy = GeneratorPosition.Y - LocalPlayerCameraLocation.Y;
            float dz = GeneratorPosition.Z - LocalPlayerCameraLocation.Z;
            float distance = sqrt(dx*dx + dy*dy + dz*dz) * 0.01f;

            // Pobierz komponent uszkodzeń generatora
            uintptr_t generatorDamageComponent = *(uintptr_t*)(Generator + 0x400);
            bool isRegressing = false;
            
            if (generatorDamageComponent) {
                uintptr_t damageData = generatorDamageComponent + 0xe8;
                isRegressing = *(bool*)(damageData + 0x1);
            }

            // Zachowujemy oryginalny kolor i tekst dla generatora
            UIColor *genColor = [UIColor colorWithRed:64.0/255.0 green:112.0/255.0 blue:255.0/255.0 alpha:1.0];
            
            // Modyfikacja istniejącego kodu wyświetlania etykiety:
            UILabel *textLabel = [[UILabel alloc] init];
            textLabel.text = @"Generator";
            textLabel.font = [UIFont systemFontOfSize:self.textSize];
            textLabel.textColor = genColor;
            textLabel.backgroundColor = [UIColor clearColor];
            textLabel.textAlignment = NSTextAlignmentCenter;
            [textLabel sizeToFit];
            
            CGFloat padding = 4;
            textLabel.frame = CGRectMake(
                GeneratorScreenPosition.x - textLabel.frame.size.width/2,
                GeneratorScreenPosition.y - textLabel.frame.size.height/2,
                textLabel.frame.size.width + padding,
                textLabel.frame.size.height
            );
            
            textLabel.clipsToBounds = YES;
            [self.espOverlayView addSubview:textLabel];

            // Zamiast label z procentami, dodaj pasek postępu
            CGFloat progressBarWidth = textLabel.frame.size.width + padding;
            CGFloat progressBarHeight = 4.0;
            CGFloat cornerRadius = progressBarHeight / 2;
            
            // Rysuj pasek postępu tylko jeśli generator jest w trakcie naprawy (między 0% a 100%)
            if (percentComplete > 0.001f && percentComplete < 0.999f) {  // Dodajemy małą tolerancję
                // Tło paska postępu
                UIBezierPath *backgroundPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(
                    GeneratorScreenPosition.x - progressBarWidth/2,
                    GeneratorScreenPosition.y - textLabel.frame.size.height/2 + textLabel.frame.size.height,
                    progressBarWidth,
                    progressBarHeight
                ) cornerRadius:cornerRadius];
                
                CAShapeLayer *backgroundLayer = [CAShapeLayer layer];
                backgroundLayer.path = backgroundPath.CGPath;
                backgroundLayer.fillColor = [UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:0.7].CGColor;
                backgroundLayer.strokeColor = nil; // Usunięcie obramowania tła
                [self.espOverlayView.layer addSublayer:backgroundLayer];
                
                // Pasek postępu
                UIBezierPath *progressPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(
                    GeneratorScreenPosition.x - progressBarWidth/2,
                    GeneratorScreenPosition.y - textLabel.frame.size.height/2 + textLabel.frame.size.height,
                    MAX(progressBarHeight, progressBarWidth * percentComplete),
                    progressBarHeight
                ) cornerRadius:cornerRadius];
                
                CAShapeLayer *progressLayer = [CAShapeLayer layer];
                progressLayer.path = progressPath.CGPath;
                // Zmień kolor wypełnienia paska postępu na pomarańczowy jeśli generator się cofa
                progressLayer.fillColor = isRegressing ? [UIColor orangeColor].CGColor : genColor.CGColor;
                progressLayer.strokeColor = nil; // Usunięcie obramowania paska postępu
                progressLayer.shadowColor = genColor.CGColor;
                progressLayer.shadowRadius = 3.0;
                progressLayer.shadowOpacity = 0.5;
                progressLayer.shadowOffset = CGSizeZero;
                [self.espOverlayView.layer addSublayer:progressLayer];

                // Label z dystansem
                UILabel *distanceLabel = [[UILabel alloc] init];
                distanceLabel.text = [NSString stringWithFormat:@"%.1fm", distance];
                distanceLabel.font = [UIFont systemFontOfSize:self.textSize - 2];
                distanceLabel.textColor = genColor;
                distanceLabel.backgroundColor = [UIColor clearColor];
                distanceLabel.textAlignment = NSTextAlignmentCenter;
                [distanceLabel sizeToFit];
                
                distanceLabel.frame = CGRectMake(
                    GeneratorScreenPosition.x - distanceLabel.frame.size.width/2,
                    GeneratorScreenPosition.y - textLabel.frame.size.height/2 + textLabel.frame.size.height + progressBarHeight,
                    distanceLabel.frame.size.width + padding,
                    distanceLabel.frame.size.height
                );
                
                distanceLabel.clipsToBounds = YES;
                [self.espOverlayView addSubview:distanceLabel];
            } else {
                // Gdy nie ma progressbar
                UILabel *distanceLabel = [[UILabel alloc] init];
                distanceLabel.text = [NSString stringWithFormat:@"%.1fm", distance];
                distanceLabel.font = [UIFont systemFontOfSize:self.textSize - 2];
                distanceLabel.textColor = genColor;
                distanceLabel.backgroundColor = [UIColor clearColor];
                distanceLabel.textAlignment = NSTextAlignmentCenter;
                [distanceLabel sizeToFit];
                
                distanceLabel.frame = CGRectMake(
                    GeneratorScreenPosition.x - distanceLabel.frame.size.width/2,
                    GeneratorScreenPosition.y - textLabel.frame.size.height/2 + textLabel.frame.size.height,
                    distanceLabel.frame.size.width + padding,
                    distanceLabel.frame.size.height
                );
                
                distanceLabel.clipsToBounds = YES;
                [self.espOverlayView addSubview:distanceLabel];
            }
        }
    }
}

- (void)drawGeneratorLine:(CGPoint)position color:(UIColor *)color {
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(self.espOverlayView.bounds.size.width / 2, 0)];
    [linePath addLineToPoint:position];
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.path = linePath.CGPath;
    lineLayer.strokeColor = color.CGColor;
    lineLayer.lineWidth = self.objectLineWidth;
    lineLayer.fillColor = nil;
    
    [self.espOverlayView.layer addSublayer:lineLayer];
}

- (void)drawGeneratorBox:(CGPoint)position color:(UIColor *)color {
    CGFloat size = self.objectESPSize;
    UIBezierPath *boxPath = [UIBezierPath bezierPathWithRect:
        CGRectMake(position.x - size/2, position.y - size/2, size, size)];
    
    CAShapeLayer *boxLayer = [CAShapeLayer layer];
    boxLayer.path = boxPath.CGPath;
    boxLayer.strokeColor = color.CGColor;
    boxLayer.lineWidth = 1.0;
    boxLayer.fillColor = nil;
    
    [self.espOverlayView.layer addSublayer:boxLayer];
}

- (void)drawGeneratorFilled:(CGPoint)position color:(UIColor *)color {
    CGFloat size = self.objectESPSize;
    UIBezierPath *boxPath = [UIBezierPath bezierPathWithRect:
        CGRectMake(position.x - size/2, position.y - size/2, size, size)];
    
    CAShapeLayer *boxLayer = [CAShapeLayer layer];
    boxLayer.path = boxPath.CGPath;
    boxLayer.strokeColor = color.CGColor;
    boxLayer.lineWidth = 1.0;
    boxLayer.fillColor = [color colorWithAlphaComponent:0.3].CGColor;
    
    [self.espOverlayView.layer addSublayer:boxLayer];
}

- (void)drawGeneratorInfo:(CGPoint)position 
                distance:(float)distance 
          percentComplete:(float)percentComplete 
              isRepaired:(BOOL)isRepaired 
              isBlocked:(BOOL)isBlocked 
                  color:(UIColor *)color {
    
    // Label dystansu
    UILabel *distanceLabel = [[UILabel alloc] init];
    distanceLabel.text = [NSString stringWithFormat:@"%.1f m", distance * 0.01f];
    distanceLabel.font = [UIFont systemFontOfSize:10];
    distanceLabel.textColor = color;
    distanceLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    distanceLabel.textAlignment = NSTextAlignmentCenter;
    [distanceLabel sizeToFit];
    
    CGFloat padding = 4;
    distanceLabel.frame = CGRectMake(
        position.x - distanceLabel.frame.size.width/2,
        position.y + self.objectESPSize/2 + 5,
        distanceLabel.frame.size.width + padding,
        distanceLabel.frame.size.height
    );
    
    distanceLabel.layer.cornerRadius = distanceLabel.frame.size.height/2;
    distanceLabel.layer.borderWidth = 1.0;
    distanceLabel.layer.borderColor = color.CGColor;
    distanceLabel.clipsToBounds = YES;
    
    [self.espOverlayView addSubview:distanceLabel];
    
    // Label stanu
    NSMutableString *stateText = [NSMutableString new];
    [stateText appendFormat:@"%.0f%%", percentComplete];
    if (isRepaired) [stateText appendString:@" ✓"];
    if (isBlocked) [stateText appendString:@" ⛔"];
    
    UILabel *stateLabel = [[UILabel alloc] init];
    stateLabel.text = stateText;
    stateLabel.font = [UIFont systemFontOfSize:10];
    stateLabel.textColor = color;
    stateLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    stateLabel.textAlignment = NSTextAlignmentCenter;
    [stateLabel sizeToFit];
    
    stateLabel.frame = CGRectMake(
        position.x - stateLabel.frame.size.width/2,
        position.y + self.objectESPSize/2 + distanceLabel.frame.size.height + 8,
        stateLabel.frame.size.width + padding,
        stateLabel.frame.size.height
    );
    
    stateLabel.layer.cornerRadius = stateLabel.frame.size.height/2;
    stateLabel.layer.borderWidth = 1.0;
    stateLabel.layer.borderColor = color.CGColor;
    stateLabel.clipsToBounds = YES;
    
    [self.espOverlayView addSubview:stateLabel];
}

- (void)drawGeneratorCompass:(CGPoint)position color:(UIColor *)color {
    // Rysuj strzałkę wskazującą na generatora
    CGPoint center = CGPointMake(self.espOverlayView.bounds.size.width / 2, 
                                self.espOverlayView.bounds.size.height / 2);
    
    CGFloat angle = atan2(position.y - center.y, 
                         position.x - center.x);
    
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    [arrowPath moveToPoint:center];
    
    CGFloat arrowLength = 30.0;
    CGFloat arrowWidth = 10.0;
    
    CGPoint arrowTip = CGPointMake(center.x + cos(angle) * arrowLength,
                                  center.y + sin(angle) * arrowLength);
    
    [arrowPath addLineToPoint:arrowTip];
    
    CGPoint leftPoint = CGPointMake(arrowTip.x - cos(angle + M_PI_4) * arrowWidth,
                                   arrowTip.y - sin(angle + M_PI_4) * arrowWidth);
    CGPoint rightPoint = CGPointMake(arrowTip.x - cos(angle - M_PI_4) * arrowWidth,
                                    arrowTip.y - sin(angle - M_PI_4) * arrowWidth);
    
    [arrowPath addLineToPoint:leftPoint];
    [arrowPath moveToPoint:arrowTip];
    [arrowPath addLineToPoint:rightPoint];
    
    CAShapeLayer *arrowLayer = [CAShapeLayer layer];
    arrowLayer.path = arrowPath.CGPath;
    arrowLayer.strokeColor = color.CGColor;
    arrowLayer.lineWidth = 2.0;
    arrowLayer.fillColor = nil;
    
    [self.espOverlayView.layer addSublayer:arrowLayer];
}

- (void)drawTotemESP {
    if (!self.showTotems || !self.showText) return;
    
    uintptr_t World = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
    if (!World) return;
    
    uintptr_t GameState = *(uintptr_t*)(World + Offsets::SDK::UWorldToGameState);
    if (!GameState) return;

    uintptr_t LocalPlayerCameraManager = GetLocalPlayerCameraManager();
    if (!LocalPlayerCameraManager) return;

    uintptr_t LocalPlayerCameraPOV = LocalPlayerCameraManager + Offsets::SDK::APlayerCameraManagerToCameraCachePrivate + Offsets::SDK::FCameraCacheEntryToPOV;
    float LocalPlayerCameraFOV = *(float*)(LocalPlayerCameraPOV + Offsets::SDK::FMinimalViewInfoToFOV);
    Vector3 LocalPlayerCameraLocation = *(Vector3*)(LocalPlayerCameraPOV + Offsets::SDK::FMinimalViewInfoToLocation);
    Vector3 LocalPlayerCameraRotation = *(Vector3*)(LocalPlayerCameraPOV + Offsets::SDK::FMinimalViewInfoToRotation);
    ViewMatrix viewMatrix = CreateViewMatrix(LocalPlayerCameraRotation);

    uintptr_t _totems = *(uintptr_t*)(GameState + Offsets::SDK::ADBDGameStateTo_totems);
    int32_t _totemsCount = *(int32_t*)(GameState + Offsets::SDK::ADBDGameStateTo_totems + Offsets::Special::TArrayToCount);
    
    for (int g = 0; g < _totemsCount && _totems != 0; g++) {
        uintptr_t Totem = *(uintptr_t*)(_totems + g * Offsets::Special::PointerSize);
        if (!Totem) continue;
        
        // Pobierz stan totemu
        uint8_t totemStateRaw = *(uint8_t*)(Totem + 0x3a8); // _totemState offset z SDK
        ETotemState totemState = static_cast<ETotemState>(totemStateRaw);
        
        // Pobierz tablicę przypisanych perków
        uintptr_t boundPerksArray = *(uintptr_t*)(Totem + 0x398); // _boundPerks offset z SDK
        int32_t boundPerksCount = *(int32_t*)(Totem + 0x398 + Offsets::Special::TArrayToCount);
        
        // Domyślna nazwa dla totemu bez perków
        NSString *hexName = @"Dull";
        
        // Jeśli totem ma przypisane perki, pobierz nazwę pierwszego
        if (boundPerksCount > 0 && boundPerksArray != 0) {
            uintptr_t boundPerk = *(uintptr_t*)(boundPerksArray);
            if (boundPerk) {
                int32_t perkNameId = *(int32_t*)(boundPerk + Offsets::Special::UObjectToFNameOffset);
                NSString *perkName = GetNameFromFName(perkNameId);
                hexName = [self getHexNameForId:perkName withState:totemState];
            }
        }
        
        uintptr_t RootComponent = GetRootComponent(Totem);
        if (!RootComponent) continue;

        Vector3 TotemPosition = GetActorPosition(RootComponent);
        CGPoint TotemScreenPosition;
        
        if (W2S(TotemScreenPosition, TotemPosition, LocalPlayerCameraLocation, LocalPlayerCameraFOV, viewMatrix)) {
            float dx = TotemPosition.X - LocalPlayerCameraLocation.X;
            float dy = TotemPosition.Y - LocalPlayerCameraLocation.Y;
            float dz = TotemPosition.Z - LocalPlayerCameraLocation.Z;
            float distance = sqrt(dx*dx + dy*dy + dz*dz) * 0.01f;

            // Określ kolor na podstawie typu hexu
            UIColor *totemColor = [self getColorForHexName:hexName];

            // Label z nazwą hexu
            UILabel *hexLabel = [[UILabel alloc] init];
            hexLabel.text = hexName;
            hexLabel.font = [UIFont systemFontOfSize:self.textSize];
            hexLabel.textColor = totemColor;
            hexLabel.backgroundColor = [UIColor clearColor];
            hexLabel.textAlignment = NSTextAlignmentCenter;
            [hexLabel sizeToFit];
            
            // Label "Totem"
            UILabel *totemLabel = [[UILabel alloc] init];
            totemLabel.text = @"Totem";
            totemLabel.font = [UIFont systemFontOfSize:self.textSize];
            totemLabel.textColor = totemColor;  // Używamy tego samego koloru
            totemLabel.backgroundColor = [UIColor clearColor];
            totemLabel.textAlignment = NSTextAlignmentCenter;
            [totemLabel sizeToFit];
            
            CGFloat padding = 1;
            totemLabel.frame = CGRectMake(
                TotemScreenPosition.x - totemLabel.frame.size.width/2,
                TotemScreenPosition.y - totemLabel.frame.size.height - hexLabel.frame.size.height,
                totemLabel.frame.size.width + padding,
                totemLabel.frame.size.height
            );
            
            hexLabel.frame = CGRectMake(
                TotemScreenPosition.x - hexLabel.frame.size.width/2,
                TotemScreenPosition.y - hexLabel.frame.size.height,
                hexLabel.frame.size.width + padding,
                hexLabel.frame.size.height
            );
            
            totemLabel.clipsToBounds = YES;
            [self.espOverlayView addSubview:totemLabel];
            
            hexLabel.clipsToBounds = YES;
            [self.espOverlayView addSubview:hexLabel];

            // Label z dystansem (jak w survivor)
            UILabel *distanceLabel = [[UILabel alloc] init];
            distanceLabel.text = [NSString stringWithFormat:@"%.1fm", distance];
            distanceLabel.font = [UIFont systemFontOfSize:self.textSize - 2];
            distanceLabel.textColor = totemColor;
            distanceLabel.backgroundColor = [UIColor clearColor];
            distanceLabel.textAlignment = NSTextAlignmentCenter;
            [distanceLabel sizeToFit];
            
            distanceLabel.frame = CGRectMake(
                TotemScreenPosition.x - distanceLabel.frame.size.width/2,
                TotemScreenPosition.y,
                distanceLabel.frame.size.width + padding,
                distanceLabel.frame.size.height
            );
            
            distanceLabel.clipsToBounds = YES;
            [self.espOverlayView addSubview:distanceLabel];
        }
    }
}
- (NSString *)getHexNameForId:(NSString *)perkName withState:(ETotemState)state {
    if (!perkName || [perkName containsString:@"None"]) {
        return @"Dull";
    }
    
    // Hex totems
    if ([perkName containsString:@"Hex_DevourHope_C"]) return @"Hex: Devour Hope";
    if ([perkName containsString:@"BP_HexNoOneEscapesDeath_C"]) return @"Hex: No One Escapes Death";
    if ([perkName containsString:@"Hex_HuntressLullaby_C"]) return @"Hex: Huntress Lullaby";
    if ([perkName containsString:@"Hex_Ruin_C"]) return @"Hex: Ruin";
    if ([perkName containsString:@"Hex_TheThirdSeal_C"]) return @"Hex: The Third Seal";
    if ([perkName containsString:@"Hex_ThrillOfTheHunt_C"]) return @"Hex: Thrill of the Hunt";
    if ([perkName containsString:@"Hex_HauntedGround_C"]) return @"Hex: Haunted Ground";
    if ([perkName containsString:@"HexRetribution_C"]) return @"Hex: Retribution";
    if ([perkName containsString:@"BP_HexUndying_C"]) return @"Hex: Undying";
    if ([perkName containsString:@"BP_K25P02_C"]) return @"Hex: Plaything";
    if ([perkName containsString:@"BP_HexPentimento_C"]) return @"Hex: Pentimento";
    if ([perkName containsString:@"BP_K30P02_C"]) return @"Hex: Face the Darkness";
    if ([perkName containsString:@"BP_HexBloodFavor_C"]) return @"Hex: Blood Favor";
    if ([perkName containsString:@"BP_HexCrowdControl_C"]) return @"Hex: Crowd Control";
    if ([perkName containsString:@"BP_K34P01_C"]) return @"Hex: Two Can Play";

    // Boon totems
    if ([perkName containsString:@"BP_S28P02_C"]) return @"Boon: Circle of Healing";
    if ([perkName containsString:@"BP_S28P03_C"]) return @"Boon: Shadow Step";
    if ([perkName containsString:@"BP_S29PO3_C"]) return @"Boon: Exponential";
    if ([perkName containsString:@"BP_S30P03_C"]) return @"Boon: Dark Theory";

    // If totem has a perk but we don't recognize it
    if (state == ETotemState::Hex) {
        return @"Unknown Hex";
    } else if (state == ETotemState::Boon) {
        return @"Unknown Boon";
    }
    
    return @"Dull";
}

- (UIColor *)getColorForHexName:(NSString *)hexName {
    if ([hexName isEqualToString:@"Dull"]) {
        return [UIColor colorWithRed:142.0/255.0 green:191.0/255.0 blue:44.0/255.0 alpha:1.0]; // Zielony dla dull totemów
    } else if ([hexName containsString:@"Boon:"]) {
        return [UIColor colorWithRed:0.0 green:0.8 blue:1.0 alpha:1.0]; // Jasnoniebieski dla boonów
    } else if ([hexName containsString:@"Hex:"]) {
        return [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]; // Czerwony dla hexów
    }
    
    return [UIColor colorWithRed:142.0/255.0 green:191.0/255.0 blue:44.0/255.0 alpha:1.0]; // Domyślny kolor
}


- (void)drawChestESP {
    if (!self.showChests) return;
    
    uintptr_t World = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
    if (!World) return;
    
    // Add this line to get GameState
    uintptr_t GameState = *(uintptr_t*)(World + Offsets::SDK::UWorldToGameState);
    if (!GameState) return;

    uintptr_t LocalPlayerCameraManager = GetLocalPlayerCameraManager();
    if (!LocalPlayerCameraManager) return;

    uintptr_t LocalPlayerCameraPOV = LocalPlayerCameraManager + Offsets::SDK::APlayerCameraManagerToCameraCachePrivate + Offsets::SDK::FCameraCacheEntryToPOV;
    float LocalPlayerCameraFOV = *(float*)(LocalPlayerCameraPOV + Offsets::SDK::FMinimalViewInfoToFOV);
    Vector3 LocalPlayerCameraLocation = *(Vector3*)(LocalPlayerCameraPOV + Offsets::SDK::FMinimalViewInfoToLocation);
    Vector3 LocalPlayerCameraRotation = *(Vector3*)(LocalPlayerCameraPOV + Offsets::SDK::FMinimalViewInfoToRotation);
    ViewMatrix viewMatrix = CreateViewMatrix(LocalPlayerCameraRotation);

    uintptr_t _searchables = *(uintptr_t*)(GameState + Offsets::SDK::ADBDGameStateTo_searchables);
    int32_t _searchablesCount = *(int32_t*)(GameState + Offsets::SDK::ADBDGameStateTo_searchables + Offsets::Special::TArrayToCount);
    
    for (int g = 0; g < _searchablesCount && _searchables != 0; g++) {
        uintptr_t Chest = *(uintptr_t*)(_searchables + g * Offsets::Special::PointerSize);
        if (!Chest) continue;
        
        // Pobierz stan skrzyni
        bool hasBeenSearched = *(bool*)(Chest + 0x38c);  // _hasBeenSearched offset
        bool containsItem = *(uintptr_t*)(Chest + 0x390) != 0; // _spawnedItem offset
        
        uintptr_t RootComponent = GetRootComponent(Chest);
        if (!RootComponent) continue;

        Vector3 ChestPosition = GetActorPosition(RootComponent);
        CGPoint ChestScreenPosition;
        
        if (W2S(ChestScreenPosition, ChestPosition, LocalPlayerCameraLocation, LocalPlayerCameraFOV, viewMatrix)) {
            float dx = ChestPosition.X - LocalPlayerCameraLocation.X;
            float dy = ChestPosition.Y - LocalPlayerCameraLocation.Y;
            float dz = ChestPosition.Z - LocalPlayerCameraLocation.Z;
            float distance = sqrt(dx*dx + dy*dy + dz*dz);

            // Określ kolor i tekst stanu skrzyni
            UIColor *chestColor;
            NSString *stateText;
            
            if (hasBeenSearched) {
                chestColor = [UIColor grayColor];
                stateText = @"Searched";
            } else if (containsItem) {
                chestColor = [UIColor greenColor];
                stateText = @"Contains Item";
            } else {
                chestColor = self.chestESPColor;
                stateText = @"Unopened";
            }

            // Rysuj ESP w zależności od wybranego typu
            switch (self.objectESPType) {
                case 0: // Line
                    [self drawObjectLine:ChestScreenPosition color:chestColor];
                    break;
                case 1: // Box
                    [self drawObjectBox:ChestScreenPosition color:chestColor];
                    break;
                case 2: // Compass
                    [self drawObjectCompass:ChestScreenPosition color:chestColor];
                    break;
                case 3: // Filled
                    [self drawObjectFilled:ChestScreenPosition color:chestColor];
                    break;
            }
            
            [self drawObjectInfo:ChestScreenPosition 
                      distance:distance 
                        state:stateText 
                        color:chestColor];
        }
    }
}

- (void)drawGateESP {
    if (!self.showGates || !self.showText) return;
    
    uintptr_t World = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
    if (!World) return;
    
    uintptr_t GameState = *(uintptr_t*)(World + Offsets::SDK::UWorldToGameState);
    if (!GameState) return;

    uintptr_t LocalPlayerCameraManager = GetLocalPlayerCameraManager();
    if (!LocalPlayerCameraManager) return;

    uintptr_t LocalPlayerCameraPOV = LocalPlayerCameraManager + Offsets::SDK::APlayerCameraManagerToCameraCachePrivate + Offsets::SDK::FCameraCacheEntryToPOV;
    float LocalPlayerCameraFOV = *(float*)(LocalPlayerCameraPOV + Offsets::SDK::FMinimalViewInfoToFOV);
    Vector3 LocalPlayerCameraLocation = *(Vector3*)(LocalPlayerCameraPOV + Offsets::SDK::FMinimalViewInfoToLocation);
    Vector3 LocalPlayerCameraRotation = *(Vector3*)(LocalPlayerCameraPOV + Offsets::SDK::FMinimalViewInfoToRotation);
    ViewMatrix viewMatrix = CreateViewMatrix(LocalPlayerCameraRotation);

    uintptr_t _gates = *(uintptr_t*)(GameState + Offsets::SDK::ADBDGameStateTo_escapeDoors);
    int32_t _gatesCount = *(int32_t*)(GameState + Offsets::SDK::ADBDGameStateTo_escapeDoors + Offsets::Special::TArrayToCount);
    
    for (int g = 0; g < _gatesCount && _gates != 0; g++) {
        uintptr_t Gate = *(uintptr_t*)(_gates + g * Offsets::Special::PointerSize);
        if (!Gate) continue;
        
        bool isActivated = *(bool*)(Gate + 0x3a8);
        bool isOpen = *(bool*)(Gate + 0x3e0);
        
        uintptr_t RootComponent = GetRootComponent(Gate);
        if (!RootComponent) continue;

        Vector3 GatePosition = GetActorPosition(RootComponent);
        CGPoint GateScreenPosition;
        
        if (W2S(GateScreenPosition, GatePosition, LocalPlayerCameraLocation, LocalPlayerCameraFOV, viewMatrix)) {
            float dx = GatePosition.X - LocalPlayerCameraLocation.X;
            float dy = GatePosition.Y - LocalPlayerCameraLocation.Y;
            float dz = GatePosition.Z - LocalPlayerCameraLocation.Z;
            float distance = sqrt(dx*dx + dy*dy + dz*dz) * 0.01f;

            UIColor *gateColor;
            NSString *stateText;
            
            if (isOpen) {
                gateColor = [UIColor greenColor];
                stateText = @"Open";
            } else if (isActivated) {
                gateColor = [UIColor yellowColor];
                stateText = @"Powered";
            } else {
                // Zmiana domyślnego koloru bramy na RGB(0, 102, 255)
                gateColor = [UIColor colorWithRed:252.0/255.0 green:82.0/255.0 blue:255.0/255.0 alpha:1.0];
                stateText = @"Closed";
            }

            // Label "Gate"
            UILabel *gateLabel = [[UILabel alloc] init];
            gateLabel.text = @"Gate";
            gateLabel.font = [UIFont systemFontOfSize:self.textSize];
            gateLabel.textColor = gateColor;
            gateLabel.backgroundColor = [UIColor clearColor];
            gateLabel.textAlignment = NSTextAlignmentCenter;
            [gateLabel sizeToFit];
            
            // Label stanu (15% mniejszy jak w totemach)
            UILabel *stateLabel = [[UILabel alloc] init];
            stateLabel.text = stateText;
            stateLabel.font = [UIFont systemFontOfSize:self.textSize * 0.85];
            stateLabel.textColor = gateColor;
            stateLabel.backgroundColor = [UIColor clearColor];
            stateLabel.textAlignment = NSTextAlignmentCenter;
            [stateLabel sizeToFit];
            
            // Label dystansu
            UILabel *distanceLabel = [[UILabel alloc] init];
            distanceLabel.text = [NSString stringWithFormat:@"%.1fm", distance];
            distanceLabel.font = [UIFont systemFontOfSize:self.textSize - 2];
            distanceLabel.textColor = gateColor;
            distanceLabel.backgroundColor = [UIColor clearColor];
            distanceLabel.textAlignment = NSTextAlignmentCenter;
            [distanceLabel sizeToFit];
            
            CGFloat padding = 1;
            
            // Pozycjonowanie etykiet
            gateLabel.frame = CGRectMake(
                GateScreenPosition.x - gateLabel.frame.size.width/2,
                GateScreenPosition.y - gateLabel.frame.size.height - stateLabel.frame.size.height,
                gateLabel.frame.size.width + padding,
                gateLabel.frame.size.height
            );
            
            stateLabel.frame = CGRectMake(
                GateScreenPosition.x - stateLabel.frame.size.width/2,
                GateScreenPosition.y - stateLabel.frame.size.height,
                stateLabel.frame.size.width + padding,
                stateLabel.frame.size.height
            );
            
            distanceLabel.frame = CGRectMake(
                GateScreenPosition.x - distanceLabel.frame.size.width/2,
                GateScreenPosition.y,
                distanceLabel.frame.size.width + padding,
                distanceLabel.frame.size.height
            );
            
            gateLabel.clipsToBounds = YES;
            stateLabel.clipsToBounds = YES;
            distanceLabel.clipsToBounds = YES;
            
            [self.espOverlayView addSubview:gateLabel];
            [self.espOverlayView addSubview:stateLabel];
            [self.espOverlayView addSubview:distanceLabel];
        }
    }
}

// Pomocnicze metody do rysowania obiektów (używane przez obie implementacje)
- (void)drawObjectLine:(CGPoint)position color:(UIColor *)color {
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(self.espOverlayView.bounds.size.width / 2, 0)];
    [linePath addLineToPoint:position];
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.path = linePath.CGPath;
    lineLayer.strokeColor = color.CGColor;
    lineLayer.lineWidth = self.survivorLineWidth;
    lineLayer.fillColor = nil;
    
    [self.espOverlayView.layer addSublayer:lineLayer];
}

- (void)drawObjectBox:(CGPoint)position color:(UIColor *)color {
    UIBezierPath *boxPath = [UIBezierPath bezierPathWithRect:
        CGRectMake(position.x - self.objectESPSize/2, position.y - self.objectESPSize/2, self.objectESPSize, self.objectESPSize)];
    
    CAShapeLayer *boxLayer = [CAShapeLayer layer];
    boxLayer.path = boxPath.CGPath;
    boxLayer.strokeColor = color.CGColor;
    boxLayer.lineWidth = 1.0;
    boxLayer.fillColor = nil;
    
    [self.espOverlayView.layer addSublayer:boxLayer];
}

- (void)drawObjectFilled:(CGPoint)position color:(UIColor *)color {
    UIBezierPath *boxPath = [UIBezierPath bezierPathWithRect:
        CGRectMake(position.x - self.objectESPSize/2, position.y - self.objectESPSize/2, self.objectESPSize, self.objectESPSize)];
    
    CAShapeLayer *boxLayer = [CAShapeLayer layer];
    boxLayer.path = boxPath.CGPath;
    boxLayer.strokeColor = color.CGColor;
    boxLayer.lineWidth = 1.0;
    boxLayer.fillColor = [color colorWithAlphaComponent:0.3].CGColor;
    
    [self.espOverlayView.layer addSublayer:boxLayer];
}

- (void)drawObjectCompass:(CGPoint)position color:(UIColor *)color {
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    [arrowPath moveToPoint:CGPointMake(self.espOverlayView.bounds.size.width / 2, 0)];
    [arrowPath addLineToPoint:position];
    
    CAShapeLayer *arrowLayer = [CAShapeLayer layer];
    arrowLayer.path = arrowPath.CGPath;
    arrowLayer.strokeColor = color.CGColor;
    arrowLayer.lineWidth = 2.0;
    arrowLayer.fillColor = nil;
    
    [self.espOverlayView.layer addSublayer:arrowLayer];
}

- (void)drawObjectInfo:(CGPoint)position 
             distance:(float)distance 
               state:(NSString *)state 
               color:(UIColor *)color {
    if (self.showText) {
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.text = [NSString stringWithFormat:@"%@ %.1fm", state, distance * 0.01f];
        textLabel.font = [UIFont systemFontOfSize:self.textSize];
        textLabel.textColor = self.textColor ? self.textColor : color;
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textAlignment = NSTextAlignmentCenter;
        [textLabel sizeToFit];
        
        CGFloat padding = 4;
        textLabel.frame = CGRectMake(
            position.x - textLabel.frame.size.width/2,
            position.y - textLabel.frame.size.height/2,
            textLabel.frame.size.width + padding,
            textLabel.frame.size.height
        );
        
        textLabel.clipsToBounds = YES;
        
        [self.espOverlayView addSubview:textLabel];
    }
}

- (void)drawHatchESP {
    if (!self.showHatch || !self.showText) return;
    
    uintptr_t World = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
    if (!World) return;
    
    uintptr_t GameState = *(uintptr_t*)(World + Offsets::SDK::UWorldToGameState);
    if (!GameState) return;

    uintptr_t LocalPlayerCameraManager = GetLocalPlayerCameraManager();
    if (!LocalPlayerCameraManager) return;

    uintptr_t LocalPlayerCameraPOV = LocalPlayerCameraManager + Offsets::SDK::APlayerCameraManagerToCameraCachePrivate + Offsets::SDK::FCameraCacheEntryToPOV;
    float LocalPlayerCameraFOV = *(float*)(LocalPlayerCameraPOV + Offsets::SDK::FMinimalViewInfoToFOV);
    Vector3 LocalPlayerCameraLocation = *(Vector3*)(LocalPlayerCameraPOV + Offsets::SDK::FMinimalViewInfoToLocation);
    Vector3 LocalPlayerCameraRotation = *(Vector3*)(LocalPlayerCameraPOV + Offsets::SDK::FMinimalViewInfoToRotation);
    ViewMatrix viewMatrix = CreateViewMatrix(LocalPlayerCameraRotation);

    uintptr_t _hatches = *(uintptr_t*)(GameState + Offsets::SDK::ADBDGameStateTo_hatches);
    int32_t _hatchesCount = *(int32_t*)(GameState + Offsets::SDK::ADBDGameStateTo_hatches + Offsets::Special::TArrayToCount);
    
    typedef enum class EHatchState : uint8_t {
        Hidden = 0,
        DefaultClose = 1,
        Opened = 2,
        ForcedClose = 3,
    } EHatchState;
    
    for (int g = 0; g < _hatchesCount && _hatches != 0; g++) {
        uintptr_t Hatch = *(uintptr_t*)(_hatches + g * Offsets::Special::PointerSize);
        if (!Hatch) continue;
        
        EHatchState hatchState = *(EHatchState*)(Hatch + 0x3a0);
        
        uintptr_t RootComponent = GetRootComponent(Hatch);
        if (!RootComponent) continue;

        Vector3 HatchPosition = GetActorPosition(RootComponent);
        CGPoint HatchScreenPosition;
        
        if (W2S(HatchScreenPosition, HatchPosition, LocalPlayerCameraLocation, LocalPlayerCameraFOV, viewMatrix)) {
            float dx = HatchPosition.X - LocalPlayerCameraLocation.X;
            float dy = HatchPosition.Y - LocalPlayerCameraLocation.Y;
            float dz = HatchPosition.Z - LocalPlayerCameraLocation.Z;
            float distance = sqrt(dx*dx + dy*dy + dz*dz) * 0.01f;

            NSString *stateText;
            
            switch (hatchState) {
                case EHatchState::Hidden:
                    stateText = @"Hidden";
                    break;
                case EHatchState::DefaultClose:
                    stateText = @"Closed";
                    break;
                case EHatchState::Opened:
                    stateText = @"Open";
                    break;
                case EHatchState::ForcedClose:
                    stateText = @"Forced Close";
                    break;
                default:
                    stateText = @"Unknown";
            }

            UIColor *hatchColor = [UIColor colorWithRed:252.0/255.0 green:177.0/255.0 blue:3.0/255.0 alpha:1.0];

            // Label "Hatch"
            UILabel *hatchLabel = [[UILabel alloc] init];
            hatchLabel.text = @"Hatch";
            hatchLabel.font = [UIFont systemFontOfSize:self.textSize];
            hatchLabel.textColor = hatchColor;
            hatchLabel.backgroundColor = [UIColor clearColor];
            hatchLabel.textAlignment = NSTextAlignmentCenter;
            [hatchLabel sizeToFit];
            
            // Label stanu (15% mniejszy jak w totemach)
            UILabel *stateLabel = [[UILabel alloc] init];
            stateLabel.text = stateText;
            stateLabel.font = [UIFont systemFontOfSize:self.textSize * 0.85];
            stateLabel.textColor = hatchColor;
            stateLabel.backgroundColor = [UIColor clearColor];
            stateLabel.textAlignment = NSTextAlignmentCenter;
            [stateLabel sizeToFit];
            
            // Label dystansu
            UILabel *distanceLabel = [[UILabel alloc] init];
            distanceLabel.text = [NSString stringWithFormat:@"%.1fm", distance];
            distanceLabel.font = [UIFont systemFontOfSize:self.textSize - 2];
            distanceLabel.textColor = hatchColor;
            distanceLabel.backgroundColor = [UIColor clearColor];
            distanceLabel.textAlignment = NSTextAlignmentCenter;
            [distanceLabel sizeToFit];
            
            CGFloat padding = 1;
            
            // Pozycjonowanie etykiet
            hatchLabel.frame = CGRectMake(
                HatchScreenPosition.x - hatchLabel.frame.size.width/2,
                HatchScreenPosition.y - hatchLabel.frame.size.height - stateLabel.frame.size.height,
                hatchLabel.frame.size.width + padding,
                hatchLabel.frame.size.height
            );
            
            stateLabel.frame = CGRectMake(
                HatchScreenPosition.x - stateLabel.frame.size.width/2,
                HatchScreenPosition.y - stateLabel.frame.size.height,
                stateLabel.frame.size.width + padding,
                stateLabel.frame.size.height
            );
            
            distanceLabel.frame = CGRectMake(
                HatchScreenPosition.x - distanceLabel.frame.size.width/2,
                HatchScreenPosition.y,
                distanceLabel.frame.size.width + padding,
                distanceLabel.frame.size.height
            );
            
            hatchLabel.clipsToBounds = YES;
            stateLabel.clipsToBounds = YES;
            distanceLabel.clipsToBounds = YES;
            
            [self.espOverlayView addSubview:hatchLabel];
            [self.espOverlayView addSubview:stateLabel];
            [self.espOverlayView addSubview:distanceLabel];
        }
    }
}

- (void)drawSurvivorESP {
    if (!self.showSurvivors || !self.showText) return;
    
    uintptr_t World = *(uintptr_t*)(BaseAddress + Offsets::Globals::GWorldOffset);
    if (!World) return;
    
    uintptr_t PersistentLevel = *(uintptr_t*)(World + Offsets::SDK::UWorldToPersistentLevel);
    if (!PersistentLevel) return;

    uintptr_t ActorArray = *(uintptr_t*)(PersistentLevel + Offsets::Special::ULevelToActorArray);
    if (!ActorArray) return;
    
    int32_t ActorCount = *(int32_t*)(PersistentLevel + Offsets::Special::ULevelToActorArray + Offsets::Special::TArrayToCount);
    
    uintptr_t LocalPlayerCameraManager = GetLocalPlayerCameraManager();
    if (!LocalPlayerCameraManager) return;

    uintptr_t LocalPlayerCameraPOV = LocalPlayerCameraManager + Offsets::SDK::APlayerCameraManagerToCameraCachePrivate + Offsets::SDK::FCameraCacheEntryToPOV;
    float LocalPlayerCameraFOV = *(float*)(LocalPlayerCameraPOV + Offsets::SDK::FMinimalViewInfoToFOV);
    Vector3 LocalPlayerCameraLocation = *(Vector3*)(LocalPlayerCameraPOV + Offsets::SDK::FMinimalViewInfoToLocation);
    Vector3 LocalPlayerCameraRotation = *(Vector3*)(LocalPlayerCameraPOV + Offsets::SDK::FMinimalViewInfoToRotation);
    ViewMatrix viewMatrix = CreateViewMatrix(LocalPlayerCameraRotation);

    // Dodaj okrąg na środku ekranu
    CGPoint screenCenter = CGPointMake(self.espOverlayView.bounds.size.width / 2, 
                                     self.espOverlayView.bounds.size.height / 2);
    CGFloat circleRadius = 70.0;
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:screenCenter
                                                             radius:circleRadius
                                                         startAngle:0
                                                           endAngle:M_PI * 2
                                                          clockwise:YES];
    
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.path = circlePath.CGPath;
    circleLayer.strokeColor = [UIColor clearColor].CGColor;
    circleLayer.fillColor = nil;
    circleLayer.lineWidth = 1.0;
    [self.espOverlayView.layer addSublayer:circleLayer];

    NSMutableArray *survivorArcs = [NSMutableArray new];
    CGFloat barWidth = 3.0;
    CGFloat originalArcLength = M_PI / 8;
    CGFloat collisionPadding = M_PI / 16; // Niewidoczny obszar kolizji

    for (int i = 0; i < ActorCount; i++) {
        uintptr_t Actor = *(uintptr_t*)(ActorArray + i * Offsets::Special::PointerSize);
        if (!Actor) continue;

        NSString* ActorName = GetNameFromFName(*(int32_t*)(Actor + Offsets::Special::UObjectToFNameOffset));
        if (!ActorName) continue;

        NSString *characterName = nil;
        
       
        // Female survivors
        if ([ActorName isEqualToString:@"BP_CamperFemale01_Character_C"]) characterName = @"Meg";
        else if ([ActorName isEqualToString:@"BP_CamperFemale02_Character_C"]) characterName = @"Claudette";
        else if ([ActorName isEqualToString:@"BP_CamperFemale03_Character_C"]) characterName = @"Nea";
        else if ([ActorName isEqualToString:@"BP_CamperFemale04_Character_C"]) characterName = @"Laurie";
        else if ([ActorName isEqualToString:@"BP_CamperFemale05_Character_C"]) characterName = @"Feng";
        else if ([ActorName isEqualToString:@"BP_CamperFemale06_Character_C"]) characterName = @"Kate";
        else if ([ActorName isEqualToString:@"BP_CamperFemale07_Character_C"]) characterName = @"Jane";
        else if ([ActorName isEqualToString:@"BP_CamperFemale09_Character_C"]) characterName = @"Yui";
        else if ([ActorName isEqualToString:@"BP_CamperFemale10_Character_C"]) characterName = @"Zarina";
        else if ([ActorName isEqualToString:@"BP_CamperFemale12_Character_C"]) characterName = @"Elodie";
        else if ([ActorName isEqualToString:@"BP_CamperFemale13_Character_C"]) characterName = @"Yun-Jin Lee";
        else if ([ActorName isEqualToString:@"BP_CamperFemale15_Character_C"]) characterName = @"Mikela";
        else if ([ActorName isEqualToString:@"BP_CamperFemale19_Character_C"]) characterName = @"Thalita";
        else if ([ActorName isEqualToString:@"BP_CamperFemale21_Character_C"]) characterName = @"Sable";
        else if ([ActorName isEqualToString:@"BP_CamperFemale16_Character_C"]) characterName = @"Haddie";
        else if ([ActorName isEqualToString:@"BP_CamperFemale07_Character_C"]) characterName = @"Jane";


        
        // Male survivors
        else if ([ActorName isEqualToString:@"BP_CamperMale01_C"]) characterName = @"Dwight";
        else if ([ActorName isEqualToString:@"BP_CamperMale02_Character_C"]) characterName = @"Jake";
        else if ([ActorName isEqualToString:@"BP_CamperMale03_Character_C"]) characterName = @"Ace";
        else if ([ActorName isEqualToString:@"BP_CamperMale04_Character_C"]) characterName = @"Bill";
        else if ([ActorName isEqualToString:@"BP_CamperMale05_Character_C"]) characterName = @"David";
        else if ([ActorName isEqualToString:@"BP_CamperMale06_Character_C"]) characterName = @"Quentin";
        else if ([ActorName isEqualToString:@"BP_CamperMale07_Character_C"]) characterName = @"Tapp";
        else if ([ActorName isEqualToString:@"BP_CamperMale08_Character_C"]) characterName = @"Adam";
        else if ([ActorName isEqualToString:@"BP_CamperMale09_Character_C"]) characterName = @"Jeff";
        else if ([ActorName isEqualToString:@"BP_CamperMale10_Character_C"]) characterName = @"Ash";
        else if ([ActorName isEqualToString:@"BP_CamperMale14_Character_C"]) characterName = @"Jonah";
        else if ([ActorName isEqualToString:@"BP_CamperMale12_Character_C"]) characterName = @"Felix";
        else if ([ActorName isEqualToString:@"BP_CamperMale13_Character_C"]) characterName = @"Renato";
        else if ([ActorName isEqualToString:@"BP_CamperMale16_Character_C"]) characterName = @"Vittorio";
        else if ([ActorName isEqualToString:@"BP_CamperMale15_Character_C"]) characterName = @"Yoichi";
        else if ([ActorName isEqualToString:@"BP_CamperMale17_Character_C"]) characterName = @"Renato";
        else if ([ActorName isEqualToString:@"BP_CamperMale18_Character_C"]) characterName = @"Gabriel";
        else if ([ActorName isEqualToString:@"BP_CamperMale19_Character_C"]) characterName = @"Nicolas";


        if (characterName && Actor != LocalPlayer) {
            uintptr_t RootComponent = GetRootComponent(Actor);
            if (!RootComponent) continue;

            // Pobierz PlayerState używając prawidłowego offsetu z APawn
            uintptr_t PlayerState = *(uintptr_t*)(Actor + 0x250); // Offset 0x250 z APawn::PlayerState
            if (!PlayerState) continue;

            // Pobierz PlayerNamePrivate jako FString
            FString* namePtr = (FString*)(PlayerState + 0x310);
            NSString *playerName = @"Unknown";

            // Pobierz SavedNetworkAddress - używamy właściwego offsetu w PlayerState
            FString* networkAddressPtr = (FString*)(PlayerState + 0x310); // SavedNetworkAddress offset w APlayerState
            NSString *networkAddress = @"Unknown";

            // Odczytaj nazwę gracza
            if (namePtr && IsBadReadPtr(namePtr, sizeof(FString)) == 0) {
                FString name = *namePtr;
                if (name.Data && name.Count > 0 && IsBadReadPtr(name.Data, name.Count * sizeof(wchar_t)) == 0) {
                    playerName = [[NSString alloc] initWithBytes:name.Data
                                                        length:name.Count * 2
                                                      encoding:NSUTF8StringEncoding];
                    
                    if (!playerName) {
                        playerName = @"Unknown";
                    }
                }
            }

            // Odczytaj adres sieciowy - używamy tego samego sposobu odczytu co dla nazwy
            if (networkAddressPtr && IsBadReadPtr(networkAddressPtr, sizeof(FString)) == 0) {
                FString address = *networkAddressPtr;
                if (address.Data && address.Count > 0 && IsBadReadPtr(address.Data, address.Count * sizeof(wchar_t)) == 0) {
                    networkAddress = [[NSString alloc] initWithBytes:address.Data
                                                            length:address.Count * 2
                                                          encoding:NSUTF8StringEncoding];
                    if (!networkAddress) {
                        networkAddress = @"Unknown";
                    }
                }
            }

            // Wyświetl tylko adres sieciowy (dla testów)
            playerName = networkAddress;

            Vector3 SurvivorPosition = GetActorPosition(RootComponent);
            CGPoint SurvivorScreenPosition;
            
            if (W2S(SurvivorScreenPosition, SurvivorPosition, LocalPlayerCameraLocation, LocalPlayerCameraFOV, viewMatrix)) {
                float dx = SurvivorPosition.X - LocalPlayerCameraLocation.X;
                float dy = SurvivorPosition.Y - LocalPlayerCameraLocation.Y;
                float dz = SurvivorPosition.Z - LocalPlayerCameraLocation.Z;
                float distance = sqrt(dx*dx + dy*dy + dz*dz) * 0.01f;

                // Oblicz kierunek na podstawie pozycji 3D
                float screenDX = -(screenCenter.x - SurvivorScreenPosition.x);  // Odwrócony znak
                float screenDY = -(screenCenter.y - SurvivorScreenPosition.y);  // Odwrócony znak
                float length = sqrt(screenDX * screenDX + screenDY * screenDY);
                
                // Normalizacja wektora kierunku
                if (length > 0) {
                    screenDX /= length;
                    screenDY /= length;
                }

                float baseAngle = atan2(screenDY, screenDX);
                if (baseAngle < 0) {
                    baseAngle += 2 * M_PI;
                }

                CGFloat arcLength = originalArcLength;

                // Sprawdź kolizje z istniejącymi łukami i dostosuj pozycję
                for (NSValue *arcValue in survivorArcs) {
                    ArcInfo existingArc;
                    [arcValue getValue:&existingArc];
                    
                    float angleDiff = fabs(baseAngle - existingArc.angle);
                    if (angleDiff > M_PI) {
                        angleDiff = 2 * M_PI - angleDiff;
                    }
                    
                    // Jeśli łuki są zbyt blisko siebie
                    float minDistance = arcLength/2 + existingArc.length/2 + collisionPadding;
                    if (angleDiff < minDistance) {
                        // Przesuń nowy łuk na granicę obszaru kolizji
                        float shift = minDistance - angleDiff;
                        if (baseAngle > existingArc.angle) {
                            baseAngle += shift;
                        } else {
                            baseAngle -= shift;
                        }
                        
                        // Normalizacja kąta
                        while (baseAngle < 0) baseAngle += 2 * M_PI;
                        while (baseAngle >= 2 * M_PI) baseAngle -= 2 * M_PI;
                    }
                }

                // Zapisz i narysuj łuk (zawsze)
                ArcInfo newArc = {baseAngle, static_cast<float>(arcLength)};
                [survivorArcs addObject:[NSValue value:&newArc withObjCType:@encode(ArcInfo)]];

                // Rysuj łuk
                float startAngle = baseAngle - arcLength/2;
                float endAngle = baseAngle + arcLength/2;

                // Rysuj główny łuk
                UIBezierPath *arcPath = [UIBezierPath bezierPathWithArcCenter:screenCenter
                                                                  radius:circleRadius
                                                                  startAngle:startAngle
                                                                    endAngle:endAngle
                                                                   clockwise:YES];

                CAShapeLayer *arcLayer = [CAShapeLayer layer];
                arcLayer.path = arcPath.CGPath;
                arcLayer.strokeColor = [UIColor colorWithRed:3.0/255.0 green:252.0/255.0 blue:102.0/255.0 alpha:1.0].CGColor;
                arcLayer.fillColor = nil;
                arcLayer.lineWidth = barWidth;
                arcLayer.lineCap = kCALineCapRound;
                arcLayer.shadowColor = [UIColor colorWithRed:3.0/255.0 green:252.0/255.0 blue:102.0/255.0 alpha:1.0].CGColor;
                arcLayer.shadowRadius = 3.0;
                arcLayer.shadowOpacity = 0.8;
                arcLayer.shadowOffset = CGSizeZero;
                arcLayer.zPosition = 100; // Niższa wartość dla ocalałych
                [self.espOverlayView.layer addSublayer:arcLayer];

                // Parametry drugiego, cieńszego łuku
                CGFloat thinBarWidth = 1.0;   // Taki sam jak dla survivors
                CGFloat thinBarOffset = 2.0;  // Taki sam jak dla survivors
                CGFloat thinArcRadius = circleRadius - barWidth/2 - thinBarOffset - thinBarWidth/2; // Promień dla cienkiego łuku

                // Rysuj cienki pasek (łuk)
                UIBezierPath *thinArcPath = [UIBezierPath bezierPathWithArcCenter:screenCenter
                                                                          radius:thinArcRadius
                                                                          startAngle:startAngle
                                                                            endAngle:endAngle
                                                                           clockwise:YES];

                CAShapeLayer *thinArcLayer = [CAShapeLayer layer];
                thinArcLayer.path = thinArcPath.CGPath;
                thinArcLayer.strokeColor = [UIColor colorWithRed:3.0/255.0 green:252.0/255.0 blue:102.0/255.0 alpha:1.0].CGColor;
                thinArcLayer.fillColor = nil;
                thinArcLayer.lineWidth = thinBarWidth;
                thinArcLayer.lineCap = kCALineCapRound;
                thinArcLayer.shadowColor = [UIColor colorWithRed:3.0/255.0 green:252.0/255.0 blue:102.0/255.0 alpha:1.0].CGColor;
                thinArcLayer.shadowRadius = 2.0;
                thinArcLayer.shadowOpacity = 0.6;
                thinArcLayer.shadowOffset = CGSizeZero;
                thinArcLayer.zPosition = 100; // Niższa wartość dla ocalałych
                [self.espOverlayView.layer addSublayer:thinArcLayer];

                // Label z nazwą postaci (characterName)
                UILabel *characterLabel = [[UILabel alloc] init];
                characterLabel.text = characterName;
                characterLabel.font = [UIFont systemFontOfSize:self.textSize];
                characterLabel.textColor = [UIColor colorWithRed:3.0/255.0 green:252.0/255.0 blue:102.0/255.0 alpha:1.0];
                characterLabel.backgroundColor = [UIColor clearColor];
                characterLabel.textAlignment = NSTextAlignmentCenter;
                [characterLabel sizeToFit];

                CGFloat padding = 4;
                characterLabel.frame = CGRectMake(
                    SurvivorScreenPosition.x - characterLabel.frame.size.width/2,
                    SurvivorScreenPosition.y - characterLabel.frame.size.height,
                    characterLabel.frame.size.width + padding,
                    characterLabel.frame.size.height
                );

                // Label z nazwą gracza (playerName)
                UILabel *playerNameLabel = [[UILabel alloc] init];
                playerNameLabel.text = playerName;
                playerNameLabel.font = [UIFont systemFontOfSize:self.textSize - 2]; // Nieco mniejsza czcionka dla nazwy gracza
                playerNameLabel.textColor = [UIColor colorWithRed:3.0/255.0 green:252.0/255.0 blue:102.0/255.0 alpha:1.0];
                playerNameLabel.backgroundColor = [UIColor clearColor];
                playerNameLabel.textAlignment = NSTextAlignmentCenter;
                [playerNameLabel sizeToFit];

                playerNameLabel.frame = CGRectMake(
                    SurvivorScreenPosition.x - playerNameLabel.frame.size.width/2,
                    SurvivorScreenPosition.y,
                    playerNameLabel.frame.size.width + padding,
                    playerNameLabel.frame.size.height
                );

                characterLabel.clipsToBounds = YES;
                playerNameLabel.clipsToBounds = YES;
                [self.espOverlayView addSubview:characterLabel];
                [self.espOverlayView addSubview:playerNameLabel];

                // Label z dystansem
                UILabel *distanceLabel = [[UILabel alloc] init];
                distanceLabel.text = [NSString stringWithFormat:@"%.1fm", distance];
                distanceLabel.font = [UIFont systemFontOfSize:self.textSize - 2];
                distanceLabel.textColor = [UIColor colorWithRed:3.0/255.0 green:252.0/255.0 blue:102.0/255.0 alpha:1.0];
                distanceLabel.backgroundColor = [UIColor clearColor];
                distanceLabel.textAlignment = NSTextAlignmentCenter;
                [distanceLabel sizeToFit];
                
                distanceLabel.frame = CGRectMake(
                    SurvivorScreenPosition.x - distanceLabel.frame.size.width/2,
                    SurvivorScreenPosition.y + characterLabel.frame.size.height,
                    distanceLabel.frame.size.width + padding,
                    distanceLabel.frame.size.height
                );
                
                distanceLabel.clipsToBounds = YES;
                [self.espOverlayView addSubview:distanceLabel];
            }
        }
    }
}


+ (void)killerLineWidthChanged:(UISlider *)sender {
    ESPView *sharedInstance = [ESPView sharedInstance];
    sharedInstance.killerLineWidth = sender.value;
}

+ (void)survivorLineWidthChanged:(UISlider *)sender {
    ESPView *sharedInstance = [ESPView sharedInstance];
    sharedInstance.survivorLineWidth = sender.value;
}

+ (void)objectLineWidthChanged:(UISlider *)sender {
    ESPView *sharedInstance = [ESPView sharedInstance];
    sharedInstance.objectLineWidth = sender.value;
}

- (void)drawSurvivorLine:(CGPoint)position color:(UIColor *)color {
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(self.espOverlayView.bounds.size.width / 2, 0)];
    [linePath addLineToPoint:position];
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.path = linePath.CGPath;
    lineLayer.strokeColor = color.CGColor;
    lineLayer.lineWidth = self.survivorLineWidth;
    lineLayer.fillColor = nil;
    
    [self.espOverlayView.layer addSublayer:lineLayer];
}

// Dodaj metody obsługi kolorów
+ (void)showTextColorPicker:(UIButton *)sender {
    ColorPickerViewController *colorPicker = [[ColorPickerViewController alloc] init];
    colorPicker.colorSelectedHandler = ^(UIColor *color, NSString *gradientType) {
        ESPView *sharedInstance = [ESPView sharedInstance];
        sharedInstance.textColor = color;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [sharedInstance clearESP];
            [sharedInstance updateESP];
        });
    };
    
    UIViewController *topVC = [self topViewController];
    [topVC presentViewController:colorPicker animated:YES completion:nil];
}

+ (void)textSizeChanged:(UISlider *)sender {
    ESPView *sharedInstance = [ESPView sharedInstance];
    sharedInstance.textSize = sender.value;
    [sharedInstance clearESP];
    [sharedInstance updateESP];
}

+ (void)textToggleChanged:(UISwitch *)sender {
    ESPView *sharedInstance = [ESPView sharedInstance];
    sharedInstance.showText = sender.isOn;
    [sharedInstance clearESP];
    [sharedInstance updateESP];
}

// Helper do znalezienia top view controllera
+ (UIViewController *)topViewController {
    UIViewController *topVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

- (void)drawTextESP:(CGPoint)position text:(NSString *)text {
    if (!self.showText) return;
    
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.text = text;
    textLabel.font = [UIFont systemFontOfSize:self.textSize];
    textLabel.textColor = self.textColor;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textAlignment = NSTextAlignmentCenter;
    [textLabel sizeToFit];
    
    CGFloat padding = 4;
    textLabel.frame = CGRectMake(
        position.x - textLabel.frame.size.width/2,
        position.y - textLabel.frame.size.height/2,
        textLabel.frame.size.width + padding,
        textLabel.frame.size.height
    );
    
    textLabel.clipsToBounds = YES;
    
    [self.espOverlayView addSubview:textLabel];
}

// Dodaj nową metodę do sprawdzania stanu gry
- (void)checkGameState {
    static dispatch_source_t timer = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);
        
        dispatch_source_set_event_handler(timer, ^{
            if (!LocalPlayer) {
                [self clearESP];
                IsKiller = false; // Zresetuj flagę IsKiller
            }
        });
        
        dispatch_resume(timer);
    });
}

// Add this method implementation before @end

- (void)drawAllBPObjectsESP {
    // Draw all ESP elements in sequence
    [self drawGeneratorESP];
    [self drawTotemESP];
    [self drawChestESP];
    [self drawGateESP];
    [self drawHatchESP];
    [self drawSurvivorESP];
    [self drawKillerESP];
}



@end 