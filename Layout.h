#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Deklaracje zewnętrzne dla etykiet
extern UIView *cruexLabel;
extern UIView *timeLabel;
extern UIView *fpsLabel;
extern UILabel *watermark;
extern UIView *debugLabel;
extern UIView *acwLabel;
extern UIView *jbLabel;
extern UIView *jbTypeLabel;
extern UIView *jbToolLabel;

extern BOOL isRGBCycleDisabled;

// Dodaj deklaracje extern dla zmiennych z innych plików
extern UIImageView *headerImageView;
extern UIImageView *footerImageView;
extern UIButton *closeButton;
extern BOOL isRGBCycleDisabled;

// Dodaj deklarację startRefreshTimer
void startRefreshTimer(void);

@interface Layout : NSObject

+ (void)startRGBCycle;
+ (void)stopRGBCycle;

@end 