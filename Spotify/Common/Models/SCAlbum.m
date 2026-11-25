#import "SCAlbum.h"

@implementation SCAlbum

#pragma mark - Lifecycle

- (instancetype)init {
    if ((self = [super init])) {
        _identifier = @"";
        _title = @"";
        _releaseType = @"Album";
        _subtitle = @"";
        _artworkName = @"";
        _tracks = @[];
    }
    return self;
}

@end
