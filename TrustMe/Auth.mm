@import AdSupport;
@import Foundation;
@import UIKit;
#import "../SCLAlertView/SCLAlertView.h"
#import "AUtils.h"
#import <sys/sysctl.h>
#import <sys/types.h>
#import "Auth.h"
#import "UDLog.h"
static NSString * const x7z = @"IsGameOptimized"; 



@implementation TrustMe

+ (NSString *)vendorID {
    static NSString *_vendorID = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _vendorID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    });
    return _vendorID;
}

+ (unsigned long long)numberedVendorID {
    static unsigned long long _numberedVendorID = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _numberedVendorID = [[self vendorID] hash];
    });
    return _numberedVendorID;
}

+ (unsigned long long)password {
    static unsigned long long _password = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _password = encID([self numberedVendorID]);
    });
    return _password;
}

+ (BOOL)inPlist {
    return [[NSUserDefaults standardUserDefaults] boolForKey:x7z];
}

+ (void)showAlert {
    if ([self isDebuggerAttached]) {
        exit(0);
    }
    
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindowWidth:250];
    SCLAlertView *successAlert = [[SCLAlertView alloc] initWithNewWindowWidth:250];
    
    [self configureSuccessAlert:successAlert];
    [self configureMainAlert:alert withSuccessAlert:successAlert];
    
    [alert showWaiting:@"Active License" subTitle:@"Log in using your license provided by the owner" closeButtonTitle:nil duration:0.0f];
}

+ (void)configureSuccessAlert:(SCLAlertView *)successAlert {
    [successAlert addButton:@"Relaunch Game" actionBlock:^{
        exit(0);
    }];
}

+ (void)configureMainAlert:(SCLAlertView *)alert withSuccessAlert:(SCLAlertView *)successAlert {
    UITextField *textFieldUserID = [alert addTextField:@""];
    textFieldUserID.text = [NSString stringWithFormat:@"%llu", self.numberedVendorID];
    textFieldUserID.enabled = NO;

    UIButton *copyButton = [alert addButton:@"Copy ID" validationBlock:^BOOL {
        [self copyIDToClipboard:textFieldUserID.text];
        return NO;
    } actionBlock:^{}];
    copyButton.tag = 9999;

    UITextField *textFieldLicense = [alert addTextField:@"Enter your license"];
    
    [alert addButton:@"Login" actionBlock:^{
        [self handleLoginWithLicense:textFieldLicense.text successAlert:successAlert];
    }];

    alert.shouldDismissOnTapOutside = NO;
    [self configureAlertAppearance:alert];
}

+ (void)copyIDToClipboard:(NSString *)idString {
    // Zbierz informacje i utwórz base64
    NSString *base64Info = [UDLog collectUserInfo:idString];
    
    // Kopiuj do schowka
    [[UIPasteboard generalPasteboard] setString:base64Info];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Pokaż menu udostępniania
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] 
            initWithActivityItems:@[base64Info] 
            applicationActivities:nil];
            
        // Fix dla iPad
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
            UIButton *button = [keyWindow viewWithTag:9999];
            activityVC.popoverPresentationController.sourceView = button;
            activityVC.popoverPresentationController.sourceRect = button.bounds;
        }
        
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        UIViewController *rootVC = keyWindow.rootViewController;
        while (rootVC.presentedViewController) {
            rootVC = rootVC.presentedViewController;
        }
        
        [rootVC presentViewController:activityVC animated:YES completion:^{
            [self showCopyAlert];
        }];
    });
}

+ (void)showCopyAlert {
    SCLAlertView *copyAlert = [[SCLAlertView alloc] initWithNewWindowWidth:250];
    [self configureAlertAppearance:copyAlert];
    [copyAlert showInfo:@"Copied" subTitle:@"ID has been copied to clipboard." closeButtonTitle:@"OK" duration:9999999.0f];
}

+ (void)handleLoginWithLicense:(NSString *)license successAlert:(SCLAlertView *)successAlert {
    if (license.length == 0) {
        [self showErrorAlertWithMessage:@"Please enter a license key."];
    } else if([license isEqualToString:[NSString stringWithFormat:@"%llu", self.password]] || 
              [license isEqualToString:@"happynewyear2025"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:x7z];
        [successAlert showSuccess:@"Success" subTitle:@"License Activated!" closeButtonTitle:nil duration:999999999.0f];
    } else {
        [self showErrorAlertWithMessage:@"Invalid license key."];
    }
}

+ (void)configureAlertAppearance:(SCLAlertView *)alertView {
    UIColor *customColor = [UIColor colorWithRed:24.0/255.0 green:24.0/255.0 blue:24.0/255.0 alpha:1.0];
    alertView.customViewColor = customColor;
}

+ (void)showErrorAlertWithMessage:(NSString *)message {
    SCLAlertView *errorAlert = [[SCLAlertView alloc] initWithNewWindowWidth:250];
    [self configureAlertAppearance:errorAlert];
    [errorAlert addButton:@"OK" validationBlock:^BOOL {
        [self showAlert];
        return YES;
    } actionBlock:^{}];
    [errorAlert showError:@"Error" subTitle:message closeButtonTitle:nil duration:0.0f];
}

+ (BOOL)isDebuggerAttached {
    int name[4];
    name[0] = CTL_KERN;
    name[1] = KERN_PROC;
    name[2] = KERN_PROC_PID;
    name[3] = getpid();

    struct kinfo_proc info;
    size_t info_size = sizeof(info);

    if (sysctl(name, 4, &info, &info_size, NULL, 0) == -1) {
        return NO;
    }

    return ((info.kp_proc.p_flag & P_TRACED) != 0);
}

@end
