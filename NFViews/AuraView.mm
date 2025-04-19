#import "AuraView.h"
#import "Magicolors/ColorsHandler.h"
#import "NFToggles.h"
#import "NFViewsCommon.h"

@implementation AuraView

static UIView *currentMenuView;

+ (void)createAuraView:(UIView *)menuView {
    // Dodajemy brakujące stałe
    currentMenuView = menuView;
    CGFloat menuWidth = 620;
    NSString *currentFont = @"ArialRoundedMTBold";  // lub inną czcionkę, której używasz w aplikacji
    
    // Oblicz wysokość obszaru dla przełączników
    CGFloat switchAreaHeight = 210;
    CGFloat scrollViewWidth = (menuWidth - 20) / 2;
    CGFloat scrollViewSpacing = 20; // Space between scroll views
    CGFloat leftScrollViewX = (menuWidth - (scrollViewWidth * 2 + scrollViewSpacing)) / 2;
    CGFloat rightScrollViewX = leftScrollViewX + scrollViewWidth + scrollViewSpacing;
    CGFloat labelHeight = 25; // Dodajemy definicję labelHeight
    CGFloat switchStartY = 3; // Dodajemy definicję switchStartY
    CGFloat switchSpacing = 18; // Dodajemy definicję switchSpacing

    // Utwórz UIScrollView dla Aura Actors
    UIScrollView *actorsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(leftScrollViewX, 67.3333 + labelHeight + 5, scrollViewWidth, switchAreaHeight)];
    actorsScrollView.backgroundColor = [UIColor clearColor];
    actorsScrollView.userInteractionEnabled = YES;
    actorsScrollView.scrollEnabled = YES;
    actorsScrollView.showsVerticalScrollIndicator = YES;
    actorsScrollView.bounces = YES;
    actorsScrollView.tag = 2000;
    actorsScrollView.hidden = YES;
    [menuView addSubview:actorsScrollView];



    // Aura Actors Label (poza ScrollView)
    UILabel *auraActorsLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftScrollViewX, 67.3333, scrollViewWidth, labelHeight)];
    auraActorsLabel.text = @"Aura Actors";
    auraActorsLabel.textColor = [UIColor whiteColor];
    auraActorsLabel.font = [UIFont fontWithName:currentFont size:16];
    auraActorsLabel.textAlignment = NSTextAlignmentCenter;
    auraActorsLabel.tag = 2001;
    auraActorsLabel.hidden = YES;
    [menuView addSubview:auraActorsLabel];

    NSArray *auraActorsTitles = @[
        @"Aura Killer",
        @"Aura Spirit (Ghost)", 
        @"Aura Spirit (Survivors)",
        @"Aura Survivors",
        @"Aura Survivors (Red)"
    ];

    // Mapowanie nazw przełączników na selektory i ikony SF Symbols
    NSDictionary *auraActorsConfig = @{
        @"Aura Killer": @{@"selector": @"auraKiller:", @"symbol": @"person.crop.circle.fill.badge.xmark", @"color": [UIColor colorWithCGColor:RightGradient]},
        @"Aura Spirit (Ghost)": @{@"selector": @"auraSpirit:", @"symbol": @"person.crop.circle.fill.badge.questionmark", @"color": [UIColor colorWithCGColor:RightGradient]},
        @"Aura Spirit (Survivors)": @{@"selector": @"auraSurvivorsSpirit:", @"symbol": @"person.3.sequence.fill", @"color": [UIColor colorWithCGColor:RightGradient]},
        @"Aura Survivors": @{@"selector": @"auraSurvivors:", @"symbol": @"person.2.circle.fill", @"color": [UIColor colorWithCGColor:RightGradient]},
        @"Aura Survivors (Red)": @{@"selector": @"auraSurvivorsRed:", @"symbol": @"person.2.wave.2.fill", @"color": [UIColor colorWithCGColor:RightGradient]}
    };

    CGFloat actorsContentHeight = switchStartY;

    for (NSUInteger i = 0; i < auraActorsTitles.count; i++) {
        NSString *title = auraActorsTitles[i];
        NSDictionary *config = auraActorsConfig[title];
        SEL selector = NSSelectorFromString(config[@"selector"]);
        
        // Tworzenie kontenera dla ikony i tekstu z gradientowym tłem
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(10, actorsContentHeight + i * switchSpacing, scrollViewWidth - 20, 30)];
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
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 21.4444, 20)];
        imageView.image = [UIImage systemImageNamed:config[@"symbol"]];
        imageView.tintColor = [UIColor whiteColor];
        [containerView addSubview:imageView];
        
        // Dodawanie etykiety z tekstem
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, scrollViewWidth - 85, 30)];
        label.text = title;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:currentFont size:12];
        [containerView addSubview:label];
        
        [actorsScrollView addSubview:containerView];
        
        // Dodawanie przełącznika
        UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(containerView.frame.size.width - 55, 0, 51, 31)];
        toggle.on = [[NSUserDefaults standardUserDefaults] boolForKey:[title stringByReplacingOccurrencesOfString:@" " withString:@""]];
        [toggle addTarget:[NFToggles class] action:selector forControlEvents:UIControlEventValueChanged];
        toggle.onTintColor = config[@"color"];
        [containerView addSubview:toggle];
        
        actorsContentHeight += switchSpacing;
    }

    actorsScrollView.contentSize = CGSizeMake(scrollViewWidth, MAX(actorsContentHeight + 20, switchAreaHeight + 1));

    // Dodaj te linie do debugowania
    NSLog(@"Actors ScrollView frame: %@", NSStringFromCGRect(actorsScrollView.frame));
    NSLog(@"Actors ScrollView contentSize: %@", NSStringFromCGSize(actorsScrollView.contentSize));

    // Utwórz UIScrollView dla Aura Objects
    UIScrollView *objectsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(rightScrollViewX, 67.3333 + labelHeight + 5, scrollViewWidth, switchAreaHeight)];
    objectsScrollView.backgroundColor = [UIColor clearColor];
    objectsScrollView.userInteractionEnabled = YES;
    objectsScrollView.scrollEnabled = YES;
    objectsScrollView.showsVerticalScrollIndicator = YES;
    objectsScrollView.bounces = YES;
    objectsScrollView.tag = 2003;
    objectsScrollView.hidden = YES;
    [menuView addSubview:objectsScrollView];

    // Aura Objects Label (poza ScrollView)
    UILabel *auraObjectsLabel = [[UILabel alloc] initWithFrame:CGRectMake(rightScrollViewX, 67.3333, scrollViewWidth, labelHeight)];
    auraObjectsLabel.text = @"Aura Objects";
    auraObjectsLabel.textColor = [UIColor whiteColor];
    auraObjectsLabel.font = [UIFont fontWithName:currentFont size:16];
    auraObjectsLabel.textAlignment = NSTextAlignmentCenter;
    auraObjectsLabel.tag = 2004;
    auraObjectsLabel.hidden = YES;
    [menuView addSubview:auraObjectsLabel];

    NSArray *auraObjectsTitles = @[
        @"Aura Generator",
        @"Aura Generator (Blue)",
        @"Aura Generator (Percentage)",
        @"Aura Hooks",
        @"Aura Lockers",
        @"Aura Breakable Doors",
        @"Aura Pallets/Windows",
        @"Aura Pallets",
        @"Aura Totems",
        @"Aura Chest",
        @"Aura Items",
        @"Aura Killer Objects",
        @"Aura Hatch",
        @"Aura Exit Gates"
    ];

    // Mapowanie nazw przełączników na selektory i ikony SF Symbols
    NSDictionary *auraObjectsConfig = @{
        @"Aura Generator": @{@"selector": @"auraGenerator:", @"symbol": @"bolt.circle.fill", @"color": [UIColor colorWithCGColor:RightGradient]},
        @"Aura Generator (Blue)": @{@"selector": @"auraGeneratorsBlue:", @"symbol": @"bolt.badge.a.fill", @"color": [UIColor colorWithCGColor:RightGradient]},
        @"Aura Generator (Percentage)": @{@"selector": @"auraGeneratorsPercentage:", @"symbol": @"chart.bar.fill", @"color": [UIColor colorWithCGColor:RightGradient]},
        @"Aura Hooks": @{@"selector": @"auraHooks:", @"symbol": @"link.circle.fill", @"color": [UIColor colorWithCGColor:RightGradient]},
        @"Aura Lockers": @{@"selector": @"auraLockers:", @"symbol": @"cabinet.fill", @"color": [UIColor colorWithCGColor:RightGradient]},
        @"Aura Breakable Doors": @{@"selector": @"auraBreakableDoors:", @"symbol": @"door.left.hand.closed", @"color": [UIColor colorWithCGColor:RightGradient]},
        @"Aura Pallets/Windows": @{@"selector": @"auraPalletsWindows:", @"symbol": @"square.stack.3d.up.fill", @"color": [UIColor colorWithCGColor:RightGradient]},
        @"Aura Pallets": @{@"selector": @"auraPallets:", @"symbol": @"hammer.circle.fill", @"color": [UIColor colorWithCGColor:RightGradient]},
        @"Aura Totems": @{@"selector": @"auraTotems:", @"symbol": @"flame.circle.fill", @"color": [UIColor colorWithCGColor:RightGradient]},
        @"Aura Chest": @{@"selector": @"auraChest:", @"symbol": @"shippingbox.fill", @"color": [UIColor colorWithCGColor:RightGradient]},
        @"Aura Items": @{@"selector": @"auraItems:", @"symbol": @"gift.circle.fill", @"color": [UIColor colorWithCGColor:RightGradient]},
        @"Aura Killer Objects": @{@"selector": @"auraKillerObjects:", @"symbol": @"scissors.circle.fill", @"color": [UIColor colorWithCGColor:RightGradient]},
        @"Aura Hatch": @{@"selector": @"auraHatch:", @"symbol": @"circle.dotted", @"color": [UIColor colorWithCGColor:RightGradient]},
        @"Aura Exit Gates": @{@"selector": @"auraExitGates:", @"symbol": @"door.right.hand.open", @"color": [UIColor colorWithCGColor:RightGradient]}
    };

    CGFloat objectsContentHeight = switchStartY;

    for (NSUInteger i = 0; i < auraObjectsTitles.count; i++) {
        NSString *title = auraObjectsTitles[i];
        NSDictionary *config = auraObjectsConfig[title];
        SEL selector = NSSelectorFromString(config[@"selector"]);
        
        // Tworzenie kontenera dla ikony i tekstu z gradientowym tłem
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(10, objectsContentHeight + i * switchSpacing, scrollViewWidth - 20, 30)];
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
        imageView.image = [UIImage systemImageNamed:config[@"symbol"]];
        imageView.tintColor = [UIColor whiteColor];
        [containerView addSubview:imageView];
        
        // Dodawanie etykiety z tekstem
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, scrollViewWidth - 85, 30)];
        label.text = title;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:currentFont size:12];
        [containerView addSubview:label];
        
        [objectsScrollView addSubview:containerView];
        
        // Dodawanie przełącznika
        UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(containerView.frame.size.width - 55, 0, 51, 31)];
        toggle.on = [[NSUserDefaults standardUserDefaults] boolForKey:[title stringByReplacingOccurrencesOfString:@" " withString:@""]];
        [toggle addTarget:[NFToggles class] action:selector forControlEvents:UIControlEventValueChanged];
        toggle.onTintColor = [UIColor colorWithCGColor:RightGradient];
        [containerView addSubview:toggle];
        
        objectsContentHeight += switchSpacing;
    }

    objectsScrollView.contentSize = CGSizeMake(scrollViewWidth, objectsContentHeight + 300);
}

@end 