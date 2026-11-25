#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCAuthTextFieldView : UIView

@property (nonatomic, strong, readonly) UITextField *textField;
- (instancetype)initWithTitle:(NSString *)title password:(BOOL)password;
- (void)setInvalid:(BOOL)invalid;

@end

NS_ASSUME_NONNULL_END
