#import "SCTrack.h"

@implementation SCTrack

#pragma mark - Lifecycle

- (instancetype)init {
    if ((self = [super init])) {
        _identifier = @"";
        _title = @"";
        _subtitle = @"";
        _artworkName = @"";
    }
    return self;
}

@end
