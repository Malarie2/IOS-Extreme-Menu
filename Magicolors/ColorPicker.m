#import "ColorPicker.h"
#import "Magicolors/ColorsHandler.h"

@interface ColorPickerViewController ()
@property (nonatomic, strong) UISegmentedControl *gradientSegment;
@property (nonatomic, strong) UISlider *colorSlider;
@property (nonatomic, strong) UISlider *saturationSlider;
@property (nonatomic, strong) UISlider *brightnessSlider;
@property (nonatomic, strong) UISlider *alphaSlider;
@property (nonatomic, strong) NSCache *thumbImageCache;
@end

@implementation ColorPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _thumbImageCache = [[NSCache alloc] init];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.85];
    
    // Główny kontener
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 420, 250)];
    containerView.center = self.view.center;
    containerView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.9];
    containerView.layer.cornerRadius = 20;
    containerView.clipsToBounds = YES;
    [self.view addSubview:containerView];

    // Dodaj tylko linie gradientowe na górze i dole kontenera
    CAGradientLayer *topGradient = [CAGradientLayer layer];
    topGradient.frame = CGRectMake(0, 0, containerView.frame.size.width, 1.5);
    topGradient.colors = @[
        (__bridge id)RightGradient,
        (__bridge id)blackColor,
        (__bridge id)blackColor,
        (__bridge id)LeftGradient
    ];
    topGradient.locations = @[@0.0, @0.3, @0.7, @1.0];
    topGradient.startPoint = CGPointMake(0, 0.5);
    topGradient.endPoint = CGPointMake(1, 0.5);
    [containerView.layer addSublayer:topGradient];

    CAGradientLayer *bottomGradient = [CAGradientLayer layer];
    bottomGradient.frame = CGRectMake(0, containerView.frame.size.height - 1.5, containerView.frame.size.width, 1.5);
    bottomGradient.colors = topGradient.colors;
    bottomGradient.locations = topGradient.locations;
    bottomGradient.startPoint = topGradient.startPoint;
    bottomGradient.endPoint = topGradient.endPoint;
    [containerView.layer addSublayer:bottomGradient];

    // Tytuł
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, containerView.frame.size.width, 20)];
    titleLabel.text = @"NINJA FRAMEWORK";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:16];
    [containerView addSubview:titleLabel];

    // Podtytuł
    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, containerView.frame.size.width, 15)];
    subtitleLabel.text = @"Color Picker";
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    subtitleLabel.textColor = [UIColor lightGrayColor];
    subtitleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
    [containerView addSubview:subtitleLabel];

    // Kontener dla segmentu z gradientem
    UIView *segmentContainer = [[UIView alloc] initWithFrame:CGRectMake((containerView.frame.size.width - (containerView.frame.size.width - 120)) / 2, 50, containerView.frame.size.width - 120, 25)];
    segmentContainer.layer.cornerRadius = 10;
    segmentContainer.clipsToBounds = YES;
    [containerView addSubview:segmentContainer];

    // Dodaj gradienty do kontenera segmentu (tło + linie)
    [self addGradientsWithBackgroundToView:segmentContainer];

    // Segment Control z dodaną opcją "Both"
    _gradientSegment = [[UISegmentedControl alloc] initWithItems:@[@"Right", @"Left", @"Both"]];
    _gradientSegment.frame = CGRectMake(2, 2, segmentContainer.frame.size.width - 4, segmentContainer.frame.size.height - 4);
    _gradientSegment.selectedSegmentIndex = 0;
    
    // Dostosuj wygląd segmentu
    _gradientSegment.backgroundColor = [UIColor clearColor];
    [_gradientSegment setTitleTextAttributes:@{
        NSFontAttributeName: [UIFont fontWithName:@"ArialRoundedMTBold" size:12],
        NSForegroundColorAttributeName: [UIColor whiteColor]
    } forState:UIControlStateNormal];
    [_gradientSegment setTitleTextAttributes:@{
        NSFontAttributeName: [UIFont fontWithName:@"ArialRoundedMTBold" size:12],
        NSForegroundColorAttributeName: [UIColor whiteColor]
    } forState:UIControlStateSelected];
    
    // Usuń domyślne tło segmentu
    _gradientSegment.layer.borderWidth = 0;
    _gradientSegment.layer.borderColor = [UIColor clearColor].CGColor;
    
    [_gradientSegment addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    [segmentContainer addSubview:_gradientSegment];

    // Suwak kolorów
    _colorSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 85, containerView.frame.size.width - 40, 20)];
    _colorSlider.minimumValue = 0.0;
    _colorSlider.maximumValue = 1.0;
    _colorSlider.value = 0.0;
    
    _colorSlider.layer.cornerRadius = 10;
    _colorSlider.layer.masksToBounds = YES;
    
    // Tworzenie gradientu dla suwaka
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, _colorSlider.frame.size.width, 20);
    gradientLayer.cornerRadius = 10;
    gradientLayer.colors = @[
        (__bridge id)[UIColor redColor].CGColor,
        (__bridge id)[UIColor yellowColor].CGColor,
        (__bridge id)[UIColor greenColor].CGColor,
        (__bridge id)[UIColor cyanColor].CGColor,
        (__bridge id)[UIColor blueColor].CGColor,
        (__bridge id)[UIColor magentaColor].CGColor,
        (__bridge id)[UIColor redColor].CGColor
    ];
    gradientLayer.startPoint = CGPointMake(0.0, 0.5);
    gradientLayer.endPoint = CGPointMake(1.0, 0.5);
    
    UIGraphicsBeginImageContextWithOptions(gradientLayer.frame.size, NO, 0.0);
    [gradientLayer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [_colorSlider setMinimumTrackImage:gradientImage forState:UIControlStateNormal];
    [_colorSlider setMaximumTrackImage:gradientImage forState:UIControlStateNormal];
    
    [_colorSlider addTarget:self action:@selector(colorSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [containerView addSubview:_colorSlider];

    float sliderHeight = 15;
    float sliderSpacing = 25; // Odstęp między sliderami
    float labelOffset = -12; // Offset dla etykiety nad sliderem
    
    // Saturation - pod RGB sliderem
    UILabel *saturationLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 125 + labelOffset, 100, 15)];
    saturationLabel.text = @"Saturation";
    saturationLabel.textColor = [UIColor whiteColor];
    saturationLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:10];
    [containerView addSubview:saturationLabel];
    
    _saturationSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 125, containerView.frame.size.width - 40, sliderHeight)];
    _saturationSlider.minimumValue = 0.0;
    _saturationSlider.maximumValue = 1.0;
    _saturationSlider.value = 1.0;
    [_saturationSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [containerView addSubview:_saturationSlider];
    
    // Konfiguracja dla saturation slidera
    _saturationSlider.layer.cornerRadius = 7.5; // Połowa wysokości suwaka
    _saturationSlider.layer.masksToBounds = YES;
    [self styleSlider:_saturationSlider];

    // Brightness - pod Saturation
    UILabel *brightnessLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 125 + sliderSpacing + labelOffset, 100, 15)];
    brightnessLabel.text = @"Brightness";
    brightnessLabel.textColor = [UIColor whiteColor];
    brightnessLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:10];
    [containerView addSubview:brightnessLabel];
    
    _brightnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 125 + sliderSpacing, containerView.frame.size.width - 40, sliderHeight)];
    _brightnessSlider.minimumValue = 0.0;
    _brightnessSlider.maximumValue = 1.0;
    _brightnessSlider.value = 1.0;
    [_brightnessSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [containerView addSubview:_brightnessSlider];
    
    // Konfiguracja dla brightness slidera
    _brightnessSlider.layer.cornerRadius = 7.5;
    _brightnessSlider.layer.masksToBounds = YES;
    [self styleSlider:_brightnessSlider];

    // Alpha - pod Brightness
    UILabel *alphaLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 125 + (sliderSpacing * 2) + labelOffset, 100, 15)];
    alphaLabel.text = @"Opacity";
    alphaLabel.textColor = [UIColor whiteColor];
    alphaLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:10];
    [containerView addSubview:alphaLabel];
    
    _alphaSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 125 + (sliderSpacing * 2), containerView.frame.size.width - 40, sliderHeight)];
    _alphaSlider.minimumValue = 0.0;
    _alphaSlider.maximumValue = 1.0;
    _alphaSlider.value = 1.0;
    [_alphaSlider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    [containerView addSubview:_alphaSlider];
    
    // Konfiguracja dla alpha slidera
    _alphaSlider.layer.cornerRadius = 7.5;
    _alphaSlider.layer.masksToBounds = YES;
    [self styleSlider:_alphaSlider];

    [self updateThumbColor];

    // Przyciski z gradientami
    UIView *cancelContainer = [[UIView alloc] initWithFrame:CGRectMake(20, containerView.frame.size.height - 45, 120, 35)];
    cancelContainer.layer.cornerRadius = 10;
    cancelContainer.clipsToBounds = YES;
    [containerView addSubview:cancelContainer];

    UIView *saveContainer = [[UIView alloc] initWithFrame:CGRectMake(containerView.frame.size.width - 140, containerView.frame.size.height - 45, 120, 35)];
    saveContainer.layer.cornerRadius = 10;
    saveContainer.clipsToBounds = YES;
    [containerView addSubview:saveContainer];

    [self addGradientsWithBackgroundToView:cancelContainer];
    [self addGradientsWithBackgroundToView:saveContainer];

    // Przyciski
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelButton.frame = cancelContainer.bounds;
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [cancelContainer addSubview:cancelButton];

    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    saveButton.frame = saveContainer.bounds;
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveColor:) forControlEvents:UIControlEventTouchUpInside];
    [saveContainer addSubview:saveButton];

    [self loadCurrentColor];
}

- (void)segmentChanged:(UISegmentedControl *)sender {
    [self loadCurrentColor];
}

- (void)loadCurrentColor {
    NSString *key = (_gradientSegment.selectedSegmentIndex == 0) ? @"CustomLeftColor" : @"CustomRightColor";
    NSString *colorString = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    if (colorString) {
        NSArray *components = [colorString componentsSeparatedByString:@","];
        if (components.count == 4) {
            _colorSlider.value = [components[0] floatValue];
            [self updateThumbColor];
        }
    }
}

- (void)saveColor:(UIButton *)sender {
    if (self.colorSelectedHandler) {
        UIColor *selectedColor = [UIColor colorWithHue:_colorSlider.value 
                                          saturation:_saturationSlider.value 
                                          brightness:_brightnessSlider.value 
                                             alpha:_alphaSlider.value];
        
        if (_gradientSegment.selectedSegmentIndex == 2) {
            self.colorSelectedHandler(selectedColor, @"both");
        } else {
            NSString *gradientType = (_gradientSegment.selectedSegmentIndex == 0) ? @"left" : @"right";
            self.colorSelectedHandler(selectedColor, gradientType);
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)colorSliderChanged:(UISlider *)slider {
    [self updateThumbColor];
}

- (void)updateThumbColor {
    UIColor *currentColor = [UIColor colorWithHue:_colorSlider.value 
                                     saturation:_saturationSlider.value 
                                     brightness:_brightnessSlider.value 
                                        alpha:_alphaSlider.value];
    UIImage *thumbImage = [self createThumbImageWithColor:currentColor];
    [_colorSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    
    // Aktualizuj tła suwaków
    [self updateSliderBackgrounds];
}

- (UIImage *)createThumbImageWithColor:(UIColor *)color {
    NSString *cacheKey = [NSString stringWithFormat:@"%@", color];
    UIImage *cachedImage = [_thumbImageCache objectForKey:cacheKey];
    if (cachedImage) return cachedImage;
    
    CGSize size = CGSizeMake(20, 20);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect outerRect = CGRectMake(0, 0, size.width, size.height);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillEllipseInRect(context, outerRect);
    
    CGRect innerRect = CGRectMake(2, 2, size.width - 4, size.height - 4);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillEllipseInRect(context, innerRect);
    
    UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [_thumbImageCache setObject:thumbImage forKey:cacheKey];
    return thumbImage;
}

- (void)addGradientsWithBackgroundToView:(UIView *)view {
    CAGradientLayer *mainGradient = [CAGradientLayer layer];
    mainGradient.frame = view.bounds;
    mainGradient.colors = @[
        (__bridge id)RightGradient,
        (__bridge id)blackColor,
        (__bridge id)blackColor,
        (__bridge id)LeftGradient
    ];
    mainGradient.locations = @[@0.0, @0.3, @0.7, @1.0];
    mainGradient.startPoint = CGPointMake(0, 0.5);
    mainGradient.endPoint = CGPointMake(1, 0.5);
    [view.layer insertSublayer:mainGradient atIndex:0];

    [self addGradientsToView:view];
}

- (void)addGradientsToView:(UIView *)view {
    CAGradientLayer *topGradient = [CAGradientLayer layer];
    topGradient.frame = CGRectMake(0, 0, view.frame.size.width, 1.5);
    topGradient.colors = @[
        (__bridge id)RightGradient,
        (__bridge id)blackColor,
        (__bridge id)blackColor,
        (__bridge id)LeftGradient
    ];
    topGradient.locations = @[@0.0, @0.3, @0.7, @1.0];
    topGradient.startPoint = CGPointMake(0, 0.5);
    topGradient.endPoint = CGPointMake(1, 0.5);
    [view.layer addSublayer:topGradient];

    CAGradientLayer *bottomGradient = [CAGradientLayer layer];
    bottomGradient.frame = CGRectMake(0, view.frame.size.height - 1.5, view.frame.size.width, 1.5);
    bottomGradient.colors = topGradient.colors;
    bottomGradient.locations = topGradient.locations;
    bottomGradient.startPoint = topGradient.startPoint;
    bottomGradient.endPoint = topGradient.endPoint;
    [view.layer addSublayer:bottomGradient];
}

- (void)updateSliderBackgrounds {
    // Tło dla suwaka nasycenia
    CAGradientLayer *saturationGradient = [CAGradientLayer layer];
    saturationGradient.frame = CGRectMake(0, 0, _saturationSlider.frame.size.width, 15);
    saturationGradient.cornerRadius = 7.5;
    saturationGradient.colors = @[
        (__bridge id)[UIColor colorWithHue:_colorSlider.value saturation:0.0 brightness:_brightnessSlider.value alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithHue:_colorSlider.value saturation:1.0 brightness:_brightnessSlider.value alpha:1.0].CGColor
    ];
    saturationGradient.startPoint = CGPointMake(0.0, 0.5);
    saturationGradient.endPoint = CGPointMake(1.0, 0.5);
    
    // Tło dla suwaka jasności
    CAGradientLayer *brightnessGradient = [CAGradientLayer layer];
    brightnessGradient.frame = CGRectMake(0, 0, _brightnessSlider.frame.size.width, 15);
    brightnessGradient.cornerRadius = 7.5;
    brightnessGradient.colors = @[
        (__bridge id)[UIColor colorWithHue:_colorSlider.value saturation:_saturationSlider.value brightness:0.0 alpha:1.0].CGColor,
        (__bridge id)[UIColor colorWithHue:_colorSlider.value saturation:_saturationSlider.value brightness:1.0 alpha:1.0].CGColor
    ];
    brightnessGradient.startPoint = CGPointMake(0.0, 0.5);
    brightnessGradient.endPoint = CGPointMake(1.0, 0.5);
    
    // Tło dla suwaka alpha
    CAGradientLayer *alphaGradient = [CAGradientLayer layer];
    alphaGradient.frame = CGRectMake(0, 0, _alphaSlider.frame.size.width, 15);
    alphaGradient.cornerRadius = 7.5;
    alphaGradient.colors = @[
        (__bridge id)[UIColor colorWithHue:_colorSlider.value saturation:_saturationSlider.value brightness:_brightnessSlider.value alpha:0.0].CGColor,
        (__bridge id)[UIColor colorWithHue:_colorSlider.value saturation:_saturationSlider.value brightness:_brightnessSlider.value alpha:1.0].CGColor
    ];
    alphaGradient.startPoint = CGPointMake(0.0, 0.5);
    alphaGradient.endPoint = CGPointMake(1.0, 0.5);
    
    // Renderowanie gradientów do obrazów z zachowaniem przezroczystości
    UIImage *saturationImage = [self imageFromGradientLayer:saturationGradient];
    UIImage *brightnessImage = [self imageFromGradientLayer:brightnessGradient];
    UIImage *alphaImage = [self imageFromGradientLayer:alphaGradient];
    
    [_saturationSlider setMinimumTrackImage:saturationImage forState:UIControlStateNormal];
    [_saturationSlider setMaximumTrackImage:saturationImage forState:UIControlStateNormal];
    [_brightnessSlider setMinimumTrackImage:brightnessImage forState:UIControlStateNormal];
    [_brightnessSlider setMaximumTrackImage:brightnessImage forState:UIControlStateNormal];
    [_alphaSlider setMinimumTrackImage:alphaImage forState:UIControlStateNormal];
    [_alphaSlider setMaximumTrackImage:alphaImage forState:UIControlStateNormal];
}

- (UIImage *)imageFromGradientLayer:(CAGradientLayer *)layer {
    UIGraphicsBeginImageContextWithOptions(layer.frame.size, NO, 0.0);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)sliderChanged:(UISlider *)slider {
    [self updateThumbColor];
}

- (void)styleSlider:(UISlider *)slider {
    // Ustaw małe kółko jako thumb dla wszystkich suwaków
    UIImage *thumbImage = [self createSmallThumbImage];
    [slider setThumbImage:thumbImage forState:UIControlStateNormal];
    [slider setThumbImage:thumbImage forState:UIControlStateHighlighted];
}

- (UIImage *)createSmallThumbImage {
    CGSize size = CGSizeMake(15, 15);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect outerRect = CGRectMake(0, 0, size.width, size.height);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillEllipseInRect(context, outerRect);
    
    CGRect innerRect = CGRectMake(1.5, 1.5, size.width - 3, size.height - 3);
    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.2 alpha:1.0].CGColor);
    CGContextFillEllipseInRect(context, innerRect);
    
    UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return thumbImage;
}

@end 