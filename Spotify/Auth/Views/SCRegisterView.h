#import <UIKit/UIKit.h>

@class SCAuthTextFieldView;
@class SCVerificationCodeInputView;

NS_ASSUME_NONNULL_BEGIN

@interface SCRegisterView : UIView

@property (nonatomic, strong, readonly) SCAuthTextFieldView *emailField;
@property (nonatomic, strong, readonly) SCVerificationCodeInputView *codeInputView;
@property (nonatomic, strong, readonly) UIButton *sendCodeButton;
@property (nonatomic, strong, readonly) UIButton *verifyButton;
- (void)setSendCodeEnabled:(BOOL)enabled verifyEnabled:(BOOL)verifyEnabled;
- (void)showEmailError:(nullable NSString *)message;
- (void)setVerificationExpanded:(BOOL)expanded email:(NSString *)email animated:(BOOL)animated;
- (void)revealFocusedInput;

@end

NS_ASSUME_NONNULL_END
