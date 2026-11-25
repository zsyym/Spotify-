#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCWelcomeView : UIView

@property (nonatomic, strong, readonly) UIButton *signUpButton;
@property (nonatomic, strong, readonly) UIButton *loginButton;
- (void)animateEntrance;

@end

NS_ASSUME_NONNULL_END
