#import "SCAuthFormModel.h"

@implementation SCAuthFormModel

#pragma mark - Lifecycle

- (instancetype)init {
    if ((self = [super init])) {
        _account = @"";
        _password = @"";
    }
    return self;
}

#pragma mark - Getters

- (BOOL)canSubmit {
    return self.validationMessage == nil;
}

- (NSString *)validationMessage {
    NSString *account = [self.account stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (!account.length)
        return @"Enter your email or username.";
    if (!self.password.length)
        return @"Enter your password.";
    return nil;
}

@end
