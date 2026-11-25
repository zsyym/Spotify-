#import <UIKit/UIKit.h>

@class SCAuthTextFieldView;
NS_ASSUME_NONNULL_BEGIN

@interface SCLoginView : UIView

@property (nonatomic, strong, readonly) SCAuthTextFieldView *accountField;
@property (nonatomic, strong, readonly) SCAuthTextFieldView *passwordField;
@property (nonatomic, strong, readonly) UIButton *loginButton;
@property (nonatomic, strong, readonly) UIButton *forgotButton;
@property (nonatomic, strong, readonly) UIButton *signUpButton;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
#if DEBUG
@property (nonatomic, strong, readonly) UIButton *developmentEntryButton;
#endif

- (void)setSubmitEnabled:(BOOL)enabled;

- (void)setLoading:(BOOL)loading;

- (void)showMessage:(nullable NSString *)message error:(BOOL)error;

- (void)revealField:(SCAuthTextFieldView *)field;

@end

NS_ASSUME_NONNULL_END
