#import "SCRegistrationFormModel.h"

@interface SCRegistrationFormModel ()

@property (nonatomic, copy, nullable) NSString *verificationEmail;

@end

@implementation SCRegistrationFormModel

#pragma mark - Lifecycle

- (instancetype)init {
    if ((self = [super init])) {
        _email = @"";
        _verificationCode = @"";
    }
    return self;
}

#pragma mark - Public Methods

- (void)setEmail:(NSString *)email {
    if ([_email isEqualToString:email])
        return;
    _email = [email copy];
    self.verificationCode = @"";
    self.verificationEmail = nil;
}

- (BOOL)beginVerificationPreview {
    if (!self.validEmail)
        return NO;
    self.verificationEmail = self.email;
    self.verificationCode = @"";
    return YES;
}

#pragma mark - Getters

- (BOOL)validEmail {
    return self.emailValidationMessage == nil;
}

- (NSString *)emailValidationMessage {
    if (!self.email.length)
        return @"Enter your email address.";
    if ([self.email rangeOfCharacterFromSet:NSCharacterSet.whitespaceAndNewlineCharacterSet].location != NSNotFound)
        return @"Your email address can’t contain spaces.";
    NSArray<NSString *> *parts = [self.email componentsSeparatedByString:@"@"];
    if (parts.count != 2 || !parts.firstObject.length || !parts.lastObject.length || self.email.length > 254)
        return @"Enter an email address like name@example.com.";
    NSString *local = parts.firstObject;
    NSCharacterSet *localCharacters =
        [NSCharacterSet characterSetWithCharactersInString:
                            @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.!#$%&'*+-/=?^_`{|}~"];
    if (local.length > 64 || [local hasPrefix:@"."] || [local hasSuffix:@"."] || [local containsString:@".."] ||
        [local rangeOfCharacterFromSet:localCharacters.invertedSet].location != NSNotFound)
        return @"Check the part before the @ symbol.";
    NSArray<NSString *> *labels = [parts.lastObject componentsSeparatedByString:@"."];
    if (labels.count < 2)
        return @"Include a complete domain, like example.com.";
    NSCharacterSet *domainCharacters = [NSCharacterSet
        characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-"];
    for (NSString *label in labels) {
        if (!label.length || label.length > 63 || [label hasPrefix:@"-"] || [label hasSuffix:@"-"] ||
            [label rangeOfCharacterFromSet:domainCharacters.invertedSet].location != NSNotFound)
            return @"Check the domain after the @ symbol.";
    }
    NSCharacterSet *letters =
        [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
    if (labels.lastObject.length < 2 ||
        [labels.lastObject rangeOfCharacterFromSet:letters.invertedSet].location != NSNotFound)
        return @"Check the ending of your email address.";
    return nil;
}

- (BOOL)validCode {
    NSCharacterSet *digits = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    return self.verificationExpanded && self.verificationCode.length == 6 &&
           [self.verificationCode rangeOfCharacterFromSet:digits.invertedSet].location == NSNotFound;
}

- (BOOL)verificationExpanded {
    return self.verificationEmail != nil && [self.verificationEmail isEqualToString:self.email];
}

@end
