#import "SCSettingsPreviewState.h"
@interface SCSettingsPreviewState ()
@property (nonatomic, strong) NSMutableDictionary *values;
@end
@implementation SCSettingsPreviewState
#pragma mark - Lifecycle

- (instancetype)init {
    if ((self = [super init]))
        _values = [@{
            @"Volume level" : @"Normal",
            @"Wi-Fi streaming" : @"Automatic",
            @"Cellular streaming" : @"Automatic",
            @"Download quality" : @"Normal",
            @"Profile visibility" : @"Private"
        } mutableCopy];
    return self;
}

#pragma mark - Public Methods

+ (instancetype)shared {
    static SCSettingsPreviewState *state;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        state = [self new];
    });
    return state;
}

- (id)valueForSetting:(NSString *)key {
    return self.values[key] ?: @0;
}

- (void)setValue:(id)value forSetting:(NSString *)key {
    self.values[key] = value;
}
@end
