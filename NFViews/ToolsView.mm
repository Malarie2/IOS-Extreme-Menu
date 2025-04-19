#import "ToolsView.h"
#import "IGGMemView.h"
#import "Utils/NakanoNino.h"
#import "Utils/NakanoMiku.h"
#import "Utils/NFPatch.h"
#import "Utils/NakanoItsuki.h"
#import "KittyMemory/MemoryPatch.hpp"
#import "Cheat/Globals.h"
#import "Cheat/Pointers.h"
#import "Cheat/Utils.h"
#import "Magicolors/ColorsHandler.h"
#import "../Macros.h"
#import "../NFrameworkObserver.h"
#import "ESPView.h" // Dodaj import ESPView
#import "CustomSlider.h"
#import "Magicolors/ColorsHandler.h"


// Static variables declarations
// Zmień definicje na deklaracje extern
extern NSMutableDictionary *appliedPatches;
extern NSMutableDictionary *originalBytes;
static float sliderValue = 0.0;
static NSString *lastMSHookOffset = nil;
static float lastMSHookSliderValue = 50.0;
static float (*original_function)(void *instance);
static BOOL hooksInstalled = NO;
static UIView *menuView;
static UIScrollView *drawScrollView = nil; // Dodaj tę linię


@implementation ToolsView

// Property implementations
@dynamic sliderValue;
@dynamic lastMSHookOffset;
@dynamic lastMSHookSliderValue;
@dynamic menuView;
@dynamic drawScrollView; // Dodaj tę linię

+ (UIView *)menuView {
    return menuView;
}

+ (void)setMenuView:(UIView *)view {
    menuView = view;
}

// Zamień showNotification na ShowAlert
+ (void)showNotification:(NSString *)title message:(NSString *)message duration:(NSTimeInterval)duration {
    ShowAlert(title, message);
}

+ (void)applyPatchWithOffset:(UIButton *)sender {
    UIScrollView *toolsScrollView = [menuView viewWithTag:9];
    UITextField *offsetField = [toolsScrollView viewWithTag:11];
    UITextField *valueField = [toolsScrollView viewWithTag:12];
    
    NSString *offsetString = offsetField.text;
    NSString *valueString = valueField.text;
    
    if (offsetString.length > 0 && valueString.length > 0) {
        uintptr_t offset;
        uint64_t value;
        
        offset = strtoull([offsetString UTF8String], NULL, 16);
        value = strtoull([valueString UTF8String], NULL, 16);
        
        NSLog(@"Applying patch - Offset: 0x%lx, Value: 0x%llx", offset, value);
        
        // Use KittyMemory to patch
        MemoryPatch patch = MemoryPatch::createWithHex(0, offset, [valueString UTF8String]);
        
        if (patch.Modify()) {
            NSLog(@"Patch applied successfully");
            
            // Save pointer to MemoryPatch object
            MemoryPatch *patchPtr = new MemoryPatch(patch);
            [appliedPatches setObject:[NSValue valueWithPointer:patchPtr] forKey:@(offset)];
            
            [self showNotification:@"Ninja Framework" message:@"The offset has been patched successfully." duration:2.0];
        } else {
            NSLog(@"Patch failed to apply");
            
            [self showNotification:@"Ninja Framework" message:@"Failed to apply the patch." duration:2.0];
        }
    } else {
        [self showNotification:@"Ninja Framework" message:@"Please enter both offset and value." duration:2.0];
    }
}

+ (void)restorePatchWithOffset:(UIButton *)sender {
    UIScrollView *toolsScrollView = [menuView viewWithTag:9];
    UITextField *offsetField = [toolsScrollView viewWithTag:11];
    
    NSString *offsetString = offsetField.text;
    
    if (offsetString.length > 0) {
        uintptr_t offset;
        
        offset = strtoull([offsetString UTF8String], NULL, 16);
        
        NSLog(@"Attempting to restore patch for offset: 0x%lx", offset);
        
        NSValue *patchValue = [appliedPatches objectForKey:@(offset)];
        
        if (patchValue) {
            MemoryPatch *patch = (MemoryPatch *)[patchValue pointerValue];
            
            if (patch && patch->Restore()) {
                NSLog(@"Patch restored successfully");
                [appliedPatches removeObjectForKey:@(offset)];
                
                [self showNotification:@"Ninja Framework" message:@"The offset has been restored to its original value." duration:2.0];
            } else {
                NSLog(@"Failed to restore patch");
                
                [self showNotification:@"Ninja Framework" message:@"Failed to restore the patch." duration:2.0];
            }
        } else {
            NSLog(@"No patch found for offset: 0x%lx", offset);
            [self showNotification:@"Ninja Framework" message:@"No patch found for this offset." duration:2.0];
        }
    } else {
        [self showNotification:@"Ninja Framework" message:@"Please enter an offset." duration:2.0];
    }
}
+ (void)applyEllekitHook:(UIButton *)sender {
    UIScrollView *ellekitScrollView = (UIScrollView *)sender.superview;
    UITextField *offsetField = [ellekitScrollView viewWithTag:42];
    UITextField *valueField = [ellekitScrollView viewWithTag:43];
    UISlider *slider = [ellekitScrollView viewWithTag:44];
    
    NSString *offsetString = offsetField.text;
    NSString *valueString;
    
    if (valueField.hidden) {
        valueString = [NSString stringWithFormat:@"%.2f", slider.value];
    } else {
        valueString = valueField.text;
    }
    
    if (offsetString.length > 0 && valueString.length > 0) {
        // Tutaj dodaj właściwą implementację hooka
        [self showNotification:@"Ninja Framework" message:@"Ellekit Hook applied successfully." duration:2.0];
    } else {
        [self showNotification:@"Ninja Framework" message:@"Please enter both offset and value." duration:2.0];
    }
}

+ (void)removeEllekitHook:(UIButton *)sender {
    UIScrollView *ellekitScrollView = (UIScrollView *)sender.superview;
    UITextField *offsetField = [ellekitScrollView viewWithTag:42];
    
    NSString *offsetString = offsetField.text;
    
    if (offsetString.length > 0) {
        // Tutaj dodaj właściwą implementację usuwania hooka
        [self showNotification:@"Ninja Framework" message:@"Ellekit Hook removed successfully." duration:2.0];
    } else {
        [self showNotification:@"Ninja Framework" message:@"Please enter an offset." duration:2.0];
    }
}


+ (void)createJailbreakPatcherInView:(UIView *)view {
    CGFloat menuWidth = view.frame.size.width;
    

    UITextField *offsetField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, (menuWidth - 20) / 2 - 5, 30)];
    offsetField.placeholder = @"Offset (e.g., 1234567)";
    offsetField.textColor = [UIColor whiteColor];
    offsetField.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    offsetField.layer.cornerRadius = 5;
    offsetField.layer.borderWidth = 1;
    offsetField.layer.masksToBounds = YES;
    [offsetField.layer addSublayer:[self createGradientLayer:offsetField.bounds]];
    offsetField.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
    offsetField.tag = 11;
    offsetField.textAlignment = NSTextAlignmentCenter;
    offsetField.delegate = [self textFieldDelegate];
    offsetField.returnKeyType = UIReturnKeyDone;
    [view addSubview:offsetField];

    UITextField *valueField = [[UITextField alloc] initWithFrame:CGRectMake((menuWidth - 20) / 2 + 15, 10, (menuWidth - 20) / 2 - 5, 30)];
    valueField.placeholder = @"Value (e.g., 00F0271E)";
    valueField.textColor = [UIColor whiteColor];
    valueField.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    valueField.layer.cornerRadius = 5;
    valueField.layer.borderWidth = 1;
    valueField.layer.masksToBounds = YES;
    [valueField.layer addSublayer:[self createGradientLayer:valueField.bounds]];
    valueField.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
    valueField.tag = 12;
    valueField.textAlignment = NSTextAlignmentCenter;
    valueField.delegate = [self textFieldDelegate];
    valueField.returnKeyType = UIReturnKeyDone;
    [view addSubview:valueField];

    UIButton *patchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    patchButton.frame = CGRectMake(10, 50, (menuWidth - 20) / 2 - 5, 30);
    [patchButton setTitle:@"Apply Patch" forState:UIControlStateNormal];
    [patchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    patchButton.layer.cornerRadius = 5;
    patchButton.layer.masksToBounds = YES;
    [patchButton.layer addSublayer:[self createGradientLayer:patchButton.bounds]];
    [patchButton addTarget:self action:@selector(applyPatchWithOffset:) forControlEvents:UIControlEventTouchUpInside];
    patchButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    patchButton.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:15];
    [view addSubview:patchButton];

    UIButton *restoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    restoreButton.frame = CGRectMake((menuWidth - 20) / 2 + 15, 50, (menuWidth - 20) / 2 - 5, 30);
    [restoreButton setTitle:@"Restore Patch" forState:UIControlStateNormal];
    [restoreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    restoreButton.layer.cornerRadius = 5;
    restoreButton.layer.masksToBounds = YES;
    [restoreButton.layer addSublayer:[self createGradientLayer:restoreButton.bounds]];
    [restoreButton addTarget:self action:@selector(restorePatchWithOffset:) forControlEvents:UIControlEventTouchUpInside];
    restoreButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    restoreButton.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:15];
    [view addSubview:restoreButton];

    UILabel *warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 90, menuWidth - 20, 60)];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"This offset patcher is intended for jailbroken users only.\nAttempting to use it on a non-jailbroken device will result in a game crash!\n\nNinja Framework provides safe offsets patching in memory."];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ArialRoundedMTBold" size:12] range:NSMakeRange(0, attributedString.length - 58)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ArialRoundedMTBold" size:9] range:NSMakeRange(attributedString.length - 58, 58)];
    warningLabel.attributedText = attributedString;
    warningLabel.textColor = [UIColor grayColor];
    warningLabel.numberOfLines = 0;
    warningLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:warningLabel];
}
+ (void)createJailedPatcherInView:(UIView *)view {
    CGFloat menuWidth = view.frame.size.width;
   

    UITextField *offsetField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, (menuWidth - 20) / 2 - 5, 30)];
    offsetField.placeholder = @"Offset (e.g., 1234567)";
    offsetField.textColor = [UIColor whiteColor];
    offsetField.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    offsetField.layer.cornerRadius = 5;
    offsetField.layer.borderWidth = 1;
    offsetField.layer.masksToBounds = YES;
    [offsetField.layer addSublayer:[self createGradientLayer:offsetField.bounds]];
    offsetField.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
    offsetField.tag = 16;
    offsetField.textAlignment = NSTextAlignmentCenter;
    offsetField.delegate = [self textFieldDelegate];
    offsetField.returnKeyType = UIReturnKeyDone;
    [view addSubview:offsetField];

    UITextField *valueField = [[UITextField alloc] initWithFrame:CGRectMake((menuWidth -20) / 2 + 15, 10, (menuWidth - 20) / 2 - 5, 30)];
    valueField.placeholder = @"Value (e.g., 00F0271E)";
    valueField.textColor = [UIColor whiteColor];
    valueField.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    valueField.layer.cornerRadius = 5;
    valueField.layer.borderWidth = 1;
    valueField.layer.masksToBounds = YES;
    [valueField.layer addSublayer:[self createGradientLayer:valueField.bounds]];
    valueField.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
    valueField.tag = 17;
    valueField.textAlignment = NSTextAlignmentCenter;
    valueField.delegate = [self textFieldDelegate];
    valueField.returnKeyType = UIReturnKeyDone;
    [view addSubview:valueField];

    UIButton *patchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    patchButton.frame = CGRectMake(10, 50, menuWidth - 20, 30);
    [patchButton setTitle:@"Apply VM Patch" forState:UIControlStateNormal];
    [patchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    patchButton.layer.cornerRadius = 5;
    patchButton.layer.masksToBounds = YES;
    [patchButton.layer addSublayer:[self createGradientLayer:patchButton.bounds]];
    [patchButton addTarget:self action:@selector(applyVMPatchWithOffset:) forControlEvents:UIControlEventTouchUpInside];
    patchButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    patchButton.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:15];
    [view addSubview:patchButton];

    UILabel *warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 90, menuWidth - 20, 60)];
    NSString *warningText = @"This offset patcher is intended for jailed users.\nJIT is required to use it!\n\nNinja Framework provides safe offsets patching in memory.";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:warningText];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ArialRoundedMTBold" size:12] range:NSMakeRange(0, warningText.length - 58)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ArialRoundedMTBold" size:9] range:NSMakeRange(warningText.length - 58, 58)];
    warningLabel.attributedText = attributedString;
    warningLabel.textColor = [UIColor grayColor];
    warningLabel.numberOfLines = 0;
    warningLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:warningLabel];
}

+ (void)jailbreakSegmentChanged:(UISegmentedControl *)sender {
    UIView *jailbreakView = [menuView viewWithTag:14];
    UIView *jailedView = [menuView viewWithTag:15];
    
    if (sender.selectedSegmentIndex == 0) {
        jailbreakView.hidden = NO;
        jailedView.hidden = YES;
    } else {
        jailbreakView.hidden = YES;
        jailedView.hidden = NO;
    }
}


+ (void)applyVMPatchWithOffset:(UIButton *)sender {
    UIScrollView *toolsScrollView = [menuView viewWithTag:9];
    UITextField *offsetField = [toolsScrollView viewWithTag:16];
    UITextField *valueField = [toolsScrollView viewWithTag:17];
    
    NSString *offsetString = offsetField.text;
    NSString *valueString = valueField.text;
    
    if (offsetString.length > 0 && valueString.length > 0) {
        uintptr_t offset;
        uint64_t value;
        
        offset = strtoull([offsetString UTF8String], NULL, 16);
        value = strtoull([valueString UTF8String], NULL, 16);
        
        NSLog(@"Applying VM patch - Offset: 0x%lx, Value: 0x%llx", offset, value);
        
        @try {
            vm(offset, value);
            NSLog(@"VM patch applied successfully");
            
            [self showNotification:@"Ninja Framework" message:@"The VM offset has been patched successfully." duration:2.0];
        } @catch (NSException *exception) {
            NSLog(@"Exception occurred while applying VM patch: %@", exception);
            
            [self showNotification:@"Ninja Framework" message:[NSString stringWithFormat:@"An error occurred while applying the patch: %@", exception.reason] duration:2.0];
        }
    } else {
        [self showNotification:@"Ninja Framework" message:@"Please enter both offset and value." duration:2.0];
    }
}



+ (UIScrollView *)createEllekitHookView:(UIView *)view {
    // Zmień menuView = view na:
    // Nie przypisujemy do menuView, używamy przekazanego view
    CGFloat menuWidth = 620;
    CGFloat labelHeight = 25;
    CGFloat switchAreaHeight = 210;

    // Calculate the height of the tools scroll view to reach the footer
    CGFloat toolsScrollViewHeight = 225;

    UIScrollView *ellekitScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(-1, 0, menuWidth, toolsScrollViewHeight)];
    ellekitScrollView.backgroundColor = [UIColor clearColor];
    ellekitScrollView.userInteractionEnabled = YES;
    ellekitScrollView.scrollEnabled = YES;
    ellekitScrollView.showsVerticalScrollIndicator = YES;
    ellekitScrollView.bounces = NO;
    ellekitScrollView.tag = 38;

    // Add title label
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, menuWidth, labelHeight)];
    titleLabel.text = @"Ellekit Hook Function";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:16];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.tag = 39;
    [ellekitScrollView addSubview:titleLabel];

    // Add small gray label
    UILabel *smallGrayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, labelHeight, menuWidth, 15)];
    smallGrayLabel.text = @"Advanced Ellekit Hook Function for jailed (JIT) devices";
    smallGrayLabel.textColor = [UIColor grayColor];
    smallGrayLabel.font = [UIFont systemFontOfSize:10];
    smallGrayLabel.textAlignment = NSTextAlignmentCenter;
    smallGrayLabel.tag = 40;
    [ellekitScrollView addSubview:smallGrayLabel];

    // Add Slider/Textfield segment control
    UISegmentedControl *sliderTextfieldSegment = [[UISegmentedControl alloc] initWithItems:@[@"Slider", @"Textfield"]];
    CGFloat segmentWidth = 140;
    CGFloat segmentHeight = 25;
    sliderTextfieldSegment.frame = CGRectMake((menuWidth - segmentWidth) / 2, labelHeight + 13 + 2, segmentWidth, segmentHeight);
    sliderTextfieldSegment.selectedSegmentIndex = 0;
    sliderTextfieldSegment.tintColor = [UIColor whiteColor];
    [sliderTextfieldSegment addTarget:self action:@selector(ellekitSliderTextfieldChanged:) forControlEvents:UIControlEventValueChanged];
    sliderTextfieldSegment.layer.cornerRadius = segmentHeight / 2;
    sliderTextfieldSegment.layer.masksToBounds = YES;
    sliderTextfieldSegment.tag = 41;
    [ellekitScrollView addSubview:sliderTextfieldSegment];

    CGFloat viewsTopMargin = 32 + segmentHeight + 13 + 1.5;

    // Add offset field
    UITextField *offsetField = [[UITextField alloc] initWithFrame:CGRectMake(10, viewsTopMargin, (menuWidth - 20) / 2 - 5, 30)];
    offsetField.placeholder = @"Offset (e.g., 1234567)";
    offsetField.textColor = [UIColor whiteColor];
    offsetField.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    offsetField.layer.cornerRadius = 5;
    offsetField.layer.borderWidth = 1;
    offsetField.layer.masksToBounds = YES;
    [offsetField.layer addSublayer:[self createGradientLayer:offsetField.bounds]];
    offsetField.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
    offsetField.tag = 42;
    offsetField.textAlignment = NSTextAlignmentCenter;
    offsetField.delegate = [self textFieldDelegate];
    offsetField.returnKeyType = UIReturnKeyDone;
    [ellekitScrollView addSubview:offsetField];

    // Add value field
    UITextField *valueField = [[UITextField alloc] initWithFrame:CGRectMake((menuWidth - 20) / 2 + 15, viewsTopMargin, (menuWidth - 20) / 2 - 5, 30)];
    valueField.placeholder = @"Value (e.g., 00F0271E)";
    valueField.textColor = [UIColor whiteColor];
    valueField.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    valueField.layer.cornerRadius = 5;
    valueField.layer.borderWidth = 1;
    valueField.layer.masksToBounds = YES;
    [valueField.layer addSublayer:[self createGradientLayer:valueField.bounds]];
    valueField.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
    valueField.tag = 43;
    valueField.textAlignment = NSTextAlignmentCenter;
    valueField.delegate = [self textFieldDelegate];
    valueField.returnKeyType = UIReturnKeyDone;
    valueField.hidden = YES;
    [ellekitScrollView addSubview:valueField];

    // Add slider
    UISlider *slider = [[UISlider alloc] initWithFrame:valueField.frame];
    slider.minimumValue = 0;
    slider.maximumValue = 100;
    slider.value = 50;
    slider.tag = 44;
    [slider addTarget:self action:@selector(ellekitSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    CAGradientLayer *gradientLayer = [self createGradientLayer:slider.bounds];
    [slider.layer insertSublayer:gradientLayer atIndex:0];
    
    slider.backgroundColor = [UIColor clearColor];
    slider.layer.cornerRadius = 5;
    slider.layer.masksToBounds = YES;
    
    [slider setThumbTintColor:[UIColor whiteColor]];
    [slider setMinimumTrackTintColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
    [slider setMaximumTrackTintColor:[UIColor colorWithWhite:1.0 alpha:0.2]];
    
    [ellekitScrollView addSubview:slider];

    // Add buttons
    UIButton *hookButton = [UIButton buttonWithType:UIButtonTypeCustom];
    hookButton.frame = CGRectMake(10, viewsTopMargin + 40, (menuWidth - 20) / 2 - 5, 30);
    [hookButton setTitle:@"Apply Ellekit Hook" forState:UIControlStateNormal];
    [hookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    hookButton.layer.cornerRadius = 5;
    hookButton.layer.masksToBounds = YES;
    [hookButton.layer addSublayer:[self createGradientLayer:hookButton.bounds]];
    [hookButton addTarget:self action:@selector(applyEllekitHook:) forControlEvents:UIControlEventTouchUpInside];
    hookButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    hookButton.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:15];
    [ellekitScrollView addSubview:hookButton];

    UIButton *unhookButton = [UIButton buttonWithType:UIButtonTypeCustom];
    unhookButton.frame = CGRectMake((menuWidth - 20) / 2 + 15, viewsTopMargin + 40, (menuWidth - 20) / 2 - 5, 30);
    [unhookButton setTitle:@"Remove Ellekit Hook" forState:UIControlStateNormal];
    [unhookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    unhookButton.layer.cornerRadius = 5;
    unhookButton.layer.masksToBounds = YES;
    [unhookButton.layer addSublayer:[self createGradientLayer:unhookButton.bounds]];
    [unhookButton addTarget:self action:@selector(removeEllekitHook:) forControlEvents:UIControlEventTouchUpInside];
    unhookButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    unhookButton.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:15];
    [ellekitScrollView addSubview:unhookButton];

    // Add warning label
    UILabel *warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, viewsTopMargin + 80, menuWidth - 20, 60)];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"This Ellekit Hooking is intended for jailed (JIT) users only.\nAttempting to use it without a JIT device will result in a game crash!\n\nNinja Framework provides safe function hooking in memory."];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ArialRoundedMTBold" size:12] range:NSMakeRange(0, attributedString.length - 58)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ArialRoundedMTBold" size:9] range:NSMakeRange(attributedString.length - 58, 58)];
    warningLabel.attributedText = attributedString;
    warningLabel.textColor = [UIColor grayColor];
    warningLabel.numberOfLines = 0;
    warningLabel.textAlignment = NSTextAlignmentCenter;
    [ellekitScrollView addSubview:warningLabel];

    // Set content size
    ellekitScrollView.contentSize = CGSizeMake(menuWidth, MAX(toolsScrollViewHeight, warningLabel.frame.origin.y + warningLabel.frame.size.height + 20));

    return ellekitScrollView;
}

// Dodaj metodę do obsługi zmiany wartości slidera
+ (void)ellekitSliderValueChanged:(UISlider *)sender {
    // Tutaj możesz dodać logikę obsługi zmiany wartości slidera
}

+ (void)ellekitSliderTextfieldChanged:(UISegmentedControl *)sender {
    UIScrollView *ellekitScrollView = (UIScrollView *)sender.superview;
    UITextField *valueField = [ellekitScrollView viewWithTag:43];
    UISlider *slider = [ellekitScrollView viewWithTag:44];
    
    if (sender.selectedSegmentIndex == 0) {
        valueField.hidden = YES;
        slider.hidden = NO;
    } else {
        valueField.hidden = NO;
        slider.hidden = YES;
    }
}

+ (void)updateToolsColors {
    UIScrollView *toolsScrollView = [menuView viewWithTag:9];
    UIScrollView *msHookScrollView = [menuView viewWithTag:29];
    UIScrollView *ellekitScrollView = [menuView viewWithTag:38];
    
    NSArray *viewsToUpdate = @[toolsScrollView, msHookScrollView, ellekitScrollView];
    
    for (UIScrollView *scrollView in viewsToUpdate) {
        for (UIView *subview in scrollView.subviews) {
            if ([subview isKindOfClass:[UIView class]] && (subview.tag == 14 || subview.tag == 15 || subview.tag == 38)) {
                // To są widoki Jailbreak, Jailed w Offset Patcher oraz Ellekit
                for (UIView *childView in subview.subviews) {
                    [self updateGradientForView:childView withColor:[UIColor colorWithCGColor:RightGradient]];
                }
            } else {
                // To s elementy w MSHook i Ellekit Hook
                [self updateGradientForView:subview withColor:[UIColor colorWithCGColor:RightGradient]];
            }
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



// Zmodyfikuj metodę textFieldDelegate, aby obsłużyć zamykanie klawiatury
+ (id<UITextFieldDelegate>)textFieldDelegate {
    return (id<UITextFieldDelegate>)self;
}

// Dodaj tę metodę do implementacji NFramework
+ (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}



+ (void)createToolsView:(UIView *)view {
    menuView = view;
    CGFloat menuWidth = 620;
    CGFloat labelHeight = 25;
    CGFloat footerHeight = 30; // Define footer height
    CGFloat gradientLineHeight = 2; // Define gradient line height
    CGFloat switchAreaHeight = 210;
 [[NFrameworkObserver sharedObserver] setMenuView:menuView];
    
   
    // Calculate the top position of the tools scroll view
    CGFloat topPosition = 67.3333 + labelHeight + 5;

    // Calculate the height of the tools scroll view to reach the footer
    CGFloat toolsScrollViewHeight = 250;

    UIScrollView *toolsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.666667, 66, menuWidth, toolsScrollViewHeight)];
    toolsScrollView.backgroundColor = [UIColor clearColor];
    toolsScrollView.userInteractionEnabled = YES;
    toolsScrollView.scrollEnabled = NO;
    toolsScrollView.showsVerticalScrollIndicator = YES;
    toolsScrollView.bounces = YES;
    toolsScrollView.hidden = YES;
    toolsScrollView.tag = 9;
    [menuView addSubview:toolsScrollView];

    UILabel *toolsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.666667, 67.3333, menuWidth, labelHeight)];
    toolsLabel.text = @"Ninja Patcher";
    toolsLabel.textColor = [UIColor whiteColor];
    toolsLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:16];
    toolsLabel.textAlignment = NSTextAlignmentCenter;
    toolsLabel.hidden = YES;
    toolsLabel.tag = 10;
    [menuView addSubview:toolsLabel];

    UILabel *smallGrayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.666667, 67.3333 + labelHeight, menuWidth , 15)];
    smallGrayLabel.text = @"Small built-in Offset Patcher for testing";
    smallGrayLabel.textColor = [UIColor grayColor];
    smallGrayLabel.font = [UIFont systemFontOfSize:10];
    smallGrayLabel.textAlignment = NSTextAlignmentCenter;
    smallGrayLabel.hidden = YES;
    smallGrayLabel.tag = 13;
    [menuView addSubview:smallGrayLabel];

    // Add Jailbreak/Jailed segmented control centered in the Tools tab
    UISegmentedControl *jailbreakSegment = [[UISegmentedControl alloc] initWithItems:@[@"JB", @"Non-JB"]];
    CGFloat segmentWidth = 120;
    CGFloat segmentHeight = 25;
    jailbreakSegment.frame = CGRectMake((menuWidth - segmentWidth) / 2, 44, segmentWidth, segmentHeight);
    jailbreakSegment.selectedSegmentIndex = 0;
    jailbreakSegment.tintColor = [UIColor whiteColor];
    [jailbreakSegment addTarget:self action:@selector(jailbreakSegmentChanged:) forControlEvents:UIControlEventValueChanged];
    jailbreakSegment.layer.cornerRadius = segmentHeight / 2;
    jailbreakSegment.layer.masksToBounds = YES;
    
    // Customize the appearance
    [jailbreakSegment setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]} forState:UIControlStateNormal];
    [jailbreakSegment setBackgroundColor:[UIColor colorWithWhite:0.2 alpha:1.0]];
    
    [toolsScrollView addSubview:jailbreakSegment];

    // Adjust the position of Jailbreak and Jailed views
    CGFloat viewsTopMargin = 32 + segmentHeight + 10; // Increased to make room for the segment control
    
    // Jailbreak view
    UIView *jailbreakView = [[UIView alloc] initWithFrame:CGRectMake(0, viewsTopMargin, menuWidth , toolsScrollViewHeight)];
    jailbreakView.tag = 14;
    [toolsScrollView addSubview:jailbreakView];

    // Jailed view
    UIView *jailedView = [[UIView alloc] initWithFrame:CGRectMake(0, viewsTopMargin, menuWidth , toolsScrollViewHeight - viewsTopMargin)];
    jailedView.tag = 15;
    jailedView.hidden = YES;
    [toolsScrollView addSubview:jailedView];

    [self createJailbreakPatcherInView:jailbreakView];
    [self createJailedPatcherInView:jailedView];
    // Add new segmented control for Ninja options
    UISegmentedControl *ninjaSegment = [[UISegmentedControl alloc] initWithItems:@[@"Patcher", @"MSHook", @"Elle Hook", @"Memory", @"Network", @"Draw"]];

    // Make the segmented control smaller and center it
    CGFloat ninjaSegmentWidth = menuWidth * 0.9; // Reduce width to 60% of menuWidth
    CGFloat ninjaSegmentHeight = 20; // Adjust height as needed
    ninjaSegment.frame = CGRectMake((menuWidth - ninjaSegmentWidth) / 2, 216, ninjaSegmentWidth, ninjaSegmentHeight);

    ninjaSegment.selectedSegmentIndex = 0;
    ninjaSegment.tintColor = [UIColor whiteColor];
    [ninjaSegment addTarget:self action:@selector(ninjaSegmentChanged:) forControlEvents:UIControlEventValueChanged];
    [toolsScrollView addSubview:ninjaSegment];

    // Bring the segmented control to the front
    [toolsScrollView bringSubviewToFront:ninjaSegment];

    // Create views for MS Hook and Ellekit Hook
    UIScrollView *msHookScrollView = [self createMSHookView:menuView];
    msHookScrollView.tag = 29;
    msHookScrollView.hidden = YES;
   
    [toolsScrollView addSubview:msHookScrollView];

    UIScrollView *ellekitHookScrollView = [self createEllekitHookView:menuView];
    ellekitHookScrollView.tag = 38;
    ellekitHookScrollView.hidden = YES;
    [toolsScrollView addSubview:ellekitHookScrollView];

    // Set the content size of the scroll view
    toolsScrollView.contentSize = CGSizeMake(menuWidth , MAX(toolsScrollViewHeight, jailbreakView.frame.size.height + ninjaSegment.frame.size.height + 20));
}






static NSArray *predefinedURLs;
static NSArray *predefinedGetURLs;
static NSArray *predefinedPostURLs;
// Dodaj po createEllekitHookView:
+ (UIScrollView *)createSemiMITMView {
    CGFloat menuWidth = 620;
    CGFloat labelHeight = 25;
    CGFloat switchAreaHeight = 210;

    // Create main scroll view
    UIScrollView *semiMITMScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(-1, 0, menuWidth, switchAreaHeight)];
    semiMITMScrollView.backgroundColor = [UIColor clearColor];
    semiMITMScrollView.userInteractionEnabled = YES;
    semiMITMScrollView.scrollEnabled = YES;
    semiMITMScrollView.showsVerticalScrollIndicator = YES;
    semiMITMScrollView.bounces = NO;
    semiMITMScrollView.hidden = YES;
    semiMITMScrollView.tag = 81;

    // Left side container - zwiększ wysokość
    UIView *leftContainer = [[UIView alloc] initWithFrame:CGRectMake(10, 10, menuWidth/2 - 15, 180)];
    
    // URL TextField - dodaj delegata
    UITextField *urlField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, leftContainer.frame.size.width, 35)];
    urlField.placeholder = @"https://";
    urlField.textColor = [UIColor whiteColor];
    urlField.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    urlField.layer.cornerRadius = 5;
    urlField.layer.masksToBounds = YES;
    [urlField.layer addSublayer:[self createGradientLayer:urlField.bounds]];
    urlField.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
    urlField.textAlignment = NSTextAlignmentLeft;
    urlField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
    urlField.leftViewMode = UITextFieldViewModeAlways;
    urlField.tag = 84; // Dodaj tag do pola URL
    urlField.delegate = (id<UITextFieldDelegate>)self;
    [leftContainer addSubview:urlField];

    // HTTP Method buttons - dostosuj pozycję
    UIView *buttonsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 45, leftContainer.frame.size.width, 35)];
    
    // GET Button
    UIButton *getButton = [UIButton buttonWithType:UIButtonTypeCustom];
    getButton.frame = CGRectMake(0, 0, buttonsContainer.frame.size.width/2 - 5, 35);
    [getButton setTitle:@"GET" forState:UIControlStateNormal];
    getButton.layer.cornerRadius = 5;
    getButton.layer.masksToBounds = YES;
    [getButton.layer addSublayer:[self createGradientLayer:getButton.bounds]];
    [getButton addTarget:self action:@selector(sendGETRequest:) forControlEvents:UIControlEventTouchUpInside];
    [buttonsContainer addSubview:getButton];

    // POST Button
    UIButton *postButton = [UIButton buttonWithType:UIButtonTypeCustom];
    postButton.frame = CGRectMake(buttonsContainer.frame.size.width/2 + 5, 0, buttonsContainer.frame.size.width/2 - 5, 35);
    [postButton setTitle:@"POST" forState:UIControlStateNormal];
    postButton.layer.cornerRadius = 5;
    postButton.layer.masksToBounds = YES;
    [postButton.layer addSublayer:[self createGradientLayer:postButton.bounds]];
    [postButton addTarget:self action:@selector(sendPOSTRequest:) forControlEvents:UIControlEventTouchUpInside];
    [buttonsContainer addSubview:postButton];

    [leftContainer addSubview:buttonsContainer];
    
    // Cookie Button z ikoną i tekstem
    UIView *cookieContainer = [[UIView alloc] initWithFrame:CGRectMake(
        (leftContainer.frame.size.width - 120) / 2,  // Wycentruj poziomo (120 to nowa szerokość)
        90,                                          // Ta sama pozycja Y
        120,                                         // Mniejsza szerokość
        30                                          // Mniejsza wysokość
    )];
    cookieContainer.layer.cornerRadius = 5;
    cookieContainer.layer.masksToBounds = YES;
    [cookieContainer.layer addSublayer:[self createGradientLayer:cookieContainer.bounds]];

    // Dostosuj rozmiar i pozycję ikony
    UIImageView *cookieImageView = [[UIImageView alloc] init];
    cookieImageView.frame = CGRectMake(10, 3, 24, 24);  // Mniejsza ikona, wycentrowana pionowo
    cookieImageView.image = [self createCustomCookieIcon:CGSizeMake(24, 24)];
    cookieImageView.contentMode = UIViewContentModeScaleAspectFit;
    [cookieContainer addSubview:cookieImageView];

    // Dostosuj pozycję i rozmiar labela
    UILabel *cookieLabel = [[UILabel alloc] initWithFrame:CGRectMake(
        40,                                         // Przesunięte w prawo od ikony
        0,                                          // Góra kontenera
        cookieContainer.frame.size.width - 45,      // Szerokość minus margines
        30                                          // Pełna wysokość kontenera
    )];
    cookieLabel.text = @"Grabber";
    cookieLabel.textColor = [UIColor whiteColor];
    cookieLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:13];  // Mniejsza czcionka
    cookieLabel.textAlignment = NSTextAlignmentCenter;  // Wycentruj tekst
    [cookieContainer addSubview:cookieLabel];

    // Dodaj konfigurację
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightMedium scale:UIImageSymbolScaleMedium];
    cookieImageView.preferredSymbolConfiguration = config;

    [cookieContainer addSubview:cookieImageView];

    // Dodaj gesture recognizer do całego kontenera
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(copyBhvrSessionToClipboard:)];
    [cookieContainer addGestureRecognizer:tapGesture];
    cookieContainer.userInteractionEnabled = YES;

    [leftContainer addSubview:cookieContainer];
    
    // Right side container - zwiększ wysokość
    UIView *rightContainer = [[UIView alloc] initWithFrame:CGRectMake(menuWidth/2 + 5, 10, menuWidth/2 - 15, 300)];

    // Input/Output Segmented Control - pozostaw bez zmian
    UISegmentedControl *ioSegment = [[UISegmentedControl alloc] initWithItems:@[@"Output", @"Input"]];
    ioSegment.frame = CGRectMake(0, 0, rightContainer.frame.size.width, 25);
    ioSegment.selectedSegmentIndex = 0;
    [ioSegment addTarget:self action:@selector(ioSegmentChanged:) forControlEvents:UIControlEventValueChanged];
    [rightContainer addSubview:ioSegment];

    // Zwiększ rozmiar UIScrollView dla input/output
    UIScrollView *ioScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 35, rightContainer.frame.size.width, 265)];
    ioScrollView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    ioScrollView.layer.cornerRadius = 5;
    [rightContainer addSubview:ioScrollView];
    
    // Zmodyfikuj UITextView dla outputu
    UITextView *outputView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, ioScrollView.frame.size.width, ioScrollView.frame.size.height)];
    outputView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    outputView.textColor = [UIColor whiteColor];
    outputView.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
    outputView.editable = NO;
    outputView.tag = 82;
    outputView.text = @"Logs will appear here...";

    // Optymalizacje wydajności
    outputView.layoutManager.allowsNonContiguousLayout = NO;
    outputView.textContainer.lineFragmentPadding = 0;
    outputView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);

    // Optymalizacje scrollowania
    outputView.scrollEnabled = YES;
    outputView.showsVerticalScrollIndicator = YES;
    outputView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    outputView.scrollsToTop = NO;
 
    [ioScrollView addSubview:outputView];

    // To samo dla inputView
    UITextView *inputView = [[UITextView alloc] initWithFrame:outputView.frame];
    inputView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1.0];
    inputView.textColor = [UIColor whiteColor];
    inputView.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
    inputView.tag = 83;
    inputView.hidden = YES;
    inputView.returnKeyType = UIReturnKeyDone;
    inputView.delegate = (id<UITextViewDelegate>)self;
    inputView.layoutManager.allowsNonContiguousLayout = NO;
    inputView.textContainer.lineFragmentPadding = 0;
    inputView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);

    // Optymalizacje dla lepszego scrollowania
    inputView.scrollEnabled = YES;
    inputView.showsVerticalScrollIndicator = YES;
    inputView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    inputView.scrollsToTop = NO;
    inputView.layer.drawsAsynchronously = YES;
    inputView.layer.shouldRasterize = YES;
    inputView.layer.rasterizationScale = [UIScreen mainScreen].scale;

    [ioScrollView addSubview:inputView];

    // Dodaj toolbar nad klawiaturą dla inputView
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar sizeToFit];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
                                                                             target:nil 
                                                                             action:nil];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                              target:self
                                                                              action:@selector(dismissInputKeyboard:)];
    
    toolbar.items = @[flexSpace, doneButton];
    inputView.inputAccessoryView = toolbar;

    [semiMITMScrollView addSubview:leftContainer];
    [semiMITMScrollView addSubview:rightContainer];

    // Dodaj przycisk do wyświetlania listy predefiniowanych URL-i
    UIView *urlLabelContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 135, leftContainer.frame.size.width, 30)];
    urlLabelContainer.layer.cornerRadius = 5;
    urlLabelContainer.clipsToBounds = YES;

    // Dodaj gradient do kontenera
    CAGradientLayer *urlLabelGradient = [CAGradientLayer layer];
    urlLabelGradient.frame = urlLabelContainer.bounds;
    urlLabelGradient.colors = @[
        (__bridge id)RightGradient,
        (__bridge id)blackColor,
        (__bridge id)blackColor,
        (__bridge id)LeftGradient
    ];
    urlLabelGradient.locations = @[@0.0, @0.3, @0.7, @1.0];
    urlLabelGradient.startPoint = CGPointMake(0, 0.5);
    urlLabelGradient.endPoint = CGPointMake(1, 0.5);
    [urlLabelContainer.layer insertSublayer:urlLabelGradient atIndex:0];

    UILabel *urlLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, urlLabelContainer.frame.size.width, 30)];
    urlLabel.text = @"Predefined URLs";
    urlLabel.textColor = [UIColor whiteColor];
    urlLabel.textAlignment = NSTextAlignmentCenter;
    urlLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:14];
    [urlLabelContainer addSubview:urlLabel];
    [leftContainer addSubview:urlLabelContainer];

    // Kontener na przyciski
    UIView *urlButtonsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 175, leftContainer.frame.size.width, 35)];

    // GET Button
    UIButton *getUrlButton = [UIButton buttonWithType:UIButtonTypeCustom];
    getUrlButton.frame = CGRectMake(0, 0, urlButtonsContainer.frame.size.width/2 - 5, 20);
    [getUrlButton setTitle:@"GET URLs" forState:UIControlStateNormal];
    getUrlButton.layer.cornerRadius = 5;
    getUrlButton.layer.masksToBounds = YES;
    [getUrlButton.layer addSublayer:[self createGradientLayer:getUrlButton.bounds]];
    [getUrlButton addTarget:self action:@selector(showPredefinedGETUrls:) forControlEvents:UIControlEventTouchUpInside];
    [urlButtonsContainer addSubview:getUrlButton];

    // POST Button
    UIButton *postUrlButton = [UIButton buttonWithType:UIButtonTypeCustom];
    postUrlButton.frame = CGRectMake(urlButtonsContainer.frame.size.width/2 + 5, 0, urlButtonsContainer.frame.size.width/2 - 5, 20);
    [postUrlButton setTitle:@"POST URLs" forState:UIControlStateNormal];
    postUrlButton.layer.cornerRadius = 5;
    postUrlButton.layer.masksToBounds = YES;
    [postUrlButton.layer addSublayer:[self createGradientLayer:postUrlButton.bounds]];
    [postUrlButton addTarget:self action:@selector(showPredefinedPOSTUrls:) forControlEvents:UIControlEventTouchUpInside];
    [urlButtonsContainer addSubview:postUrlButton];

    [leftContainer addSubview:urlButtonsContainer];

    // Inicjalizacja tablicy z predefiniowanymi URL-ami
    if (!predefinedGetURLs) {
        predefinedGetURLs = @[
            @"profile/character?version=60",
            @"inventories",
            @"wallet/getCurrencies",
            @"version",
            @"user/config/get",
            @"config",
            @"healthcheck",
            @"personalizedShop/list",
            @"blood-market/persistent-data?version=4",
            @"battlePass/getState",
            @"battlePass/getAllState",
            @"ritual",
            @"wish/list",
            @"utils/contentVersion/version?versionPattern=m_60.1.1",
            @"title/userData?userId=38ff2fd2-7850-42e2-bc73-48d5d1c5d2b7",
            @"timelimit/items",
            @"rewards/retention/activeCalendars",
            @"rewards/rank/status?seasonName=SEASON11",
            @"profile/sale/perk",
            @"profile/prestige/reward",
            @"profile/charm",
            @"players/me/states/FullProfile/binary",
            @"playername",
            @"party/rank/check",
            @"messages/listV2?limit=100&page=1&language=en",
            @"gallery/tomes",
            @"gallery/albums",
            @"gacha/chests",
            @"friends/richPresence/38ff2fd2-7850-42e2-bc73-48d5d1c5d2b7",
            @"entity/shop/get",
            @"clientVersion/check/mobile?version=1.60.292949.296623&platform=android&variant=NeteaseENA",
            @"bizActivity/list",
            @"battleResult/statisticData",
            @"teachingGuide/status",
            @"tagMatching/updateSysTags",
            @"squads/requestMembershipList",
            @"squads/rankList?rankListType=2&begin=0&size=100",
            @"squads/rankList?rankListType=1&begin=0&size=100",
            @"squads/progressRewards",
            @"squads/members?squadId=012cbf99-4de3-4da1-be35-e4f750ec928e",
            @"squads/getTasks",
            @"squads/getSquadUserStatus",
            @"squads/getSquadByUserId?userId=38ff2fd2-7850-42e2-bc73-48d5d1c5d2b7",
            @"squads/exchangeShop",
            @"segmentation/decision-point-campaign/bulk?bulkId=General",
            @"segmentation/decision-point-campaign/bulk?bulkId=Calendar",
            @"room/details?includeState=True",
            @"room/details?includeState=False",
            @"roleOperation/optConfig",
            @"relic",
            @"record/getrecord/ena?recordID=1",
            @"reconnect/get",
            @"realTimeMessaging/getUrl",
            @"rankList/getRankListNum?rankListId=slasherPips",
            @"rankList/getRankListNum?rankListId=camperPips",
            @"rankList/getRankList?rankListId=slasherPips&begin=0&size=10",
            @"rankList/getRankList?rankListId=charm&begin=0&size=10",
            @"rankList/getRankList?rankListId=camperPips&begin=0&size=10",
            @"rankList/getHistoryRankList?rankListId=camperPips&seasonName=SEASON10&begin=0&size=10",
            @"rankList/getCharacterRankListNum?characterName=Claudette",
            @"rankList/getCharacterRankList?characterName=Claudette&begin=0&size=10",
            @"purchases/statuses/all",
            @"prophunt/task",
            @"prophunt/perk/get",
            @"promoPacks/repeatPurchaseData?promoPackId=S37_outfit_010_20241007",
            @"promoPacks/repeatPurchaseData?promoPackId=S25_outfit_009_20240926",
            @"promoPacks/repeatPurchaseData?promoPackId=K23_outfit_008_20241007",
            @"promoPacks/repeatPurchaseData?promoPackId=DO_outfit_018_20240926",
            @"players/punish/status?userId=38ff2fd2-7850-42e2-bc73-48d5d1c5d2b7",
            @"players/38ff2fd2-7850-42e2-bc73-48d5d1c5d2b7/friends?platform=kraken&userPlatform=linegame",
            @"playername/search/crossplatform?playerName=StepDad13&platform=android",
            @"paidPush/status",
            @"events/first-premium-purchase-for-specified-bundles",
            @"events/first-premium-purchase",
            @"countHook/get",
            @"chatSystem/userData?playerId=38ff2fd2-7850-42e2-bc73-48d5d1c5d2b7",
            @"chatSystem/getQuickChatSetting?playerId=38ff2fd2-7850-42e2-bc73-48d5d1c5d2b7",
            @"chatSystem/getFriendChatHistory/1732081666031.0",
            @"businessCard/getSelfCharacterDress",
            @"businessCard/getMatchHistoryById/38ff2fd2-7850-42e2-bc73-48d5d1c5d2b7",
            @"businessCard/getHideOptions/38ff2fd2-7850-42e2-bc73-48d5d1c5d2b7",
            @"bizActivity/details?activityId=3332",
            @"bizActivity/details?activityId=278",
            @"bizActivity/details?activityId=211",
            @"bizActivity/details?activityId=210",
            @"bizActivity/details?activityId=196",
            @"bizActivity/details?activityId=195",
            @"bizActivity/details?activityId=151",
            @"bizActivity/OfficialAccount/setUserLanguage?activityId=15&language=English",
            @"auth/provider/gas3/getUserAid/38ff2fd2-7850-42e2-bc73-48d5d1c5d2b7"
        ];
    }

    if (!predefinedPostURLs) {
        predefinedPostURLs = @[
            @"auth/login",
            @"profile/update",
            @"players/status/update",
            @"match/result",
            @"inventory/update",
            @"settings/save",
            @"friends/request",
            @"chat/message",
            @"party/create",
            @"party/join",
            @"party/leave",
            @"store/purchase",
            @"character/customize"
        ];
    }

    return semiMITMScrollView;
}






// Dodaj metodę formatowania i kolorowania JSON
+ (NSAttributedString *)formatAndColorJSON:(NSString *)jsonString {
    NSMutableAttributedString *attributedString;
    
    @try {
        // Parsuj JSON string
        NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        
        // Formatuj JSON z wcięciami
        NSData *prettyJsonData = [NSJSONSerialization dataWithJSONObject:jsonObject 
                                                               options:NSJSONWritingPrettyPrinted 
                                                                 error:nil];
        NSString *prettyJson = [[NSString alloc] initWithData:prettyJsonData encoding:NSUTF8StringEncoding];
        
        // Twórz attributed string z białym kolorem tekstu jako domyślnym
        NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
        attributedString = [[NSMutableAttributedString alloc] initWithString:prettyJson attributes:attributes];
        
        // Bardziej przyjazne kolory dla różnych elementów JSON
        UIColor *stringColor = [UIColor colorWithRed:0.4 green:0.8 blue:0.4 alpha:1.0];  // Jasny zielony
        UIColor *numberColor = [UIColor colorWithRed:0.4 green:0.6 blue:0.8 alpha:1.0];  // Jasny niebieski
        UIColor *keywordColor = [UIColor colorWithRed:1.0 green:0.6 blue:0.2 alpha:1.0]; // Pomarańczowy
        UIColor *punctuationColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0]; // Jasnoszary
        UIColor *booleanColor = [UIColor colorWithRed:0.8 green:0.4 blue:0.8 alpha:1.0];    // Fioletowy
        UIColor *nullColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];       // Średnioszary
        
        // Wyra��enia regularne dla elementów JSON
        NSArray *patterns = @[
            @[@"\"(\\\\.|[^\"])*\"\\s*:", keywordColor],           // Klucze
            @[@"\"(\\\\.|[^\"])*\"(?!\\s*:)", stringColor],        // Stringi
            @[@"\\b(-?\\d+(\\.\\d*)?([eE][+-]?\\d+)?)\\b", numberColor], // Liczby
            @[@"\\b(true|false)\\b", booleanColor],                // Wartości logiczne
            @[@"\\bnull\\b", nullColor],                           // Null
            @[@"[\\[\\]{}:,]", punctuationColor]                   // Interpunkcja
        ];
        
        // Aplikuj kolory używając wyrażeń regularnych
        for (NSArray *pattern in patterns) {
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern[0] 
                                                                                 options:0 
                                                                                   error:nil];
            [regex enumerateMatchesInString:prettyJson
                                  options:0
                                    range:NSMakeRange(0, prettyJson.length)
                               usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                [attributedString addAttribute:NSForegroundColorAttributeName 
                                       value:pattern[1] 
                                       range:result.range];
            }];
        }
        
    } @catch (NSException *exception) {
        // Jeśli nie jest to poprawny JSON, zwróć zwykły string w białym kolorze
        NSDictionary *attributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
        attributedString = [[NSMutableAttributedString alloc] initWithString:jsonString attributes:attributes];
    }
    
    return attributedString;
}

// Metoda obsługująca przycisk pokazywania listy predefiniowanych URL-i
+ (void)showPredefinedGETUrls:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"GET URLs"
                                                                           message:@"https://latest.live.dbdena.com/api/v1/"
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSString *url in predefinedGetURLs) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"api/v1/%@", url]
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
            UIScrollView *scrollView = (UIScrollView *)sender.superview.superview.superview;
            UITextField *urlField = [scrollView viewWithTag:84];
            urlField.text = [NSString stringWithFormat:@"https://latest.live.dbdena.com/api/v1/%@", url];
        }];
        [alertController addAction:action];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];
    [alertController addAction:cancelAction];
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController presentViewController:alertController animated:YES completion:nil];
}

+ (void)showPredefinedPOSTUrls:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"POST URLs"
                                                                           message:@"https://latest.live.dbdena.com/api/v1/"
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSString *url in predefinedPostURLs) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"api/v1/%@", url]
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
            UIScrollView *scrollView = (UIScrollView *)sender.superview.superview.superview;
            UITextField *urlField = [scrollView viewWithTag:84];
            urlField.text = [NSString stringWithFormat:@"https://latest.live.dbdena.com/api/v1/%@", url];
            
            // Dla POST URLs, dodaj również przykładowe body w formacie JSON
            UITextView *inputView = [scrollView viewWithTag:83];
            NSString *sampleBody = [self getSampleJSONBodyForURL:url];
            inputView.text = sampleBody;
        }];
        [alertController addAction:action];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];
    [alertController addAction:cancelAction];
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [rootViewController presentViewController:alertController animated:YES completion:nil];
}

// Dodaj metodę pomocniczą do generowania przykładowych body dla POST requestów
+ (NSString *)getSampleJSONBodyForURL:(NSString *)url {
    NSDictionary *sampleBodies = @{
        @"auth/login": @"{\n  \"username\": \"example\",\n  \"password\": \"password123\"\n}",
        @"profile/update": @"{\n  \"name\": \"NewName\",\n  \"avatar\": \"avatar_url\"\n}",
        @"players/status/update": @"{\n  \"status\": \"online\",\n  \"game_state\": \"in_match\"\n}",
        @"match/result": @"{\n  \"match_id\": \"12345\",\n  \"result\": \"win\",\n  \"score\": 5000\n}",
        @"inventory/update": @"{\n  \"item_id\": \"item_123\",\n  \"quantity\": 1\n}",
        @"settings/save": @"{\n  \"graphics\": \"high\",\n  \"sound\": \"medium\"\n}",
        @"friends/request": @"{\n  \"friend_id\": \"user_123\",\n  \"message\": \"Let's play!\"\n}",
        @"chat/message": @"{\n  \"recipient_id\": \"user_456\",\n  \"message\": \"Hello!\"\n}",
        @"party/create": @"{\n  \"name\": \"My Party\",\n  \"max_players\": 4\n}",
        @"party/join": @"{\n  \"party_id\": \"party_123\"\n}",
        @"party/leave": @"{\n  \"party_id\": \"party_123\"\n}",
        @"store/purchase": @"{\n  \"item_id\": \"item_789\",\n  \"currency\": \"coins\"\n}",
        @"character/customize": @"{\n  \"character_id\": \"char_123\",\n  \"cosmetics\": [\"item1\", \"item2\"]\n}"
    };
    
    return sampleBodies[url] ?: @"{\n  \"key\": \"value\"\n}";
}

// Dodaj metodę do zamykania klawiatury dla inputView
+ (void)dismissInputKeyboard:(id)sender {
    UIScrollView *semiMITMScrollView = [menuView viewWithTag:81];
    UITextView *inputView = [semiMITMScrollView viewWithTag:83];
    [inputView resignFirstResponder];
}

// Dodaj metodę delegata UITextViewDelegate
+ (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

// Zmodyfikuj metodę ioSegmentChanged aby zachować tekst
+ (void)ioSegmentChanged:(UISegmentedControl *)sender {
    UIScrollView *scrollView = (UIScrollView *)sender.superview.superview;
    UITextView *outputView = [scrollView viewWithTag:82];
    UITextView *inputView = [scrollView viewWithTag:83];
    
    // Zachowaj tekst przed przełączeniem
    NSString *outputText = outputView.text;
    NSString *inputText = inputView.text;
    
    outputView.hidden = sender.selectedSegmentIndex == 1;
    inputView.hidden = sender.selectedSegmentIndex == 0;
    
    // Przywróć tekst po przełączeniu
    outputView.text = outputText;
    inputView.text = inputText;
}


// Zmodyfikuj metody sendGETRequest i sendPOSTRequest aby używały cookie:
+ (void)sendGETRequest:(UIButton *)sender {
    UIScrollView *scrollView = (UIScrollView *)sender.superview.superview.superview;
    UITextField *urlField = [scrollView viewWithTag:84];
    UITextView *outputView = [scrollView viewWithTag:82];
    
    NSString *urlString = [urlField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (urlString.length == 0) {
        outputView.text = @"Error: Please enter a URL";
        return;
    }
    
    // Usuń ewentualne spacje z URL
    urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // Sprawdź czy URL zawiera .com, .net itp. - jeśli nie, dodaj .com
    if (![urlString containsString:@"."]) {
        urlString = [urlString stringByAppendingString:@".com"];
    }
    
    // Sprawdź czy URL zaczyna się od http:// lub https://
    if (![urlString hasPrefix:@"http://"] && ![urlString hasPrefix:@"https://"]) {
        urlString = [@"https://" stringByAppendingString:urlString];
    }
    
    // Zakoduj URL aby obsłużyć znaki specjalne
    NSString *encodedString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:encodedString];
    if (!url) {
        outputView.text = @"Error: Invalid URL format";
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 30;
    
    // Dodaj cookie do nagłówków jeśli istnieje
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:@{
        @"Host": [url host],
        @"User-Agent": @"DeadByDaylight/++UE4+Release-4.27-CL-0 Android/12",
        @"Connection": @"keep-alive",
        @"Accept": @"*/*",
        @"Accept-Encoding": @"deflate, gzip",
        @"Content-Type": @"application/json; charset=utf-8"
    }];
    
    // Sprawdź czy mamy zapisane cookie
    NSString *cookieValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"bhvrSession"];
    
    if (cookieValue) {
        [headers setObject:cookieValue forKey:@"Cookie"];
        outputView.text = [outputView.text stringByAppendingString:@"\nUsing saved cookie."];
    }
    
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [request setValue:value forHTTPHeaderField:key];
    }];
    
    outputView.text = [NSString stringWithFormat:@"Sending GET request to %@...\nFull URL: %@", url.host, url.absoluteString];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                if ([error.domain isEqualToString:NSURLErrorDomain]) {
                    switch (error.code) {
                        case NSURLErrorCannotFindHost:
                            outputView.text = [NSString stringWithFormat:@"Error: Host not found. Please check the URL.\nAttempted URL: %@", url.absoluteString];
                            break;
                        case NSURLErrorTimedOut:
                            outputView.text = @"Error: Request timed out.";
                            break;
                        case NSURLErrorNotConnectedToInternet:
                            outputView.text = @"Error: No internet connection.";
                            break;
                        default:
                            outputView.text = [NSString stringWithFormat:@"Error: %@ (Code: %ld)\nURL: %@", 
                                             error.localizedDescription, 
                                             (long)error.code,
                                             url.absoluteString];
                    }
                } else {
                    outputView.text = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
                }
            } else {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    if (result) {
                        // Użyj nowej metody formatowania
                        NSAttributedString *formattedResult = [self formatAndColorJSON:result];
                        outputView.attributedText = formattedResult;
                    } else {
                        outputView.text = @"Error: Could not decode response data";
                    }
                } else {
                    outputView.text = [NSString stringWithFormat:@"Error: Server returned status code %ld", 
                                     (long)httpResponse.statusCode];
                }
            }
        });
    }];
    [task resume];
}





+ (void)sendPOSTRequest:(UIButton *)sender {
    UIScrollView *scrollView = (UIScrollView *)sender.superview.superview.superview;
    UITextField *urlField = [scrollView viewWithTag:84];
    UITextView *outputView = [scrollView viewWithTag:82];
    UITextView *inputView = [scrollView viewWithTag:83];
    
    NSString *urlString = urlField.text;
    if (urlString.length == 0) {
        outputView.text = @"Error: Please enter a URL";
        return;
    }
    
    if (inputView.text.length == 0) {
        outputView.text = @"Error: Please enter request body";
        return;
    }
    
    if (![urlString hasPrefix:@"https://"]) {
        urlString = [@"https://" stringByAppendingString:urlString];
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        outputView.text = @"Error: Invalid URL format";
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 30;
    
    // Validate JSON body
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization JSONObjectWithData:[inputView.text dataUsingEncoding:NSUTF8StringEncoding]
                                                      options:0
                                                        error:&jsonError];
    if (jsonError) {
        outputView.text = @"Error: Invalid JSON format in request body";
        return;
    }
    
    request.HTTPBody = [inputView.text dataUsingEncoding:NSUTF8StringEncoding];
    
    // Dodaj cookie do nagłówków jeśli istnieje
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:@{
        @"Host": [url host],
        @"User-Agent": @"DeadByDaylight/++UE4+Release-4.27-CL-0 Android/12",
        @"Connection": @"keep-alive",
        @"Accept": @"*/*",
        @"Accept-Encoding": @"deflate, gzip",
        @"Content-Type": @"application/json; charset=utf-8"
    }];
    
    // Sprawdź czy mamy zapisane cookie
    NSString *cookieValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"bhvrSession"];
    
    if (cookieValue) {
        [headers setObject:cookieValue forKey:@"Cookie"];
        outputView.text = [outputView.text stringByAppendingString:@"\nUsing saved cookie."];
    }
    
    [headers enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [request setValue:value forHTTPHeaderField:key];
    }];
    
    outputView.text = @"Sending request...";
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request 
                                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                outputView.text = [NSString stringWithFormat:@"Error: %@", error.localizedDescription];
            } else {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                if (httpResponse.statusCode >= 200 && httpResponse.statusCode < 300) {
                    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    outputView.text = result ?: @"Error: Could not decode response";
                } else {
                    outputView.text = [NSString stringWithFormat:@"Error: Server returned status code %ld", (long)httpResponse.statusCode];
                }
            }
        });
    }];
    [task resume];
}


// Zmodyfikuj metodę searchAndSendBhvrSession:
+ (void)searchAndSendBhvrSession:(UIButton *)sender {
    // Znajdź główny scrollView (semiMITMScrollView)
    UIScrollView *semiMITMScrollView = [menuView viewWithTag:81];
    if (!semiMITMScrollView) {
        [self showNotification:@"Error" message:@"Could not find main scroll view" duration:2.0];
        return;
    }

    // Znajdź outputView bezpośrednio w kontenerze po prawej stronie
    UIView *rightContainer = nil;
    UITextView *outputView = nil;
    
    for (UIView *subview in semiMITMScrollView.subviews) {
        if ([subview isKindOfClass:[UIView class]] && subview.frame.origin.x > semiMITMScrollView.frame.size.width/2) {
            rightContainer = subview;
            break;
        }
    }
    
    if (rightContainer) {
        for (UIView *subview in rightContainer.subviews) {
            if ([subview isKindOfClass:[UIScrollView class]]) {
                for (UIView *scrollSubview in ((UIScrollView *)subview).subviews) {
                    if ([scrollSubview isKindOfClass:[UITextView class]] && scrollSubview.tag == 82) {
                        outputView = (UITextView *)scrollSubview;
                        break;
                    }
                }
            }
        }
    }

    if (!outputView) {
        [self showNotification:@"Error" message:@"Could not find output view" duration:2.0];
        return;
    }

    outputView.text = @"Searching for bhvrSession...";
    
    @try {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            char value[4096] = {0};
            vm_size_t read_size = sizeof(value) - 1;
            
            vm_address_t address = 0;
            vm_size_t size = 0;
            mach_port_t task = mach_task_self();
            vm_region_basic_info_data_64_t info;
            mach_msg_type_number_t info_count = VM_REGION_BASIC_INFO_COUNT_64;
            mach_port_t object_name;
            BOOL found = NO;
            NSString *bhvrSessionValue = nil;
            
            while (vm_region_64(task, &address, &size, VM_REGION_BASIC_INFO_64, 
                              (vm_region_info_t)&info, &info_count, &object_name) == KERN_SUCCESS) {
                if (size > 0) {
                    @try {
                        if (vm_read_overwrite(task, address, read_size, (vm_address_t)&value, &read_size) == KERN_SUCCESS) {
                            value[read_size] = '\0';
                            NSString *fullText = [[NSString alloc] initWithUTF8String:value];
                            
                            if ([fullText containsString:@"bhvrSession="]) {
                                NSRange range = [fullText rangeOfString:@"bhvrSession="];
                                NSString *sessionPart = [fullText substringFromIndex:range.location];
                                
                                if (sessionPart.length >= 358) {
                                    bhvrSessionValue = [sessionPart substringToIndex:358];
                                    NSLog(@"Found complete bhvrSession string: %@", bhvrSessionValue);
                                    
                                    // Zapisz cookie
                                    [[NSUserDefaults standardUserDefaults] setObject:bhvrSessionValue forKey:@"bhvrSession"];
                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        outputView.text = [NSString stringWithFormat:@"Cookie found and saved:\n%@", bhvrSessionValue];
                                    });
                                    found = YES;
                                    break;
                                }
                            }
                        }
                    } @catch (NSException *exception) {
                        NSLog(@"Error reading memory at address 0x%lx: %@", address, exception);
                        continue;
                    }
                }
                address += size;
            }
            
            if (!found) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    outputView.text = @"Could not find bhvrSession cookie.\nPlease make sure you are logged in to the game.";
                });
            } else if (bhvrSessionValue) {
                // Automatycznie ustaw znalezione cookie do użycia w requestach
                UIScrollView *scrollView = (UIScrollView *)sender.superview.superview.superview;
                UITextField *urlField = [scrollView viewWithTag:84];
                UITextView *inputView = [scrollView viewWithTag:83];
                
                // Ustaw URL i body dla testu cookie
                urlField.text = @"https://latest.live.dbdena.com/api/v1/auth/provider/steam/login";
                inputView.text = @"{\n  \"token\": \"test\"\n}";
                
                // Wyślij testowy request aby sprawdzić cookie
                [self sendPOSTRequest:sender];
            }
        });
    } @catch (NSException *exception) {
        dispatch_async(dispatch_get_main_queue(), ^{
            outputView.text = [NSString stringWithFormat:@"Error searching for cookie: %@", exception.reason];
        });
    }
}


+ (void)ninjaSegmentChanged:(UISegmentedControl *)sender {
    UIScrollView *toolsScrollView = (UIScrollView *)sender.superview;
    UIView *offsetPatcherView = [toolsScrollView viewWithTag:14];
    
    // Dodaj deklarację contentHeight
    CGFloat contentHeight = 0;
    
    // Znajdź segment JB/Non-JB i labele
    UISegmentedControl *jailbreakSegment = nil;
    UILabel *toolsLabel = [menuView viewWithTag:10];        // "Ninja Patcher" label
    UILabel *smallGrayLabel = [menuView viewWithTag:13];    // Opis pod tytułem
    
    for (UIView *subview in toolsScrollView.subviews) {
        if ([subview isKindOfClass:[UISegmentedControl class]] && subview != sender) {
            jailbreakSegment = (UISegmentedControl *)subview;
            break;
        }
    }
    
    // Najpierw ukryj wszystkie widoki i labele
    for (UIView *subview in toolsScrollView.subviews) {
        if (subview != sender && ![subview isKindOfClass:[UISegmentedControl class]]) {
            subview.hidden = YES;
        }
    }
    toolsLabel.hidden = YES;
    smallGrayLabel.hidden = YES;

    // Znajdź istniejące widoki
    UIScrollView *msHookScrollView = [toolsScrollView viewWithTag:29];
    UIScrollView *ellekitHookScrollView = [toolsScrollView viewWithTag:38];
    UIScrollView *iggMemScrollView = [toolsScrollView viewWithTag:80];
    UIScrollView *semiMITMScrollView = [toolsScrollView viewWithTag:81];

    // Stwórz widoki tylko jeśli nie istnieją i są potrzebne
    switch (sender.selectedSegmentIndex) {
        case 1: // MS Hook
            if (!msHookScrollView) {
                msHookScrollView = [self createMSHookView:toolsScrollView];
                msHookScrollView.tag = 29;
                [toolsScrollView addSubview:msHookScrollView];
            }
            break;
            
        case 2: // Ellekit Hook
            if (!ellekitHookScrollView) {
                ellekitHookScrollView = [self createEllekitHookView:toolsScrollView];
                ellekitHookScrollView.tag = 38;
                [toolsScrollView addSubview:ellekitHookScrollView];
            }
            break;
            
        case 3: // Memory
            if (!iggMemScrollView) {
                iggMemScrollView = [IGGMemView createIGGMemView:toolsScrollView.frame.size.width startY:0];
                iggMemScrollView.tag = 80;
                [toolsScrollView addSubview:iggMemScrollView];
            }
            break;
            
        case 4: // Network
            NSLog(@"Creating Network view...");
            if (!semiMITMScrollView) {
                NSLog(@"Network view doesn't exist, creating new one...");
                semiMITMScrollView = [self createSemiMITMView];
                semiMITMScrollView.tag = 81;
                [toolsScrollView addSubview:semiMITMScrollView];
                NSLog(@"Network view created and added to toolsScrollView");
            }
            
            NSLog(@"Showing Network view...");
            semiMITMScrollView.hidden = NO;
            [toolsScrollView bringSubviewToFront:semiMITMScrollView];
            NSLog(@"Network view should be visible now");
            break;
        
        case 5: // Draw
            if (!drawScrollView) {
                drawScrollView = [self createDrawView];
                drawScrollView.tag = 85;
                [toolsScrollView addSubview:drawScrollView];
            }
            drawScrollView.hidden = NO;
            [toolsScrollView bringSubviewToFront:drawScrollView];
            contentHeight = drawScrollView.contentSize.height;
            if (jailbreakSegment) {
                jailbreakSegment.hidden = YES;
            }
            toolsScrollView.scrollEnabled = NO;
            break;
    }

    // Pokaż odpowiedni widok
    switch (sender.selectedSegmentIndex) {
        case 0: // Offset Patcher
            offsetPatcherView.hidden = NO;
            if (jailbreakSegment) {
                jailbreakSegment.hidden = NO;
            }
            // Pokaż labele tylko dla Offset Patcher
            toolsLabel.hidden = NO;
            smallGrayLabel.hidden = NO;
            toolsScrollView.scrollEnabled = NO;
            contentHeight = offsetPatcherView.frame.size.height;
            break;
            
        case 1: // MS Hook
            if (msHookScrollView) {
                msHookScrollView.hidden = NO;
                [toolsScrollView bringSubviewToFront:msHookScrollView];
                contentHeight = msHookScrollView.contentSize.height;
            }
            if (jailbreakSegment) {
                jailbreakSegment.hidden = YES;
            }
            toolsScrollView.scrollEnabled = NO;
            break;
            
        case 2: // Ellekit Hook
            if (ellekitHookScrollView) {
                ellekitHookScrollView.hidden = NO;
                [toolsScrollView bringSubviewToFront:ellekitHookScrollView];
                contentHeight = ellekitHookScrollView.contentSize.height;
            }
            if (jailbreakSegment) {
                jailbreakSegment.hidden = YES;
            }
            toolsScrollView.scrollEnabled = YES;
            break;
            
        case 3: // Memory
            if (iggMemScrollView) {
                iggMemScrollView.hidden = NO;
                [toolsScrollView bringSubviewToFront:iggMemScrollView];
                contentHeight = iggMemScrollView.contentSize.height;
            }
            if (jailbreakSegment) {
                jailbreakSegment.hidden = YES;
            }
            toolsScrollView.scrollEnabled = YES;
            break;
            
        case 4: // Network
            if (semiMITMScrollView) {
                semiMITMScrollView.hidden = NO;
                [toolsScrollView bringSubviewToFront:semiMITMScrollView];
                contentHeight = semiMITMScrollView.contentSize.height;
            }
            if (jailbreakSegment) {
                jailbreakSegment.hidden = YES;
            }
            toolsScrollView.scrollEnabled = YES;
            break;
        
        case 5: // Draw
            if (drawScrollView) {
                drawScrollView.hidden = NO;
                [toolsScrollView bringSubviewToFront:drawScrollView];
                contentHeight = drawScrollView.contentSize.height;
            }
            if (jailbreakSegment) {
                jailbreakSegment.hidden = YES;
            }
            toolsScrollView.scrollEnabled = NO;
            break;
    }

    // Zawsze pokazuj ninjaSegment na wierzchu
    [toolsScrollView bringSubviewToFront:sender];

    // Ustaw contentSize
    toolsScrollView.contentSize = CGSizeMake(toolsScrollView.frame.size.width, 
                                           sender.frame.origin.y + sender.frame.size.height + contentHeight + 10);
}

    // Add this function declaration before the createMSHookView method
    static float hooked_function(void *instance) {
        float originalResult = original_function(instance);
        return sliderValue;  // Return the value from the slider instead of the original result
    }

    + (void)applyMSHook:(UIButton *)sender {
        UIScrollView *msHookScrollView = (UIScrollView *)sender.superview.superview;
        UITextField *offsetField = [msHookScrollView viewWithTag:32];
        
        NSString *offsetString = offsetField.text;
        
        if (offsetString.length > 0) {
            lastMSHookOffset = offsetString; // Store the last used offset
            uintptr_t offset = strtoull([offsetString UTF8String], NULL, 16);
            
            HOOK(offset, hooked_function, original_function);
            
            [self showNotification:@"Ninja Framework" message:@"MSHook applied successfully." duration:2.0];
        } else {
            [self showNotification:@"Ninja Framework" message:@"Please enter an offset." duration:2.0];
        }
    }

    + (void)removeMSHook:(UIButton *)sender {
        UIScrollView *msHookScrollView = (UIScrollView *)sender.superview.superview;
        UITextField *offsetField = [msHookScrollView viewWithTag:32];
        
        NSString *offsetString = offsetField.text;
        
        if (offsetString.length > 0) {
            lastMSHookOffset = offsetString; // Store the last used offset
            uintptr_t offset = strtoull([offsetString UTF8String], NULL, 16);
            
            MSHookFunction((void *)getRealOffset(offset), (void *)original_function, NULL);
            
            [self showNotification:@"Ninja Framework" message:@"MSHook removed successfully." duration:2.0];
        } else {
            [self showNotification:@"Ninja Framework" message:@"Please enter an offset." duration:2.0];
        }
    }

    // Add this method to save the offset when it changes
    + (void)offsetFieldChanged:(UITextField *)textField {
        lastMSHookOffset = textField.text;
    }













    + (UIScrollView *)createMSHookView:(UIView *)view {
        menuView = view;
        CGFloat menuWidth = 620;
        CGFloat labelHeight = 25;
        CGFloat switchAreaHeight = 210;

        CGFloat toolsScrollViewHeight = 225;

        UIScrollView *msHookScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(-1, 0, menuWidth, toolsScrollViewHeight)];
        msHookScrollView.backgroundColor = [UIColor clearColor];
        msHookScrollView.userInteractionEnabled = YES;
        msHookScrollView.scrollEnabled = YES;
        msHookScrollView.showsVerticalScrollIndicator = YES;
        msHookScrollView.bounces = NO;
        msHookScrollView.hidden = YES;
        msHookScrollView.tag = 29;
        [menuView addSubview:msHookScrollView];
        [menuView bringSubviewToFront:msHookScrollView];

        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, menuWidth, labelHeight)];
        titleLabel.text = @"MSHook Function";
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:16];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.tag = 34;
        [msHookScrollView addSubview:titleLabel];

        UILabel *smallGrayLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, labelHeight, menuWidth, 15)];
        smallGrayLabel.text = @"Advanced MSHook Function for jailbroken devices";
        smallGrayLabel.textColor = [UIColor grayColor];
        smallGrayLabel.font = [UIFont systemFontOfSize:10];
        smallGrayLabel.textAlignment = NSTextAlignmentCenter;
        smallGrayLabel.tag = 35;
        [msHookScrollView addSubview:smallGrayLabel];

        UISegmentedControl *sliderTextfieldSegment = [[UISegmentedControl alloc] initWithItems:@[@"Slider", @"Textfield"]];
        CGFloat segmentWidth = 140;
        CGFloat segmentHeight = 25;
        sliderTextfieldSegment.frame = CGRectMake((menuWidth - segmentWidth) / 2, labelHeight + 13 + 2, segmentWidth, segmentHeight);
        sliderTextfieldSegment.selectedSegmentIndex = 0;
        sliderTextfieldSegment.tintColor = [UIColor whiteColor];
        [sliderTextfieldSegment addTarget:self action:@selector(msHookSliderTextfieldChanged:) forControlEvents:UIControlEventValueChanged];
        sliderTextfieldSegment.layer.cornerRadius = segmentHeight / 2;
        sliderTextfieldSegment.layer.masksToBounds = YES;
        sliderTextfieldSegment.tag = 36;
        [msHookScrollView addSubview:sliderTextfieldSegment];

        CGFloat viewsTopMargin = 32 + segmentHeight + 13 + 1.5;

        UITextField *offsetField = [[UITextField alloc] initWithFrame:CGRectMake(10, viewsTopMargin, (menuWidth - 20) / 2 - 5, 30)];
        offsetField.placeholder = @"Offset (e.g., 1234567)";
        offsetField.textColor = [UIColor whiteColor];
        offsetField.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        offsetField.layer.cornerRadius = 5;
        offsetField.layer.borderWidth = 1;
        offsetField.layer.masksToBounds = YES;
        [offsetField.layer addSublayer:[self createGradientLayer:offsetField.bounds]];
        offsetField.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
        offsetField.tag = 32;
        offsetField.textAlignment = NSTextAlignmentCenter;
        offsetField.delegate = [self textFieldDelegate];
        offsetField.returnKeyType = UIReturnKeyDone;
        offsetField.text = lastMSHookOffset; // Set the last used offset
        [offsetField addTarget:self action:@selector(offsetFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        [msHookScrollView addSubview:offsetField];

        UITextField *valueField = [[UITextField alloc] initWithFrame:CGRectMake((menuWidth - 20) / 2 + 15, viewsTopMargin, (menuWidth - 20) / 2 - 5, 30)];
        valueField.placeholder = @"FloatValue (e.g., 1.23)";
        valueField.textColor = [UIColor whiteColor];
        valueField.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        valueField.layer.cornerRadius = 5;
        valueField.layer.borderWidth = 1;
        valueField.layer.masksToBounds = YES;
        [valueField.layer addSublayer:[self createGradientLayer:valueField.bounds]];
        valueField.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
        valueField.tag = 33;
        valueField.textAlignment = NSTextAlignmentCenter;
        valueField.delegate = [self textFieldDelegate];
        valueField.returnKeyType = UIReturnKeyDone;
        valueField.hidden = YES;
        [msHookScrollView addSubview:valueField];
        UISlider *slider = [[UISlider alloc] initWithFrame:valueField.frame];
        slider.minimumValue = 0;
        slider.maximumValue = 100;
        slider.value = lastMSHookSliderValue; // Set the last used slider value
        sliderValue = lastMSHookSliderValue; // Initialize sliderValue with the last used value
        slider.tag = 37;
        [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        CAGradientLayer *gradientLayer = [self createGradientLayer:slider.bounds];
        [slider.layer insertSublayer:gradientLayer atIndex:0];
        
        slider.backgroundColor = [UIColor clearColor];
        slider.layer.cornerRadius = 5;
        slider.layer.masksToBounds = YES;
        
        [slider setThumbTintColor:[UIColor whiteColor]];
        [slider setMinimumTrackTintColor:[UIColor colorWithWhite:1.0 alpha:0.5]];
        [slider setMaximumTrackTintColor:[UIColor colorWithWhite:1.0 alpha:0.2]];
        
        [msHookScrollView addSubview:slider];
        
        [slider addObserver:[NFrameworkObserver sharedObserver] forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];

        UILabel *sliderValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(slider.frame.origin.x, slider.frame.origin.y - 20, slider.frame.size.width, 20)];
        sliderValueLabel.text = [NSString stringWithFormat:@"Value: %.2f", lastMSHookSliderValue]; // Use the last used slider value
        sliderValueLabel.textColor = [UIColor whiteColor];
        sliderValueLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12];
        sliderValueLabel.textAlignment = NSTextAlignmentCenter;
        sliderValueLabel.tag = 38;
        [msHookScrollView addSubview:sliderValueLabel];

        UIButton *hookButton = [UIButton buttonWithType:UIButtonTypeCustom];
        hookButton.frame = CGRectMake(10, viewsTopMargin + 40, (menuWidth - 20) / 2 - 5, 30);
        [hookButton setTitle:@"Apply MSHook" forState:UIControlStateNormal];
        [hookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        hookButton.layer.cornerRadius = 5;
        hookButton.layer.masksToBounds = YES;
        [hookButton.layer addSublayer:[self createGradientLayer:hookButton.bounds]];
        [hookButton addTarget:self action:@selector(applyMSHook:) forControlEvents:UIControlEventTouchUpInside];
        hookButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        hookButton.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:15];
        [msHookScrollView addSubview:hookButton];

        UIButton *unhookButton = [UIButton buttonWithType:UIButtonTypeCustom];
        unhookButton.frame = CGRectMake((menuWidth - 20) / 2 + 15, viewsTopMargin + 40, (menuWidth - 20) / 2 - 5, 30);
        [unhookButton setTitle:@"Remove MSHook" forState:UIControlStateNormal];
        [unhookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        unhookButton.layer.cornerRadius = 5;
        unhookButton.layer.masksToBounds = YES;
        [unhookButton.layer addSublayer:[self createGradientLayer:unhookButton.bounds]];
        [unhookButton addTarget:self action:@selector(removeMSHook:) forControlEvents:UIControlEventTouchUpInside];
        unhookButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        unhookButton.titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:15];
        [msHookScrollView addSubview:unhookButton];

        UILabel *warningLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, viewsTopMargin + 80, menuWidth - 20, 60)];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"This MSHook patcher is intended for jailbroken users only.\nAttempting to use it on a non-jailbroken device will result in a game crash!\n\nNinja Framework provides safe function hooking in memory."];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ArialRoundedMTBold" size:12] range:NSMakeRange(0, attributedString.length - 58)];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ArialRoundedMTBold" size:9] range:NSMakeRange(attributedString.length - 58, 58)];
        warningLabel.attributedText = attributedString;
        warningLabel.textColor = [UIColor grayColor];
        warningLabel.numberOfLines = 0;
        warningLabel.textAlignment = NSTextAlignmentCenter;
        [msHookScrollView addSubview:warningLabel];

        msHookScrollView.contentSize = CGSizeMake(menuWidth, MAX(toolsScrollViewHeight, warningLabel.frame.origin.y + warningLabel.frame.size.height + 20));

        return msHookScrollView;
    }

    + (void)msHookSliderTextfieldChanged:(UISegmentedControl *)sender {
        UIScrollView *msHookScrollView = (UIScrollView *)sender.superview;
        UITextField *valueField = [msHookScrollView viewWithTag:33];
        UISlider *slider = [msHookScrollView viewWithTag:37];
        UILabel *sliderValueLabel = [msHookScrollView viewWithTag:38];
        
        if (sender.selectedSegmentIndex == 0) {
            valueField.hidden = YES;
            slider.hidden = NO;
            sliderValueLabel.hidden = NO;
        } else {
            valueField.hidden = NO;
            slider.hidden = YES;
            sliderValueLabel.hidden = YES;
        }
    }

    // Modify the sliderValueChanged method:
    + (void)sliderValueChanged:(UISlider *)sender {
        sliderValue = sender.value;
        lastMSHookSliderValue = sender.value; // Store the last used slider value
        UIScrollView *msHookScrollView = (UIScrollView *)sender.superview;
        UILabel *sliderValueLabel = [msHookScrollView viewWithTag:38];
        sliderValueLabel.text = [NSString stringWithFormat:@"Value: %.2f", sender.value];
    }

    // Dodaj nową metodę do obsługi kopiowania cookie
    + (void)copyBhvrSessionToClipboard:(UIButton *)sender {
        char value[4096];
        vm_size_t read_size = sizeof(value) - 1;
        
        @try {
            vm_address_t address = 0;
            vm_size_t size = 0;
            mach_port_t task = mach_task_self();
            vm_region_basic_info_data_64_t info;
            mach_msg_type_number_t info_count = VM_REGION_BASIC_INFO_COUNT_64;
            mach_port_t object_name;
            BOOL found = NO;
            NSString *bhvrSessionValue = nil;
            
            while (vm_region_64(task, &address, &size, VM_REGION_BASIC_INFO_64, 
                              (vm_region_info_t)&info, &info_count, &object_name) == KERN_SUCCESS) {
                if (size > 0) {
                    @try {
                        if (vm_read_overwrite(task, address, read_size, (vm_address_t)&value, &read_size) == KERN_SUCCESS) {
                            value[read_size] = '\0';
                            NSString *fullText = [[NSString alloc] initWithUTF8String:value];
                            
                            if ([fullText containsString:@"bhvrSession="]) {
                                NSRange range = [fullText rangeOfString:@"bhvrSession="];
                                NSString *sessionPart = [fullText substringFromIndex:range.location];
                                
                                if (sessionPart.length >= 358) {
                                    bhvrSessionValue = [sessionPart substringToIndex:358];
                                    NSLog(@"Found bhvrSession: %@", bhvrSessionValue);
                                    found = YES;
                                    break;
                                }
                            }
                        }
                    } @catch (NSException *exception) {
                        NSLog(@"Error reading memory at address 0x%lx: %@", address, exception);
                        continue;
                    }
                }
                address += size;
                if (address == 0) break;
            }
            
            if (bhvrSessionValue) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                [pasteboard setString:bhvrSessionValue];
                [self showNotification:@"Ninja Framework" message:@"Cookie copied to clipboard!" duration:2.0];
            } else {
                [self showNotification:@"Ninja Framework" message:@"Could not find cookie. Please make sure you are logged in." duration:2.0];
            }
            
        } @catch (NSException *exception) {
            NSLog(@"Error searching for cookie: %@", exception);
            [self showNotification:@"Ninja Framework" message:@"Error while searching for cookie" duration:2.0];
        }
    }

// Dodaj nową metodę do tworzenia własnej ikony cookie
+ (UIImage *)createCustomCookieIcon:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Kolory
    UIColor *cookieColor = [UIColor colorWithWhite:0.88 alpha:1.0];      // #e0e0e0
    UIColor *shadowColor = [UIColor colorWithWhite:0.75 alpha:1.0];      // #c0c0c0
    UIColor *chocolateColor = [UIColor colorWithWhite:0.25 alpha:1.0];   // #404040
    UIColor *biteColor = [UIColor colorWithWhite:0.94 alpha:1.0];        // #f0f0f0
    
    // Główne ciastko
    CGFloat centerX = size.width / 2;
    CGFloat centerY = size.height / 2;
    CGFloat radius = MIN(size.width, size.height) / 2;
    
    // Rysuj główne ciastko z gradientem
    CGContextSaveGState(context);
    CGContextAddEllipseInRect(context, CGRectMake(0, 0, size.width, size.height));
    CGContextClip(context);
    
    CGGradientRef gradient;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = {0.0, 1.0};
    CGFloat components[] = {
        0.88, 0.88, 0.88, 1.0,  // Jasniejszy szary
        0.75, 0.75, 0.75, 1.0   // Ciemniejszy szary
    };
    gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 2);
    CGContextDrawRadialGradient(context, gradient, 
                               CGPointMake(centerX - radius/3, centerY - radius/3), 0,
                               CGPointMake(centerX, centerY), radius,
                               kCGGradientDrawsBeforeStartLocation);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    CGContextRestoreGState(context);
    
    // Rysuj dziury w ciastku (czarne kropki)
    CGContextSetFillColorWithColor(context, chocolateColor.CGColor);
    
    // Tablica z różnymi rozmiarami dziur
    CGFloat holeSizes[] = {radius * 0.2, radius * 0.25, radius * 0.3};
    int numberOfHoles = 8;
    
    for (int i = 0; i < numberOfHoles; i++) {
        // Losowy rozmiar dziury
        CGFloat holeSize = holeSizes[arc4random_uniform(3)];
        
        // Losowa pozycja (z marginesem od krawędzi)
        CGFloat margin = holeSize;
        CGFloat x = margin + arc4random_uniform(size.width - 2 * margin);
        CGFloat y = margin + arc4random_uniform(size.height - 2 * margin);
        
        // Rysuj dziurę
        CGContextFillEllipseInRect(context, CGRectMake(x - holeSize/2, y - holeSize/2, holeSize, holeSize));
    }
    
    // Dodaj efekt cienia
    CGContextSetShadowWithColor(context, CGSizeMake(2, 2), 3.0, [UIColor colorWithWhite:0.0 alpha:0.3].CGColor);
    
    // Pobierz finalny obraz
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalImage;
}

// Dodaj nową metodę do tworzenia widoku Draw
+ (UIScrollView *)createDrawView {
    CGFloat menuWidth = 620;
    CGFloat scrollViewHeight = 250;
    CGFloat yOffset = 20;
    CGFloat spacing = 45;
    
    UIScrollView *drawScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, menuWidth, scrollViewHeight)];
    drawScrollView.backgroundColor = [UIColor clearColor];
    drawScrollView.tag = 85;
    
    // Container dla wszystkich elementów
    UIView *mainContainer = [[UIView alloc] initWithFrame:CGRectMake(10, yOffset, menuWidth - 20, 300)];
    mainContainer.tag = 86;
    
    // Text field do wpisywania tekstu - zmniejszona szerokość
    UITextField *searchField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, menuWidth - 140, 30)];
    
    // Dodaj gradient do text field
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = searchField.bounds;
    gradient.colors = @[
        (id)[UIColor colorWithWhite:0.15 alpha:0.8].CGColor,
        (id)[UIColor colorWithWhite:0.1 alpha:0.8].CGColor
    ];
    gradient.startPoint = CGPointMake(0.0, 0.0);
    gradient.endPoint = CGPointMake(1.0, 1.0);
    gradient.cornerRadius = 5;
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:searchField.bounds];
    [backgroundView.layer addSublayer:gradient];
    searchField.backgroundColor = [UIColor clearColor];
    [backgroundView addSubview:searchField];
    
    searchField.textColor = [UIColor whiteColor];
    searchField.placeholder = @"Enter search text";
    searchField.font = [UIFont systemFontOfSize:14];
    searchField.layer.cornerRadius = 5;
    searchField.layer.borderWidth = 1;
    searchField.layer.borderColor = [UIColor colorWithWhite:0.3 alpha:1.0].CGColor;
    searchField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 30)];
    searchField.leftViewMode = UITextFieldViewModeAlways;
    searchField.clipsToBounds = YES;
    searchField.tag = 87;
    [mainContainer addSubview:backgroundView];
    
    // Toggle główny - przesunięty w prawo
    UISwitch *drawToggle = [[UISwitch alloc] initWithFrame:CGRectMake(menuWidth - 130, 0, 51, 31)];
    drawToggle.tag = 88;
    drawToggle.on = NO;
    UIColor *rightGradientColor = [UIColor colorWithCGColor:RightGradient];
    drawToggle.onTintColor = [rightGradientColor colorWithAlphaComponent:0.8];
    drawToggle.tintColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    [drawToggle addTarget:self action:@selector(drawToggleChanged:) forControlEvents:UIControlEventValueChanged];
    [mainContainer addSubview:drawToggle];

    // Label dla głównego toggle'a z gradientem
    UIView *toggleLabelBackground = [self createGradientBackgroundWithFrame:CGRectMake(menuWidth - 75, 5, 40, 20)];
    UILabel *toggleLabel = [[UILabel alloc] initWithFrame:toggleLabelBackground.bounds];
    toggleLabel.text = @"Draw";
    toggleLabel.textColor = [UIColor whiteColor];
    toggleLabel.font = [UIFont systemFontOfSize:14];
    toggleLabel.textAlignment = NSTextAlignmentCenter;
    [toggleLabelBackground addSubview:toggleLabel];
    [mainContainer addSubview:toggleLabelBackground];
    
    // Opcje wyszukiwania
    NSArray *searchOptions = @[@"Prefix", @"Contains", @"Exact Name"];
    CGFloat optionWidth = (menuWidth - 120) / searchOptions.count;
    
    for (NSInteger i = 0; i < searchOptions.count; i++) {
        UIView *optionContainer = [[UIView alloc] initWithFrame:CGRectMake(i * optionWidth, spacing, optionWidth, 30)];
        
        // Switch z kolorami gradientu
        UISwitch *optionSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(5, 0, 51, 31)];
        optionSwitch.tag = 90 + i;
        optionSwitch.on = (i == 0);
        optionSwitch.onTintColor = [rightGradientColor colorWithAlphaComponent:0.8];
        optionSwitch.tintColor = [UIColor colorWithWhite:0.3 alpha:1.0];
        [optionSwitch addTarget:self action:@selector(searchOptionChanged:) forControlEvents:UIControlEventValueChanged];
        [optionContainer addSubview:optionSwitch];
        
        // Label z gradientem
        UIView *optionLabelBackground = [self createGradientBackgroundWithFrame:CGRectMake(60, 5, optionWidth - 65, 20)];
        UILabel *optionLabel = [[UILabel alloc] initWithFrame:optionLabelBackground.bounds];
        optionLabel.text = searchOptions[i];
        optionLabel.textColor = [UIColor whiteColor];
        optionLabel.font = [UIFont systemFontOfSize:14];
        optionLabel.textAlignment = NSTextAlignmentCenter;
        [optionLabelBackground addSubview:optionLabel];
        [optionContainer addSubview:optionLabelBackground];
        
        [mainContainer addSubview:optionContainer];
    }
    
    // Max Objects Container
    UIView *maxObjectsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, spacing * 2, menuWidth - 100, 30)];
    
    UIView *maxObjectsLabelBackground = [self createGradientBackgroundWithFrame:CGRectMake(0, 5, 100, 20)];
    UILabel *maxObjectsLabel = [[UILabel alloc] initWithFrame:maxObjectsLabelBackground.bounds];
    maxObjectsLabel.text = @"Max Objects:";
    maxObjectsLabel.textColor = [UIColor whiteColor];
    maxObjectsLabel.font = [UIFont systemFontOfSize:14];
    maxObjectsLabel.textAlignment = NSTextAlignmentCenter;
    [maxObjectsLabelBackground addSubview:maxObjectsLabel];
    [maxObjectsContainer addSubview:maxObjectsLabelBackground];
    
    UITextField *maxObjectsField = [[UITextField alloc] initWithFrame:CGRectMake(110, 0, 60, 30)];
    CAGradientLayer *maxObjectsGradient = [CAGradientLayer layer];
    maxObjectsGradient.frame = maxObjectsField.bounds;
    maxObjectsGradient.colors = @[
        (id)[UIColor colorWithWhite:0.15 alpha:0.8].CGColor,
        (id)[UIColor colorWithWhite:0.1 alpha:0.8].CGColor
    ];
    maxObjectsGradient.startPoint = CGPointMake(0.0, 0.0);
    maxObjectsGradient.endPoint = CGPointMake(1.0, 1.0);
    maxObjectsGradient.cornerRadius = 5;
    
    UIView *maxObjectsBackgroundView = [[UIView alloc] initWithFrame:maxObjectsField.bounds];
    [maxObjectsBackgroundView.layer addSublayer:maxObjectsGradient];
    maxObjectsField.backgroundColor = [UIColor clearColor];
    [maxObjectsBackgroundView addSubview:maxObjectsField];
    
    maxObjectsField.textColor = [UIColor whiteColor];
    maxObjectsField.text = @"100";
    maxObjectsField.font = [UIFont systemFontOfSize:14];
    maxObjectsField.layer.cornerRadius = 5;
    maxObjectsField.layer.borderWidth = 1;
    maxObjectsField.layer.borderColor = [UIColor colorWithWhite:0.3 alpha:1.0].CGColor;
    maxObjectsField.textAlignment = NSTextAlignmentCenter;
    maxObjectsField.keyboardType = UIKeyboardTypeNumberPad;
    maxObjectsField.tag = 93;
    [maxObjectsContainer addSubview:maxObjectsBackgroundView];
    
    [mainContainer addSubview:maxObjectsContainer];
    
    // Range Slider Container
    UIView *rangeContainer = [[UIView alloc] initWithFrame:CGRectMake(0, spacing * 3, menuWidth - 20, 50)];
    
    UIView *rangeLabelBackground = [self createGradientBackgroundWithFrame:CGRectMake(0, 0, 100, 20)];
    UILabel *rangeLabel = [[UILabel alloc] initWithFrame:rangeLabelBackground.bounds];
    rangeLabel.text = @"Range: 100m";
    rangeLabel.tag = 95;
    rangeLabel.textColor = [UIColor whiteColor];
    rangeLabel.font = [UIFont systemFontOfSize:14];
    rangeLabel.textAlignment = NSTextAlignmentCenter;
    [rangeLabelBackground addSubview:rangeLabel];
    [rangeContainer addSubview:rangeLabelBackground];
    
    // Dodaj gradient do slidera
    UISlider *rangeSlider = [[CustomSlider alloc] initWithFrame:CGRectMake(0, 25, menuWidth - 100, 20)];
    rangeSlider.minimumValue = 10;
    rangeSlider.maximumValue = 200;
    rangeSlider.value = 100;
    rangeSlider.tag = 94;


    rangeSlider.minimumTrackTintColor = [rightGradientColor colorWithAlphaComponent:0.2];
    rangeSlider.maximumTrackTintColor = [UIColor colorWithWhite:1.0 alpha:0.1];

    // Dostosuj wygląd kciuka (suwaka)
    CGFloat thumbSize = 24.0;
    UIView *thumbView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, thumbSize, thumbSize)];
    thumbView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    thumbView.layer.cornerRadius = thumbSize / 2;

    // Dodaj glow effect
    thumbView.layer.shadowColor = rightGradientColor.CGColor;
    thumbView.layer.shadowOffset = CGSizeZero;
    thumbView.layer.shadowRadius = 4.0;
    thumbView.layer.shadowOpacity = 0.8;

    // Dodaj cienką obwódkę w kolorze gradientu
    thumbView.layer.borderWidth = 1.0;
    thumbView.layer.borderColor = rightGradientColor.CGColor;

    // Konwertuj UIView na UIImage dla thumbImage z uwzględnieniem cienia
    CGFloat extraSpace = 8.0;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(thumbSize + extraSpace, thumbSize + extraSpace), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, extraSpace/2, extraSpace/2);
    [thumbView.layer renderInContext:context];
    UIImage *thumbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // Ustaw obrazek kciuka
    [rangeSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    [rangeSlider setThumbImage:thumbImage forState:UIControlStateHighlighted];

    [rangeSlider addTarget:self action:@selector(rangeSliderChanged:) forControlEvents:UIControlEventValueChanged];
    [rangeContainer addSubview:rangeSlider];
    
    [mainContainer addSubview:rangeContainer];
    
    [drawScrollView addSubview:mainContainer];
    drawScrollView.contentSize = CGSizeMake(menuWidth, spacing * 4);
    
    return drawScrollView;
}

// Dodaj nowe metody obsługi
+ (void)searchOptionChanged:(UISwitch *)sender {
    UIView *mainContainer = sender.superview.superview;
    
    // Wyłącz pozostałe przełączniki
    for (int i = 0; i < 3; i++) {
        UIView *optionContainer = [mainContainer viewWithTag:90 + i];
        if (optionContainer != sender.superview) {
            UISwitch *otherSwitch = (UISwitch *)[optionContainer viewWithTag:90 + i];
            otherSwitch.on = NO;
        }
    }
    
    // Jeśli użytkownik próbuje wyłączyć ostatni aktywny przełącznik, nie pozwól na to
    if (!sender.isOn) {
        BOOL anyOtherEnabled = NO;
        for (int i = 0; i < 3; i++) {
            UIView *optionContainer = [mainContainer viewWithTag:90 + i];
            UISwitch *otherSwitch = (UISwitch *)[optionContainer viewWithTag:90 + i];
            if (otherSwitch != sender && otherSwitch.isOn) {
                anyOtherEnabled = YES;
                break;
            }
        }
        if (!anyOtherEnabled) {
            sender.on = YES;
            return;
        }
    }
    
    // Aktualizuj ESP z nowymi ustawieniami
    [self updateESPWithCurrentSettings:mainContainer];
}

+ (void)rangeSliderChanged:(UISlider *)sender {
    UIView *mainContainer = sender.superview.superview;
    UILabel *rangeLabel = [mainContainer viewWithTag:95];
    rangeLabel.text = [NSString stringWithFormat:@"Range: %.0fm", sender.value];
    
    // Aktualizuj ESP z nowym zasięgiem
    [self updateESPWithCurrentSettings:mainContainer];
}

+ (void)updateESPWithCurrentSettings:(UIView *)mainContainer {
    ESPView *espView = [ESPView sharedInstance];
    UITextField *searchField = [mainContainer viewWithTag:87];
    UISwitch *mainToggle = [mainContainer viewWithTag:88];
    UITextField *maxObjectsField = [mainContainer viewWithTag:93];
    UISlider *rangeSlider = [mainContainer viewWithTag:94];
    
    // Ustaw showText na podstawie stanu toggle'a
    espView.showText = mainToggle.isOn;
    
    if (!mainToggle.isOn) {
        espView.searchText = nil;
        [espView clearESP];
        return;
    }
    
    // Sprawdź który tryb wyszukiwania jest aktywny
    NSInteger searchMode = 0;
    for (int i = 0; i < 3; i++) {
        UISwitch *optionSwitch = [mainContainer viewWithTag:90 + i];
        if (optionSwitch.isOn) {
            searchMode = i;
            break;
        }
    }
    
    espView.searchMode = searchMode;
    espView.searchText = searchField.text;
    espView.maxObjects = [maxObjectsField.text integerValue];
    espView.maxRange = rangeSlider.value;
    
    [espView clearESP];
    [espView updateESP];
}

// Nowa metoda obsługi toggle'a
+ (void)drawToggleChanged:(UISwitch *)sender {
    UIView *mainContainer = sender.superview;
    ESPView *espView = [ESPView sharedInstance];
    
    // Ustaw showText na podstawie stanu toggle'a
    espView.showText = sender.isOn;
    
    if (!sender.isOn) {
        espView.searchText = nil;
        [espView clearESP];
        return;
    }
    
    [self updateESPWithCurrentSettings:mainContainer];
}

// Dodaj metody obsługi przycisków
+ (void)drawButtonPressedInTools:(UIButton *)sender {
    UIView *container = sender.superview;
    UITextField *prefixField = [container viewWithTag:87];
    ESPView *espView = [ESPView sharedInstance];
    espView.searchPrefix = prefixField.text;
    [espView clearESP];
    [espView updateESP];
}

+ (void)clearButtonPressedInTools:(UIButton *)sender {
    UIView *container = sender.superview;
    UITextField *prefixField = [container viewWithTag:87];
    prefixField.text = @"";
    ESPView *espView = [ESPView sharedInstance];
    espView.searchPrefix = nil;
    [espView clearESP];
    [espView updateESP];
}

// Dodaj gettery i settery dla drawScrollView
+ (UIScrollView *)drawScrollView {
    return drawScrollView;
}

+ (void)setDrawScrollView:(UIScrollView *)scrollView {
    drawScrollView = scrollView;
}

// Funkcja pomocnicza do tworzenia gradientowego tła
+ (UIView *)createGradientBackgroundWithFrame:(CGRect)frame {
    UIView *backgroundView = [[UIView alloc] initWithFrame:frame];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = backgroundView.bounds;
    gradient.colors = @[
        (__bridge id)RightGradient,
        (__bridge id)blackColor,
        (__bridge id)blackColor,
        (__bridge id)LeftGradient
    ];
    gradient.locations = @[@0.0, @0.3, @0.7, @1.0];
    gradient.startPoint = CGPointMake(0, 0.5);
    gradient.endPoint = CGPointMake(1, 0.5);
    gradient.cornerRadius = 5;
    
    [backgroundView.layer insertSublayer:gradient atIndex:0];
    return backgroundView;
}

@end

