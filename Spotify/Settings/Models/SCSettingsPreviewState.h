#import <Foundation/Foundation.h>

@interface SCSettingsPreviewState : NSObject
@property (class, nonatomic, readonly) SCSettingsPreviewState *shared;
- (id)valueForSetting:(NSString *)key;
- (void)setValue:(id)value forSetting:(NSString *)key;
@end
