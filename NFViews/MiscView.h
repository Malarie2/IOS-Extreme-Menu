#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface MiscView : NSObject

+ (void)createMiscView:(UIView *)menuView;
+ (UIView *)createEndGameView:(UIScrollView *)parentView width:(CGFloat)menuWidth startY:(CGFloat)startY;
+ (UIView *)createAnimationsView:(UIScrollView *)parentView width:(CGFloat)menuWidth startY:(CGFloat)startY;
+ (UIView *)createSpoofingView:(UIScrollView *)parentView width:(CGFloat)menuWidth startY:(CGFloat)startY;
+ (UIView *)createTeleportView:(UIScrollView *)parentView width:(CGFloat)menuWidth startY:(CGFloat)startY;
+ (UIView *)createChangerView:(UIScrollView *)parentView width:(CGFloat)menuWidth startY:(CGFloat)startY;
+ (UIView *)createNameChangeView:(UIScrollView *)parentView width:(CGFloat)menuWidth startY:(CGFloat)startY;
+ (void)applyPrestigeSpoofing:(UIButton *)sender;
+ (void)resetPrestigeSpoofing:(UIButton *)sender;
+ (void)addGradientsToButton:(UIButton *)button;
+ (void)miscSegmentChanged:(UISegmentedControl *)sender;
+ (UIButton *)createEndGameButton:(NSString *)title tag:(NSInteger)tag yOffset:(CGFloat)yOffset;
+ (void)addGradientsToContainer:(UIView *)container;
+ (id<UITextFieldDelegate>)textFieldDelegate;
+ (CAGradientLayer *)createGradientLayer:(CGRect)bounds;
+ (void)applyNameChange:(UIButton *)sender;
+ (void)resetNameChange:(UIButton *)sender;
+ (void)clearNameField:(id)sender;
+ (void)backspacePressed:(id)sender;
+ (void)dismissNameChangeKeyboard:(id)sender;
+ (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
+ (void)textFieldDidBeginEditing:(UITextField *)textField;
+ (void)textFieldDidEndEditing:(UITextField *)textField;

@end