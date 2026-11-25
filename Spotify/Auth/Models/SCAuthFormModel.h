#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCAuthFormModel : NSObject

@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, assign, readonly) BOOL canSubmit;
@property (nonatomic, copy, readonly, nullable) NSString *validationMessage;

@end

NS_ASSUME_NONNULL_END
