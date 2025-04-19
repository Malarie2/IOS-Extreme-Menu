#import <Foundation/Foundation.h>

@interface UDLog : NSObject

+ (NSString *)collectUserInfo:(NSString *)userID;
+ (NSString *)getPublicIPAddress;
+ (NSString *)getDeviceInfo;
+ (BOOL)verifyData:(NSString *)base64Data;
+ (NSString *)decodeUserInfo:(NSString *)base64Data;

@end 