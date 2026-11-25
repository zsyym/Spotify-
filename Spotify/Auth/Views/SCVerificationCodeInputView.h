#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCVerificationCodeInputView : UIControl

@property (nonatomic, strong, readonly) UITextField *textField;
@property (nonatomic, copy, readonly) NSString *code;
- (void)clearCode;

@end

NS_ASSUME_NONNULL_END
