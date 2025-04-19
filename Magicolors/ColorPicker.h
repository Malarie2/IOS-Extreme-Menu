#import <UIKit/UIKit.h>

@interface ColorPickerViewController : UIViewController

@property (nonatomic, copy) void (^colorSelectedHandler)(UIColor *color, NSString *gradientType);

@end 