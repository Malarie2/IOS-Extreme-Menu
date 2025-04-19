#import "KillerView.h"
#import "Magicolors/ColorsHandler.h"
#import "NFToggles.h"
#import "NFViewsCommon.h"

@implementation KillerView

+ (void)createKillerView:(UIView *)menuView {
    // Dodajemy brakujące stałe
    CGFloat menuWidth = 620;
    NSString *currentFont = @"ArialRoundedMTBold";  // lub inną czcionkę, której używasz w aplikacji
    
    CGFloat switchAreaHeight = 210;
    CGFloat scrollViewWidth = (menuWidth - 20) / 2;
    CGFloat scrollViewSpacing = 20;
    CGFloat leftScrollViewX = (menuWidth - (scrollViewWidth * 2 + scrollViewSpacing)) / 2;
    CGFloat rightScrollViewX = leftScrollViewX + scrollViewWidth + scrollViewSpacing;
    CGFloat labelHeight = 25;
    CGFloat switchStartY = 3;
    CGFloat switchSpacing = 18;









    // Add scroll view for Killer Left toggles
    UIScrollView *killerLeftScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(leftScrollViewX, 67.3333 + labelHeight + 5, scrollViewWidth, switchAreaHeight)];
    killerLeftScrollView.backgroundColor = [UIColor clearColor];
    killerLeftScrollView.userInteractionEnabled = YES;
    killerLeftScrollView.scrollEnabled = YES;
    killerLeftScrollView.showsVerticalScrollIndicator = YES;
    killerLeftScrollView.bounces = YES;
    killerLeftScrollView.hidden = YES;
    killerLeftScrollView.tag = 3000;
    [menuView addSubview:killerLeftScrollView];

    // Add scroll view for Killer Right toggles
    UIScrollView *killerRightScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(rightScrollViewX, 67.3333 + labelHeight + 5, scrollViewWidth, switchAreaHeight)];
    killerRightScrollView.backgroundColor = [UIColor clearColor];
    killerRightScrollView.userInteractionEnabled = YES;
    killerRightScrollView.scrollEnabled = YES;
    killerRightScrollView.showsVerticalScrollIndicator = YES;
    killerRightScrollView.bounces = YES;
    killerRightScrollView.hidden = YES;
    killerRightScrollView.tag = 3001;

    [menuView addSubview:killerRightScrollView];

    // Killer Label
    UILabel *killerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.666667, 67.3333, menuWidth, labelHeight)];
    killerLabel.text = @"Killer";
    killerLabel.textColor = [UIColor whiteColor];
    killerLabel.font = [UIFont fontWithName:currentFont size:16];
    killerLabel.textAlignment = NSTextAlignmentCenter;
    killerLabel.hidden = YES;
    killerLabel.tag = 3002;
    [menuView addSubview:killerLabel];



    // Podziel szerokość na dwie kolumny
    CGFloat columnWidthKiller = (menuWidth - 21.33333) / 2;

    // Pierwsza kolumna toggles
    NSArray *killerTogglesLeft = @[
        @"Max Turn Speed",
        @"Extra Bleeding Survivors",
        @"Block Players Move",
        @"Mayers Insta Kill",
        @"Infinity Phase Walk",
        @"Back Position (Spirit)",
        @"Disable Survivor Wiggle",
        @"No Hit Cooldown"
    ];

    // Druga kolumna toggles
    NSArray *killerTogglesRight = @[
        @"No Speed Cooldown Hit",
        @"Infinity Buba Chainsaw",
        @"Infinity Hit Duration + Auto Hit",
        @"Fast Knife x1",
        @"Fast Knife x2",
        @"Fast Knife x3",
        @"Fast Knife x4",
        @"Fast Knife x5"
    ];

    // Mapowanie nazw przełączników na selektory
    NSDictionary *killerSelectors = @{
        @"Max Turn Speed": @"maxTurnSpeed:",
        @"Extra Bleeding Survivors": @"extraBleedingSurvivors:",
        @"Block Players Move": @"blockPlayersMove:",
        @"Mayers Insta Kill": @"mayersInstaKill:",
        @"Infinity Phase Walk": @"infinityPhaseWalk:",
        @"Back Position (Spirit)": @"backPositionSpirit:",
        @"Disable Survivor Wiggle": @"disableSurvivorWiggle:",
        @"No Hit Cooldown": @"noHitCooldown:",
        @"No Speed Cooldown Hit": @"noSpeedCooldownHit:",
        @"Infinity Buba Chainsaw": @"infinityBubaChainsaw:",
        @"Infinity Hit Duration + Auto Hit": @"infinityHitDurationAutoHit:",
        @"Fast Knife x1": @"fastKnifeX1:",
        @"Fast Knife x2": @"fastKnifeX2:",
        @"Fast Knife x3": @"fastKnifeX3:",
        @"Fast Knife x4": @"fastKnifeX4:",
        @"Fast Knife x5": @"fastKnifeX5:"
    };

    // Tablica z SF Symbols dla przełączników Killer Left
    NSArray *killerLeftImages = @[
        [UIImage systemImageNamed:@"speedometer"],               // Max Turn Speed
        [UIImage systemImageNamed:@"drop.fill"],                // Extra Bleeding Survivors
        [UIImage systemImageNamed:@"person.crop.circle.badge.xmark"], // Block Players Move
        [UIImage systemImageNamed:@"bolt.heart.fill"],          // Mayers Insta Kill
        [UIImage systemImageNamed:@"figure.walk.motion"],       // Infinity Phase Walk
        [UIImage systemImageNamed:@"arrow.uturn.backward"],     // Back Position (Spirit)
        [UIImage systemImageNamed:@"hand.raised.slash"],        // Disable Survivor Wiggle
        [UIImage systemImageNamed:@"clock.badge.xmark"]         // No Hit Cooldown
    ];

    // Tablica z SF Symbols dla przełączników Killer Right
    NSArray *killerRightImages = @[
        [UIImage systemImageNamed:@"hare.fill"],                // No Speed Cooldown Hit
        [UIImage systemImageNamed:@"infinity.circle.fill"],     // Infinity Buba Chainsaw
        [UIImage systemImageNamed:@"bolt.shield.fill"],         // Infinity Hit Duration + Auto Hit
        [UIImage systemImageNamed:@"1.circle.fill"],            // Fast Knife x1
        [UIImage systemImageNamed:@"2.circle.fill"],            // Fast Knife x2
        [UIImage systemImageNamed:@"3.circle.fill"],            // Fast Knife x3
        [UIImage systemImageNamed:@"4.circle.fill"],            // Fast Knife x4
        [UIImage systemImageNamed:@"5.circle.fill"]             // Fast Knife x5
    ];

    // Dodaj przełączniki w lewej kolumnie Killer
    CGFloat killerLeftContentHeight = switchStartY;
    for (NSUInteger i = 0; i < killerTogglesLeft.count; i++) {
        NSString *title = killerTogglesLeft[i];
        SEL selector = NSSelectorFromString(killerSelectors[title]);
        
        // Stwórz kontener dla ikony i tekstu z gradientowym tłem
        UIView *switchContainer = [[UIView alloc] initWithFrame:CGRectMake(10, killerLeftContentHeight + i * switchSpacing, scrollViewWidth - 20, 30)];
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
        
        // Dodaj ikonę
        UIImageView *iconView = [[UIImageView alloc] initWithImage:killerLeftImages[i]];
        iconView.frame = CGRectMake(5, 5, 20, 20);
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.tintColor = [UIColor whiteColor];
        [switchContainer addSubview:iconView];
        
        // Dodaj etykietę
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, (scrollViewWidth - 20) * 0.7 - 25, 30)];
        label.text = title;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:currentFont size:12];
        [switchContainer addSubview:label];
        



        
        // Dodaj przełącznik
        UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(switchContainer.frame.size.width - 55, 0, 51, 31)];
        toggle.on = [[NSUserDefaults standardUserDefaults] boolForKey:[title stringByReplacingOccurrencesOfString:@" " withString:@""]];
        [toggle addTarget:[NFToggles class] action:selector forControlEvents:UIControlEventValueChanged];
        toggle.onTintColor = [UIColor colorWithCGColor:RightGradient];
        [switchContainer addSubview:toggle];
        
        [killerLeftScrollView addSubview:switchContainer];
        
        killerLeftContentHeight += switchSpacing;
    }











    // Dodaj przełączniki w prawej kolumnie Killer
    CGFloat killerRightContentHeight = switchStartY;
    for (NSUInteger i = 0; i < killerTogglesRight.count; i++) {
        NSString *title = killerTogglesRight[i];
        SEL selector = NSSelectorFromString(killerSelectors[title]);
        
        // Stwórz kontener dla ikony i tekstu z gradientowym tłem
        UIView *switchContainer = [[UIView alloc] initWithFrame:CGRectMake(10, killerRightContentHeight + i * switchSpacing, scrollViewWidth - 20, 30)];
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
        
        // Dodaj ikonę
        UIImageView *iconView = [[UIImageView alloc] initWithImage:killerRightImages[i]];
        iconView.frame = CGRectMake(5, 5, 20, 20);
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.tintColor = [UIColor whiteColor];
        [switchContainer addSubview:iconView];
        
        // Dodaj etykietę
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, (scrollViewWidth - 20) * 0.7 - 25, 30)];
        label.text = title;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont fontWithName:currentFont size:12];
        [switchContainer addSubview:label];
        
        // Dodaj przełącznik
        UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(switchContainer.frame.size.width - 55, 0, 51, 31)];
        toggle.on = [[NSUserDefaults standardUserDefaults] boolForKey:[title stringByReplacingOccurrencesOfString:@" " withString:@""]];
        [toggle addTarget:[NFToggles class] action:selector forControlEvents:UIControlEventValueChanged];
        toggle.onTintColor = [UIColor colorWithCGColor:RightGradient];
        [switchContainer addSubview:toggle];
        
        [killerRightScrollView addSubview:switchContainer];
        
        killerRightContentHeight += switchSpacing;
    }




    // Ustaw contentSize na podstawie wyższej kolumny
    // Wyłącz scrollowanie poziome dla killerLeftScrollView
    killerLeftScrollView.alwaysBounceHorizontal = NO;
    killerLeftScrollView.showsHorizontalScrollIndicator = NO;
    killerLeftScrollView.contentSize = CGSizeMake(scrollViewWidth, MAX(killerLeftContentHeight + 20, 285 + 1));





    // Wyłącz scrollowanie poziome dla killerRightScrollView
    killerRightScrollView.alwaysBounceHorizontal = NO;
    killerRightScrollView.showsHorizontalScrollIndicator = NO;
    killerRightScrollView.contentSize = CGSizeMake(scrollViewWidth, MAX(killerRightContentHeight + 20, 285 + 1));

}

@end 