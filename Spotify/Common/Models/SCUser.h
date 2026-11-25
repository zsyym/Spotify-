#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSNotificationName const SCProfileDidChange;
@interface SCUser : NSObject
@property (class, nonatomic, readonly) SCUser *current;
@property (nonatomic, copy, readonly) NSString *nickname;
@property (nonatomic, strong, readonly) UIImage *photo;
@property (nonatomic, copy, readonly) NSString *displayIdentity;
+ (NSString *)trimmedName:(NSString *)name;
+ (BOOL)isValidName:(NSString *)name;
- (void)saveName:(NSString *)name photo:(UIImage *)photo;
@end
