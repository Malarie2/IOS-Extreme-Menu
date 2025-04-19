#import <UIKit/UIKit.h>

@interface ESPView : NSObject

+ (instancetype)sharedInstance;
+ (void)createESPView;

+ (void)killerSegmentChanged:(UISegmentedControl *)sender;
+ (void)survivorSegmentChanged:(UISegmentedControl *)sender;
+ (void)objectsSegmentChanged:(UISegmentedControl *)sender;
+ (void)updateKillerOptions:(UIScrollView *)scrollView forSegment:(NSInteger)segment;
+ (void)updateSurvivorOptions:(UIScrollView *)scrollView forSegment:(NSInteger)segment;
+ (void)updateObjectsOptions:(UIScrollView *)scrollView forSegment:(NSInteger)segment;
+ (void)addSwitchesForOptions:(NSDictionary *)options toView:(UIScrollView *)scrollView withType:(NSInteger)type;
+ (void)espSegmentChanged:(UISegmentedControl *)sender;
+ (void)hideAllESPViews:(UIScrollView *)scrollView;
+ (void)showSurvivorESP:(UIScrollView *)scrollView;
+ (void)showKillerESP:(UIScrollView *)scrollView;
+ (void)showObjectsESP:(UIScrollView *)scrollView;

- (void)drawKillerESP;
- (void)drawGeneratorESP;
- (void)drawTotemESP;
- (void)drawChestESP;
- (void)drawGateESP;
- (void)drawHatchESP;
- (void)drawSurvivorESP;
- (void)drawAllBPObjectsESP;

@property (nonatomic, strong) NSMutableArray<NSValue *> *generatorPositions;
@property (nonatomic, strong) NSMutableArray<NSValue *> *totemPositions;
@property (nonatomic, strong) NSMutableArray<NSValue *> *chestPositions;
@property (nonatomic, strong) NSMutableArray<NSValue *> *gatePositions;
@property (nonatomic, strong) NSMutableArray<NSValue *> *hatchPositions;
@property (nonatomic, strong) NSMutableArray<NSValue *> *survivorPositions;
@property (nonatomic, strong) NSMutableArray<NSValue *> *killerPosition;

@property (nonatomic, assign) BOOL showGenerators;
@property (nonatomic, assign) BOOL showTotems;
@property (nonatomic, assign) BOOL showChests;
@property (nonatomic, assign) BOOL showGates;
@property (nonatomic, assign) BOOL showHatch;
@property (nonatomic, assign) BOOL showSurvivors;
@property (nonatomic, assign) BOOL showKiller;

@property (nonatomic, assign) NSInteger killerESPType;
@property (nonatomic, assign) NSInteger survivorESPType;
@property (nonatomic, assign) NSInteger objectESPType;

@property (nonatomic, strong) UIColor *killerESPColor;
@property (nonatomic, strong) UIColor *survivorESPColor;
@property (nonatomic, strong) UIColor *generatorESPColor;
@property (nonatomic, strong) UIColor *totemESPColor;
@property (nonatomic, strong) UIColor *chestESPColor;
@property (nonatomic, strong) UIColor *gateESPColor;
@property (nonatomic, strong) UIColor *hatchESPColor;

@property (nonatomic, assign) CGFloat killerESPSize;
@property (nonatomic, assign) CGFloat survivorESPSize;
@property (nonatomic, assign) CGFloat objectESPSize;

@property (nonatomic, assign) CGPoint killerScreenPosition;
@property (nonatomic, assign) CGPoint screenCenter;
@property (nonatomic, assign) float distance;
@property (nonatomic, assign) BOOL shouldDraw;
@property (nonatomic, assign) float boxWidth;
@property (nonatomic, assign) CGPoint topLeft;
@property (nonatomic, assign) CGPoint bottomRight;
@property (nonatomic, assign) CGPoint boxCenter;

@property (nonatomic, assign) CGFloat killerLineWidth;
@property (nonatomic, assign) CGFloat survivorLineWidth;
@property (nonatomic, assign) CGFloat objectLineWidth;

- (void)setupESPOverlayView;
- (void)updateESP;
- (void)toggleESP;
- (void)clearESP;

@property (nonatomic, readonly) UIView *espOverlayView;

// Cache and threading properties
@property (nonatomic, strong) dispatch_queue_t dataCollectionQueue;
@property (nonatomic, strong) dispatch_queue_t renderQueue;
@property (nonatomic, strong) NSCache *positionCache;
@property (atomic, strong) NSMutableDictionary *espData;
@property (nonatomic, assign) NSTimeInterval lastUpdateTime;
@property (nonatomic, assign) NSTimeInterval cacheTimeout;

@property (nonatomic, assign) BOOL showText;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) CGFloat textSize;

@property (nonatomic, strong) NSString *searchPrefix;
@property (nonatomic, strong) UITextField *prefixTextField;

@property (nonatomic, assign) NSInteger searchMode; // 0: Prefix, 1: Contains, 2: Exact
@property (nonatomic, strong) NSString *searchText;
@property (nonatomic, assign) NSInteger maxObjects;
@property (nonatomic, assign) float maxRange;

@property (nonatomic, strong) UIColor *objectESPColor;

@property (nonatomic, assign) BOOL showDrawObjects; // Osobny toggle dla Draw Objects

@end 