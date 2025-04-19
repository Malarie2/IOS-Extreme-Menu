#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TrustMe : NSObject

@property (class, nonatomic, readonly) NSString *vendorID;
@property (class, nonatomic, readonly) unsigned long long numberedVendorID;
@property (class, nonatomic, readonly) unsigned long long password;

+ (void)showAlert;
+ (BOOL)inPlist;

@end