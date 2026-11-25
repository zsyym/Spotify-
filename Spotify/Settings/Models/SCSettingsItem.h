#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SCSettingKind) {
    SCSettingLink,
    SCSettingSwitch,
    SCSettingSlider,
    SCSettingChoice,
    SCSettingInfo,
    SCSettingProfile,
    SCSettingUsage,
    SCSettingUnavailable
};
@interface SCSettingsItem : NSObject
@property (nonatomic, assign, readonly) SCSettingKind kind;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *detail;
@property (nonatomic, copy, readonly) NSString *symbol;
+ (NSArray<SCSettingsItem *> *)itemsForPage:(NSString *)page;
+ (NSString *)noteForPage:(NSString *)page;
+ (NSArray<NSString *> *)choicesFor:(NSString *)page;
@end
