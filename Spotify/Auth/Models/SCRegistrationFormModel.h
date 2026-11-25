#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCRegistrationFormModel : NSObject

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *verificationCode;
@property (nonatomic, assign, readonly) BOOL validEmail;
@property (nonatomic, assign, readonly) BOOL validCode;
@property (nonatomic, assign, readonly) BOOL verificationExpanded;
@property (nonatomic, copy, readonly, nullable) NSString *emailValidationMessage;
- (BOOL)beginVerificationPreview;

@end

NS_ASSUME_NONNULL_END
