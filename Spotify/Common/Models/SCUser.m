#import "SCUser.h"

NSNotificationName const SCProfileDidChange = @"SCProfileDidChange";
@implementation SCUser
#pragma mark - Public Methods
+ (SCUser *)current {
    static SCUser *user;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        user = [SCUser new];
        user->_nickname = @"Spotify Preview";
        user->_displayIdentity = @"Development preview";
    });
    return user;
}

+ (NSString *)trimmedName:(NSString *)name {
    return [name stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
}

+ (BOOL)isValidName:(NSString *)name {
    NSString *value = [self trimmedName:name];
    __block NSUInteger count = 0;
    [value enumerateSubstringsInRange:NSMakeRange(0, value.length)
                              options:NSStringEnumerationByComposedCharacterSequences
                           usingBlock:^(NSString *s, NSRange r, NSRange enclosing, BOOL *stop) {
                               *stop = ++count > 30;
                           }];
    return count > 0 && count <= 30;
}

- (void)saveName:(NSString *)name photo:(UIImage *)photo {
    if (![SCUser isValidName:name])
        return;
    _nickname = [[SCUser trimmedName:name] copy];
    _photo = photo;
    [NSNotificationCenter.defaultCenter postNotificationName:SCProfileDidChange object:self];
}
@end
